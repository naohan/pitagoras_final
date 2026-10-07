"""Excepciones del módulo RAG."""


class RAGError(Exception):
    def __init__(self, message: str, code: str = "rag_error") -> None:
        self.message = message
        self.code = code
        super().__init__(message)


class DocumentLoadError(RAGError):
    def __init__(self, path: str, reason: str) -> None:
        super().__init__(f"Failed to load document '{path}': {reason}", "document_load_error")


class UnsupportedFormatError(RAGError):
    def __init__(self, extension: str) -> None:
        super().__init__(f"Unsupported file format: {extension}", "unsupported_format")


class CollectionNotFoundError(RAGError):
    def __init__(self, name: str) -> None:
        super().__init__(f"ChromaDB collection '{name}' not found", "collection_not_found")
