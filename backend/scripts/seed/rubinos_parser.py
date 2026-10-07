"""Parsea preguntas del banco Rubiños / matematicasn (HTML)."""

from __future__ import annotations

import html as html_module
import re
from dataclasses import dataclass, field
from pathlib import Path
from urllib.error import URLError
from urllib.request import Request, urlopen

from scripts.seed.seed_academic import classify_subtopic_key

USER_AGENT = "PitagorasBot/1.0 (+educational seed)"

SECTION_MARKERS = {
    "ingenierias": ("EVALUACIÃ“N INGENIERÃAS", ("CLAVES-RESPUESTAS DE INGENIERÃAS", "EVALUACIÃ“N SOCIALES")),
    "biomedicas": ("EVALUACIÃ“N BIOMÃ‰DICAS", ("EVALUACIÃ“N INGENIERÃAS", "CLAVES – RESPUESTAS")),
    "sociales": ("EVALUACIÃ“N SOCIALES", ("CLAVES-RESPUESTAS DE SOCIALES", "Publicidad")),
}


@dataclass
class ParsedQuestion:
    number: int
    stem: str
    options: list[tuple[str, str]]
    correct_label: str
    subtopic_key: str
    explanation: str
    section: str = "general"
    metadata: dict = field(default_factory=dict)


def strip_html(raw: str) -> str:
    text = re.sub(r"(?is)<script[^>]*>.*?</script>", " ", raw)
    text = re.sub(r"(?is)<style[^>]*>.*?</style>", " ", text)
    text = re.sub(r"(?is)<br\s*/?>", "\n", text)
    text = re.sub(r"(?is)</p>", "\n\n", text)
    text = re.sub(r"<[^>]+>", " ", text)
    text = html_module.unescape(text)
    text = re.sub(r"[ \t]+", " ", text)
    text = re.sub(r"\n{3,}", "\n\n", text)
    return text.strip()


def fetch_html(url: str, timeout: int = 60) -> str:
    request = Request(url, headers={"User-Agent": USER_AGENT})
    with urlopen(request, timeout=timeout) as response:
        charset = response.headers.get_content_charset() or "utf-8"
        return response.read().decode(charset, errors="replace")


def load_html_source(*, url: str | None, file_path: str | None) -> str:
    if file_path:
        return Path(file_path).read_text(encoding="utf-8", errors="replace")
    if url:
        return fetch_html(url)
    raise ValueError("Indica --url o --file")


NON_MATH_KEYWORDS = (
    "interculturalidad",
    "discriminatorio",
    "conductista",
    "watson",
    "mitosis",
    "fisiología respiratoria",
    "eritropoyetina",
    "psicología",
    "biología",
    "metaprendizaje",
    "metacognición",
    "constitucional",
    "habeas",
    "tubo neural",
    "pavlov",
    "vigotsky",
    "andamiaje",
    "mediación",
    "conciliación",
    "agentes económicos",
    "movimientos tectónicos",
    "literatura",
    "filosofía",
)


def parse_answer_key(text: str) -> dict[int, str]:
    """Extrae claves tipo 1)A 2) D 3) A del bloque CLAVES."""
    clean = re.sub(r"\*+", " ", text)
    answers: dict[int, str] = {}
    for match in re.finditer(r"(\d+)\s*\)\s*([A-Ea-e])", clean):
        answers[int(match.group(1))] = match.group(2).upper()
    return answers


def extract_section_text(full_text: str, start_marker: str, end_markers: tuple[str, ...]) -> str:
    start = re.search(re.escape(start_marker), full_text, re.IGNORECASE)
    if not start:
        return ""
    begin = start.end()
    end = len(full_text)
    for marker in end_markers:
        found = re.search(re.escape(marker), full_text[begin:], re.IGNORECASE)
        if found:
            end = min(end, begin + found.start())
    return full_text[begin:end].strip()


def extract_section_answer_key(full_text: str, section: str) -> dict[int, str]:
    if section == "ingenierias":
        match = re.search(
            r"CLAVES-RESPUESTAS DE INGENIERÃAS\s*:?(.*?)(?=EVALUACIÃ“N SOCIALES|\Z)",
            full_text,
            re.IGNORECASE | re.DOTALL,
        )
        if match:
            return parse_answer_key(match.group(1))
    if section == "biomedicas":
        block = extract_section_text(
            full_text,
            "CLAVES – RESPUESTAS",
            ("EVALUACIÃ“N BIOMÃ‰DICAS",),
        )
        if block:
            return parse_answer_key(block)
    return {}


def _normalize_stem(raw: str) -> str:
    stem = re.sub(r"\s+", " ", raw).strip()
    stem = re.sub(r"^\*+\s*", "", stem)
    stem = re.sub(r"^:\s*", "", stem)
    stem = re.sub(r"^\*\*\s*", "", stem)
    stem = re.sub(r"^_+\s*", "", stem)
    stem = re.sub(r"_+\s*$", "", stem)
    return stem.strip()


def _is_math_relevant(stem: str) -> bool:
    lower = stem.lower()
    return not any(keyword in lower for keyword in NON_MATH_KEYWORDS)


def _should_skip(stem: str) -> bool:
    lower = stem.lower()
    if len(stem) < 12:
        return True
    if not _is_math_relevant(stem):
        return True
    skip_phrases = (
        "en la figura",
        "la figura,",
        "la figura muestra",
        "qué figura completa",
        "complete el cuadro",
        "calcule la velocidad a los (b+4a+3)",
        "los datos obtenidos se muestran en la gráfica",
        "halle n de:",
        "dada la función\n\n f(n)",
    )
    return any(phrase in lower for phrase in skip_phrases)


def _split_question_blocks(section_text: str) -> list[tuple[int, str]]:
    patterns = [
        r"(?i)\*\*_PREGUNTA\s+(\d+)_\*\*",
        r"(?i)\*\*PREGUNTA\s+(\d+)\*\*\s*\*\*:\s*\*\*",
        r"(?i)\*\*PREGUNTA\s+(\d+)\*\*",
        r"(?i)PREGUNTA\s+(\d+)\s*:",
    ]
    for pattern in patterns:
        parts = re.split(pattern, section_text)
        if len(parts) >= 3:
            blocks: list[tuple[int, str]] = []
            i = 1
            while i < len(parts) - 1:
                try:
                    number = int(parts[i].strip())
                except ValueError:
                    i += 2
                    continue
                blocks.append((number, parts[i + 1]))
                i += 2
            if blocks:
                return blocks
    return []


def _extract_options(body: str) -> tuple[str, list[tuple[str, str]]]:
    rpta_match = re.search(r'Rpta\.\s*:\s*"([A-E])"', body, re.IGNORECASE)
    before = body[: rpta_match.start()] if rpta_match else body

    option_matches = list(
        re.finditer(
            r"(?:^|\n)\s*([A-E])\)\s*(.+?)(?=\n\s*[A-E]\)|\n\n|\Z)",
            before,
            re.DOTALL,
        )
    )
    if len(option_matches) < 4:
        option_matches = list(
            re.finditer(r"([A-E])\)\s*([^\n]+)", before)
        )

    if len(option_matches) < 4:
        return _normalize_stem(before), []

    first_option = option_matches[0]
    stem = _normalize_stem(before[: first_option.start()])

    options: list[tuple[str, str]] = []
    seen: set[str] = set()
    for match in option_matches:
        label = match.group(1).upper()
        if label in seen:
            continue
        text = re.sub(r"\s+", " ", match.group(2)).strip()
        if text:
            options.append((label, text))
            seen.add(label)

    return stem, options


def _parse_question_block(
    number: int,
    body: str,
    *,
    answer_key: dict[int, str],
    section: str,
    source_label: str,
) -> ParsedQuestion | None:
    rpta_match = re.search(r'Rpta\.\s*:\s*"([A-E])"', body, re.IGNORECASE)
    correct_label = rpta_match.group(1).upper() if rpta_match else answer_key.get(number)
    if not correct_label:
        return None

    stem, options = _extract_options(body)
    if _should_skip(stem) or len(options) < 4:
        return None

    labels = {label for label, _ in options}
    if correct_label not in labels:
        return None

    subtopic_key = classify_subtopic_key(stem)
    correct_text = next(text for label, text in options if label == correct_label)
    explanation = (
        f"Respuesta correcta: {correct_label} ({correct_text}). "
        f"Fuente: {source_label}. Sección: {section}. "
        f"Tema: {subtopic_key.replace('_', ' ')}."
    )

    return ParsedQuestion(
        number=number,
        stem=stem,
        options=options,
        correct_label=correct_label,
        subtopic_key=subtopic_key,
        explanation=explanation,
        section=section,
        metadata={"source": source_label, "question_number": number},
    )


def parse_section_questions(
    full_text: str,
    section: str,
    *,
    limit: int | None = None,
) -> list[ParsedQuestion]:
    if section not in SECTION_MARKERS:
        raise ValueError(f"Sección desconocida: {section}")

    start_marker, end_markers = SECTION_MARKERS[section]
    section_text = extract_section_text(full_text, start_marker, end_markers)
    if not section_text:
        return []

    answer_key = extract_section_answer_key(full_text, section)
    parsed: list[ParsedQuestion] = []
    for number, body in _split_question_blocks(section_text):
        item = _parse_question_block(
            number,
            body,
            answer_key=answer_key,
            section=section,
            source_label="UNSA solucionario Rubiños",
        )
        if item is None:
            continue
        parsed.append(item)
        if limit is not None and len(parsed) >= limit:
            break
    return parsed


def parse_rubinos_questions(
    raw_html: str,
    *,
    limit: int | None = None,
    section: str | None = None,
) -> list[ParsedQuestion]:
    text = strip_html(raw_html)

    if section and section != "legacy":
        return parse_section_questions(text, section, limit=limit)

    # Formato antiguo (página de funciones con Rpta inline)
    blocks = re.split(r"(?i)\*\*PREGUNTA\s+(\d+)\*\*", text)
    if len(blocks) < 2:
        blocks = re.split(r"(?i)PREGUNTA\s+(\d+)\s*:", text)

    parsed: list[ParsedQuestion] = []
    i = 1
    while i < len(blocks) - 1:
        try:
            number = int(blocks[i].strip())
        except ValueError:
            i += 2
            continue
        body = blocks[i + 1]
        i += 2
        item = _parse_question_block(
            number,
            body,
            answer_key={},
            section="legacy",
            source_label="Rubiños funciones",
        )
        if item is None:
            continue
        parsed.append(item)
        if limit is not None and len(parsed) >= limit:
            break
    return parsed


def load_parsed_questions(
    *,
    url: str | None = None,
    file_path: str | None = None,
    limit: int | None = None,
    section: str | None = None,
) -> list[ParsedQuestion]:
    try:
        raw = load_html_source(url=url, file_path=file_path)
    except URLError as exc:
        raise RuntimeError(f"No se pudo descargar la URL: {exc}") from exc
    return parse_rubinos_questions(raw, limit=limit, section=section)
