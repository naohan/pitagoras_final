from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.dependencies import get_current_student_id, get_db
from app.preparation.service import PreparationService
from app.schemas.preparation import (
    AdmissionExamTargetResponse,
    AdmissionProcessResponse,
    PreparationProfileResponse,
    PreparationProfileUpdate,
)

router = APIRouter(tags=["Preparación / onboarding"])


@router.get(
    "/universities/{university_id}/exam-targets",
    response_model=list[AdmissionExamTargetResponse],
    summary="Modalidades de postulación (Quinto, CEPRE, Ordinario, …)",
)
def list_exam_targets(
    university_id: int,
    active_only: bool = True,
    db: Session = Depends(get_db),
) -> list[AdmissionExamTargetResponse]:
    items = PreparationService(db).list_exam_targets(
        university_id,
        active_only=active_only,
    )
    return [AdmissionExamTargetResponse.model_validate(item) for item in items]


@router.get(
    "/admission-processes",
    response_model=list[AdmissionProcessResponse],
    summary="Procesos de admisión (temario/balotario) por carrera o universidad",
)
def list_admission_processes(
    career_id: int | None = None,
    university_id: int | None = None,
    active_only: bool = True,
    db: Session = Depends(get_db),
) -> list[AdmissionProcessResponse]:
    items = PreparationService(db).list_admission_processes(
        career_id=career_id,
        university_id=university_id,
        active_only=active_only,
    )
    return [AdmissionProcessResponse.model_validate(item) for item in items]


@router.get(
    "/students/me/preparation-profile",
    response_model=PreparationProfileResponse,
    summary="Perfil de preparación del estudiante autenticado",
)
def get_preparation_profile(
    student_id: int = Depends(get_current_student_id),
    db: Session = Depends(get_db),
) -> PreparationProfileResponse:
    try:
        return PreparationService(db).get_profile(student_id)
    except ValueError as exc:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail={"code": str(exc), "message": "Student not found."},
        ) from exc


@router.put(
    "/students/me/preparation-profile",
    response_model=PreparationProfileResponse,
    summary="Guardar propósito (ingreso o aprender tema), universidad/carrera o subtema",
)
def update_preparation_profile(
    payload: PreparationProfileUpdate,
    student_id: int = Depends(get_current_student_id),
    db: Session = Depends(get_db),
) -> PreparationProfileResponse:
    try:
        profile = PreparationService(db).update_profile(student_id, payload)
        db.commit()
        return profile
    except ValueError as exc:
        db.rollback()
        code = str(exc)
        http_status = status.HTTP_400_BAD_REQUEST
        if code in {"student_not_found", "university_not_found", "focus_subtopic_not_found"}:
            http_status = status.HTTP_404_NOT_FOUND
        raise HTTPException(
            status_code=http_status,
            detail={"code": code, "message": code.replace("_", " ")},
        ) from exc
