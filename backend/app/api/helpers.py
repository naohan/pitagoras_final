from typing import Any

from fastapi import HTTPException, status


def apply_update(entity: object, data: dict[str, Any]) -> object:
    for field, value in data.items():
        setattr(entity, field, value)
    return entity


def not_found(entity_name: str, entity_id: int) -> HTTPException:
    return HTTPException(
        status_code=status.HTTP_404_NOT_FOUND,
        detail=f"{entity_name} with id {entity_id} not found",
    )
