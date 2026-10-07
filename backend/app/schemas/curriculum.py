from pydantic import BaseModel, ConfigDict, Field

from app.models.enums import CurriculumFramework


class CurriculumMappingResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    subtopic_id: int
    framework: CurriculumFramework
    external_code: str
    external_label: str
    origin_label: str = Field(
        ...,
        description="Etiqueta de producto: Base escolar (CNEB) o Temario/balotario de admisión",
    )


class SubtopicCurriculumResponse(BaseModel):
    subtopic_id: int
    subtopic_name: str = ""
    topic_name: str = ""
    course_name: str = ""
    area_name: str = ""
    theory_text: str = ""
    origins: list[str]
    mappings: list[CurriculumMappingResponse]


class LearnableTopicResponse(BaseModel):
    subtopic_id: int
    subtopic_name: str
    topic_name: str
    course_name: str = Field(..., description="Curso interno (Component), p.ej. Aritmética")
    area_name: str = Field(..., description="Área oficial CNEB, p.ej. Matemática")
    theory_text: str = Field(default="", description="Teoría pedagógica del tema")
    framework: CurriculumFramework
    external_code: str
    external_label: str
    origin_label: str


class CurriculumCourseResponse(BaseModel):
    course_id: int
    course_name: str
    topics: list[LearnableTopicResponse] = Field(default_factory=list)


class CurriculumAreaResponse(BaseModel):
    area_name: str
    courses: list[CurriculumCourseResponse] = Field(default_factory=list)


class CurriculumCatalogResponse(BaseModel):
    """Áreas CNEB oficiales con sus cursos internos y temas."""

    areas: list[CurriculumAreaResponse]
