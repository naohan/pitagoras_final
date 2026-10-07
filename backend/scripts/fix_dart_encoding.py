"""Repara mojibake UTF-8 en archivos Dart (BOM + doble encoding PowerShell/cp1252)."""

from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[2] / "frontend" / "lib"

# Reemplazos explícitos de los casos más comunes tras Set-Content PowerShell.
DIRECT = {
    "Ã\x81rea": "Área",
    "Área": "Área",
    "á": "á",
    "é": "é",
    "í": "í",
    "ó": "ó",
    "ú": "ú",
    "ñ": "ñ",
    "ÃÁ": "Á",
    "Ã‰": "É",
    "Ã“": "Ó",
    "Ãš": "Ú",
    "Â·": "·",
    "Â ": " ",
    "—": "—",
    "–": "–",
    "â€œ": "“",
    "â€\x9d": "”",
    "â€˜": "‘",
    "â€™": "’",
    "â€¦": "…",
    "âš\xa0ï¸\x8f": "⚠️",
    "âš\xa0": "⚠",
    "âš ï¸": "⚠️",
    "âš ": "⚠",
    "Evaluación": "Evaluación",
    "Diagnóstico": "Diagnóstico",
    "diagnóstico": "diagnóstico",
}


def repair_text(text: str) -> str:
    repaired = text
    for _ in range(3):
        for enc in ("cp1252", "latin-1"):
            try:
                candidate = repaired.encode(enc).decode("utf-8")
            except (UnicodeEncodeError, UnicodeDecodeError):
                continue
            if candidate != repaired:
                repaired = candidate
                break
        else:
            break
    for bad, good in DIRECT.items():
        repaired = repaired.replace(bad, good)
    return repaired


def main() -> None:
    fixed = 0
    for path in ROOT.rglob("*.dart"):
        raw = path.read_bytes()
        text = raw.decode("utf-8-sig")
        repaired = repair_text(text)
        if repaired == text and not raw.startswith(b"\xef\xbb\xbf"):
            continue
        path.write_bytes(repaired.encode("utf-8"))
        fixed += 1
        print(f"fixed {path.relative_to(ROOT.parent)}")
    print(f"TOTAL {fixed}")


if __name__ == "__main__":
    main()
