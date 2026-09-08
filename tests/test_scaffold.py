#!/usr/bin/env python3
"""Repository scaffold checks.

These are lightweight source checks until Mojo execution is wired into CI.
They enforce the design invariant and verify that the expected demo entrypoints
exist in the staged Mojo files.
"""

from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def read(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def test_no_forbidden_trig_tokens_in_src() -> None:
    import re

    token_re = re.compile(
        r"\b(?:sin|cos|tan|asin|acos|atan|sinh|cosh|tanh|radian|degree)\b|unit circle|polar angle",
        re.IGNORECASE,
    )
    violations = []
    for path in (ROOT / "src").rglob("*.mojo"):
        for lineno, line in enumerate(path.read_text(encoding="utf-8").splitlines(), start=1):
            if token_re.search(line):
                violations.append(f"{path.relative_to(ROOT)}:{lineno}: {line.strip()}")
    assert not violations, "Forbidden trig tokens found:\n" + "\n".join(violations)


def test_rational_arithmetic_demo_entrypoints_exist() -> None:
    text = read("src/rat_q.mojo")
    assert "fn demo_q_normalization()" in text
    assert "fn demo_q_order()" in text


def test_interval_demo_entrypoints_exist() -> None:
    text = read("src/interval_q.mojo")
    assert "fn demo_interval_mul()" in text
    assert "fn demo_complex_quadrance_point()" in text


def test_ray_address_not_angle_api() -> None:
    text = read("src/rational_trig.mojo")
    assert "struct RayAddr" in text
    assert "double_ray_addr" in text
    assert "RatAngle" not in text
    assert "double_angle" not in text
