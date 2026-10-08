from fastapi import APIRouter, Depends, Response, status
from sqlalchemy.orm import Session

from app.api.helpers import apply_update, not_found
from app.auth.auth_service import AuthUser
from app.core.dependencies import get_current_user, get_db, require_roles
from app.models.academic import University
from app.models.enums import UserRole
from app.repositories.university_repository import UniversityRepository
from app.schemas.university import UniversityCreate, UniversityResponse, UniversityUpdate

router = APIRouter(prefix="/universities", tags=["Universities"])


@router.get("", response_model=list[UniversityResponse])
def list_universities(
    skip: int = 0,
    limit: int = 100,
    active_only: bool = False,
    country: str | None = None,
    db: Session = Depends(get_db),
    _: AuthUser = Depends(get_current_user),
) -> list[University]:
    repo = UniversityRepository(db)
    if country:
        return list(repo.list_by_country(country, skip=skip, limit=limit, active_only=active_only))
    return list(repo.list_all(skip=skip, limit=limit, active_only=active_only))


@router.get("/{university_id}", response_model=UniversityResponse)
def get_university(
    university_id: int,
    db: Session = Depends(get_db),
    _: AuthUser = Depends(get_current_user),
) -> University:
    entity = UniversityRepository(db).get_by_id(university_id)
    if entity is None:
        raise not_found("University", university_id)
    return entity


@router.post("", response_model=UniversityResponse, status_code=status.HTTP_201_CREATED)
def create_university(
    payload: UniversityCreate,
    db: Session = Depends(get_db),
    _: AuthUser = Depends(require_roles(UserRole.ADMIN)),
) -> University:
    repo = UniversityRepository(db)
    entity = University(**payload.model_dump())
    repo.create(entity)
    db.commit()
    db.refresh(entity)
    return entity


@router.put("/{university_id}", response_model=UniversityResponse)
def update_university(
    university_id: int,
    payload: UniversityUpdate,
    db: Session = Depends(get_db),
    _: AuthUser = Depends(require_roles(UserRole.ADMIN)),
) -> University:
    repo = UniversityRepository(db)
    entity = repo.get_by_id(university_id)
    if entity is None:
        raise not_found("University", university_id)
    apply_update(entity, payload.model_dump(exclude_unset=True))
    db.commit()
    db.refresh(entity)
    return entity


@router.delete("/{university_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_university(
    university_id: int,
    db: Session = Depends(get_db),
    _: AuthUser = Depends(require_roles(UserRole.ADMIN)),
) -> Response:
    repo = UniversityRepository(db)
    if not repo.delete_by_id(university_id):
        raise not_found("University", university_id)
    db.commit()
    return Response(status_code=status.HTTP_204_NO_CONTENT)
