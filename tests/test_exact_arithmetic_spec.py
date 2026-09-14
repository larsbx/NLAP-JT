"""Regressions for the exact-arithmetic hook.

Specification: docs/rational-interval-arithmetic-spec.md. The first group checks
that every wire of the hook (section 7) is present; the second executes the
spec's laws against the secondary Python oracle over ``fractions.Fraction``.
"""

from fractions import Fraction
from pathlib import Path
import subprocess
import sys
import tomllib

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))

from audit_exact_arithmetic import (  # noqa: E402
    ALLOWLIST,
    REQUIRED_SECTIONS,
    SPEC,
    SPEC_REL,
    allowlisted,
    arithmetic_consumers,
    audit,
    binding_rows,
)
from interval_exclusion_reference import I  # noqa: E402


def text(rel: str) -> str:
    return (ROOT / rel).read_text(encoding="utf-8")


# --- section 7: hook wiring -------------------------------------------------


def test_spec_exists_with_required_sections():
    body = SPEC.read_text(encoding="utf-8")
    assert all(section in body for section in REQUIRED_SECTIONS)
    assert "authoritative only for NLAP-JT" in body
    assert "is mirrored byte-for-byte" not in body


def test_audit_passes_on_current_tree():
    assert audit() == []


def test_audit_script_is_executable_and_green():
    result = subprocess.run(
        [sys.executable, str(ROOT / "tools" / "audit_exact_arithmetic.py")],
        capture_output=True,
        text=True,
        check=False,
    )
    assert result.returncode == 0, result.stdout + result.stderr


def test_binding_table_covers_the_kernels_and_quarantines_floats():
    rows = binding_rows()
    by_class = {}
    for cls, paths in rows:
        by_class.setdefault(cls, set()).update(paths)
    assert {"src/rat_q.mojo", "src/interval_q.mojo", "src/poly_interval_eval.mojo"} <= by_class["DEMO"]
    assert "src/complex_box.mojo" in by_class["QUARANTINED"]
    assert by_class["QUARANTINED"] == allowlisted()
    assert ALLOWLIST.exists()
    assert arithmetic_consumers() <= set().union(*by_class.values())


def test_audit_rejects_a_float_outside_the_allowlist(tmp_path, monkeypatch):
    import audit_exact_arithmetic as mod

    kernel = tmp_path / "src"
    kernel.mkdir()
    (kernel / "leak.mojo").write_text("var x: Float64 = 1.5\n", encoding="utf-8")
    monkeypatch.setattr(mod, "SCAN_ROOTS", [kernel])
    monkeypatch.setattr(mod, "ROOT", tmp_path)
    monkeypatch.setattr(mod, "binding_rows", lambda text=None: [])
    monkeypatch.setattr(mod, "allowlisted", lambda: set())
    errors = mod.audit()
    assert any("leak.mojo:1" in e and "C1" in e for e in errors)


def test_audit_rejects_every_mojo_decimal_float_form(tmp_path, monkeypatch):
    import audit_exact_arithmetic as mod

    kernel = tmp_path / "src"
    kernel.mkdir()
    forms = ["1e-3", "2.", ".5", "1.25", "1_000.5_0", "2E+4"]
    (kernel / "leak.mojo").write_text(
        "\n".join(f"var x{i} = {literal}" for i, literal in enumerate(forms)),
        encoding="utf-8",
    )
    monkeypatch.setattr(mod, "SCAN_ROOTS", [kernel])
    monkeypatch.setattr(mod, "ROOT", tmp_path)
    monkeypatch.setattr(mod, "binding_rows", lambda text=None: [])
    monkeypatch.setattr(mod, "allowlisted", lambda: set())
    errors = mod.audit()
    assert len([e for e in errors if "floating point in kernel scope" in e]) == len(forms)


def test_audit_rejects_unbound_arithmetic_consumer(tmp_path, monkeypatch):
    import audit_exact_arithmetic as mod

    kernel = tmp_path / "src"
    kernel.mkdir()
    (kernel / "consumer.mojo").write_text("from rat_q import Q\n", encoding="utf-8")
    monkeypatch.setattr(mod, "SCAN_ROOTS", [kernel])
    monkeypatch.setattr(mod, "ROOT", tmp_path)
    monkeypatch.setattr(mod, "binding_rows", lambda text=None: [])
    monkeypatch.setattr(mod, "allowlisted", lambda: set())
    assert "arithmetic consumer lacks binding row: src/consumer.mojo" in mod.audit()


def test_policy_surfaces_point_at_the_spec():
    assert SPEC_REL in text("README.md")
    assert SPEC_REL in text("docs/mojo_first_execution_policy.md")
    assert "tools/audit_exact_arithmetic.py" in text(".github/workflows/no-trig-audit.yml")
    policy = tomllib.loads(text("backend.toml"))["policy"]
    assert policy["exact_arithmetic_spec"] == SPEC_REL
    assert policy["no_float_certificate_arithmetic"] is True
    assert "no_float_certificate_arithmetic" in text("tools/audit_backend_manifest.py")


def test_mojo_law_tests_are_wired_into_the_smoke_target():
    smoke = text("src/smoke_tests.mojo")
    for name in ["test_rational_field_laws", "test_interval_enclosure_laws"]:
        assert f"def {name}()" in smoke
        assert f"if not {name}():" in smoke


# --- sections 1 to 3: executable laws against the Fraction oracle -----------


def iv(lo, hi) -> I:
    return I(Fraction(lo), Fraction(hi))


def test_rational_equality_is_decidable_and_cancellation_lossless():
    assert Fraction(1, 10) + Fraction(2, 10) == Fraction(3, 10)
    a, b, c = Fraction(1, 3), Fraction(1, 7), Fraction(-2, 9)
    assert (a + b) + c == a + (b + c)
    assert a * (b + c) == a * b + a * c
    assert (a + b) - b == a


def test_floats_violate_the_laws_the_spec_is_replacing():
    assert 0.1 + 0.2 != 0.3
    assert (1e16 + 1.0) - 1e16 != 1.0


def test_inclusion_theorem_on_a_sample():
    x, y = iv(1, 3), iv(-1, 2)
    for px in (Fraction(1), Fraction(5, 2), Fraction(3)):
        for py in (Fraction(-1), Fraction(1, 3), Fraction(2)):
            for op, fop in ((x.add, px + py), (x.sub, px - py), (x.mul, px * py)):
                box = op(y)
                assert box.lo <= fop <= box.hi


def test_dependency_problem_and_subdistributivity():
    x, y, z = iv(1, 3), iv(-1, 2), iv(2, 5)
    d = x.sub(x)
    assert (d.lo, d.hi) == (Fraction(-2), Fraction(2)) and d.contains_zero()
    lhs, rhs = x.mul(y.add(z)), x.mul(y).add(x.mul(z))
    assert rhs.lo <= lhs.lo and lhs.hi <= rhs.hi


def test_reversed_endpoints_fail_closed():
    try:
        iv(2, 1)
    except ValueError:
        return
    raise AssertionError("J1 not enforced")
