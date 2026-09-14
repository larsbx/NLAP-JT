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
    assert "def bigint_backend_blocks_proof_acceptance" in src


def test_dynamic_limb_phase_one_is_explicitly_incomplete():
    src = read(BIG)
    z = read(ROOT / "src" / "bigint_z.mojo")
    smoke = read(ROOT / "src" / "smoke_tests.mojo")
    assert "dynamic_limb_phase_one_backend_status" in src
    assert '"MojoDynamicLimbBigZPhaseOne"' in src
    assert "struct BigZ(Copyable)" in z
    assert "var limbs: List[UInt64]" in z
    for operation in ["bigz_add", "bigz_sub", "bigz_mul", "bigz_eq", "bigz_lt"]:
        assert f"def {operation}" in z
    assert "q7_square.limb(2) == 323" in z
    assert "not status.has_euclidean_gcd" in src
    assert "not status.has_exact_divisibility" in src
    assert "not status.has_canonical_serialization" in src
    assert "not status.allows_certificate_acceptance" in src
    assert "if not bigint_z_phase_one_smoke():" in smoke
    assert "if not bigint_adapter_phase_one_smoke():" in smoke


def test_dynamic_limb_phase_two_adds_division_and_gcd_but_stays_blocked():
    src = read(BIG)
    z = read(ROOT / "src" / "bigint_z.mojo")
    smoke = read(ROOT / "src" / "smoke_tests.mojo")
    assert "dynamic_limb_phase_two_backend_status" in src
    assert '"MojoDynamicLimbBigZPhaseTwo"' in src
    for operation in ["bigz_abs_divmod", "bigz_divmod", "bigz_div_exact", "bigz_gcd"]:
        assert f"def {operation}" in z
    assert "if division.rejected or not division.remainder.is_zero():" in z
    assert "bigz_divmod_identity_holds" in z
    assert "status.has_euclidean_gcd and status.has_exact_divisibility" in src
    assert "not status.has_canonical_serialization" in src
    assert "not status.allows_certificate_acceptance" in src
    assert "if not bigint_z_phase_two_smoke():" in smoke
    assert "if not bigint_adapter_phase_two_smoke():" in smoke


def test_dynamic_limb_bigz_adds_canonical_serialization_and_is_integer_ready():
    src = read(BIG)
    z = read(ROOT / "src" / "bigint_z.mojo")
    smoke = read(ROOT / "src" / "smoke_tests.mojo")
    assert "dynamic_limb_bigz_backend_status" in src
    assert '"MojoDynamicLimbBigZ"' in src
    for operation in ["bigz_is_canonical", "bigz_canonical_bytes", "canonical_bytes_equal"]:
        assert f"def {operation}" in z
    assert "byte_len >> UInt64(length_index * 8)" in z
    assert "negative.bytes[9] == 59" in z
    assert "def integer_backend_ready" in src
    assert "status.integer_backend_ready()" in src
    assert "not status.allows_certificate_acceptance" in src
    assert "not status.proof_ready()" in src
    assert "bigint_backend_blocks_proof_acceptance(status)" in src
    assert "if not bigint_z_phase_three_smoke():" in smoke
    assert "if not bigint_adapter_complete_smoke():" in smoke


def test_completed_integer_backend_cannot_enable_certificate_acceptance():
    src = read(BIG)
    complete = src.split("def dynamic_limb_bigz_backend_status()", 1)[1].split(
        "# Target adapter operations", 1
    )[0]
    assert '"MojoDynamicLimbBigZ"' in complete
    assert complete.count("True,") == 6
    assert complete.count("False,") == 1
    assert complete.rstrip().endswith("False,\n    )")


def test_rational_backend_requires_normalization_and_safe_order():
    src = read(RAT)
    assert "struct RationalBackendStatus" in src
    assert "normalized_after_every_operation" in src
    assert "denominator_strictly_positive" in src
    assert "equality_cross_multiply_safe" in src
    assert "order_cross_multiply_safe" in src
    assert "canonical_fraction_serialization" in src


def test_current_q_uses_bigz_but_blocks_proof_acceptance():
    src = read(RAT)
    assert "current_q_backend_status" in src
    assert "dynamic_limb_bigz_backend_status()" in src
    assert "q_backend_blocks_proof_acceptance" in src
    assert "acceptance flag remains false" in src
    assert "not status.backend.allows_certificate_acceptance" in src
    assert "q_backend_blocks_proof_acceptance(status)" in src
    smoke = read(ROOT / "src" / "smoke_tests.mojo")
    assert "if not q_backend_migration_smoke():" in smoke


def test_q_storage_is_normalized_bigz_and_fail_closed():
    src = read(ROOT / "src" / "rat_q.mojo")
    smoke = read(ROOT / "src" / "smoke_tests.mojo")
    assert "struct Q(Copyable)" in src
    assert "var num: BigZ" in src
    assert "var den: BigZ" in src
    assert "var rejected: Bool" in src
    assert "def q_normalize_bigz" in src
    assert "if d.is_zero():" in src
    assert "other.num.is_zero()" in src
    assert "var common = bigz_gcd(nn, dd)" in src
    assert "bigz_div_exact" in src
    assert "def q_canonical_bytes" in src
    assert "beyond_i64" in src
    assert "if not bigq_storage_smoke():" in smoke


def test_no_bad_numeric_or_analytic_shortcuts_in_backend_contracts():
    combined = (read(BIG) + "\n" + read(RAT)).lower()
    forbidden = ["float64", "math.", "cmath", "numpy", "atan(", "radian", "degree"]
    for token in forbidden:
        assert token not in combined
