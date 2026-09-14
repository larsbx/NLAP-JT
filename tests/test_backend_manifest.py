from pathlib import Path
import tomllib

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / "backend.toml"
AUDIT = ROOT / "tools" / "audit_backend_manifest.py"


def manifest():
    return tomllib.loads(MANIFEST.read_text(encoding="utf-8"))


def test_manifest_declares_demo_backend_not_proof_grade():
    data = manifest()
    assert data["backend"]["name"] == "Int64DemoBackend"
    assert data["backend"]["kind"] == "demo"
    assert data["backend"]["proof_grade"] is False
    assert data["policy"]["allow_demo_certificates"] is True
    assert data["policy"]["allow_proof_grade_certificates"] is False


def test_manifest_keeps_finite_regime_invariants_true():
    policy = manifest()["policy"]
    assert policy["no_analytic_trig"] is True
    assert policy["no_analytic_points"] is True
    assert policy["points_are_vertices_of_vertices"] is True
    assert policy["squarefree_localization_only"] is True
    assert policy["pointwise_exact_type_exclusion"] is True
    assert policy["no_float_certificate_arithmetic"] is True
    assert policy["exact_arithmetic_spec"] == "docs/rational-interval-arithmetic-spec.md"


def test_manifest_blocks_proof_grade_requirements_on_demo_backend():
    reqs = manifest()["requirements"]
    assert reqs["unbounded_storage"] is False
    assert reqs["exact_add_sub_mul"] is False
    assert reqs["euclidean_gcd"] is False
    assert reqs["exact_divisibility"] is False
    assert reqs["normalized_serialization"] is False
    assert reqs["canonical_hash_encoding"] is False


def test_checked_int64_transition_layer_is_compiler_wired():
    src = (ROOT / "src" / "checked_int64_backend.mojo").read_text(encoding="utf-8")
    smoke = (ROOT / "src" / "smoke_tests.mojo").read_text(encoding="utf-8")
    for operation in ["checked_add_i64", "checked_sub_i64", "checked_mul_i64", "checked_neg_i64"]:
        assert f"def {operation}" in src
    assert "denominator_is_valid_i64" in src
    assert "q8_growth_must_overflow_i64" in src
    assert "from checked_int64_backend import checked_i64_boundary_smoke" in smoke
    assert "if not checked_i64_boundary_smoke():" in smoke


def test_checked_rational_transition_layer_is_compiler_wired():
    src = (ROOT / "src" / "checked_q.mojo").read_text(encoding="utf-8")
    smoke = (ROOT / "src" / "smoke_tests.mojo").read_text(encoding="utf-8")
    for operation in ["checked_q_add", "checked_q_sub", "checked_q_mul", "checked_q_div", "checked_q_lt"]:
        assert f"def {operation}" in src
    assert "normalize_checked_q(1, 0).rejected" in src
    assert "from checked_q import checked_q_smoke" in smoke
    assert "if not checked_q_smoke():" in smoke


def test_checked_interval_transition_layer_is_compiler_wired():
    src = (ROOT / "src" / "checked_interval_q.mojo").read_text(encoding="utf-8")
    smoke = (ROOT / "src" / "smoke_tests.mojo").read_text(encoding="utf-8")
    for operation in ["checked_iq_add", "checked_iq_sub", "checked_iq_mul", "checked_iq_reciprocal", "checked_iq_sign"]:
        assert f"def {operation}" in src
    assert "if ordered.rejected or not ordered.value" in src
    assert "from checked_interval_q import checked_iq_smoke" in smoke
    assert "if not checked_iq_smoke():" in smoke


def test_checked_complex_horner_layer_is_compiler_wired():
    src = (ROOT / "src" / "checked_complex_interval.mojo").read_text(encoding="utf-8")
    smoke = (ROOT / "src" / "smoke_tests.mojo").read_text(encoding="utf-8")
    for operation in ["checked_complex_add", "checked_complex_mul", "eval_checked_poly_ascending_horner", "eval_checked_p21"]:
        assert f"def {operation}" in src
    assert "if acc.rejected:" in src
    assert "from checked_complex_interval import checked_complex_horner_smoke" in smoke
    assert "if not checked_complex_horner_smoke():" in smoke


def test_checked_krawczyk_layer_is_compiler_wired():
    src = (ROOT / "src" / "checked_krawczyk_witness.mojo").read_text(encoding="utf-8")
    smoke = (ROOT / "src" / "smoke_tests.mojo").read_text(encoding="utf-8")
    assert "struct CheckedKrawczykResult(ImplicitlyCopyable)" in src
    assert "if beta.rejected or image.rejected:" in src
    assert "invalid_radius.rejected" in src
    assert "overflow_radius.rejected" in src
    assert "from checked_krawczyk_witness import checked_krawczyk_smoke" in smoke
    assert "if not checked_krawczyk_smoke():" in smoke


def test_backend_manifest_audit_exists_and_checks_all_requirements():
    src = AUDIT.read_text(encoding="utf-8")
    for key in [
        "unbounded_storage",
        "exact_add_sub_mul",
        "exact_order",
        "euclidean_gcd",
        "exact_divisibility",
        "normalized_serialization",
        "canonical_hash_encoding",
    ]:
        assert key in src
    assert "demo backend cannot be proof_grade" in src
    assert "backend.proof_grade and policy.allow_proof_grade_certificates must change together" in src
