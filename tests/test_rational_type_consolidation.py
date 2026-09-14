from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_q_is_the_only_rational_arithmetic_value_type():
    canonical = (ROOT / "src" / "rat_q.mojo").read_text(encoding="utf-8")
    geometry = (ROOT / "src" / "rational_trig.mojo").read_text(encoding="utf-8")
    witnesses = (ROOT / "src" / "cert_types.mojo").read_text(encoding="utf-8")

    assert "struct Q(" in canonical
    assert "from rat_q import Q" in geometry
    assert "struct Rat" not in geometry
    assert "struct Rat" not in witnesses


def test_rational_geometry_uses_normalized_equality():
    geometry = (ROOT / "src" / "rational_trig.mojo").read_text(encoding="utf-8")
    assert "lhs.eq(Q.one())" in geometry
    assert "lhs.num == lhs.den" not in geometry
