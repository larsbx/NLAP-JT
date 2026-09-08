#!/usr/bin/env python3
"""Audit core files for forbidden point-primitive language.

The finite-regime calculus does not treat ideal points as primitive. Core code may
use coordinate records, singleton boxes, dyadic boxes, symbolic ray addresses,
and localized root handles.

This audit intentionally focuses on executable source and tests. Prose docs may
explain the invariant and contrast it with classical point language.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CORE_PATHS = [ROOT / "src", ROOT / "tests"]

# Banned in source as type/function/API names. We allow ComplexIQ.point because
# interval_q.mojo still uses it as a singleton-box constructor; new code should
# prefer explicit singleton naming.
TOKEN_RE = re.compile(
    r"\b(?:Point|point_eval|eval_point|point_value|to_point_interval)\b|fn\s+point\s*\(",
)

ALLOW_LINES = {
    "return ComplexIQ.point(self.re, self.im)",
    "fn point(x: Q) -> IQ:",
    "fn point(re: Q, im: Q) -> ComplexIQ:",
}


def iter_files() -> list[Path]:
    files: list[Path] = []
    for base in CORE_PATHS:
        if not base.exists():
            continue
        for path in base.rglob("*"):
            if path.is_file() and path.suffix in {".mojo", ".py"}:
                files.append(path)
    return files


def main() -> int:
    violations: list[tuple[Path, int, str]] = []
    for path in iter_files():
        text = path.read_text(encoding="utf-8")
        for lineno, line in enumerate(text.splitlines(), start=1):
            stripped = line.strip()
            if stripped in ALLOW_LINES:
                continue
            if TOKEN_RE.search(line):
                violations.append((path.relative_to(ROOT), lineno, stripped))

    if violations:
        print("Forbidden point-primitive API language found in core files:\n")
        for path, lineno, line in violations:
            print(f"{path}:{lineno}: {line}")
        print("\nUse coordinate records, singleton boxes, dyadic boxes, or root handles instead.")
        return 1

    print("OK: no forbidden point-primitive API language found in core files.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
