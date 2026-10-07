from dataclasses import dataclass
from pathlib import Path
from typing import Any

from app.core.config import settings
from app.rag.chunking import TextChunker
from app.rag.chroma import ChromaStore, VectorSearchResult
from app.rag.embeddings import EmbeddingProvider, SentenceTransformerEmbeddings
from app.rag.loader import DocumentLoader, LoadedDocument


@dataclass
class IngestResult:
    source: str
    chunks_indexed: int
    chunk_ids: list[str]
    warning: str | None = None


class RAGService:
    """Orquesta loader → chunking → embeddings → ChromaDB."""

    def __init__(
        self,
        store: ChromaStore | None = None,
        loader: DocumentLoader | None = None,
        chunker: TextChunker | None = None,
        embedding_provider: EmbeddingProvider | None = None,
    ) -> None:
        self._embeddings = embedding_provider or SentenceTransformerEmbeddings(
            model_name=settings.embedding_model
        )
        self._store = store or ChromaStore(
            persist_directory=settings.chroma_persist_directory,
            collection_name=settings.chroma_collection_name,
            embedding_provider=self._embeddings,
        )
        self._loader = loader or DocumentLoader()
        self._chunker = chunker or TextChunker(
            chunk_size=settings.rag_chunk_size,
            chunk_overlap=settings.rag_chunk_overlap,
        )

    def ingest_text(
        self,
        text: str,
        *,
        source: str = "inline",
        metadata: dict[str, Any] | None = None,
    ) -> IngestResult:
        document = self._loader.load_text(text, source=source, metadata=metadata)
        return self._ingest_document(document, metadata)

    def ingest_file(
        self,
        file_path: str | Path,
        metadata: dict[str, Any] | None = None,
    ) -> IngestResult:
        document, warning = self._loader.load_file(
            file_path,
            metadata=metadata,
            max_pdf_pages=settings.rag_max_pdf_pages,
        )
        result = self._ingest_document(document, metadata)
        return IngestResult(
            source=result.source,
            chunks_indexed=result.chunks_indexed,
            chunk_ids=result.chunk_ids,
            warning=warning,
        )

    def search(
        self,
        query: str,
        *,
        top_k: int = 5,
        subtopic_id: int | None = None,
        topic_id: int | None = None,
        area_id: int | None = None,
        student_id: int | None = None,
    ) -> list[VectorSearchResult]:
        where = self._build_filter(
            subtopic_id=subtopic_id,
            topic_id=topic_id,
            area_id=area_id,
            student_id=student_id,
        )
        return self._store.search(query, top_k=top_k, where=where or None)

    def build_material_diagram(
        self,
        *,
        title: str | None = None,
        query: str | None = None,
        source: str | None = None,
        subtopic_id: int | None = None,
        topic_id: int | None = None,
        area_id: int | None = None,
        student_id: int | None = None,
        top_k: int = 8,
    ) -> tuple[str, list, int]:
        from app.rag.diagram_builder import MaterialDiagramNode, build_material_diagram

        search_query = (query or title or "conceptos principales definiciones temas").strip()
        # Con `source` no filtramos por subtema: suele no coincidir con el PDF subido.
        effective_subtopic = subtopic_id if not source else None

        results: list[VectorSearchResult] = []
        filter_attempts: list[dict[str, int | None]] = [
            {"subtopic_id": effective_subtopic, "student_id": student_id},
            {"subtopic_id": None, "student_id": student_id},
            {"subtopic_id": effective_subtopic, "student_id": None},
            {"subtopic_id": None, "student_id": None},
        ]
        seen: set[str] = set()
        for attempt in filter_attempts:
            batch = self.search(
                search_query,
                top_k=top_k,
                subtopic_id=attempt["subtopic_id"],
                topic_id=topic_id,
                area_id=area_id,
                student_id=attempt["student_id"],
            )
            for item in batch:
                if item.id not in seen:
                    seen.add(item.id)
                    results.append(item)
            if len(results) >= top_k:
                break

        if source:
            needle = source.strip().lower()
            filtered = [
                item
                for item in results
                if needle in str(item.metadata.get("source", "")).lower()
                or needle in str(item.metadata.get("title", "")).lower()
            ]
            if filtered:
                results = filtered

        if not results:
            return title or "Material de estudio", [], 0

        resolved_title = title or str(results[0].metadata.get("title") or results[0].metadata.get("source") or "Apuntes")
        nodes: list[MaterialDiagramNode] = build_material_diagram(
            title=resolved_title,
            chunks=[item.text for item in results],
        )
        return resolved_title, nodes, len(results)

    def stats(self) -> dict[str, Any]:
        return {
            "collection": settings.chroma_collection_name,
            "persist_directory": settings.chroma_persist_directory,
            "embedding_model": settings.embedding_model,
            "chunk_count": self._store.count(),
            "embedding_dimension": self._embeddings.dimension,
        }

    def _ingest_document(
        self,
        document: LoadedDocument,
        extra_metadata: dict[str, Any] | None,
    ) -> IngestResult:
        merged_metadata = {
            **document.metadata,
            **(extra_metadata or {}),
            "source": document.source,
            "source_type": document.source_type,
        }
        chunks = self._chunker.split(document.text, base_metadata=merged_metadata)
        if not chunks:
            return IngestResult(source=document.source, chunks_indexed=0, chunk_ids=[])

        texts = [chunk.text for chunk in chunks]
        metadatas = [chunk.metadata for chunk in chunks]
        chunk_ids = self._store.add_chunks(texts, metadatas)
        return IngestResult(
            source=document.source,
            chunks_indexed=len(chunk_ids),
            chunk_ids=chunk_ids,
        )

    def _build_filter(
        self,
        *,
        subtopic_id: int | None,
        topic_id: int | None,
        area_id: int | None,
        student_id: int | None = None,
    ) -> dict[str, Any] | None:
        filters: list[dict[str, Any]] = []
        if subtopic_id is not None:
            filters.append({"subtopic_id": subtopic_id})
        if topic_id is not None:
            filters.append({"topic_id": topic_id})
        if area_id is not None:
            filters.append({"area_id": area_id})
        if student_id is not None:
            filters.append({"student_id": student_id})

        if not filters:
            return None
        if len(filters) == 1:
            return filters[0]
        return {"$and": filters}
