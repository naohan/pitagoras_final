from fastapi import APIRouter, Depends, Response, status
from sqlalchemy.orm import Session

from app.api.helpers import apply_update, not_found
from app.auth.auth_service import AuthUser
from app.core.dependencies import get_current_user, get_db, require_roles
from app.models.academic import Career
from app.models.enums import UserRole
from app.preparation.service import PreparationService
from app.repositories.career_repository import CareerRepository
from app.schemas.career import CareerCreate, CareerResponse, CareerUpdate

router = APIRouter(prefix="/careers", tags=["Careers"])


def _to_response(entity: Career) -> CareerResponse:
    data = CareerResponse.model_validate(entity)
    return data.model_copy(
        update={"score_range_label": PreparationService.score_range_label(entity)}
    )


@router.get("", response_model=list[CareerResponse])
def list_careers(
    skip: int = 0,
    limit: int = 100,
    active_only: bool = False,
    university_id: int | None = None,
    admission_process_id: int | None = None,
    db: Session = Depends(get_db),
    _: AuthUser = Depends(get_current_user),
) -> list[CareerResponse]:
    repo = CareerRepository(db)
    if admission_process_id is not None:
        from app.models.academic import AdmissionProcess

        admission = db.get(AdmissionProcess, admission_process_id)
        if admission is None:
            return []
        career = admission.career
        if active_only and not career.is_active:
            return []
        if university_id is not None and career.university_id != university_id:
            return []
        return [_to_response(career)]
    if university_id is not None:
        items = list(
            repo.list_by_university_id(
                university_id,
                skip=skip,
                limit=limit,
                active_only=active_only,
            )
        )
    else:
        items = list(repo.list_all(skip=skip, limit=limit, active_only=active_only))
    return [_to_response(item) for item in items]


@router.get("/{career_id}", response_model=CareerResponse)
def get_career(
    career_id: int,
    db: Session = Depends(get_db),
    _: AuthUser = Depends(get_current_user),
) -> CareerResponse:
    entity = CareerRepository(db).get_by_id(career_id)
    if entity is None:
        raise not_found("Career", career_id)
    return _to_response(entity)


@router.post("", response_model=CareerResponse, status_code=status.HTTP_201_CREATED)
def create_career(
    payload: CareerCreate,
    db: Session = Depends(get_db),
    _: AuthUser = Depends(require_roles(UserRole.ADMIN)),
) -> CareerResponse:
    repo = CareerRepository(db)
    entity = Career(**payload.model_dump())
    repo.create(entity)
    db.commit()
    db.refresh(entity)
    return _to_response(entity)


@router.put("/{career_id}", response_model=CareerResponse)
def update_career(
    career_id: int,
    payload: CareerUpdate,
    db: Session = Depends(get_db),
    _: AuthUser = Depends(require_roles(UserRole.ADMIN)),
) -> CareerResponse:
    repo = CareerRepository(db)
    entity = repo.get_by_id(career_id)
    if entity is None:
        raise not_found("Career", career_id)
    apply_update(entity, payload.model_dump(exclude_unset=True))
    db.commit()
    db.refresh(entity)
    return _to_response(entity)


@router.delete("/{career_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_career(
    career_id: int,
    db: Session = Depends(get_db),
    _: AuthUser = Depends(require_roles(UserRole.ADMIN)),
) -> Response:
    repo = CareerRepository(db)
    if not repo.delete_by_id(career_id):
        raise not_found("Career", career_id)
    db.commit()
    return Response(status_code=status.HTTP_204_NO_CONTENT)
