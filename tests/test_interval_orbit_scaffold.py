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


def test_native_interval_recurrence_exists():
    src = text()
    assert "from interval_q import ComplexIQ, IQ" in src
    assert "fn next_orbit_value" in src
    assert "return z.square().add(c_box)" in src
    assert "fn build_interval_orbit_h3" in src
    assert "fn build_interval_orbit_h6" in src
    assert "fn collision_interval" in src
    assert "return b.sub(a)" in src
    assert "fn excludes_zero" in src
    assert "z.re.excludes_zero() or z.im.excludes_zero()" in src


def test_intended_pair_has_clean_semantics():
    src = text()
    assert "return i >= ell and ((j - i) % period == 0)" in src
    assert "j >= ell" not in src


def test_same_box_and_exact_endpoint_gate_present():
    src = text()
    assert "used_same_parameter_box" in src
    assert "used_exact_rational_endpoints" in src
    assert "excluded_forbidden_count == self.forbidden_count" in src


def test_c_minus_2_uses_native_interval_verifier():
    src = text()
    assert "fn c_minus_2_box" in src
    assert "verify_exact_type_exclusions_h3(c_minus_2_box(), 2, 1)" in src
    assert "fn demo_native_c_minus_2_accepts" in src
    assert "return demo_c_minus_2_status().accepted()" in src


def test_m41_is_still_marked_placeholder_not_proof():
    src = text()
    assert "Placeholder until a certificate-ready dyadic M_4,1 box" in src
    assert "contract check, not as a completed proof witness" in src


def test_demo_counts_preserved():
    src = text()
    assert "IntervalOrbitStatus(True, True, True, 18" in src
    assert "forbidden_count(ell, period, horizon)" in src


def test_no_forbidden_runtime_shortcuts_in_interval_orbit():
    src = text().lower()
    forbidden = ["float64", "math.", "cmath", "numpy", "atan", "radian", "degree"]
    for token in forbidden:
        assert token not in src
