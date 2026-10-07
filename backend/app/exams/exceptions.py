"""Excepciones del motor de exámenes."""


class ExamEngineError(Exception):
    def __init__(self, message: str, code: str = "exam_engine_error") -> None:
        self.message = message
        self.code = code
        super().__init__(message)


class ExamNotFoundError(ExamEngineError):
    def __init__(self, exam_id: int) -> None:
        super().__init__(f"Student exam {exam_id} not found", "exam_not_found")


class TemplateNotFoundError(ExamEngineError):
    def __init__(self, template_id: int) -> None:
        super().__init__(f"Exam template {template_id} not found", "template_not_found")


class StudentNotFoundError(ExamEngineError):
    def __init__(self, student_id: int) -> None:
        super().__init__(f"Student {student_id} not found", "student_not_found")


class ExamNotInProgressError(ExamEngineError):
    def __init__(self, status: str) -> None:
        super().__init__(f"Exam is not in progress (status={status})", "exam_not_in_progress")


class ExamTimeExpiredError(ExamEngineError):
    def __init__(self) -> None:
        super().__init__("Exam time has expired", "exam_time_expired")


class QuestionNotInExamError(ExamEngineError):
    def __init__(self, question_id: int) -> None:
        super().__init__(
            f"Question {question_id} is not part of this exam",
            "question_not_in_exam",
        )


class InvalidOptionError(ExamEngineError):
    def __init__(self, option_id: int) -> None:
        super().__init__(f"Option {option_id} is invalid for this question", "invalid_option")


class ExamAlreadyCompletedError(ExamEngineError):
    def __init__(self) -> None:
        super().__init__("Exam is already completed", "exam_already_completed")


class InsufficientQuestionsError(ExamEngineError):
    def __init__(self, needed: int, found: int) -> None:
        super().__init__(
            f"Not enough questions available (needed {needed}, found {found})",
            "insufficient_questions",
        )
