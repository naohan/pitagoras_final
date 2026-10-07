from dataclasses import dataclass
from typing import Any
from uuid import uuid4

import chromadb
from chromadb.api.models.Collection import Collection

from app.rag.embeddings import EmbeddingProvider


@dataclass
class VectorSearchResult:
    id: str
    text: str
    score: float
    metadata: dict[str, Any]


class ChromaStore:
    """Cliente ChromaDB para almacenamiento y búsqueda vectorial."""

    def __init__(
        self,
        persist_directory: str,
        collection_name: str,
        embedding_provider: EmbeddingProvider,
    ) -> None:
        self._client = chromadb.PersistentClient(path=persist_directory)
        self._collection_name = collection_name
        self._embeddings = embedding_provider
        self._collection: Collection | None = None

    @property
    def collection(self) -> Collection:
        if self._collection is None:
            self._collection = self._client.get_or_create_collection(
                name=self._collection_name,
                metadata={"hnsw:space": "cosine"},
            )
        return self._collection

    def add_chunks(
        self,
        texts: list[str],
        metadatas: list[dict[str, Any]],
        ids: list[str] | None = None,
    ) -> list[str]:
        chunk_ids = ids or [str(uuid4()) for _ in texts]
        embeddings = self._embeddings.embed_documents(texts)
        sanitized_meta = [self._sanitize_metadata(meta) for meta in metadatas]
        self.collection.add(
            ids=chunk_ids,
            documents=texts,
            embeddings=embeddings,
            metadatas=sanitized_meta,
        )
        return chunk_ids

    def search(
        self,
        query: str,
        *,
        top_k: int = 5,
        where: dict[str, Any] | None = None,
    ) -> list[VectorSearchResult]:
        query_embedding = self._embeddings.embed_query(query)
        results = self.collection.query(
            query_embeddings=[query_embedding],
            n_results=top_k,
            where=where,
            include=["documents", "metadatas", "distances"],
        )

        ids = results.get("ids", [[]])[0]
        documents = results.get("documents", [[]])[0]
        metadatas = results.get("metadatas", [[]])[0]
        distances = results.get("distances", [[]])[0]

        output: list[VectorSearchResult] = []
        for doc_id, text, meta, distance in zip(ids, documents, metadatas, distances):
            score = 1 - float(distance) if distance is not None else 0.0
            output.append(
                VectorSearchResult(
                    id=doc_id,
                    text=text or "",
                    score=round(score, 4),
                    metadata=meta or {},
                )
            )
        return output

    def count(self) -> int:
        return self.collection.count()

    def reset_collection(self) -> None:
        self._client.delete_collection(self._collection_name)
        self._collection = None

    def _sanitize_metadata(self, metadata: dict[str, Any]) -> dict[str, Any]:
        sanitized: dict[str, Any] = {}
        for key, value in metadata.items():
            if value is None:
                continue
            if isinstance(value, (str, int, float, bool)):
                sanitized[key] = value
            else:
                sanitized[key] = str(value)
        return sanitized
