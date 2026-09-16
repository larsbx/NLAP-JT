from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DOC = ROOT / "docs" / "C1_theorem_tag_import_ledger.md"
SRC = ROOT / "src" / "C1_theorem_tag_import_ledger.mojo"


def body(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def test_ledger_names_final_import_payload_fields():
    text = body(DOC)
    for field in [
        "TheoremTagName",
        "SourceFamily",
        "CoveredClass",
        "ConclusionKind",
        "AssumptionPayload",
        "AdapterUse",
        "StrengthClass",
        "ImportStatus",
    ]:
        assert field in text


def test_allowed_conclusion_kinds_are_explicit_in_doc_and_mojo():
    text = body(DOC) + "\n" + body(SRC)
    for kind in [
        "RationalParameterRayLanding",
        "RationalRaySeparatorInterpretation",
        "FiberDefinitionEquivalence",
        "KnownTrivialFiberClass",
        "YoccozPuzzleLocalConnectivityUnderHypotheses",
        "RenormalizationWithAprioriBounds",
        "BoundaryIdentificationSoundness",
        "TuningKneadingSubstitution",
    ]:
        assert kind in text
    assert "allowed_conclusion_kind" in text


def test_strength_classes_block_global_mlc_imports():
    text = body(DOC) + "\n" + body(SRC)
    assert "MLC_STRENGTH_GLOBAL" in text
    assert "FORBIDDEN_PLACEHOLDER" in text
    assert "forbidden_strength_class" in text
    assert "generic_mlc_import_admissible() -> Bool" in text
    assert "return False" in text


def test_forbidden_import_names_cannot_be_final_premises():
    text = body(DOC) + "\n" + body(SRC)
    for name in [
        "GenericMLC",
        "AllFibersTrivial",
        "EveryPersistentNonSeparationCollapses",
        "ResidualClosureNoMissingLinks",
        "BoundedSearchTermination",
        "RendererEvidence",
        "NumericalPictureShrinkage",
    ]:
        assert name in text
    assert "forbidden_import_name" in text


def test_final_admissibility_requires_checked_assumption_payload():
    text = body(SRC)
    assert "assumption_payload_present" in text
    assert "adapter_use_declared" in text
    assert "ImportStatus.checked().code" in text
    assert "theorem_tag_admissible_for_final" in text


def test_import_conclusion_strength_and_status_are_typed():
    text = body(SRC)
    assert "struct ImportConclusionKind" in text
    assert "struct ImportStrengthClass" in text
    assert "struct ImportStatus" in text
    assert "var conclusion_kind: ImportConclusionKind" in text
    assert "var strength_class: ImportStrengthClass" in text
    assert "var import_status: ImportStatus" in text
    assert "conclusion_kind: String" not in text
    assert "strength_class: String" not in text
    assert "import_status: String" not in text


def test_initial_tags_are_scaffolded_not_final_checked():
    text = body(SRC)
    assert "rational_parameter_ray_landing_tag_ready" in text
    assert "fiber_definition_equivalence_tag_ready" in text
    assert "known_trivial_fiber_class_tag_ready" in text
    assert "ImportStatus.scaffolded()" in text
    assert "theorem_tags_block_final_proof_until_checked() -> Bool" in text


def test_next_priority_is_assumption_payloads():
    text = body(DOC) + "\n" + body(SRC)
    assert "TheoremTagAssumptionPayloads" in text
    assert "next_priority_after_theorem_tag_ledger" in text


def test_kneading_form_of_tuning_tag_is_recorded_with_source_and_stays_scaffolded():
    doc = body(DOC)
    src = body(SRC)
    assert "### Kneading form of tuning" in doc
    assert "KneadingFormOfTuning" in doc and "KneadingFormOfTuning" in src
    for source in ["Douady", "Hubbard", "Derrida, Gervois, and Pomeau", "Milnor"]:
        assert source in doc
    assert "Covered class: kneading sequences of real quadratic parameters" in doc
    assert "Strength class: `CLASSICAL_IMPORTED_CLASS_SPECIFIC`" in doc.split("### Kneading form of tuning")[1]
    assert "def tuning_kneading_substitution() -> Self: return Self(7)" in src
    assert "kind.code <= 7" in src
    tag = src.split("def kneading_form_of_tuning_tag_ready()")[1].split("\n\n\n")[0]
    assert "ImportConclusionKind.tuning_kneading_substitution()" in tag
    assert "ImportStrengthClass.classical_class_specific()" in tag
    assert "ImportStatus.scaffolded()" in tag
