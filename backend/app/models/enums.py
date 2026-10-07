import enum


class QuestionLevel(str, enum.Enum):
    BASIC = "basic"
    INTERMEDIATE = "intermediate"
    ADVANCED = "advanced"


class StudentExamStatus(str, enum.Enum):
    PENDING = "pending"
    IN_PROGRESS = "in_progress"
    COMPLETED = "completed"
    EXPIRED = "expired"


class UserRole(str, enum.Enum):
    STUDENT = "student"
    PARENT = "parent"


class StudyActivityType(str, enum.Enum):
    EXAM = "exam"
    FLASHCARDS = "flashcards"
    POMODORO = "pomodoro"
    MATERIAL = "material"
    MOTIVATOR = "motivator"


class CurriculumFramework(str, enum.Enum):
    ADMISSION_TEMARIO = "admission_temario"
    CNEB_SECUNDARIA = "cneb_secundaria"


class StudyPurpose(str, enum.Enum):
    """Propósito del estudiante: ingresar a la universidad o aprender temas."""

    ADMISSION = "admission"
    TOPIC_LEARNING = "topic_learning"
