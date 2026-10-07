"""Indexa en ChromaDB los PDFs de docs/data para el Tutor IA (RAG).

Uso (desde backend/ con venv activo):
    python -m scripts.seed.seed_rag_docs
    python -m scripts.seed.seed_rag_docs --dry-run
    python -m scripts.seed.seed_rag_docs --only libros-matematica
    python -m scripts.seed.seed_rag_docs --limit 3

Los archivos deben estar en: pitagoras/docs/data/
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

from sqlalchemy import select

from app.database.session import SessionLocal
from app.models.academic import AdmissionProcess, Area, Component, Subtopic, Topic
from app.rag.exceptions import RAGError
from app.rag.rag_service import RAGService

REPO_ROOT = Path(__file__).resolve().parents[2]
DEFAULT_DATA_DIR = REPO_ROOT / "docs" / "data"

# Carpeta relativa dentro de docs/data → metadatos para búsqueda
FOLDER_TAGS: dict[str, dict] = {
    "libros-matematica": {
        "content_type": "libro",
        "area_name": "Matemáticas",
        "canal": "general",
    },
    "temario": {
        "content_type": "temario",
        "area_name": "Matemáticas",
        "canal": "general",
    },
    "examen-ordinario": {
        "content_type": "examen",
        "university": "UNSA",
    },
    "CEPREQUINTOS  EXAMEN  1ER Y 2DO EXAMEN 2023-20260627T103328Z-3-001": {
        "content_type": "examen_cepre",
        "area_name": "Matemáticas",
    },
}

CANAL_TAGS: dict[str, dict] = {
    "CANAL 1": {"canal": "biomedicas", "area_name": "Ciencias Biomédicas"},
    "CANAL 2": {"canal": "ingenierias", "area_name": "Ingenierías"},
    "CANAL 3 Y 4": {"canal": "sociales", "area_name": "Ciencias Sociales"},
}


def _resolve_subtopic_id(db) -> int | None:
    """Primer subtema activo del árbol demo (SIS / UNSA)."""
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


def _top_folder(relative: Path) -> str:
    parts = relative.parts
    return parts[0] if parts else ""


def _metadata_for_file(relative: Path) -> dict:
    top = _top_folder(relative)
    meta: dict = {
        "title": relative.stem,
        "source_path": relative.as_posix(),
        **FOLDER_TAGS.get(top, {"content_type": "documento"}),
    }
    for part in relative.parts:
        if part in CANAL_TAGS:
            meta.update(CANAL_TAGS[part])
            break
    return meta


def _collect_pdfs(data_dir: Path, only: str | None) -> list[Path]:
    if not data_dir.is_dir():
        raise FileNotFoundError(f"No existe la carpeta de datos: {data_dir}")

    pdfs: list[Path] = []
    for path in sorted(data_dir.rglob("*.pdf")):
        if not path.is_file():
            continue
        rel = path.relative_to(data_dir)
        if only and not rel.as_posix().startswith(only.replace("\\", "/")):
            continue
        pdfs.append(path)
    return pdfs


def seed_rag_docs(
    *,
    data_dir: Path = DEFAULT_DATA_DIR,
    dry_run: bool = False,
    only: str | None = None,
    limit: int | None = None,
    subtopic_id: int | None = None,
) -> None:
    pdfs = _collect_pdfs(data_dir, only)
    if limit is not None:
        pdfs = pdfs[:limit]

    if not pdfs:
        print(f"No se encontraron PDFs en {data_dir}")
        return

    print(f"Carpeta de datos: {data_dir}")
    print(f"PDFs encontrados: {len(pdfs)}")
    if dry_run:
        for path in pdfs:
            rel = path.relative_to(data_dir)
            meta = _metadata_for_file(rel)
            print(f"  [dry-run] {rel} -> {meta.get('content_type')} / {meta.get('canal', '-')}")
        return

    db = SessionLocal()
    rag = RAGService()
    resolved_subtopic = subtopic_id if subtopic_id is not None else _resolve_subtopic_id(db)
    if resolved_subtopic is None:
        print("Aviso: no hay subtema en BD. Ejecuta antes: python -m scripts.seed.seed_demo")
    else:
        print(f"subtopic_id para indexación: {resolved_subtopic}")

    ok = 0
    failed: list[tuple[str, str]] = []

    try:
        for index, path in enumerate(pdfs, start=1):
            rel = path.relative_to(data_dir)
            meta = _metadata_for_file(rel)
            if resolved_subtopic is not None:
                meta["subtopic_id"] = resolved_subtopic

            print(f"[{index}/{len(pdfs)}] {rel.name} …", end=" ", flush=True)
            try:
                result = rag.ingest_file(path, metadata=meta)
                print(f"OK ({result.chunks_indexed} fragmentos)")
                ok += 1
            except RAGError as exc:
                print(f"ERROR: {exc.message}")
                failed.append((str(rel), exc.message))
            except Exception as exc:
                print(f"ERROR: {exc}")
                failed.append((str(rel), str(exc)))
    finally:
        db.close()

    stats = rag.stats()
    print()
    print(f"Indexados: {ok}/{len(pdfs)} archivos")
    print(f"Fragmentos totales en ChromaDB: {stats['chunk_count']}")
    if failed:
        print(f"Fallidos ({len(failed)}):")
        for name, reason in failed:
            print(f"  - {name}: {reason}")


def main() -> None:
    parser = argparse.ArgumentParser(description="Indexar PDFs de docs/data en ChromaDB")
    parser.add_argument(
        "--data-dir",
        type=Path,
        default=DEFAULT_DATA_DIR,
        help="Ruta a docs/data (por defecto: pitagoras/docs/data)",
    )
    parser.add_argument("--dry-run", action="store_true", help="Solo listar archivos sin indexar")
    parser.add_argument(
        "--only",
        type=str,
        default=None,
        help="Prefijo de carpeta, ej. libros-matematica o examen-ordinario",
    )
    parser.add_argument("--limit", type=int, default=None, help="Máximo de PDFs a procesar")
    parser.add_argument("--subtopic-id", type=int, default=None, help="ID de subtema en metadata")
    args = parser.parse_args()

    try:
        seed_rag_docs(
            data_dir=args.data_dir.resolve(),
            dry_run=args.dry_run,
            only=args.only,
            limit=args.limit,
            subtopic_id=args.subtopic_id,
        )
    except FileNotFoundError as exc:
        print(exc, file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
