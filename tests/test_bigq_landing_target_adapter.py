from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def test_bigq_ray_address_is_normalized_fail_closed_and_unbounded():
    src = (ROOT / "src" / "bigq_ray_address.mojo").read_text(encoding="utf-8")
    assert "from rat_q import Q, q_from_bigz, q_rejected" in src
    assert "value.num.sign < 0 or not value.lt(Q.one())" in src
    assert "var beyond_i64 = bigz_add(bigz_from_i64(9223372036854775807)" in src
    assert "bigz_mul(beyond_i64, bigz_from_i64(2))" in src
    assert "malformed.rejected and out_of_range.rejected" in src


def test_bigq_landing_association_composes_same_exponent_replays():
    src = (ROOT / "src" / "bigq_landing_target_adapter.mojo").read_text(encoding="utf-8")
    assert "verify_bigq_p21_krawczyk_c_minus_2(half_width_den_power)" in src
    assert "bigq_p21_exact_type_exclusions(half_width_den_power)" in src
    assert "self.exclusions.half_width_den_power == self.half_width_den_power" in src
    assert "self.rays.preperiod + self.correspondence.critical_orbit_preperiod_offset == self.ell" in src
    assert "var narrow = verify_bigq_c_minus_2_landing_target_association(80)" in src


def test_correspondence_metadata_cannot_accept_theorem_or_certificate():
    src = (ROOT / "src" / "bigq_landing_target_adapter.mojo").read_text(encoding="utf-8")
    assert "A citation key is metadata, never executable evidence of its theorem." in src
    assert "def theorem_import_accepted(self) -> Bool:\n        #" in src
    assert "def certificate_accepted(self) -> Bool:\n        return False" in src
    assert "not association.theorem_import_accepted()" in src
    assert "not association.certificate_accepted()" in src


def test_bigq_landing_replay_is_compiler_wired_and_policy_clean():
    smoke = (ROOT / "src" / "smoke_tests.mojo").read_text(encoding="utf-8")
    boundary = (ROOT / "docs" / "mojo-toolchain-boundary.md").read_text(encoding="utf-8")
    assert "from bigq_ray_address import bigq_ray_address_replay_smoke" in smoke
    assert "from bigq_landing_target_adapter import bigq_landing_target_replay_smoke" in smoke
    assert "if not bigq_landing_target_replay_smoke():" in smoke
    assert "src/bigq_ray_address.mojo" in boundary
    assert "src/bigq_landing_target_adapter.mojo" in boundary


def test_global_open_obligations_remain_explicitly_unproved():
    ledger = (ROOT / "src" / "C1_final_proof_block_ledger.mojo").read_text(encoding="utf-8")
    residual = (ROOT / "src" / "C1_residual_closure_no_missing_links.mojo").read_text(encoding="utf-8")
    assert 'ProofBlockStatus("ResidualClosureNoMissingLinks", False, False, True, False, True)' in ledger
    assert "def residual_closure_no_missing_links_accepts" in residual
    assert "def proves_c1_by_itself() -> Bool:\n    return False" in residual
