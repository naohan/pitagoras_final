from fastapi import APIRouter, Depends, Response, status
from sqlalchemy.orm import Session

from app.api.helpers import apply_update, not_found
from app.auth.auth_service import AuthUser
from app.core.dependencies import get_current_user, get_db, require_roles
from app.models.enums import UserRole
from app.models.question import Question, QuestionOption
from app.repositories.question_repository import QuestionRepository
from app.schemas.question import QuestionCreate, QuestionResponse, QuestionUpdate

router = APIRouter(prefix="/questions", tags=["Questions"])


def _build_question(payload: QuestionCreate) -> Question:
    data = payload.model_dump()
    options_data = data.pop("options", [])
    question = Question(**data)
    for option_data in options_data:
        question.options.append(QuestionOption(**option_data))
    return question


def _replace_options(question: Question, options_data: list[dict]) -> None:
    question.options.clear()
    for option_data in options_data:
        question.options.append(QuestionOption(**option_data))


@router.get("", response_model=list[QuestionResponse])
def list_questions(
    skip: int = 0,
    limit: int = 100,
    active_only: bool = False,
    subtopic_id: int | None = None,
    difficulty: int | None = None,
    with_options: bool = False,
    db: Session = Depends(get_db),
    _: AuthUser = Depends(get_current_user),
) -> list[Question]:
    repo = QuestionRepository(db)
    if subtopic_id is not None:
        if with_options:
            return list(
                repo.list_by_subtopic_id_with_options(
                    subtopic_id,
                    skip=skip,
                    limit=limit,
                    active_only=active_only,
                )
            )
        return list(
            repo.list_by_subtopic_id(
                subtopic_id,
                skip=skip,
                limit=limit,
                active_only=active_only,
            )
        )
    if difficulty is not None:
        return list(
            repo.list_by_difficulty(
                difficulty,
                skip=skip,
                limit=limit,
                active_only=active_only,
            )
        )
    return list(repo.list_all(skip=skip, limit=limit, active_only=active_only))


@router.get("/{question_id}", response_model=QuestionResponse)
def get_question(
    question_id: int,
    db: Session = Depends(get_db),
    _: AuthUser = Depends(get_current_user),
) -> Question:
    entity = QuestionRepository(db).get_by_id_with_options(question_id)
    if entity is None:
        raise not_found("Question", question_id)
    return entity


@router.post("", response_model=QuestionResponse, status_code=status.HTTP_201_CREATED)
def create_question(
    payload: QuestionCreate,
    db: Session = Depends(get_db),
    _: AuthUser = Depends(require_roles(UserRole.ADMIN)),
) -> Question:
    repo = QuestionRepository(db)
    entity = _build_question(payload)
    repo.create(entity)
    db.commit()
    created = repo.get_by_id_with_options(entity.id)
    if created is None:
        raise not_found("Question", entity.id)
    return created


@router.put("/{question_id}", response_model=QuestionResponse)
def update_question(
    question_id: int,
    payload: QuestionUpdate,
    db: Session = Depends(get_db),
    _: AuthUser = Depends(require_roles(UserRole.ADMIN)),
) -> Question:
    repo = QuestionRepository(db)
    entity = repo.get_by_id_with_options(question_id)
    if entity is None:
        raise not_found("Question", question_id)

    update_data = payload.model_dump(exclude_unset=True)
    options_data = update_data.pop("options", None)
    apply_update(entity, update_data)
    if options_data is not None:
        _replace_options(entity, options_data)

    db.commit()
    updated = repo.get_by_id_with_options(question_id)
    if updated is None:
        raise not_found("Question", question_id)
    return updated


@router.delete("/{question_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_question(
    question_id: int,
    db: Session = Depends(get_db),
    _: AuthUser = Depends(require_roles(UserRole.ADMIN)),
) -> Response:
    repo = QuestionRepository(db)
    if not repo.delete_by_id(question_id):
        raise not_found("Question", question_id)
    db.commit()
    return Response(status_code=status.HTTP_204_NO_CONTENT)
