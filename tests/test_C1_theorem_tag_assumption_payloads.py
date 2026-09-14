from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DOC = ROOT / "docs" / "C1_theorem_tag_assumption_payloads.md"
SRC = ROOT / "src" / "C1_theorem_tag_assumption_payloads.mojo"


def body(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def test_payload_document_defines_required_core_fields():
    text = body(DOC)
    for field in [
        "TheoremTagName",
        "SourceFamily",
        "ConclusionKind",
        "StrengthClass",
        "AssumptionPayloadKind",
        "FiniteWitnessPayload",
        "AdapterPayload",
        "OpenFrontierUse = false",
        "GenericMLCUse = false",
    ]:
        assert field in text


def test_payload_document_lists_import_payload_kinds():
    text = body(DOC)
    for kind in [
        "RationalParameterRayLandingPayload",
        "FiberDefinitionPayload",
        "KnownTrivialFiberPayload",
        "YoccozPuzzlePayload",
        "AprioriBoundsPayload",
    ]:
        assert kind in text


def test_payload_document_rejects_generic_and_shortcut_imports():
    text = body(DOC)
    assert "Rejected use: proving local connectivity" in text
    assert "Rejected use: asserting that same-fiber implies equality" in text
    assert "Rejected use: generic boundary closure" in text
    assert "Rejected use: global MLC" in text
    assert "Rejected use: assuming bounds for all infinitely renormalizable parameters" in text


def test_mojo_checker_has_allowed_payload_predicates():
    text = body(SRC)
    assert "allowed_payload_kind" in text
    assert "allowed_payload_conclusion" in text
    assert "allowed_payload_strength" in text
    assert "payload_has_required_core_fields" in text
    assert "theorem_tag_payload_admissible" in text


def test_mojo_checker_blocks_forbidden_imports():
    text = body(SRC)
    for forbidden in [
        "GenericMLC",
        "AllFibersTrivial",
        "ResidualClosureNoMissingLinks",
        "EveryPersistentNonSeparationCollapses",
        "BoundedSearchTermination",
    ]:
        assert forbidden in text
    assert "generic_mlc_payload_rejected" in text
    assert "bounded_search_payload_rejected" in text


def test_initial_payload_scaffolds_are_not_generic_imports():
    text = body(SRC)
    assert "rational_parameter_ray_landing_payload_scaffold" in text
    assert "fiber_definition_payload_scaffold" in text
    assert "LocalLanding" in text
    assert "AdapterOnly" in text
    assert "uses_generic_mlc" in text
    assert "uses_bounded_search_only" in text


def test_next_priority_is_payload_instances():
    text = body(DOC) + "\n" + body(SRC)
    assert "TheoremTagPayloadInstances" in text
