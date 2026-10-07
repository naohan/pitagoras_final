from decimal import Decimal

from sqlalchemy import select
from sqlalchemy.orm import Session, selectinload

from app.models.academic import AdmissionProcess, Career, Component, Subtopic, Topic, University
from app.models.admission_exam_target import AdmissionExamTarget
from app.models.enums import StudyPurpose
from app.models.student import Student
from app.schemas.preparation import PreparationProfileResponse, PreparationProfileUpdate


class PreparationService:
    def __init__(self, session: Session) -> None:
        self._session = session

    def list_exam_targets(
        self,
        university_id: int,
        *,
        active_only: bool = True,
    ) -> list[AdmissionExamTarget]:
        stmt = (
            select(AdmissionExamTarget)
            .where(AdmissionExamTarget.university_id == university_id)
            .order_by(AdmissionExamTarget.display_order, AdmissionExamTarget.id)
        )
        if active_only:
            stmt = stmt.where(AdmissionExamTarget.is_active.is_(True))
        return list(self._session.scalars(stmt).all())

    def list_admission_processes(
        self,
        *,
        career_id: int | None = None,
        university_id: int | None = None,
        active_only: bool = True,
    ) -> list[AdmissionProcess]:
        stmt = select(AdmissionProcess).order_by(AdmissionProcess.year.desc(), AdmissionProcess.id)
        if career_id is not None:
            stmt = stmt.where(AdmissionProcess.career_id == career_id)
        if university_id is not None:
            stmt = stmt.join(Career).where(Career.university_id == university_id)
        if active_only:
            stmt = stmt.where(AdmissionProcess.is_active.is_(True))
        return list(self._session.scalars(stmt).all())

    def get_profile(self, student_id: int) -> PreparationProfileResponse:
        student = self._load_student(student_id)
        return self._to_profile(student)

    def update_profile(
        self,
        student_id: int,
        payload: PreparationProfileUpdate,
    ) -> PreparationProfileResponse:
        student = self._load_student(student_id)
        purpose = payload.purpose or (
            StudyPurpose(student.purpose)
            if student.purpose
            else StudyPurpose.ADMISSION
        )

        if purpose == StudyPurpose.TOPIC_LEARNING:
            return self._update_topic_learning(student, payload, purpose)
        return self._update_admission(student, payload, purpose)

    def _update_topic_learning(
        self,
        student: Student,
        payload: PreparationProfileUpdate,
        purpose: StudyPurpose,
    ) -> PreparationProfileResponse:
        subtopic_id = payload.focus_subtopic_id
        if subtopic_id is None:
            raise ValueError("focus_subtopic_required_for_topic_learning")
        subtopic = self._session.get(Subtopic, subtopic_id)
        if subtopic is None or not subtopic.is_active:
            raise ValueError("focus_subtopic_not_found")

        student.purpose = purpose.value
        student.focus_subtopic_id = subtopic_id
        # Aprender un tema no exige carrera; se pueden limpiar o conservar.
        if payload.university_id is not None:
            student.university_id = payload.university_id
        if payload.career_id is not None:
            student.career_id = payload.career_id
        self._session.flush()
        self._session.expire(student)
        return self.get_profile(student.id)

    def _update_admission(
        self,
        student: Student,
        payload: PreparationProfileUpdate,
        purpose: StudyPurpose,
    ) -> PreparationProfileResponse:
        if payload.university_id is None or payload.career_id is None:
            raise ValueError("university_and_career_required_for_admission")

        university = self._session.get(University, payload.university_id)
        if university is None:
            raise ValueError("university_not_found")
        career = self._session.get(Career, payload.career_id)
        if career is None or career.university_id != payload.university_id:
            raise ValueError("career_not_found")

        admission_process_id = payload.admission_process_id
        if admission_process_id is None:
            admission_process_id = self._default_admission_process_id(career.id)
        else:
            process = self._session.get(AdmissionProcess, admission_process_id)
            if process is None or process.career_id != career.id:
                raise ValueError("admission_process_not_found")

        exam_target_code = payload.exam_target_code
        if exam_target_code:
            target = self._session.scalars(
                select(AdmissionExamTarget).where(
                    AdmissionExamTarget.university_id == university.id,
                    AdmissionExamTarget.code == exam_target_code,
                    AdmissionExamTarget.is_active.is_(True),
                )
            ).first()
            if target is None:
                raise ValueError("exam_target_not_found")

        student.purpose = purpose.value
        student.university_id = university.id
        student.career_id = career.id
        student.admission_process_id = admission_process_id
        student.exam_target_code = exam_target_code
        if payload.focus_subtopic_id is not None:
            student.focus_subtopic_id = payload.focus_subtopic_id
        self._session.flush()
        self._session.expire(student)
        return self.get_profile(student.id)

    def _default_admission_process_id(self, career_id: int) -> int | None:
        stmt = (
            select(AdmissionProcess)
            .where(
                AdmissionProcess.career_id == career_id,
                AdmissionProcess.is_active.is_(True),
            )
            .order_by(AdmissionProcess.year.desc(), AdmissionProcess.id.desc())
            .limit(1)
        )
        process = self._session.scalars(stmt).first()
        return process.id if process else None

    def _load_student(self, student_id: int) -> Student:
        stmt = (
            select(Student)
            .where(Student.id == student_id)
            .options(
                selectinload(Student.university),
                selectinload(Student.career),
                selectinload(Student.admission_process),
                selectinload(Student.focus_subtopic)
                .selectinload(Subtopic.topic)
                .selectinload(Topic.component)
                .selectinload(Component.area),
            )
        )
        student = self._session.scalars(stmt).first()
        if student is None:
            raise ValueError("student_not_found")
        return student

    def _to_profile(self, student: Student) -> PreparationProfileResponse:
        university = student.university
        career = student.career
        exam_label = None
        if student.university_id and student.exam_target_code:
            target = self._session.scalars(
                select(AdmissionExamTarget).where(
                    AdmissionExamTarget.university_id == student.university_id,
                    AdmissionExamTarget.code == student.exam_target_code,
                )
            ).first()
            exam_label = target.label if target else None

        purpose = None
        if student.purpose:
            try:
                purpose = StudyPurpose(student.purpose)
            except ValueError:
                purpose = None

        uni_code = university.code if university else None
        meta_title = f"Meta {uni_code}" if uni_code else None

        focus = student.focus_subtopic
        focus_name = focus.name if focus else None
        topic_name = focus.topic.name if focus and focus.topic else None
        area_name = None
        if focus and focus.topic and focus.topic.component:
            area_name = focus.topic.component.area.name if focus.topic.component.area else None
        # Lazy load area via query if needed
        if focus and area_name is None:
            area_name = self._area_name_for_subtopic(focus.id)

        learning_title = None
        if purpose == StudyPurpose.TOPIC_LEARNING and focus_name:
            learning_title = f"Estudiando: {focus_name}"

        return PreparationProfileResponse(
            purpose=purpose,
            university_id=student.university_id,
            university_code=uni_code,
            university_name=university.name if university else None,
            career_id=student.career_id,
            career_code=career.code if career else None,
            career_name=career.name if career else None,
            admission_process_id=student.admission_process_id,
            exam_target_code=student.exam_target_code,
            exam_target_label=exam_label,
            focus_subtopic_id=student.focus_subtopic_id,
            focus_subtopic_name=focus_name,
            focus_topic_name=topic_name,
            focus_area_name=area_name,
            learning_title=learning_title,
            target_score=career.target_score if career else None,
            score_min=career.score_min if career else None,
            score_max=career.score_max if career else None,
            meta_title=meta_title if purpose != StudyPurpose.TOPIC_LEARNING else None,
        )

    def _area_name_for_subtopic(self, subtopic_id: int) -> str | None:
        from app.models.academic import Area, Component, Topic

        stmt = (
            select(Area.name)
            .join(Component, Component.area_id == Area.id)
            .join(Topic, Topic.component_id == Component.id)
            .join(Subtopic, Subtopic.topic_id == Topic.id)
            .where(Subtopic.id == subtopic_id)
        )
        return self._session.execute(stmt).scalar_one_or_none()

    @staticmethod
    def score_range_label(career: Career) -> str | None:
        if career.score_min is None or career.score_max is None:
            return None
        lo = Decimal(career.score_min)
        hi = Decimal(career.score_max)
        # Guion ASCII: evita glifos tipográficos que algunas fuentes no traen.
        return f"{lo:g} - {hi:g}"
