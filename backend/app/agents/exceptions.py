"""Excepciones del Tutor IA."""


class TutorError(Exception):
    def __init__(self, message: str, code: str = "tutor_error") -> None:
        self.message = message
        self.code = code
        super().__init__(message)


class QuestionNotFoundError(TutorError):
    def __init__(self, question_id: int) -> None:
        super().__init__(f"Question {question_id} not found", "question_not_found")


class LLMConfigurationError(TutorError):
    def __init__(self, detail: str) -> None:
        super().__init__(detail, "llm_configuration_error")


class LLMRequestError(TutorError):
    def __init__(self, detail: str) -> None:
        super().__init__(detail, "llm_request_error")
