#!/usr/bin/env python3
"""Audit core files for forbidden analytic trigonometry.

This is a guardrail for the finite-regime Mandelbrot project. Core source code
must use rational trigonometry: quadrance, spread, dot/cross determinants,
rational rotors, and Q/Z angle doubling. It must not call analytic trig APIs.

The audit is intentionally lexical and conservative. False positives should be
fixed by renaming or moving comparison material outside core paths.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CORE_PATHS = [ROOT / "src", ROOT / "docs"]
FORBIDDEN = [
    "sin",
    "cos",
    "tan",
    "asin",
    "acos",
    "atan",
    "sinh",
    "cosh",
    "tanh",
    "radian",
    "degree",
    "unit circle",
    "polar angle",
]

# Allow policy docs to mention forbidden terms while defining the ban.
ALLOWLIST = {
    ROOT / "docs" / "rational-trigonometry-policy.md",
}

TOKEN_RE = re.compile(
    r"\b(?:sin|cos|tan|asin|acos|atan|sinh|cosh|tanh|radian|degree)\b|unit circle|polar angle",
    re.IGNORECASE,
)


def iter_files() -> list[Path]:
    files: list[Path] = []
    for base in CORE_PATHS:
        if not base.exists():
            continue
        for path in base.rglob("*"):
            if path.is_file() and path.suffix in {".mojo", ".md", ".py"}:
                files.append(path)
    return files


def main() -> int:
    violations: list[tuple[Path, int, str]] = []
    for path in iter_files():
        if path in ALLOWLIST:
            continue
        text = path.read_text(encoding="utf-8")
        for lineno, line in enumerate(text.splitlines(), start=1):
            if TOKEN_RE.search(line):
                violations.append((path.relative_to(ROOT), lineno, line.strip()))

    if violations:
        print("Forbidden analytic trigonometry terms found in core files:\n")
        for path, lineno, line in violations:
            print(f"{path}:{lineno}: {line}")
        print("\nUse quadrance, spread, dot/cross determinants, rational rotors, or Q/Z doubling instead.")
        return 1

    print("OK: no forbidden analytic trigonometry terms found in audited core files.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
