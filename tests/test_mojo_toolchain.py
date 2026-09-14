from pathlib import Path
import subprocess
import tomllib


ROOT = Path(__file__).resolve().parents[1]


def test_toolchain_versions_and_tasks_are_pinned():
    manifest = tomllib.loads((ROOT / "pixi.toml").read_text(encoding="utf-8"))
    assert manifest["dependencies"]["mojo"] == "==1.0.0"
    assert manifest["pypi-dependencies"]["pytest"] == "==8.3.5"
    assert manifest["tasks"]["mojo-smoke"] == "mojo src/smoke_tests.mojo"
    assert manifest["tasks"]["mojo-build"].startswith("mojo build src/smoke_tests.mojo")


def test_ci_executes_both_mojo_compile_paths():
    workflow = (ROOT / ".github" / "workflows" / "no-trig-audit.yml").read_text(
        encoding="utf-8"
    )
    assert "pixi run mojo-build" in workflow
    assert "pixi run mojo-smoke" in workflow


def test_smoke_failure_exits_nonzero():
    result = subprocess.run(
        ["mojo", "src/smoke_failure_probe.mojo"],
        cwd=ROOT,
        capture_output=True,
        text=True,
        check=False,
    )
    assert result.returncode != 0
    assert "finite-regime Mandelbrot smoke tests: FAIL" in (
        result.stdout + result.stderr
    )


def test_compiler_checked_boundary_is_explicit():
    boundary = (ROOT / "docs" / "mojo-toolchain-boundary.md").read_text(
        encoding="utf-8"
    )
    for path in [
        "src/smoke_tests.mojo",
        "src/poly_z.mojo",
        "src/cert_types.mojo",
        "src/rat_q.mojo",
        "src/integer_gcd.mojo",
        "src/ray_address.mojo",
        "src/rational_trig.mojo",
        "src/alignment_audit_status.mojo",
        "src/interval_q.mojo",
        "src/poly_interval_eval.mojo",
        "src/krawczyk_witness.mojo",
        "src/C1_final_proof_block_ledger.mojo",
        "src/C1_residual_closure_no_missing_links.mojo",
        "src/C1_theorem_tag_assumption_payloads.mojo",
        "src/C1_theorem_tag_import_ledger.mojo",
    ]:
        assert path in boundary
    assert "Passing it does not imply that" in boundary
    assert "every `.mojo` file compiles" in boundary
