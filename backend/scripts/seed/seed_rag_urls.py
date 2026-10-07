"""Indexa páginas web del banco Rubiños / matematicasn en ChromaDB (RAG).

El Tutor IA y los agentes usan este material para explicaciones contextualizadas.
Las preguntas del examen viven en MySQL (seed_demo + seed_extra_questions).

Uso (desde backend/):
    python -m scripts.seed.seed_rag_urls
    python -m scripts.seed.seed_rag_urls --dry-run
    python -m scripts.seed.seed_rag_urls --url https://matematicasn.blogspot.com/...
"""

from __future__ import annotations

import argparse
import html
import re
import sys
import urllib.error
import urllib.request
from pathlib import Path

from sqlalchemy import select

from app.database.session import SessionLocal
from app.models.academic import AdmissionProcess, Area, Component, Subtopic, Topic
from app.rag.exceptions import RAGError
from app.rag.rag_service import RAGService

# Páginas del banco de preguntas resueltas (Rubiños / matematicasn)
DEFAULT_URLS: list[dict[str, str]] = [
    {
        "url": "https://matematicasn.blogspot.com/2019/03/examen-admision-unsa-solucionario-pdf.html",
        "title": "Solucionario UNSA - ingenierías y claves",
        "content_type": "solucionario_unsa",
        "area_name": "Matemáticas",
    },
    {
        "url": "https://matematicasn.blogspot.com/2016/01/estudio-y-representacion-de-funciones.html",
        "title": "Banco Rubiños - funciones y matemática UNSA",
        "content_type": "banco_preguntas",
        "area_name": "Matemáticas",
    },
]

USER_AGENT = "PitagorasBot/1.0 (+https://github.com/pitagoras; educational RAG indexing)"


def _strip_html(raw: str) -> str:
    text = re.sub(r"(?is)<script[^>]*>.*?</script>", " ", raw)
    text = re.sub(r"(?is)<style[^>]*>.*?</style>", " ", text)
    text = re.sub(r"(?is)<br\s*/?>", "\n", text)
    text = re.sub(r"(?is)</p>", "\n\n", text)
    text = re.sub(r"<[^>]+>", " ", text)
    text = html.unescape(text)
    text = re.sub(r"[ \t]+", " ", text)
    text = re.sub(r"\n{3,}", "\n\n", text)
    return text.strip()


def _fetch_url(url: str, timeout: int = 30) -> str:
    request = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    with urllib.request.urlopen(request, timeout=timeout) as response:
        charset = response.headers.get_content_charset() or "utf-8"
        return response.read().decode(charset, errors="replace")


def _resolve_subtopic_id(db) -> int | None:
    stmt = (
        select(Subtopic.id)
        .join(Topic, Subtopic.topic_id == Topic.id)
        .join(Component, Topic.component_id == Component.id)
        .join(Area, Component.area_id == Area.id)
        .join(AdmissionProcess, Area.admission_process_id == AdmissionProcess.id)
        .where(Subtopic.is_active.is_(True))
        .order_by(Subtopic.display_order)
        .limit(1)
    )
    return db.scalar(stmt)


def seed_rag_urls(
    urls: list[dict[str, str]] | None = None,
    *,
    dry_run: bool = False,
) -> None:
    entries = urls or DEFAULT_URLS
    db = SessionLocal()
    try:
        subtopic_id = _resolve_subtopic_id(db)
        rag = RAGService()
        indexed = 0
        skipped = 0

        for entry in entries:
            url = entry["url"]
            title = entry.get("title", url)
            print(f"→ {title}")
            print(f"  {url}")

            if dry_run:
                try:
                    html_body = _fetch_url(url)
                    text = _strip_html(html_body)
                    print(f"  [dry-run] {len(text)} caracteres extraídos")
                except urllib.error.URLError as exc:
                    print(f"  [dry-run] error: {exc}")
                continue

            try:
                html_body = _fetch_url(url)
            except urllib.error.URLError as exc:
                print(f"  omitido (red): {exc}")
                skipped += 1
                continue

            text = _strip_html(html_body)
            if len(text) < 200:
                print("  omitido (contenido muy corto)")
                skipped += 1
                continue

            metadata = {
                "title": title,
                "source_url": url,
                "content_type": entry.get("content_type", "web"),
                "area_name": entry.get("area_name", "General"),
                "canal": "rubinos",
            }
            if subtopic_id is not None:
                metadata["subtopic_id"] = subtopic_id

            try:
                result = rag.ingest_text(text, source=url, metadata=metadata)
                indexed += 1
                print(f"  indexado: {result.chunks_indexed} chunks")
            except RAGError as exc:
                print(f"  error RAG: {exc}")
                skipped += 1

        print()
        print(f"Páginas indexadas: {indexed}")
        if skipped:
            print(f"Omitidas: {skipped}")
        if not dry_run and indexed:
            print("El Tutor IA ya puede usar este material en explicaciones.")
    finally:
        db.close()


def main() -> None:
    parser = argparse.ArgumentParser(description="Indexa URLs del banco Rubiños en RAG")
    parser.add_argument("--dry-run", action="store_true", help="Solo descarga y muestra tamaño")
    parser.add_argument("--url", action="append", help="URL adicional a indexar")
    args = parser.parse_args()

    urls = list(DEFAULT_URLS)
    if args.url:
        for extra in args.url:
            urls.append(
                {
                    "url": extra,
                    "title": Path(extra).name or extra,
                    "content_type": "banco_preguntas",
                    "area_name": "General",
                }
            )

    seed_rag_urls(urls, dry_run=args.dry_run)


if __name__ == "__main__":
    main()
