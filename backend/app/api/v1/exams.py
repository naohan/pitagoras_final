from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.dependencies import get_db
from app.exams.exam_engine_service import ExamEngineService
from app.exams.exceptions import ExamEngineError
from app.models.exam import ExamTemplate, StudentExam
from app.models.answer import StudentAnswer
from app.repositories.exam_template_repository import ExamTemplateRepository
from app.repositories.student_exam_repository import StudentExamRepository
from app.schemas.exam import (
    ExamTemplateCreate,
    ExamTemplateResponse,
    ExamTimeStatusResponse,
    QuestionForExam,
    QuestionOptionForExam,
    StartAdaptiveStudentExamRequest,
    StartStudentExamRequest,
    StudentAnswerResponse,
    StudentExamResponse,
    StudentExamResultResponse,
    SubmitAnswerRequest,
    SaveAnswerRequest,
    SavedAnswerItemResponse,
    QuestionOptionReview,
    BreakdownItemResponse,
    ExamResultResponse,
)

router = APIRouter(tags=["Exam Engine"])


def _engine(db: Session = Depends(get_db)) -> ExamEngineService:
    return ExamEngineService(db)


def _handle_engine_error(exc: ExamEngineError) -> HTTPException:
    status_code = status.HTTP_400_BAD_REQUEST
    if exc.code in ("exam_not_found", "template_not_found", "student_not_found"):
        status_code = status.HTTP_404_NOT_FOUND
    elif exc.code == "exam_time_expired":
        status_code = status.HTTP_409_CONFLICT
    return HTTPException(status_code=status_code, detail={"code": exc.code, "message": exc.message})


def _build_exam_questions(template: ExamTemplate) -> list[QuestionForExam]:
    items = sorted(template.template_questions, key=lambda x: x.display_order)
    questions: list[QuestionForExam] = []
    for item in items:
        if item.question is None:
            continue
        questions.append(
            QuestionForExam(
                id=item.question.id,
                subtopic_id=item.question.subtopic_id,
                stem=item.question.stem,
                difficulty=item.question.difficulty,
                display_order=item.display_order,
                options=[
                    QuestionOptionForExam(
                        id=opt.id,
                        label=opt.label,
                        text=opt.text,
                        display_order=opt.display_order,
                    )
                    for opt in sorted(item.question.options, key=lambda o: o.display_order)
                ],
            )
        )
    return questions


def _resolve_area_name(answer: StudentAnswer) -> str | None:
    question = answer.question
    if question is None or question.subtopic is None:
        return None
    topic = question.subtopic.topic
    if topic is None or topic.component is None:
        return None
    area = topic.component.area
    return area.name if area else None


def _build_saved_answer_item(
    answer: StudentAnswer,
    *,
    display_order: int = 0,
) -> SavedAnswerItemResponse:
    question = answer.question
    if question is None:
        raise HTTPException(status_code=500, detail="Question not loaded for saved answer")

    return SavedAnswerItemResponse(
        student_answer_id=answer.id,
        student_exam_id=answer.student_exam_id,
        question_id=answer.question_id,
        stem=question.stem,
        area_name=_resolve_area_name(answer),
        selected_option_id=answer.selected_option_id,
        is_correct=answer.is_correct,
        is_saved=answer.is_saved,
        answered_at=answer.answered_at,
        display_order=display_order,
        options=[
            QuestionOptionReview(
                id=opt.id,
                label=opt.label,
                text=opt.text,
                is_correct=opt.is_correct,
                display_order=opt.display_order,
            )
            for opt in sorted(question.options, key=lambda o: o.display_order)
        ],
    )


def _build_student_exam_response(student_exam: StudentExam) -> StudentExamResponse:
    template = student_exam.exam_template
    questions = _build_exam_questions(template) if template else []
    return StudentExamResponse(
        id=student_exam.id,
        student_id=student_exam.student_id,
        exam_template_id=student_exam.exam_template_id,
        status=student_exam.status,
        started_at=student_exam.started_at,
        finished_at=student_exam.finished_at,
        created_at=student_exam.created_at,
        updated_at=student_exam.updated_at,
        questions=questions,
        answers=[StudentAnswerResponse.model_validate(a) for a in student_exam.answers],
    )


def _build_result_response(student_exam: StudentExam) -> StudentExamResultResponse:
    result = student_exam.result
    return StudentExamResultResponse(
        student_exam_id=student_exam.id,
        status=student_exam.status,
        result=ExamResultResponse.model_validate(result) if result else None,
        areas=[
            BreakdownItemResponse(
                id=r.id,
                total_questions=r.total_questions,
                correct_answers=r.correct_answers,
                score_percent=r.score_percent,
                area_id=r.area_id,
            )
            for r in student_exam.result_areas
        ],
        components=[
            BreakdownItemResponse(
                id=r.id,
                total_questions=r.total_questions,
                correct_answers=r.correct_answers,
                score_percent=r.score_percent,
                component_id=r.component_id,
            )
            for r in student_exam.result_components
        ],
        topics=[
            BreakdownItemResponse(
                id=r.id,
                total_questions=r.total_questions,
                correct_answers=r.correct_answers,
                score_percent=r.score_percent,
                topic_id=r.topic_id,
            )
            for r in student_exam.result_topics
        ],
        subtopics=[
            BreakdownItemResponse(
                id=r.id,
                total_questions=r.total_questions,
                correct_answers=r.correct_answers,
                score_percent=r.score_percent,
                subtopic_id=r.subtopic_id,
            )
            for r in student_exam.result_subtopics
        ],
    )


@router.post(
    "/exam-templates",
    response_model=ExamTemplateResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Crear plantilla de examen con selección de preguntas",
)
def create_exam_template(
    payload: ExamTemplateCreate,
    db: Session = Depends(get_db),
    engine: ExamEngineService = Depends(_engine),
) -> ExamTemplate:
    try:
        template = engine.create_exam_template(
            admission_process_id=payload.admission_process_id,
            name=payload.name,
            duration_minutes=payload.duration_minutes,
            question_count=payload.question_count,
            auto_select_questions=payload.auto_select_questions,
            question_ids=payload.question_ids,
        )
        db.commit()
        return template
    except ExamEngineError as exc:
        db.rollback()
        raise _handle_engine_error(exc) from exc


@router.get(
    "/exam-templates",
    response_model=list[ExamTemplateResponse],
    summary="Listar plantillas por carrera o proceso de admisión",
)
def list_exam_templates(
    career_id: int | None = None,
    admission_process_id: int | None = None,
    active_only: bool = True,
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db),
) -> list[ExamTemplate]:
    repo = ExamTemplateRepository(db)
    if career_id is not None:
        templates = repo.list_by_career_id(
            career_id,
            skip=skip,
            limit=limit,
            active_only=active_only,
        )
    elif admission_process_id is not None:
        templates = repo.list_by_admission_process_id(
            admission_process_id,
            skip=skip,
            limit=limit,
            active_only=active_only,
        )
    else:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Provide career_id or admission_process_id",
        )
    return list(templates)


@router.get(
    "/exam-templates/{template_id}",
    response_model=ExamTemplateResponse,
    summary="Obtener plantilla de examen",
)
def get_exam_template(
    template_id: int,
    db: Session = Depends(get_db),
) -> ExamTemplate:
    template = ExamTemplateRepository(db).get_with_questions(template_id)
    if template is None:
        raise HTTPException(status_code=404, detail="Exam template not found")
    return template


@router.post(
    "/student-exams",
    response_model=StudentExamResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Iniciar sesión de examen",
)
def start_student_exam(
    payload: StartStudentExamRequest,
    db: Session = Depends(get_db),
    engine: ExamEngineService = Depends(_engine),
) -> StudentExamResponse:
    try:
        student_exam = engine.start_student_exam(
            student_id=payload.student_id,
            exam_template_id=payload.exam_template_id,
        )
        db.commit()
        return _build_student_exam_response(student_exam)
    except ExamEngineError as exc:
        db.rollback()
        raise _handle_engine_error(exc) from exc


@router.post(
    "/student-exams/adaptive",
    response_model=StudentExamResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Iniciar simulacro adaptativo según diagnóstico",
)
def start_adaptive_student_exam(
    payload: StartAdaptiveStudentExamRequest,
    db: Session = Depends(get_db),
    engine: ExamEngineService = Depends(_engine),
) -> StudentExamResponse:
    try:
        student_exam = engine.start_adaptive_simulacro(
            student_id=payload.student_id,
            based_on_student_exam_id=payload.based_on_student_exam_id,
            question_count=payload.question_count,
        )
        db.commit()
        return _build_student_exam_response(student_exam)
    except ExamEngineError as exc:
        db.rollback()
        raise _handle_engine_error(exc) from exc


@router.get(
    "/student-exams/{student_exam_id}",
    response_model=StudentExamResponse,
    summary="Obtener examen en curso o finalizado",
)
def get_student_exam(
    student_exam_id: int,
    db: Session = Depends(get_db),
) -> StudentExamResponse:
    student_exam = StudentExamRepository(db).get_with_template_and_questions(student_exam_id)
    if student_exam is None:
        raise HTTPException(status_code=404, detail="Student exam not found")
    return _build_student_exam_response(student_exam)


@router.get(
    "/student-exams/{student_exam_id}/time",
    response_model=ExamTimeStatusResponse,
    summary="Consultar tiempo restante del examen",
)
def get_exam_time_status(
    student_exam_id: int,
    db: Session = Depends(get_db),
    engine: ExamEngineService = Depends(_engine),
) -> ExamTimeStatusResponse:
    try:
        time_status = engine.get_time_status(student_exam_id)
        return ExamTimeStatusResponse.model_validate(time_status)
    except ExamEngineError as exc:
        raise _handle_engine_error(exc) from exc


@router.post(
    "/student-exams/{student_exam_id}/answers",
    response_model=StudentAnswerResponse,
    summary="Guardar respuesta del estudiante",
)
def submit_answer(
    student_exam_id: int,
    payload: SubmitAnswerRequest,
    db: Session = Depends(get_db),
    engine: ExamEngineService = Depends(_engine),
) -> StudentAnswerResponse:
    try:
        answer = engine.submit_answer(
            student_exam_id=student_exam_id,
            question_id=payload.question_id,
            selected_option_id=payload.selected_option_id,
            time_seconds=payload.time_seconds,
        )
        db.commit()
        return StudentAnswerResponse.model_validate(answer)
    except ExamEngineError as exc:
        db.rollback()
        raise _handle_engine_error(exc) from exc


@router.patch(
    "/student-exams/{student_exam_id}/answers/{question_id}/save",
    response_model=StudentAnswerResponse,
    summary="Marcar o desmarcar pregunta para repasar",
)
def toggle_save_answer(
    student_exam_id: int,
    question_id: int,
    payload: SaveAnswerRequest,
    db: Session = Depends(get_db),
    engine: ExamEngineService = Depends(_engine),
) -> StudentAnswerResponse:
    try:
        answer = engine.toggle_save_answer(
            student_exam_id=student_exam_id,
            question_id=question_id,
            is_saved=payload.is_saved,
        )
        db.commit()
        return StudentAnswerResponse.model_validate(answer)
    except ExamEngineError as exc:
        db.rollback()
        raise _handle_engine_error(exc) from exc


@router.get(
    "/students/{student_id}/saved-answers",
    response_model=list[SavedAnswerItemResponse],
    summary="Listar preguntas guardadas del estudiante",
)
def list_saved_answers(
    student_id: int,
    correctness: str = "all",
    db: Session = Depends(get_db),
    engine: ExamEngineService = Depends(_engine),
) -> list[SavedAnswerItemResponse]:
    try:
        answers = engine.list_saved_answers(student_id, correctness=correctness)
        return [_build_saved_answer_item(answer) for answer in answers]
    except ExamEngineError as exc:
        raise _handle_engine_error(exc) from exc


@router.get(
    "/student-exams/{student_exam_id}/review",
    response_model=list[SavedAnswerItemResponse],
    summary="Revisión completa de respuestas post-examen",
)
def get_exam_review(
    student_exam_id: int,
    correctness: str = "all",
    db: Session = Depends(get_db),
    engine: ExamEngineService = Depends(_engine),
) -> list[SavedAnswerItemResponse]:
    try:
        items = engine.get_exam_review(student_exam_id, correctness=correctness)
        return [
            _build_saved_answer_item(answer, display_order=display_order)
            for answer, display_order in items
        ]
    except ExamEngineError as exc:
        raise _handle_engine_error(exc) from exc


@router.post(
    "/student-exams/{student_exam_id}/finish",
    response_model=StudentExamResultResponse,
    summary="Finalizar examen, calificar y guardar resultados",
)
def finish_student_exam(
    student_exam_id: int,
    db: Session = Depends(get_db),
    engine: ExamEngineService = Depends(_engine),
) -> StudentExamResultResponse:
    try:
        student_exam = engine.finish_exam(student_exam_id)
        db.commit()
        return _build_result_response(student_exam)
    except ExamEngineError as exc:
        db.rollback()
        raise _handle_engine_error(exc) from exc


@router.get(
    "/student-exams/{student_exam_id}/results",
    response_model=StudentExamResultResponse,
    summary="Obtener resultados del examen",
)
def get_student_exam_results(
    student_exam_id: int,
    db: Session = Depends(get_db),
) -> StudentExamResultResponse:
    student_exam = StudentExamRepository(db).get_with_result(student_exam_id)
    if student_exam is None:
        raise HTTPException(status_code=404, detail="Student exam not found")
    if student_exam.result is None:
        raise HTTPException(status_code=404, detail="Results not available yet")
    return _build_result_response(student_exam)
