#!/usr/bin/env python3
"""Audit mathematical terminology governance.

This is not a theorem checker. It enforces repository hygiene:

- risky bridge/isomorphism language must be governed;
- novel bridge terms must include genealogy and leak discipline;
- rank-2 files must not introduce circle/locus primitives;
- a project terminology registry and use manifest must exist;
- deprecated C1 bridge terminology must not be used for new claims.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SCAN_ROOTS = [ROOT / "docs", ROOT / "src", ROOT / "tests"]
REGISTRY = ROOT / "docs" / "terminology-registry.md"
USE_MANIFEST = ROOT / "docs" / "terminology-use-manifest.md"

DECLARATION_RE = re.compile(r"Terminology declaration:\s*(?P<term>.+)")
REQUIRED_DECLARATION_FIELDS = [
    "Terminology declaration:",
    "Genealogy:",
    "Bridge claim:",
    "Known leaks:",
    "Use discipline:",
]

RISKY_PHRASES = [
    "obvious isomorphism",
    "canonical analogy",
    "essentially the same",
    "same as",
    "just a",
    "nothing but",
    "isomorphic to",
    "equivalent to",
    "corresponds exactly",
    "proof by analogy",
]

NEGATING_CONTEXT = [
    "not ",
    "no ",
    "without ",
    "unless ",
    "forbidden",
    "disallow",
    "reject",
    "blocked",
    "must not",
    "cannot",
    "does not",
    "is not",
]

MIGRATION_CONTEXT = [
    "deprecated",
    "legacy",
    "replaces",
    "rather than",
    "migration",
    "old term",
]

RANK2_FILES = [
    ROOT / "docs" / "rank2-coordinate-substrate.md",
    ROOT / "src" / "rank2_operator.mojo",
]

RANK2_BANNED_LOCI = [
    "unit circle",
    "circle object",
    "circle primitive",
    "disk object",
    "arc object",
    "circumference",
    "analytic locus",
]

REGISTRY_REQUIRED_TERMS = [
    "PointVertex",
    "rank-2 coordinate record",
    "finite rational-ray nest",
    "SeparatorCatalogueAdequacy",
    "persistent non-separation",
    "persistent wake ambiguity",
    "Mojo theorem kernel",
]

C1_SCOPED_TERMS = [
    "finite rational-ray nest",
    "persistent non-separation",
    "persistent wake ambiguity",
    "wake ambiguity",
    "SeparatorCatalogueAdequacy",
    "SeparatorCatalogueSoundness",
    "SeparatorCatalogueCompleteness",
    "side-assignment witness",
    "separator code",
]

DEPRECATED_TERMS = [
    "catalogue extensionality",
]

C1_SCOPED_PREFIXES = (
    "docs/C1_",
    "src/C1_",
    "tests/test_C1_",
)

ALLOWLIST = {
    "docs/terminology-governance.md",
    "docs/terminology-registry.md",
    "docs/terminology-use-manifest.md",
    "tests/test_terminology_governance.py",
    "tests/test_terminology_registry.py",
    "tests/test_terminology_use_manifest.py",
}


def iter_files():
    for root in SCAN_ROOTS:
        if not root.exists():
            continue
        for path in root.rglob("*"):
            if path.is_file() and path.suffix in {".md", ".mojo", ".py"}:
                yield path


def rel(path: Path) -> str:
    return path.relative_to(ROOT).as_posix()


def has_full_declaration(text: str) -> bool:
    if not DECLARATION_RE.search(text):
        return False
    return all(field in text for field in REQUIRED_DECLARATION_FIELDS)


def has_context(text: str, index: int, markers: list[str]) -> bool:
    window = text[max(0, index - 140): index + 140].lower()
    return any(marker in window for marker in markers)


def is_negated_context(text: str, index: int) -> bool:
    return has_context(text, index, NEGATING_CONTEXT)


def is_migration_context(text: str, index: int) -> bool:
    return has_context(text, index, MIGRATION_CONTEXT)


def audit_registry(errors: list[str]) -> None:
    if not REGISTRY.exists():
        errors.append("docs/terminology-registry.md: required terminology registry is missing")
        return
    text = REGISTRY.read_text(encoding="utf-8")
    if "## Established field terms" not in text:
        errors.append("docs/terminology-registry.md: missing established field terms section")
    if "## Project terms with declarations" not in text:
        errors.append("docs/terminology-registry.md: missing project declaration section")
    if "## Deprecated project terms" not in text:
        errors.append("docs/terminology-registry.md: missing deprecated project terms section")
    for term in REGISTRY_REQUIRED_TERMS:
        if term not in text:
            errors.append(f"docs/terminology-registry.md: missing governed term {term!r}")
    declarations = DECLARATION_RE.findall(text)
    if len(declarations) < len(REGISTRY_REQUIRED_TERMS):
        errors.append("docs/terminology-registry.md: too few terminology declarations")
    if not has_full_declaration(text):
        errors.append("docs/terminology-registry.md: declaration blocks must include genealogy, bridge claim, known leaks, and use discipline")


def audit_use_manifest(errors: list[str]) -> None:
    if not USE_MANIFEST.exists():
        errors.append("docs/terminology-use-manifest.md: required terminology use manifest is missing")
        return
    text = USE_MANIFEST.read_text(encoding="utf-8")
    required_sections = [
        "## Registered project terms currently allowed",
        "## Terms requiring local declaration outside C1 files",
        "## Terms requiring theorem-tag status",
        "## High-risk bridge phrases",
        "## Circle/rank-2 ban",
    ]
    for section in required_sections:
        if section not in text:
            errors.append(f"docs/terminology-use-manifest.md: missing section {section!r}")
    for term in C1_SCOPED_TERMS:
        if term not in text:
            errors.append(f"docs/terminology-use-manifest.md: missing scoped term {term!r}")
    if "catalogue extensionality" in text and "deprecated" not in text.lower():
        errors.append("docs/terminology-use-manifest.md: legacy catalogue extensionality must be marked deprecated")


def audit_declarations(path: Path, text: str, errors: list[str]) -> None:
    if "Terminology declaration:" not in text:
        return
    missing = [field for field in REQUIRED_DECLARATION_FIELDS if field not in text]
    if missing:
        errors.append(
            f"{rel(path)}: terminology declaration missing fields: {', '.join(missing)}"
        )


def audit_risky_phrases(path: Path, text: str, errors: list[str]) -> None:
    rp = rel(path)
    if rp in ALLOWLIST:
        return
    lower = text.lower()
    governed = has_full_declaration(text)
    for phrase in RISKY_PHRASES:
        start = 0
        while True:
            idx = lower.find(phrase, start)
            if idx == -1:
                break
            if not governed and not is_negated_context(lower, idx):
                errors.append(
                    f"{rp}: risky phrase '{phrase}' requires terminology declaration with genealogy and leaks"
                )
            start = idx + len(phrase)


def audit_deprecated_terms(path: Path, text: str, errors: list[str]) -> None:
    rp = rel(path)
    lower = text.lower()
    for term in DEPRECATED_TERMS:
        start = 0
        while True:
            idx = lower.find(term, start)
            if idx == -1:
                break
            if not is_migration_context(lower, idx):
                errors.append(
                    f"{rp}: deprecated term '{term}' requires migration/deprecation context; use SeparatorCatalogueAdequacy/Soundness/Completeness"
                )
            start = idx + len(term)


def audit_c1_scoped_terms(path: Path, text: str, errors: list[str]) -> None:
    rp = rel(path)
    if rp in ALLOWLIST or rp.startswith(C1_SCOPED_PREFIXES):
        return
    lower = text.lower()
    governed = has_full_declaration(text) or "docs/terminology-registry.md" in text
    for term in C1_SCOPED_TERMS:
        idx = lower.find(term.lower())
        if idx == -1:
            continue
        if not governed and not is_negated_context(lower, idx):
            errors.append(
                f"{rp}: C1-scoped term '{term}' requires local declaration or registry pointer outside C1 files"
            )


def audit_rank2_loci(errors: list[str]) -> None:
    for path in RANK2_FILES:
        if not path.exists():
            continue
        text = path.read_text(encoding="utf-8").lower()
        rp = rel(path)
        for phrase in RANK2_BANNED_LOCI:
            idx = text.find(phrase)
            if idx == -1:
                continue
            if rp == "docs/rank2-coordinate-substrate.md" and is_negated_context(text, idx):
                continue
            errors.append(f"{rp}: rank-2 locus phrase '{phrase}' is not allowed")


def main() -> int:
    errors: list[str] = []
    audit_registry(errors)
    audit_use_manifest(errors)
    for path in iter_files():
        text = path.read_text(encoding="utf-8")
        audit_declarations(path, text, errors)
        audit_risky_phrases(path, text, errors)
        audit_deprecated_terms(path, text, errors)
        audit_c1_scoped_terms(path, text, errors)
    audit_rank2_loci(errors)

    if errors:
        print("Terminology governance audit failed:")
        for error in errors:
            print(f"- {error}")
        return 1
    print("Terminology governance audit passed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
