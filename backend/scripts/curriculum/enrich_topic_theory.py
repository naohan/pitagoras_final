"""Enriquece theory_text de cada subtema con desarrollo detallado.

Combina el marco pedagógico local del catálogo CNEB con el contenido íntegro
de uno o varios artículos de Wikipedia en español (introducción + secciones
relevantes), y guarda el resultado en formato markdown ligero que la app
renderiza en el panel de teoría.

Uso (desde backend/):
    python -m scripts.migrate.migrate_subtopic_theory
    python -m scripts.seed.seed_cneb_secondary
    python -m scripts.curriculum.enrich_topic_theory                # todos los subtemas
    python -m scripts.curriculum.enrich_topic_theory --only-missing # solo los incompletos
    python -m scripts.curriculum.enrich_topic_theory --refresh      # ignora la caché
"""

from __future__ import annotations

import argparse
import json
import re
import time
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path
from typing import Any

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.database.session import SessionLocal
from app.models.academic import Area, Component, Subtopic, Topic
from scripts.curriculum.cneb_catalog import CNEB_FULL_CATALOG, EXCLUDED_AREA_NAMES
from scripts.curriculum.cneb_extra_topics import EXTRA_TEACHING_TOPICS
from scripts.curriculum.wiki_titles import WIKI_TITLES

WIKI_API = "https://es.wikipedia.org/w/api.php"
USER_AGENT = (
    "PitagorasBot/2.0 (proyecto educativo escolar; contacto: soporte@pitagoras.local)"
)
CACHE_PATH = Path(__file__).resolve().parents[1] / "data" / "wiki_cache.json"

REQUEST_TIMEOUT = 60
REQUEST_RETRIES = 3
RETRY_BACKOFF = 4.0

# Secciones de Wikipedia sin valor pedagógico para el panel de teoría.
SKIP_SECTIONS = {
    "véase también",
    "referencias",
    "bibliografía",
    "enlaces externos",
    "notas",
    "notas y referencias",
    "fuentes",
    "galería",
    "galería de imágenes",
    "citas",
    "obras",
    "filmografía",
    "discografía",
    "premios",
    "anexos",
}

MAX_INTRO_CHARS = 2200
MAX_SECTION_CHARS = 1100
MAX_SECTIONS_PER_ARTICLE = 5
MIN_SECTION_CHARS = 160

_HEADING_RE = re.compile(r"^(={2,6})\s*(.+?)\s*\1\s*$", re.MULTILINE)


# ------------------------------------------------------------------- matemática


def _latex_to_text(tex: str) -> str:
    """Convierte una fórmula LaTeX en una aproximación legible en texto plano."""
    text = re.sub(r"\}\s*$", "", tex.strip())
    text = text.replace("\\displaystyle", "")
    text = re.sub(r"\\frac\s*\{([^{}]*)\}\s*\{([^{}]*)\}", r"(\1)/(\2)", text)
    text = re.sub(r"\\sqrt\s*\{([^{}]*)\}", r"âˆš(\1)", text)
    text = re.sub(r"\\(cdot|times)\b", "Â·", text)
    text = re.sub(r"\\(leq|le)\b", "â‰¤", text)
    text = re.sub(r"\\(geq|ge)\b", "â‰¥", text)
    text = re.sub(r"\\neq\b", "â‰ ", text)
    text = re.sub(r"\\pm\b", "Â±", text)
    text = re.sub(r"\\[a-zA-Z]+", " ", text)
    text = text.replace("{", "").replace("}", "").replace("\\", "")
    text = re.sub(r"\s+", " ", text)
    return text.strip()


def _is_math_noise(line: str) -> bool:
    """Las fórmulas llegan como líneas sangradas con un símbolo por renglón."""
    return not line.strip() or (line[:1].isspace() and len(line.strip()) <= 40)


def _clean_math(text: str) -> str:
    """Colapsa los bloques `{\\displaystyle ...}` de Wikipedia en texto inline."""
    lines = text.split("\n")
    output: list[str] = []
    index = 0
    while index < len(lines):
        line = lines[index]
        if "{\\displaystyle" not in line:
            output.append(line)
            index += 1
            continue

        end = index
        chunk = line
        while chunk.count("{") > chunk.count("}") and end + 1 < len(lines):
            end += 1
            chunk = f"{chunk} {lines[end]}"
        match = re.search(r"\{\\displaystyle(.*)", chunk, re.DOTALL)
        formula = _latex_to_text(match.group(1)) if match else ""

        removed = 0
        while output and _is_math_noise(output[-1]) and removed < 400:
            output.pop()
            removed += 1

        if output and output[-1].strip():
            output[-1] = f"{output[-1].rstrip()} {formula}".rstrip()
        elif formula:
            output.append(formula)

        index = end + 1
        while index < len(lines) and _is_math_noise(lines[index]):
            index += 1

    cleaned = "\n".join(output)
    return re.sub(r"[ \t]{2,}", " ", cleaned)


# --------------------------------------------------------------------------- red


def _load_cache() -> dict[str, Any]:
    if not CACHE_PATH.exists():
        return {}
    try:
        return json.loads(CACHE_PATH.read_text(encoding="utf-8"))
    except Exception:
        return {}


def _save_cache(cache: dict[str, Any]) -> None:
    CACHE_PATH.parent.mkdir(parents=True, exist_ok=True)
    CACHE_PATH.write_text(
        json.dumps(cache, ensure_ascii=False, indent=1), encoding="utf-8"
    )


def _api_get(params: dict[str, Any]) -> dict[str, Any] | None:
    url = f"{WIKI_API}?{urllib.parse.urlencode(params)}"
    request = urllib.request.Request(
        url, headers={"User-Agent": USER_AGENT, "Accept": "application/json"}
    )
    for attempt in range(1, REQUEST_RETRIES + 1):
        try:
            with urllib.request.urlopen(request, timeout=REQUEST_TIMEOUT) as response:
                return json.loads(response.read().decode("utf-8", errors="replace"))
        except urllib.error.HTTPError as exc:
            if exc.code in (429, 503) and attempt < REQUEST_RETRIES:
                time.sleep(RETRY_BACKOFF * attempt)
                continue
            print(f"    ! HTTP {exc.code} {exc.reason}", flush=True)
            return None
        except Exception as exc:  # timeout, DNS, reset...
            if attempt < REQUEST_RETRIES:
                time.sleep(RETRY_BACKOFF * attempt)
                continue
            print(f"    ! {type(exc).__name__}: {exc}", flush=True)
            return None
    return None


def _fetch_article(title: str) -> dict[str, str] | None:
    """Devuelve {'title', 'url', 'text'} con el artículo completo en texto plano."""
    data = _api_get(
        {
            "action": "query",
            "prop": "extracts|info",
            "explaintext": 1,
            "redirects": 1,
            "titles": title,
            "inprop": "url",
            "format": "json",
            "formatversion": 2,
            "utf8": 1,
        }
    )
    if not data:
        return None
    pages = data.get("query", {}).get("pages", [])
    for page in pages:
        if page.get("missing"):
            continue
        text = (page.get("extract") or "").strip()
        if len(text) < 200:
            continue
        if "puede referirse a" in text[:400] or "puede hacer referencia a" in text[:400]:
            continue  # página de desambiguación
        return {
            "title": page.get("title") or title,
            "url": page.get("fullurl") or "",
            "text": _clean_math(text),
        }
    return None


def _search_title(query: str) -> str | None:
    data = _api_get(
        {
            "action": "query",
            "list": "search",
            "srsearch": query,
            "srlimit": 3,
            "format": "json",
            "formatversion": 2,
            "utf8": 1,
        }
    )
    if not data:
        return None
    for hit in data.get("query", {}).get("search", []):
        title = hit.get("title") or ""
        if title and "(desambiguación)" not in title:
            return title
    return None


# ------------------------------------------------------------------ composición


def _trim(text: str, limit: int) -> str:
    text = re.sub(r"\n{3,}", "\n\n", text.strip())
    if len(text) <= limit:
        return text
    cut = text[:limit]
    end = max(cut.rfind(". "), cut.rfind(".\n"))
    return (cut[: end + 1] if end > limit * 0.5 else cut.rstrip()) + " [â€¦]"


def _split_sections(text: str) -> tuple[str, list[tuple[str, str]]]:
    matches = list(_HEADING_RE.finditer(text))
    if not matches:
        return text.strip(), []

    intro = text[: matches[0].start()].strip()
    sections: list[tuple[str, str]] = []
    for index, match in enumerate(matches):
        level = len(match.group(1))
        title = match.group(2).strip()
        end = matches[index + 1].start() if index + 1 < len(matches) else len(text)
        body = text[match.end() : end].strip()
        if level > 2:
            continue
        if title.lower() in SKIP_SECTIONS:
            continue
        if len(body) < MIN_SECTION_CHARS:
            continue
        sections.append((title, body))
    return intro, sections


def _article_block(article: dict[str, str]) -> list[str]:
    intro, sections = _split_sections(article["text"])
    lines = [f"### {article['title']}", ""]
    if intro:
        lines += [_trim(intro, MAX_INTRO_CHARS), ""]
    for title, body in sections[:MAX_SECTIONS_PER_ARTICLE]:
        lines += [f"**{title}**", "", _trim(body, MAX_SECTION_CHARS), ""]
    return lines


def _compose_theory(
    *,
    area: str,
    course: str,
    topic: str,
    subtopic: str,
    base_theory: str,
    articles: list[dict[str, str]],
) -> str:
    lines: list[str] = [
        f"# {subtopic}",
        "",
        f"**Área CNEB:** {area}",
        f"**Curso:** {course}",
        f"**Unidad:** {topic}",
        "",
        "## 1. Marco para aprender",
        "",
        base_theory.strip()
        or (
            f"{subtopic} forma parte de {topic} dentro del curso de {course}. "
            "Empieza por comprender el concepto, luego practica con ejemplos "
            "guiados y termina resolviendo ejercicios de examen."
        ),
        "",
        "## 2. Desarrollo detallado",
        "",
    ]

    if articles:
        lines += [
            "Explicación ampliada a partir de artículos enciclopédicos públicos "
            "(Wikipedia en español), organizada para estudio escolar.",
            "",
        ]
        for article in articles:
            lines += _article_block(article)
    else:
        lines += [
            "No se encontró un artículo enciclopédico suficientemente específico "
            "para este título. Apóyate en el marco de la sección 1, en tu texto "
            "escolar y en los ejercicios que resuelvas con el tutor.",
            "",
        ]

    lines += [
        "## 3. Qué debes dominar",
        "",
        "- Explicar el concepto con tus propias palabras, sin leer.",
        "- Resolver 3 ejemplos guiados y 3 ejercicios de forma independiente.",
        "- Reconocer los errores frecuentes y cómo evitarlos.",
        "- Conectar el tema con una situación cotidiana o de examen de admisión.",
        "",
        "## 4. Fuentes",
        "",
        "- Currículo Nacional de la Educación Básica (MINEDU): competencias del área.",
        "- Programa Curricular de Educación Secundaria (MINEDU).",
    ]
    for article in articles:
        if article.get("url"):
            lines.append(f"- Wikipedia (ES) — {article['title']}: {article['url']}")
    lines.append(
        "- Contrasta siempre con tu texto escolar y con tu docente: las fuentes "
        "abiertas pueden tener matices o quedar desactualizadas."
    )
    return "\n".join(lines).strip() + "\n"


# ------------------------------------------------------------------------ datos


def _base_theories() -> dict[str, str]:
    theories: dict[str, str] = {}
    for node in list(CNEB_FULL_CATALOG) + list(EXTRA_TEACHING_TOPICS):
        if node.subtopic_name not in theories and node.theory:
            theories[node.subtopic_name] = node.theory
    return theories


def _subtopic_index(db: Session) -> dict[str, tuple[str, str, str, list[Subtopic]]]:
    rows = db.execute(
        select(Area.name, Component.name, Topic.name, Subtopic)
        .join(Component, Component.area_id == Area.id)
        .join(Topic, Topic.component_id == Component.id)
        .join(Subtopic, Subtopic.topic_id == Topic.id)
    ).all()

    index: dict[str, tuple[str, str, str, list[Subtopic]]] = {}
    for area_name, course_name, topic_name, subtopic in rows:
        if area_name in EXCLUDED_AREA_NAMES:
            continue
        entry = index.get(subtopic.name)
        if entry is None:
            index[subtopic.name] = (area_name, course_name, topic_name, [subtopic])
        else:
            entry[3].append(subtopic)
    return index


def _is_complete(theory: str | None) -> bool:
    if not theory:
        return False
    text = theory.strip()
    return len(text) >= 2500 and (
        "wikipedia.org" in text or "## 2. Desarrollo detallado" in text
    )


# -------------------------------------------------------------------- ejecución


def enrich(
    *, sleep_s: float = 0.4, only_missing: bool = False, refresh: bool = False
) -> None:
    cache: dict[str, Any] = {} if refresh else _load_cache()
    db = SessionLocal()
    try:
        index = _subtopic_index(db)
        if not index:
            print("No hay subtemas. Corre scripts.seed.seed_cneb_secondary primero.")
            return

        base_theories = _base_theories()
        names = sorted(index)
        if only_missing:
            names = [
                name
                for name in names
                if not all(_is_complete(s.theory_text) for s in index[name][3])
            ]

        print(f"Subtemas a procesar: {len(names)}", flush=True)
        updated_rows = 0
        with_articles = 0

        for position, name in enumerate(names, start=1):
            area_name, course_name, topic_name, subtopics = index[name]
            print(f"[{position}/{len(names)}] {course_name} / {name}", flush=True)

            titles = list(WIKI_TITLES.get(name, []))
            articles: list[dict[str, str]] = []
            for title in titles:
                cached = cache.get(title, "__absent__")
                if cached == "__absent__":
                    article = _fetch_article(title)
                    cache[title] = article
                    time.sleep(sleep_s)
                else:
                    article = cached
                if article:
                    articles.append(article)

            if not articles:
                query = f"{name} {course_name}" if course_name else name
                found = _search_title(query) or _search_title(name)
                time.sleep(sleep_s)
                if found:
                    cached = cache.get(found, "__absent__")
                    article = (
                        _fetch_article(found) if cached == "__absent__" else cached
                    )
                    if cached == "__absent__":
                        cache[found] = article
                        time.sleep(sleep_s)
                    if article:
                        articles.append(article)

            if articles:
                with_articles += 1
                print(
                    "    + " + ", ".join(a["title"] for a in articles),
                    flush=True,
                )
            else:
                print("    - sin artículo", flush=True)

            theory = _compose_theory(
                area=area_name,
                course=course_name,
                topic=topic_name,
                subtopic=name,
                base_theory=base_theories.get(name, ""),
                articles=articles,
            )
            for subtopic in subtopics:
                subtopic.theory_text = theory
                updated_rows += 1

            if position % 10 == 0:
                db.commit()
                _save_cache(cache)
                print(f"    checkpoint: {updated_rows} filas", flush=True)

        db.commit()
        _save_cache(cache)
        print(
            f"Listo. Filas actualizadas: {updated_rows}. "
            f"Subtemas con artículo: {with_articles}/{len(names)}",
            flush=True,
        )
    except Exception:
        db.rollback()
        _save_cache(cache)
        raise
    finally:
        db.close()


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--only-missing", action="store_true")
    parser.add_argument("--refresh", action="store_true")
    parser.add_argument("--sleep", type=float, default=0.4)
    args = parser.parse_args()
    enrich(sleep_s=args.sleep, only_missing=args.only_missing, refresh=args.refresh)


if __name__ == "__main__":
    main()
