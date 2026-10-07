from enum import Enum


class ResourceType(str, Enum):
    VIDEO = "video"
    EXERCISES = "exercises"
    MOCK_EXAM = "mock_exam"
    PDF = "pdf"
    FLASHCARDS = "flashcards"
