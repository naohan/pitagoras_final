from datetime import datetime
from decimal import Decimal

from pydantic import BaseModel, ConfigDict, Field

from app.models.enums import StudentExamStatus


class ExamTemplateCreate(BaseModel):
    admission_process_id: int
    name: str = Field(..., max_length=150)
    duration_minutes: int = Field(..., gt=0)
    question_count: int = Field(..., gt=0)
    auto_select_questions: bool = True
    question_ids: list[int] | None = None


class ExamTemplateQuestionResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    question_id: int
    display_order: int


class ExamTemplateResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    admission_process_id: int
    name: str
    duration_minutes: int
    question_count: int
    is_active: bool
    created_at: datetime
    updated_at: datetime
    template_questions: list[ExamTemplateQuestionResponse] = Field(default_factory=list)


class StartStudentExamRequest(BaseModel):
    student_id: int
    exam_template_id: int


class StartAdaptiveStudentExamRequest(BaseModel):
    student_id: int
    based_on_student_exam_id: int = Field(
        ...,
        description="ID del examen de diagnóstico completado",
    )
    question_count: int = Field(default=15, ge=5, le=100)


class SubmitAnswerRequest(BaseModel):
    question_id: int
    selected_option_id: int | None = None
    time_seconds: int | None = Field(default=None, ge=0)


class StudentAnswerResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    student_exam_id: int
    question_id: int
    selected_option_id: int | None
    is_correct: bool | None
    is_saved: bool = False
    time_seconds: int | None
    answered_at: datetime | None
    created_at: datetime


class QuestionOptionForExam(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    label: str
    text: str
    display_order: int


class QuestionForExam(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    subtopic_id: int
    stem: str
    difficulty: int
    display_order: int
    options: list[QuestionOptionForExam] = Field(default_factory=list)


class StudentExamResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    student_id: int
    exam_template_id: int
    status: StudentExamStatus
    started_at: datetime | None
    finished_at: datetime | None
    created_at: datetime
    updated_at: datetime
    questions: list[QuestionForExam] = Field(default_factory=list)
    answers: list[StudentAnswerResponse] = Field(default_factory=list)


class ExamTimeStatusResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    student_exam_id: int
    status: StudentExamStatus
    started_at: datetime | None
    finished_at: datetime | None
    duration_minutes: int
    elapsed_seconds: int
    remaining_seconds: int
    is_expired: bool


class BreakdownItemResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    total_questions: int
    correct_answers: int
    score_percent: Decimal
    area_id: int | None = None
    component_id: int | None = None
    topic_id: int | None = None
    subtopic_id: int | None = None


class ExamResultResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    student_exam_id: int
    total_questions: int
    correct_answers: int
    score_percent: Decimal
    duration_seconds: int | None
    calculated_at: datetime
    created_at: datetime


class StudentExamResultResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    student_exam_id: int
    status: StudentExamStatus
    result: ExamResultResponse | None = None
    areas: list[BreakdownItemResponse] = Field(default_factory=list)
    components: list[BreakdownItemResponse] = Field(default_factory=list)
    topics: list[BreakdownItemResponse] = Field(default_factory=list)
    subtopics: list[BreakdownItemResponse] = Field(default_factory=list)


class SaveAnswerRequest(BaseModel):
    is_saved: bool


class QuestionOptionReview(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    label: str
    text: str
    is_correct: bool
    display_order: int


class SavedAnswerItemResponse(BaseModel):
    student_answer_id: int
    student_exam_id: int
    question_id: int
    stem: str
    area_name: str | None = None
    selected_option_id: int | None
    is_correct: bool | None
    is_saved: bool
    answered_at: datetime | None
    display_order: int = 0
    options: list[QuestionOptionReview] = Field(default_factory=list)
