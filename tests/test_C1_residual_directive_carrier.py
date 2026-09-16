"""The residual-class carrier is a directive prefix of DGP tuning patterns
computed from periodic rational ray addresses (docs/C1_residual_directive_carrier.md).

The oracle below is an independent Python model of the kneading letters, the
DGP twist, and the star product of docs/tuning-substitutions-spec.md in
larsbx/finite-math-kernels. It pins the constants that
src/C1_residual_directive_carrier.mojo asserts in residual_directive_carrier_smoke.
"""

from __future__ import annotations

import re
import tomllib
from fractions import Fraction
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DOC = ROOT / "docs" / "C1_residual_directive_carrier.md"
SRC = ROOT / "src" / "C1_residual_directive_carrier.mojo"
LEDGER_DOC = ROOT / "docs" / "C1_theorem_tag_import_ledger.md"
SMOKE = ROOT / "src" / "smoke_tests.mojo"
VENDORED = ROOT / "vendored.toml"
MERGE_COMMIT = "007e40f679f3b9be86dade148b3bf08c518de74a"


def text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


# --- independent oracle -----------------------------------------------------------


def period(theta: Fraction, cap: int) -> int:
    x = theta
    for p in range(1, cap + 1):
        x = (2 * x) % 1
        if x == theta:
            return p
    return 0


def kneading_letters(theta: Fraction, cap: int = 16) -> tuple[int, ...] | None:
    p = period(theta, cap)
    if p < 2:
        return None
    lo, hi = theta / 2, (theta + 1) / 2
    letters, x = [], theta
    for _ in range(p - 1):
        if lo < x < hi:
            letters.append(1)
        elif x < lo or x > hi:
            letters.append(0)
        else:
            return None
        x = (2 * x) % 1
    return tuple(letters) if x in (lo, hi) else None


def dgp(prefix: tuple[int, ...]) -> tuple[tuple[int, ...], bool]:
    return prefix, sum(prefix) % 2 == 1


def substitution(pattern):
    prefix, twist = pattern
    return tuple(prefix + (s ^ int(twist),) for s in (0, 1))


def star(a, b):
    images = substitution(a)
    return tuple(x for letter in b[0] for x in images[letter]) + a[0], a[1] != b[1]


def address(num: int, den: int) -> Fraction:
    return Fraction(num, den)


# --- pinned values --------------------------------------------------------------------


def test_oracle_pins_the_kneading_letters_asserted_by_the_mojo_smoke():
    assert kneading_letters(address(1, 3)) == (1,)
    assert kneading_letters(address(2, 5)) == (1, 0, 1)
    assert kneading_letters(address(3, 7)) == (1, 0)
    assert kneading_letters(address(7, 15)) == (1, 0, 0)
    assert kneading_letters(address(1, 7)) == (1, 1)
    assert kneading_letters(address(1, 2)) is None
    assert kneading_letters(address(0, 1)) is None
    assert kneading_letters(address(7, 15), cap=3) is None


def test_oracle_star_square_of_period_doubling_is_the_two_fifths_pattern():
    pd = dgp(kneading_letters(address(1, 3)))
    assert pd == ((1,), True)
    assert substitution(pd) == ((1, 1), (1, 0))
    assert star(pd, pd) == dgp(kneading_letters(address(2, 5))) == ((1, 0, 1), False)
    assert substitution(star(pd, pd)) == ((1, 0, 1, 0), (1, 0, 1, 1))
    assert star(star(pd, pd), pd)[0] == (1, 0, 1, 1, 1, 0, 1)


def test_oracle_kneading_letters_always_start_with_one_and_have_period_minus_one_letters():
    for den in range(3, 64, 2):
        for num in range(1, den):
            theta = address(num, den)
            letters = kneading_letters(theta, cap=64)
            p = period(theta, 64)
            if p >= 2:
                assert letters is not None and letters[0] == 1 and len(letters) == p - 1


def test_mojo_smoke_pins_the_same_constants():
    src = text(SRC)
    assert "ray_addr_from_i64(1, 3)" in src and "ray_addr_from_i64(2, 5)" in src
    assert "ray_addr_from_i64(3, 7)" in src and "ray_addr_from_i64(7, 15)" in src
    assert "var r: List[Int] = [1]" in src
    assert "var rlr: List[Int] = [1, 0, 1]" in src
    assert "var rl: List[Int] = [1, 0]" in src
    assert "var rll: List[Int] = [1, 0, 0]" in src
    assert "var cascade_three: List[Int] = [1, 0, 1, 1, 1, 0, 1]" in src
    assert "composite.image(0)[3] == 0 and composite.image(1)[3] == 1" in src


# --- structure ----------------------------------------------------------------------------


def test_carrier_is_fed_by_the_exact_ray_address_kernel_and_the_vendored_tuning_kernels():
    src = text(SRC)
    assert "from bigq_ray_address import BigQRayAddr, bigq_double_ray_addr, make_bigq_ray_addr" in src
    assert "from substitution_dynamics.tuning import TuningPattern, dgp_twist, kneading_prefix, star_product" in src
    assert "from substitution_dynamics.sadic import directive_composite" in src
    assert "struct ResidualDirectiveCarrier(Copyable, Movable)" in src
    assert "var patterns: List[TuningPattern]" in src
    for symbol in [
        "def kneading_letters(address: BigQRayAddr, cap: Int) -> KneadingLetters",
        "def directive_carrier_extend(",
        "def same_directive_prefix(",
        "def strict_directive_refinement(",
        "TuningPattern.dgp(letters.letters)",
    ]:
        assert symbol in src
    assert "Float" not in src


def test_rejections_fail_closed_and_nothing_is_proved():
    src = text(SRC)
    assert "def rejected_kneading_letters()" in src
    assert "def rejected_directive_carrier()" in src
    for non_claim in [
        "def directive_prefix_proves_same_fiber() -> Bool:\n    return False",
        "def directive_prefix_proves_c1() -> Bool:\n    return False",
        "def directive_prefix_supplies_apriori_bounds() -> Bool:\n    return False",
    ]:
        assert non_claim in src
    assert "kneading_letters(ray_addr_from_i64(1, 2), cap).rejected" in src
    assert "kneading_letters(ray_addr_from_i64(0, 1), cap).rejected" in src


def test_theorem_tag_instance_binds_the_tuning_source_and_stays_inadmissible():
    src = text(SRC)
    assert "struct KneadingTuningInstance(Copyable, Movable)" in src
    assert '"DouadyHubbardTuning"' in src
    assert '"kneading sequences of real quadratic parameters under tuning"' in src
    assert "var real_slice_convention_declared: Bool" in src
    assert "var classification_proof_attached: Bool" in src
    assert "self.pattern.pattern.twist == dgp_twist(self.pattern.pattern.prefix)" in src
    assert "instance.source_scope_checked() and not instance.final_import_admissible()" in src
    ledger = text(LEDGER_DOC)
    assert "KneadingFormOfTuning" in ledger and "src/C1_residual_directive_carrier.mojo" in ledger


def test_smoke_closure_runs_the_carrier():
    smoke = text(SMOKE)
    assert "from C1_residual_directive_carrier import residual_directive_carrier_smoke" in smoke
    assert "if not residual_directive_carrier_smoke():" in smoke
    assert "def residual_directive_carrier_smoke() -> Bool:" in text(SRC)


def test_document_declares_the_term_with_genealogy_and_leaks():
    body = text(DOC)
    assert body.splitlines()[2].startswith("Status:")
    assert "Terminology declaration: residual-class directive carrier" in body
    for field in ["Genealogy:", "Bridge claim:", "Known leaks:", "Use discipline:"]:
        assert field in body
    assert "a priori bounds" in body
    assert "real-slice convention" in body
    assert "## Non-claims" in body


def test_regime_correspondence_binds_the_carrier_symbols():
    spec = tomllib.loads(text(ROOT / "spec" / "regime_correspondences.toml"))
    entry = next(e for e in spec["correspondence"] if e["id"] == "residual-directive-prefix")
    assert entry["class"] == "symbolic_encoding" and entry["status"] == "theorem_dependent"
    assert set(entry["symbols"]) == {
        "src/C1_residual_directive_carrier.mojo::kneading_letters",
        "src/C1_residual_directive_carrier.mojo::ResidualDirectiveCarrier",
    }
    assert text(SRC).count("# Regime correspondence: residual-directive-prefix") == 2


def test_substitution_dynamics_is_vendored_at_the_finite_math_kernels_merge_commit():
    manifest = tomllib.loads(text(VENDORED))
    packages = {p["name"]: p for p in manifest["package"]}
    assert set(packages) == {"finite_exact", "claim_governance", "substitution_dynamics"}
    for pkg in packages.values():
        assert pkg["repository"] == "larsbx/finite-math-kernels"
        assert pkg["commit"] == MERGE_COMMIT
    files = packages["substitution_dynamics"]["files"]
    assert {"substitution_dynamics/tuning.mojo", "substitution_dynamics/sadic.mojo", "substitution_dynamics/substitution.mojo"} <= set(files)
    assert all(re.fullmatch(r"[0-9a-f]{64}", digest) for digest in files.values())
