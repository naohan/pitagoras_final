"""Repara mojibake UTF-8 en scripts Python del backend."""

from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parent
MARKERS = ("Ã", "â€", "Â", "ðŸ")
DIRECT = {
    "IngenierÃ­a": "Ingeniería",
    "IngenierÃ­as": "Ingenierías",
    "AdmisiÃ³n": "Admisión",
    "DiagnÃ³stico": "Diagnóstico",
    "educaciÃ³n": "educación",
    "EducaciÃ³n": "Educación",
    "matemÃ¡tica": "matemática",
    "MatemÃ¡tica": "Matemática",
    "â€”": "—",
    "â€“": "–",
    "Ã¡": "á",
    "Ã©": "é",
    "Ã­": "í",
    "Ã³": "ó",
    "Ãº": "ú",
    "Ã±": "ñ",
    "Ã\x81": "Á",
    "Ã": "Á",
}


def repair(text: str) -> str:
    out = text
    for _ in range(3):
        for enc in ("cp1252", "latin-1"):
            try:
                cand = out.encode(enc).decode("utf-8")
            except (UnicodeEncodeError, UnicodeDecodeError):
                continue
            if cand != out:
                out = cand
                break
        else:
            break
    for bad, good in DIRECT.items():
        out = out.replace(bad, good)
    return out


def main() -> None:
    fixed = 0
    for path in ROOT.rglob("*.py"):
        if path.name == Path(__file__).name:
            continue
        raw = path.read_bytes()
        text = raw.decode("utf-8-sig")
        if not any(m in text for m in MARKERS):
            if raw.startswith(b"\xef\xbb\xbf"):
                path.write_bytes(text.encode("utf-8"))
                fixed += 1
            continue
        repaired = repair(text)
        if repaired != text or raw.startswith(b"\xef\xbb\xbf"):
            path.write_bytes(repaired.encode("utf-8"))
            fixed += 1
            print(f"fixed {path.relative_to(ROOT)}")
    print(f"TOTAL {fixed}")


if __name__ == "__main__":
    main()
