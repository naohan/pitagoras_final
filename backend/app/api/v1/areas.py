from fastapi import APIRouter, Depends, Response, status
from sqlalchemy.orm import Session

from app.api.helpers import apply_update, not_found
from app.auth.auth_service import AuthUser
from app.core.dependencies import get_current_user, get_db, require_roles
from app.models.academic import Area
from app.models.enums import UserRole
from app.repositories.area_repository import AreaRepository
from app.schemas.area import AreaCreate, AreaResponse, AreaUpdate

router = APIRouter(prefix="/areas", tags=["Areas"])


@router.get("", response_model=list[AreaResponse])
def list_areas(
    skip: int = 0,
    limit: int = 100,
    active_only: bool = False,
    admission_process_id: int | None = None,
    db: Session = Depends(get_db),
    _: AuthUser = Depends(get_current_user),
) -> list[Area]:
    repo = AreaRepository(db)
    if admission_process_id is not None:
        return list(
            repo.list_by_admission_process_id(
                admission_process_id,
                skip=skip,
                limit=limit,
                active_only=active_only,
            )
        )
    return list(repo.list_all(skip=skip, limit=limit, active_only=active_only))


@router.get("/{area_id}", response_model=AreaResponse)
def get_area(
    area_id: int,
    db: Session = Depends(get_db),
    _: AuthUser = Depends(get_current_user),
) -> Area:
    entity = AreaRepository(db).get_by_id(area_id)
    if entity is None:
        raise not_found("Area", area_id)
    return entity


@router.post("", response_model=AreaResponse, status_code=status.HTTP_201_CREATED)
def create_area(
    payload: AreaCreate,
    db: Session = Depends(get_db),
    _: AuthUser = Depends(require_roles(UserRole.ADMIN)),
) -> Area:
    repo = AreaRepository(db)
    entity = Area(**payload.model_dump())
    repo.create(entity)
    db.commit()
    db.refresh(entity)
    return entity


@router.put("/{area_id}", response_model=AreaResponse)
def update_area(
    area_id: int,
    payload: AreaUpdate,
    db: Session = Depends(get_db),
    _: AuthUser = Depends(require_roles(UserRole.ADMIN)),
) -> Area:
    repo = AreaRepository(db)
    entity = repo.get_by_id(area_id)
    if entity is None:
        raise not_found("Area", area_id)
    apply_update(entity, payload.model_dump(exclude_unset=True))
    db.commit()
    db.refresh(entity)
    return entity


@router.delete("/{area_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_area(
    area_id: int,
    db: Session = Depends(get_db),
    _: AuthUser = Depends(require_roles(UserRole.ADMIN)),
) -> Response:
    repo = AreaRepository(db)
    if not repo.delete_by_id(area_id):
        raise not_found("Area", area_id)
    db.commit()
    return Response(status_code=status.HTTP_204_NO_CONTENT)
