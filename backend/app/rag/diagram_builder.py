"""Construye diagramas jerárquicos desde fragmentos RAG (sin LLM)."""

from __future__ import annotations

import re
from dataclasses import dataclass, field

_BULLET_RE = re.compile(r"^[-•*]\s+(.+)$")
_NUMBERED_RE = re.compile(r"^\d+[\.\)]\s+(.+)$")
_HEADING_RE = re.compile(r"^#{1,3}\s+(.+)$")


@dataclass
class MaterialDiagramNode:
    id: str
    label: str
    children: list[MaterialDiagramNode] = field(default_factory=list)


def build_material_diagram(*, title: str, chunks: list[str]) -> list[MaterialDiagramNode]:
    """Extrae secciones y viñetas del texto indexado."""
    root_label = (title or "Material de estudio").strip()[:120]
    sections: list[MaterialDiagramNode] = []
    current: MaterialDiagramNode | None = None
    fallback_items: list[str] = []

    def _append_item(label: str) -> None:
        clean = _clean_label(label)
        if not clean:
            return
        target = current if current is not None else None
        if target is None:
            fallback_items.append(clean)
            return
        child_id = f"{target.id}_{len(target.children)}"
        target.children.append(MaterialDiagramNode(id=child_id, label=clean))

    for chunk in chunks:
        for raw_line in chunk.splitlines():
            line = raw_line.strip()
            if len(line) < 3:
                continue

            heading = _HEADING_RE.match(line)
            if heading:
                section = MaterialDiagramNode(
                    id=f"sec_{len(sections)}",
                    label=_clean_label(heading.group(1)),
                )
                sections.append(section)
                current = section
                continue

            if line.endswith(":") and len(line) <= 100 and not _NUMBERED_RE.match(line):
                section = MaterialDiagramNode(
                    id=f"sec_{len(sections)}",
                    label=_clean_label(line[:-1]),
                )
                sections.append(section)
                current = section
                continue

            bullet = _BULLET_RE.match(line) or _NUMBERED_RE.match(line)
            if bullet:
                _append_item(bullet.group(1))
                continue

            if line.isupper() and 4 < len(line) < 80:
                section = MaterialDiagramNode(
                    id=f"sec_{len(sections)}",
                    label=_clean_label(line.title()),
                )
                sections.append(section)
                current = section
                continue

            if len(line) > 20 and line.endswith("."):
                fallback_items.append(_clean_label(line))

    if sections:
        populated = [s for s in sections if s.children or s.label]
        if populated:
            return [
                MaterialDiagramNode(
                    id="root",
                    label=root_label,
                    children=populated,
                )
            ]

    if fallback_items:
        unique = _dedupe(fallback_items[:12])
        return [
            MaterialDiagramNode(
                id="root",
                label=root_label,
                children=[
                    MaterialDiagramNode(id=f"item_{i}", label=item)
                    for i, item in enumerate(unique)
                ],
            )
        ]

    return []


def _clean_label(text: str) -> str:
    cleaned = re.sub(r"\s+", " ", text).strip()
    if len(cleaned) > 140:
        return f"{cleaned[:137]}..."
    return cleaned


def _dedupe(items: list[str]) -> list[str]:
    seen: set[str] = set()
    result: list[str] = []
    for item in items:
        key = item.lower()
        if key in seen:
            continue
        seen.add(key)
        result.append(item)
    return result
