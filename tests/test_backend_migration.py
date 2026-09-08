from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BIG = ROOT / "src" / "bigint_adapter.mojo"
RAT = ROOT / "src" / "rat_backend_plan.mojo"


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def test_bigint_adapter_requires_unbounded_and_canonical_backend():
    src = read(BIG)
    assert "struct BigIntBackendStatus" in src
    assert "has_unbounded_storage" in src
    assert "has_canonical_serialization" in src
    assert "allows_certificate_acceptance" in src
    assert "self.has_unbounded_storage" in src
    assert "self.allows_certificate_acceptance" in src


def test_int64_demo_backend_is_not_proof_ready():
    src = read(BIG)
    assert '"Int64DemoBackend"' in src
    assert "False," in src
    assert "fn bigint_backend_blocks_proof_acceptance" in src


def test_rational_backend_requires_normalization_and_safe_order():
    src = read(RAT)
    assert "struct RationalBackendStatus" in src
    assert "normalized_after_every_operation" in src
    assert "denominator_strictly_positive" in src
    assert "equality_cross_multiply_safe" in src
    assert "order_cross_multiply_safe" in src
    assert "canonical_fraction_serialization" in src


def test_current_q_backend_blocks_proof_acceptance():
    src = read(RAT)
    assert "current_q_backend_status" in src
    assert "int64_demo_backend_status()" in src
    assert "q_backend_blocks_proof_acceptance" in src
    assert "Int64 implementation must not be proof-grade" in src


def test_no_bad_numeric_or_analytic_shortcuts_in_backend_contracts():
    combined = (read(BIG) + "\n" + read(RAT)).lower()
    forbidden = ["float64", "math.", "cmath", "numpy", "atan(", "radian", "degree"]
    for token in forbidden:
        assert token not in combined
