"""Excepciones del sistema de diagnóstico."""


class DiagnosticError(Exception):
    def __init__(self, message: str, code: str = "diagnostic_error") -> None:
        self.message = message
        self.code = code
        super().__init__(message)


class ExamNotCompletedError(DiagnosticError):
    def __init__(self, student_exam_id: int) -> None:
        super().__init__(
            f"Exam {student_exam_id} is not completed; diagnostics unavailable",
            "exam_not_completed",
        )


class DiagnosticNotFoundError(DiagnosticError):
    def __init__(self, student_exam_id: int) -> None:
        super().__init__(
            f"No diagnostic data for exam {student_exam_id}",
            "diagnostic_not_found",
        )
