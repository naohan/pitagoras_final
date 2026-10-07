from dataclasses import dataclass
from pathlib import Path

from app.rag.exceptions import DocumentLoadError, UnsupportedFormatError

SUPPORTED_EXTENSIONS = {".txt", ".md", ".pdf"}


@dataclass
class LoadedDocument:
    text: str
    source: str
    source_type: str
    metadata: dict


class DocumentLoader:
    """Carga texto desde archivos o cadenas planas."""

    def load_text(self, text: str, *, source: str = "inline", metadata: dict | None = None) -> LoadedDocument:
        return LoadedDocument(
            text=text.strip(),
            source=source,
            source_type="text",
            metadata=metadata or {},
        )

    def load_file(
        self,
        file_path: str | Path,
        metadata: dict | None = None,
        *,
        max_pdf_pages: int | None = None,
    ) -> tuple[LoadedDocument, str | None]:
        path = Path(file_path)
        if not path.exists():
            raise DocumentLoadError(str(path), "file not found")

        extension = path.suffix.lower()
        if extension not in SUPPORTED_EXTENSIONS:
            raise UnsupportedFormatError(extension)

        warning: str | None = None
        if extension in {".txt", ".md"}:
            text = path.read_text(encoding="utf-8")
        elif extension == ".pdf":
            text, warning = self._load_pdf(path, max_pages=max_pdf_pages)
        else:
            raise UnsupportedFormatError(extension)

        document = LoadedDocument(
            text=text.strip(),
            source=str(path),
            source_type=extension.lstrip("."),
            metadata={**(metadata or {}), "filename": path.name},
        )
        return document, warning

    def _load_pdf(self, path: Path, *, max_pages: int | None = None) -> tuple[str, str | None]:
        errors: list[str] = []
        warning: str | None = None

        try:
            text, truncated = self._load_pdf_pypdf(path, max_pages=max_pages)
            if text.strip():
                if truncated:
                    warning = (
                        f"Solo se indexaron las primeras {max_pages} páginas del PDF "
                        "(límite de demo). Sube un capítulo en .txt para material completo."
                    )
                return text, warning
            errors.append("pypdf no extrajo texto")
        except DocumentLoadError as exc:
            errors.append(str(exc.message))

        try:
            text, truncated = self._load_pdf_pdfplumber(path, max_pages=max_pages)
            if text.strip():
                if truncated:
                    warning = (
                        f"Solo se indexaron las primeras {max_pages} páginas del PDF "
                        "(límite de demo). Sube un capítulo en .txt para material completo."
                    )
                return text, warning
            errors.append("pdfplumber no extrajo texto")
        except DocumentLoadError as exc:
            errors.append(str(exc.message))

        reason = (
            "No se pudo extraer texto del PDF. "
            f"Detalle: {'; '.join(errors)}. "
            "Prueba copiar un capítulo a un archivo .txt o usa «Pegar texto» en la app."
        )
        raise DocumentLoadError(str(path), reason)

    def _load_pdf_pypdf(self, path: Path, *, max_pages: int | None = None) -> tuple[str, bool]:
        try:
            from pypdf import PdfReader
        except ImportError as exc:
            raise DocumentLoadError(str(path), "pypdf is not installed") from exc

        reader = PdfReader(str(path))
        total_pages = len(reader.pages)
        limit = total_pages
        truncated = False
        if max_pages is not None and total_pages > max_pages:
            limit = max_pages
            truncated = True

        pages = [page.extract_text() or "" for page in reader.pages[:limit]]
        return "\n".join(pages).strip(), truncated

    def _load_pdf_pdfplumber(self, path: Path, *, max_pages: int | None = None) -> tuple[str, bool]:
        try:
            import pdfplumber
        except ImportError as exc:
            raise DocumentLoadError(str(path), "pdfplumber is not installed") from exc

        parts: list[str] = []
        truncated = False
        with pdfplumber.open(str(path)) as pdf:
            total_pages = len(pdf.pages)
            limit = total_pages
            if max_pages is not None and total_pages > max_pages:
                limit = max_pages
                truncated = True
            for page in pdf.pages[:limit]:
                page_text = page.extract_text() or ""
                if page_text.strip():
                    parts.append(page_text)
        return "\n".join(parts).strip(), truncated
