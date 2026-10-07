from typing import Any

from pydantic import BaseModel, Field


class RAGIngestTextRequest(BaseModel):
    text: str = Field(..., min_length=1)
    source: str = "inline"
    subtopic_id: int | None = None
    topic_id: int | None = None
    area_id: int | None = None
    title: str | None = None


class RAGIngestResponse(BaseModel):
    source: str
    chunks_indexed: int
    chunk_ids: list[str]
    warning: str | None = None


class RAGSearchRequest(BaseModel):
    query: str = Field(..., min_length=1)
    top_k: int = Field(default=5, ge=1, le=20)
    subtopic_id: int | None = None
    topic_id: int | None = None
    area_id: int | None = None


class RAGSearchResultItem(BaseModel):
    id: str
    text: str
    score: float
    metadata: dict[str, Any] = Field(default_factory=dict)


class RAGSearchResponse(BaseModel):
    query: str
    results: list[RAGSearchResultItem]


class RAGStatsResponse(BaseModel):
    collection: str
    persist_directory: str
    embedding_model: str
    chunk_count: int
    embedding_dimension: int


class RAGContextResponse(BaseModel):
    career_id: int
    subtopic_id: int | None = None
    subtopic_name: str | None = None
    topic_name: str | None = None
    area_name: str | None = None
    curriculum_origins: list[str] = Field(default_factory=list)


class RAGDiagramRequest(BaseModel):
    title: str | None = None
    query: str | None = None
    source: str | None = None
    subtopic_id: int | None = None
    topic_id: int | None = None
    area_id: int | None = None
    top_k: int = Field(default=8, ge=1, le=20)


class RAGDiagramNodeResponse(BaseModel):
    id: str
    label: str
    children: list["RAGDiagramNodeResponse"] = Field(default_factory=list)


class RAGDiagramResponse(BaseModel):
    title: str
    chunk_count: int
    nodes: list[RAGDiagramNodeResponse]
