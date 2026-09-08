from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
KRAW = ROOT / "src" / "krawczyk_witness.mojo"
JOINT = ROOT / "src" / "joint_certificate.mojo"


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def test_krawczyk_scaffold_has_required_policies():
    src = read(KRAW)
    assert "struct KrawczykWitnessStatus" in src
    assert "fn p21_value" in src
    assert "fn p21_derivative" in src
    assert "fn p21_krawczyk_image" in src
    assert "fn verify_p21_krawczyk_c_minus_2" in src
    assert "fn demo_krawczyk_p21_c_minus_2" in src
    assert "fn demo_krawczyk_p41_m41_placeholder" in src
    assert "placeholder-only" in src


def test_p21_polynomial_derivative_and_inverse_preserved():
    src = read(KRAW)
    assert "P21(C)=C(C+2)" in src
    assert "dP21(C)=2C+2" in src
    assert "complex_minus_half" in src
    assert "Q(-1, 2)" in src


def test_p21_demo_is_computed_not_status_asserted():
    src = read(KRAW)
    demo_start = src.index("fn demo_krawczyk_p21_c_minus_2")
    demo_src = src[demo_start:src.index("fn f7_name")]
    assert "verify_p21_krawczyk_c_minus_2(8)" in demo_src
    assert "var ok" in demo_src
    assert "KrawczykWitnessStatus(\"P_2_1\", True, True, True, ok" in demo_src
    assert "KrawczykWitnessStatus(\"P_2_1\", True, True, True, True" not in demo_src


def test_krawczyk_formula_is_present():
    src = read(KRAW)
    assert "K(beta)=m-A P(m)+(1-A P'(beta))(beta-m)" in src
    assert "one_minus_a_dp" in src
    assert "beta_minus_m" in src
    assert "image.strict_subset_of(beta)" in src


def test_p41_remains_not_accepted_until_interval_eval_lands():
    src = read(KRAW)
    assert "P_4_1" in src
    assert "False, \"beta_m41_pending\"" in src
    assert "P_4_1=C(C+2)(C^3+2C^2+2C+2)F7" in src


def test_joint_certificate_requires_both_halves_and_tags():
    src = read(JOINT)
    assert "struct JointCertificateStatus" in src
    assert "self.krawczyk.accepted()" in src
    assert "self.exclusions.accepted()" in src
    assert "self.theorem_tags.accepted()" in src
    assert "self.angle_kneading_match" in src
    assert "self.box_names_match" in src


def test_joint_certificate_rejects_bad_paths():
    src = read(JOINT)
    assert "fn must_reject_krawczyk_without_exclusions" in src
    assert "fn must_reject_exclusions_without_krawczyk" in src
    assert "fn must_reject_box_mismatch" in src
    assert "return not status.accepted()" in src


def test_no_forbidden_shortcuts_in_new_scaffolds():
    combined = (read(KRAW) + "\n" + read(JOINT)).lower()
    forbidden = ["float64", "math.", "cmath", "numpy", "atan", "radian", "degree"]
    for token in forbidden:
        assert token not in combined
