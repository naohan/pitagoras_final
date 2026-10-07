from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.dependencies import get_current_student_id, get_db
from app.schemas.study_activity import (
    StreakResponse,
    StudyActivityRecordRequest,
    StudyActivityRecordResponse,
)
from app.study_activity.service import StreakService

router = APIRouter(prefix="/study-activity", tags=["Racha de estudio"])


@router.post(
    "",
    response_model=StudyActivityRecordResponse,
    summary="Registrar actividad de estudio del día (America/Lima)",
)
def record_study_activity(
    payload: StudyActivityRecordRequest,
    student_id: int = Depends(get_current_student_id),
    db: Session = Depends(get_db),
) -> StudyActivityRecordResponse:
    activity = StreakService(db).record(
        student_id,
        payload.activity_type,
        payload.ref_id,
    )
    db.commit()
    return StudyActivityRecordResponse(
        id=activity.id,
        student_id=activity.student_id,
        activity_type=activity.activity_type,
        activity_date=activity.activity_date,
        ref_id=activity.ref_id,
    )


@router.get(
    "/streak",
    response_model=StreakResponse,
    summary="Racha actual, récord y máscara semanal",
)
def get_study_streak(
    student_id: int = Depends(get_current_student_id),
    db: Session = Depends(get_db),
) -> StreakResponse:
    snapshot = StreakService(db).get_streak(student_id)
    return StreakResponse(
        current_streak=snapshot.current_streak,
        longest_streak=snapshot.longest_streak,
        week_mask=snapshot.week_mask,
        last_activity_date=snapshot.last_activity_date,
    )
