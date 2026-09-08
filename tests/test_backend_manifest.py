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


def test_manifest_blocks_proof_grade_requirements_on_demo_backend():
    reqs = manifest()["requirements"]
    assert reqs["unbounded_storage"] is False
    assert reqs["euclidean_gcd"] is False
    assert reqs["exact_divisibility"] is False
    assert reqs["normalized_serialization"] is False
    assert reqs["canonical_hash_encoding"] is False


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
