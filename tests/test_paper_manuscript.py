from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PAPER = ROOT / "paper" / "finite_certificates_for_mandelbrot_fibers.tex"
BIB = ROOT / "paper" / "finite_certificates_for_mandelbrot_fibers.bib"


def body(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def test_manuscript_exists_and_has_standard_structure():
    text = body(PAPER)
    assert "\\begin{abstract}" in text
    assert "\\section{Introduction}" in text
    assert "\\section{Relation to the literature}" in text
    assert "\\section{Conclusion}" in text
    assert "\\bibliography{finite_certificates_for_mandelbrot_fibers}" in text


def test_manuscript_states_c1_as_open_separator_program():
    text = body(PAPER)
    assert "Conjecture" in text
    assert "C1, separator form" in text
    assert "open frontier" in text
    assert "not as a theorem" in text
    assert "Residual closure with no missing links" in text


def test_manuscript_uses_audit_correct_terms():
    text = body(PAPER)
    assert "separator-catalogue adequacy" in text
    assert "separator-catalogue soundness" in text
    assert "separator-catalogue completeness" in text
    assert "finite theorem kernel" in text
    assert "Mojo" in text
    assert "catalogue extensionality" not in text.lower()


def test_manuscript_exposes_analytic_import_boundary():
    text = body(PAPER)
    assert "theorem tags" in text
    assert "assumption checks" in text
    assert "does not silently reprove" in text
    assert "rational parameter-ray landing" in text or "rational parameter rays" in text
    assert "fiber" in text


def test_bibliography_contains_core_literature():
    text = body(BIB)
    for key in [
        "SchleicherFibersLC",
        "SchleicherRationalParameterRays",
        "MilnorOrbitPortraits",
        "DouadyHubbardEtude",
        "HertlingMandelbrotComputable",
        "BravermanYampolskyJuliaComputability",
    ]:
        assert key in text
