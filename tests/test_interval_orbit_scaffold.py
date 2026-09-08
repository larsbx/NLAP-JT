from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src" / "interval_orbit.mojo"


def text() -> str:
    return SRC.read_text(encoding="utf-8")


def test_interval_orbit_scaffold_exists():
    src = text()
    assert "struct OrbitEvalConfig" in src
    assert "struct IntervalOrbitStatus" in src
    assert "fn forbidden_count" in src
    assert "fn intended_pair" in src


def test_intended_pair_has_clean_semantics():
    src = text()
    assert "return i >= ell and ((j - i) % period == 0)" in src
    assert "j >= ell" not in src


def test_same_box_and_exact_endpoint_gate_present():
    src = text()
    assert "used_same_parameter_box" in src
    assert "used_exact_rational_endpoints" in src
    assert "excluded_forbidden_count == self.forbidden_count" in src


def test_demo_counts_preserved():
    src = text()
    assert "IntervalOrbitStatus(True, True, True, 5" in src
    assert "IntervalOrbitStatus(True, True, True, 18" in src


def test_no_forbidden_runtime_shortcuts_in_interval_orbit():
    src = text().lower()
    forbidden = ["float64", "math.", "cmath", "numpy", "atan", "radian", "degree"]
    for token in forbidden:
        assert token not in src
