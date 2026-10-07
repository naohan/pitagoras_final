from dataclasses import dataclass


@dataclass
class TextChunk:
    text: str
    chunk_index: int
    start_char: int
    end_char: int
    metadata: dict


class TextChunker:
    """Divide texto en fragmentos con solapamiento para indexación RAG."""

    def __init__(self, chunk_size: int = 800, chunk_overlap: int = 120) -> None:
        self.chunk_size = chunk_size
        self.chunk_overlap = chunk_overlap

    def split(self, text: str, base_metadata: dict | None = None) -> list[TextChunk]:
        if not text:
            return []

        base = dict(base_metadata or {})
        chunks: list[TextChunk] = []
        start = 0
        index = 0
        text_length = len(text)

        while start < text_length:
            end = min(start + self.chunk_size, text_length)
            chunk_text = text[start:end].strip()
            if chunk_text:
                chunks.append(
                    TextChunk(
                        text=chunk_text,
                        chunk_index=index,
                        start_char=start,
                        end_char=end,
                        metadata={**base, "chunk_index": index},
                    )
                )
                index += 1
            if end >= text_length:
                break
            start = end - self.chunk_overlap

        return chunks
