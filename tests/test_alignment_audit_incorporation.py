from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
AUDIT = ROOT / "docs" / "alignment_audit_deep_research_findings.md"
MOJO_POLICY = ROOT / "docs" / "mojo_first_execution_policy.md"
STATUS = ROOT / "src" / "alignment_audit_status.mojo"


def text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def test_deep_research_findings_are_recorded():
    body = text(AUDIT)
    assert "deep literature" in body
    assert "PersistentNonSeparation" in body
    assert "fiber-triviality strength" in body
    assert "MLC-strength" in body


def test_open_frontier_strength_gate_is_explicit():
    body = text(AUDIT) + "\n" + text(STATUS)
    assert "OPEN_FRONTIER" in body
    assert "MLC_STRENGTH_CANDIDATE" in body or "mlc_strength_candidate" in body
    assert "ResidualFrontierRefinement" in body
    assert "theorem_proved" in body


def test_finite_state_does_not_prove_global_termination():
    body = text(AUDIT) + "\n" + text(STATUS)
    assert "finite carrier at each stage does not imply" in body
    assert "bounded_search_proves_global_termination() -> Bool" in body
    assert "finite_state_alone_proves_well_foundedness() -> Bool" in body
    assert "return False" in body


def test_mojo_is_first_class_but_not_theorem_kernel():
    body = text(MOJO_POLICY) + "\n" + text(STATUS)
    assert "Mojo is the default first-class language" in body
    assert "mojo_is_first_class_execution_language() -> Bool" in body
    assert "mojo_is_trusted_theorem_kernel() -> Bool" in body
    assert "return False" in body


def test_separator_catalogue_adequacy_replaces_extensionality_for_new_work():
    body = text(AUDIT) + "\n" + text(MOJO_POLICY) + "\n" + text(STATUS)
    assert "SeparatorCatalogueSoundness" in body
    assert "SeparatorCatalogueCompleteness" in body
    assert "SeparatorCatalogueAdequacy" in body
    assert "legacy_catalogue_extensionality_name_retired_for_new_work" in body


def test_rank2_layer_restriction_not_absolute_ontology_claim():
    body = text(AUDIT) + "\n" + text(MOJO_POLICY) + "\n" + text(STATUS)
    assert "layer restriction" in body
    assert "not primitive constructors" in body or "must not expose primitive constructors" in body
    assert "rank2_circle_primitive_available() -> Bool" in body
    assert "rank2_higher_layer_adapter_required() -> Bool" in body
