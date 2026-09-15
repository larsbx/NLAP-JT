"""Regressions for the vendored exact-arithmetic packages.

The arithmetic (BigZ, Q in ``src/finite_exact/``; IQ, ComplexIQ in
``src/interval_q/``) is vendored byte-for-byte from larsbx/finite_exact and
larsbx/interval_q and pinned in ``vendored.toml``. The hardening this
repository did before extraction (long division, cancellation, singleton
constructors, the randomized property probe) is now verified upstream; here
we check the pin, the wiring, and that no local arithmetic grew back.
"""

from __future__ import annotations

import subprocess
import sys
import tomllib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))

import check_vendored_sync as sync  # noqa: E402


def text(rel: str) -> str:
    return (ROOT / rel).read_text(encoding="utf-8")


def test_vendored_packages_match_their_pins():
    assert sync.check() == []
    packages = {p["name"]: p for p in sync.load()}
    assert set(packages) == {"finite_exact", "interval_q"}
    for name, pkg in packages.items():
        assert pkg["repository"] == f"larsbx/{name}" and pkg["root"] == "src"
        assert f"{name}/__init__.mojo" in pkg["files"]
    result = subprocess.run([sys.executable, str(ROOT / "tools" / "check_vendored_sync.py")], capture_output=True, text=True, check=False)
    assert result.returncode == 0, result.stdout


def test_vendoring_is_wired_into_pixi_and_ci():
    manifest = tomllib.loads(text("pixi.toml"))
    assert manifest["tasks"]["vendored"] == "python tools/check_vendored_sync.py"
    assert "property" not in manifest["tasks"]
    workflow = text(".github/workflows/no-trig-audit.yml")
    assert "pixi run vendored" in workflow and "pixi run property" not in workflow
    assert not (ROOT / "src" / "exact_arithmetic_property_probe.mojo").exists()
    assert not (ROOT / "tools" / "exact_arithmetic_property_oracle.py").exists()


def test_hardened_arithmetic_is_what_was_vendored():
    z = text("src/finite_exact/bigint_z.mojo")
    assert "def bigz_abs_divmod(" in z and "Knuth Algorithm D" in z
    q = text("src/finite_exact/rat_q.mojo")
    assert "def q_cross_terms(" in q and "def q_cancellation_smoke(" in q
    assert "bigz_lt(bigz_mul(self.num, other.den), bigz_mul(other.num, self.den))" not in q
    iq = text("src/interval_q/closed_q.mojo")
    assert "def singleton(x: Q) -> IQ:" in iq and "def singleton(re: Q, im: Q) -> ComplexIQ:" in iq
    smoke = text("src/smoke_tests.mojo")
    for name in ["bigz_long_division_smoke", "q_cancellation_smoke", "bigq_interval_conformance_smoke"]:
        assert f"not {name}()" in smoke


def test_no_flat_arithmetic_modules_or_point_constructors_remain():
    for retired in ["bigint_z.mojo", "rat_q.mojo", "interval_q.mojo"]:
        assert not (ROOT / "src" / retired).exists(), retired
    for path in sorted((ROOT / "src").rglob("*.mojo")):
        body = path.read_text(encoding="utf-8")
        assert ".point(" not in body, path
        assert "def point(" not in body and "fn point(" not in body, path
        for line in body.splitlines():
            assert not line.startswith(("from bigint_z import", "from rat_q import", "from interval_q import")), (path, line)


def test_no_points_audit_has_no_exemptions_and_bans_def_point():
    audit = text("tools/audit_no_points.py")
    assert "ALLOW_LINES: set[str] = set()" in audit
    assert r"(?:fn|def)\s+point\s*\(" in audit
    assert r"\.point\s*\(" in audit


def test_binding_file_points_upstream_and_keeps_only_this_repositorys_rows():
    spec = text("docs/rational-interval-arithmetic-spec.md")
    assert "larsbx/finite_exact:docs/rational-interval-arithmetic-spec.md" in spec
    assert "### 6.2 `larsbx/NLAP-JT`" in spec and "### 6.1" not in spec
    boundary = text("docs/exact-arithmetic-public-boundary.md")
    assert "larsbx/finite_exact:docs/exact-arithmetic-public-boundary.md" in boundary
    assert "larsbx/interval_q:docs/exact-arithmetic-public-boundary.md" in boundary
    assert "src/finite_exact/bigint_z.mojo" in text("docs/mojo-toolchain-boundary.md")
    assert "src/interval_q/closed_q.mojo" in text("docs/mojo-toolchain-boundary.md")
