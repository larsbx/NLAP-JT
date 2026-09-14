from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src" / "interval_orbit.mojo"


def text() -> str:
    return SRC.read_text(encoding="utf-8")


def test_interval_orbit_scaffold_exists():
    src = text()
    assert "struct OrbitEvalConfig" in src
    assert "struct IntervalOrbitStatus" in src
    assert "def forbidden_count" in src
    assert "def intended_pair" in src


def test_native_interval_recurrence_exists():
    src = text()
    assert "from interval_q import ComplexIQ, IQ, IQBoolResult" in src
    assert "def next_orbit_value" in src
    assert "return z.square().add(c_box)" in src
    assert "def build_interval_orbit_h3" in src
    assert "def build_interval_orbit_h6" in src
    assert "def collision_interval" in src
    assert "return b.sub(a)" in src
    assert "def excludes_zero" in src
    assert "if re_result.rejected or im_result.rejected:" in src
    assert "return IQBoolResult(re_result.value or im_result.value, False)" in src


def test_bigq_exact_type_replay_uses_shared_box_and_typed_failure():
    src = text()
    smoke = (ROOT / "src" / "smoke_tests.mojo").read_text(encoding="utf-8")
    assert "from krawczyk_witness import c_minus_2_box" in src
    assert "struct BigQExactTypeExclusionResult(Copyable)" in src
    assert "def bigq_p21_exact_type_exclusions(half_width_den_power: Int)" in src
    assert "c_minus_2_box(half_width_den_power)" in src
    assert "def arithmetic_replay_accepted(self) -> Bool:" in src
    assert "def ambiguous(self) -> Bool:" in src
    assert "var narrow_box = bigq_p21_exact_type_exclusions(80)" in src
    assert "if not bigq_exact_type_exclusion_replay_smoke():" in smoke


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
    assert "from krawczyk_witness import c_minus_2_box" in src
    assert "verify_exact_type_exclusions_h3(c_minus_2_box(8), 2, 1)" in src
    assert "def demo_native_c_minus_2_accepts" in src
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
