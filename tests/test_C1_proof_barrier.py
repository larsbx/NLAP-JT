from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DOC = ROOT / "docs" / "C1_proof_barrier_and_conditional_theorem.md"


def text(path):
    return path.read_text(encoding="utf-8")


def test_c1_barrier_states_not_proved_or_disproved():
    body = text(DOC)
    assert "neither proved nor disproved" in body
    assert "classical generic fiber-triviality frontier" in body


def test_conditional_theorem_is_allowed_but_global_claim_blocked():
    body = text(DOC)
    assert "Conditional theorem C1-local" in body
    assert "Conditional theorem C1-global" in body
    assert "No file may claim" in body
    assert "all generic boundary fibers are trivial" in body


def test_established_cases_are_separated_from_open_cases():
    body = text(DOC)
    assert "Misiurewicz parameters" in body
    assert "boundaries of hyperbolic components" in body
    assert "open cases" in body


def test_no_renderer_or_numerical_image_proves_c1():
    body = text(DOC)
    assert "a renderer proves local connectivity" in body
    assert "a numerical image proves a fiber statement" in body
