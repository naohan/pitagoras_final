"""Servicio de rachas de estudio basado en study_activities."""

from __future__ import annotations

from dataclasses import dataclass
from datetime import date, datetime, timedelta
from zoneinfo import ZoneInfo

from sqlalchemy import select
from sqlalchemy.dialects.mysql import insert as mysql_insert
from sqlalchemy.orm import Session

from app.models.enums import StudyActivityType
from app.models.study_activity import StudyActivity

LIMA_TZ = ZoneInfo("America/Lima")


@dataclass(frozen=True)
class StreakSnapshot:
    current_streak: int
    longest_streak: int
    week_mask: list[bool]
    last_activity_date: date | None


class StreakService:
    def __init__(self, session: Session) -> None:
        self._session = session

    def today_lima(self) -> date:
        return datetime.now(LIMA_TZ).date()

    def record(
        self,
        student_id: int,
        activity_type: StudyActivityType | str,
        ref_id: str | None = None,
    ) -> StudyActivity:
        if isinstance(activity_type, str):
            activity_type = StudyActivityType(activity_type)

        activity_date = self.today_lima()
        normalized_ref = (ref_id or "").strip()[:64]

        stmt = mysql_insert(StudyActivity).values(
            student_id=student_id,
            activity_type=activity_type.value,
            activity_date=activity_date,
            ref_id=normalized_ref,
        )
        stmt = stmt.on_duplicate_key_update(
            id=StudyActivity.id,
        )
        self._session.execute(stmt)
        self._session.flush()

        existing = self._session.scalars(
            select(StudyActivity).where(
                StudyActivity.student_id == student_id,
                StudyActivity.activity_type == activity_type,
                StudyActivity.activity_date == activity_date,
                StudyActivity.ref_id == normalized_ref,
            )
        ).first()
        if existing is None:
            raise RuntimeError("Failed to upsert study activity")
        return existing

    def get_streak(self, student_id: int) -> StreakSnapshot:
        today = self.today_lima()
        dates = self._activity_dates(student_id)
        date_set = set(dates)

        current = self._current_streak(date_set, today)
        longest = self._longest_streak(dates)
        week_mask = self._week_mask(date_set, today)
        last_activity = dates[-1] if dates else None

        return StreakSnapshot(
            current_streak=current,
            longest_streak=longest,
            week_mask=week_mask,
            last_activity_date=last_activity,
        )

    def _activity_dates(self, student_id: int) -> list[date]:
        stmt = (
            select(StudyActivity.activity_date)
            .where(StudyActivity.student_id == student_id)
            .distinct()
            .order_by(StudyActivity.activity_date.asc())
        )
        return list(self._session.scalars(stmt).all())

    @staticmethod
    def _current_streak(date_set: set[date], today: date) -> int:
        if not date_set:
            return 0
        if today in date_set:
            cursor = today
        elif (today - timedelta(days=1)) in date_set:
            cursor = today - timedelta(days=1)
        else:
            return 0

        streak = 0
        while cursor in date_set:
            streak += 1
            cursor -= timedelta(days=1)
        return streak

    @staticmethod
    def _longest_streak(sorted_dates: list[date]) -> int:
        if not sorted_dates:
            return 0
        best = 1
        run = 1
        for i in range(1, len(sorted_dates)):
            if sorted_dates[i] == sorted_dates[i - 1] + timedelta(days=1):
                run += 1
                best = max(best, run)
            else:
                run = 1
        return best

    @staticmethod
    def _week_mask(date_set: set[date], today: date) -> list[bool]:
        # Lunes=0 … Domingo=6 de la semana actual (America/Lima).
        monday = today - timedelta(days=today.weekday())
        return [(monday + timedelta(days=i)) in date_set for i in range(7)]
