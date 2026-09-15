#!/usr/bin/env python3
"""Audit the exact-arithmetic hook (docs/rational-interval-arithmetic-spec.md).

Three checks, all lexical and CI-cheap:

1. the binding file exists and carries every required section heading
   (the specification proper is larsbx/finite_exact:docs/rational-interval-arithmetic-spec.md);
2. every arithmetic module is named in this repository's binding table (spec
   section 6), exists, cites the specification by path (criterion C7), and is
   listed in the allowlist exactly when its class is QUARANTINED;
3. no floating-point type or literal appears in executable kernel code
   outside the allowlist (criterion C1).
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from source_tokens import mask_comments_and_strings  # noqa: E402

ROOT = Path(__file__).resolve().parents[1]
SPEC_REL = "docs/rational-interval-arithmetic-spec.md"
SPEC = ROOT / SPEC_REL
ALLOWLIST = ROOT / "tools" / "exact_arithmetic_allowlist.md"
SCAN_ROOTS = [ROOT / "src"]
BINDING_HEADING = "### 6.2 `larsbx/NLAP-JT`"

# Sections 0 to 5 of the specification live upstream in larsbx/finite_exact;
# this repository keeps the pointer, its binding table, and the hook.
REQUIRED_SECTIONS = [
    "## 0. Where the specification lives",
    "## 6. Repository binding",
    "### 6.2 `larsbx/NLAP-JT`",
    "## 7. Hook: how the specification is enforced",
]

FLOAT_RE = re.compile(
    r"\b(?:Float16|Float32|Float64|BFloat16|FloatLiteral|Float|float)\b"
    r"|(?<![\w.])(?:"
    r"(?:\d(?:_?\d)*\.(?:\d(?:_?\d)*)?|\.\d(?:_?\d)*)"
    r"(?:[eE][+-]?\d(?:_?\d)*)?"
    r"|\d(?:_?\d)*[eE][+-]?\d(?:_?\d)*"
    r")(?![\w.])"
)
PATH_RE = re.compile(r"`([\w./-]+\.(?:mojo|py))`")
ARITHMETIC_IMPORT_RE = re.compile(r"^from\s+(?:finite_exact\.rat_q|interval_q\.closed_q)\s+import\b", re.MULTILINE)


def _section(text: str, heading: str) -> str:
    start = text.index(heading) + len(heading)
    rest = text[start:]
    match = re.search(r"^#{2,3} ", rest, flags=re.MULTILINE)
    return rest if match is None else rest[: match.start()]


def binding_rows(text: str | None = None) -> list[tuple[str, list[str]]]:
    """Return ``(class, [module paths])`` for each row of this repo's table."""
    body = text if text is not None else SPEC.read_text(encoding="utf-8")
    rows: list[tuple[str, list[str]]] = []
    for line in _section(body, BINDING_HEADING).splitlines():
        cells = [c.strip() for c in line.strip().strip("|").split("|")]
        if len(cells) < 3 or cells[0] in {"Spec item", "---"} or set(cells[0]) <= {"-"}:
            continue
        paths = PATH_RE.findall(cells[1])
        if paths:
            rows.append((cells[2], paths))
    return rows


def allowlisted() -> set[str]:
    if not ALLOWLIST.exists():
        return set()
    return set(PATH_RE.findall(ALLOWLIST.read_text(encoding="utf-8")))


def kernel_files() -> list[Path]:
    files: list[Path] = []
    for base in SCAN_ROOTS:
        for path in sorted(base.rglob("*.mojo")):
            if not any(part.startswith(".") for part in path.relative_to(ROOT).parts):
                files.append(path)
    return files


def arithmetic_consumers() -> set[str]:
    """Return source modules that directly instantiate the Q/IQ layers."""
    return {
        path.relative_to(ROOT).as_posix()
        for path in kernel_files()
        if ARITHMETIC_IMPORT_RE.search(path.read_text(encoding="utf-8"))
    }


def audit() -> list[str]:
    errors: list[str] = []
    if not SPEC.exists():
        return [f"missing specification {SPEC_REL}"]
    spec = SPEC.read_text(encoding="utf-8")
    errors += [f"spec lacks section {s!r}" for s in REQUIRED_SECTIONS if s not in spec]
    if errors:
        return errors

    allow = allowlisted()
    quarantined: set[str] = set()
    bound: set[str] = set()
    for cls, paths in binding_rows(spec):
        for rel in paths:
            bound.add(rel)
            path = ROOT / rel
            if not path.exists():
                errors.append(f"binding row names missing file {rel}")
                continue
            if cls == "QUARANTINED":
                quarantined.add(rel)
            if SPEC_REL not in path.read_text(encoding="utf-8"):
                errors.append(f"{rel} does not cite {SPEC_REL} (C7)")
    errors += [
        f"arithmetic consumer lacks binding row: {rel}"
        for rel in sorted(arithmetic_consumers() - bound)
    ]
    errors += [f"{rel} is QUARANTINED but not allowlisted" for rel in sorted(quarantined - allow)]
    errors += [f"{rel} is allowlisted but not a QUARANTINED binding row" for rel in sorted(allow - quarantined)]

    for path in kernel_files():
        rel = path.relative_to(ROOT).as_posix()
        if rel in allow:
            continue
        masked = mask_comments_and_strings(path.read_text(encoding="utf-8"))
        for lineno, line in enumerate(masked.splitlines(), start=1):
            if FLOAT_RE.search(line):
                errors.append(f"{rel}:{lineno}: floating point in kernel scope (C1): {line.strip()}")
    return list(dict.fromkeys(errors))


def main() -> int:
    errors = audit()
    if errors:
        print("Exact arithmetic audit failed:\n")
        for err in errors:
            print(f"- {err}")
        print(f"\nSee {SPEC_REL}, sections 5 to 7.")
        return 1
    print("OK: exact-arithmetic hook intact; no floating point in kernel scope.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
