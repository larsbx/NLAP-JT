# Internal theorem-tag import ledger for the priority conjecture.
#
# Mojo checks finite import records. It does not silently reprove imported
# analytic theorems; it verifies that named tags have the required payloads and
# do not smuggle global MLC-strength conclusions into premises.

struct TheoremTagRecord:
    var name: String
    var source_family_named: Bool
    var covered_class_explicit: Bool
    var conclusion_kind: String
    var assumption_payload_present: Bool
    var adapter_use_declared: Bool
    var strength_class: String
    var import_status: String

    fn __init__(
        inout self,
        name: String,
        source_family_named: Bool,
        covered_class_explicit: Bool,
        conclusion_kind: String,
        assumption_payload_present: Bool,
        adapter_use_declared: Bool,
        strength_class: String,
        import_status: String,
    ):
        self.name = name
        self.source_family_named = source_family_named
        self.covered_class_explicit = covered_class_explicit
        self.conclusion_kind = conclusion_kind
        self.assumption_payload_present = assumption_payload_present
        self.adapter_use_declared = adapter_use_declared
        self.strength_class = strength_class
        self.import_status = import_status


fn allowed_conclusion_kind(kind: String) -> Bool:
    return (
        kind == "RationalParameterRayLanding"
        or kind == "RationalRaySeparatorInterpretation"
        or kind == "FiberDefinitionEquivalence"
        or kind == "KnownTrivialFiberClass"
        or kind == "YoccozPuzzleLocalConnectivityUnderHypotheses"
        or kind == "RenormalizationWithAprioriBounds"
        or kind == "BoundaryIdentificationSoundness"
    )


fn allowed_strength_class(strength_class: String) -> Bool:
    return (
        strength_class == "FINITE_ONLY"
        or strength_class == "CLASSICAL_IMPORTED_LOCAL"
        or strength_class == "CLASSICAL_IMPORTED_CLASS_SPECIFIC"
    )


fn forbidden_strength_class(strength_class: String) -> Bool:
    return (
        strength_class == "MLC_STRENGTH_GLOBAL"
        or strength_class == "FORBIDDEN_PLACEHOLDER"
    )


fn forbidden_import_name(name: String) -> Bool:
    return (
        name == "GenericMLC"
        or name == "AllFibersTrivial"
        or name == "EveryPersistentNonSeparationCollapses"
        or name == "ResidualClosureNoMissingLinks"
        or name == "BoundedSearchTermination"
        or name == "RendererEvidence"
        or name == "NumericalPictureShrinkage"
    )


fn import_record_complete(record: TheoremTagRecord) -> Bool:
    return (
        record.source_family_named
        and record.covered_class_explicit
        and allowed_conclusion_kind(record.conclusion_kind)
        and record.assumption_payload_present
        and record.adapter_use_declared
        and record.import_status == "CHECKED"
    )


fn theorem_tag_admissible_for_final(record: TheoremTagRecord) -> Bool:
    if forbidden_import_name(record.name):
        return False
    if forbidden_strength_class(record.strength_class):
        return False
    return import_record_complete(record) and allowed_strength_class(record.strength_class)


fn rational_parameter_ray_landing_tag_ready() -> TheoremTagRecord:
    return TheoremTagRecord(
        "RationalParameterRayLanding",
        True,
        True,
        "RationalParameterRayLanding",
        False,  # source-specific assumption payload still must be supplied per use
        True,
        "CLASSICAL_IMPORTED_LOCAL",
        "SCAFFOLDED",
    )


fn fiber_definition_equivalence_tag_ready() -> TheoremTagRecord:
    return TheoremTagRecord(
        "FiberDefinitionEquivalence",
        True,
        True,
        "FiberDefinitionEquivalence",
        False,
        True,
        "CLASSICAL_IMPORTED_LOCAL",
        "SCAFFOLDED",
    )


fn known_trivial_fiber_class_tag_ready() -> TheoremTagRecord:
    return TheoremTagRecord(
        "KnownTrivialFiberClass",
        True,
        True,
        "KnownTrivialFiberClass",
        False,
        True,
        "CLASSICAL_IMPORTED_CLASS_SPECIFIC",
        "SCAFFOLDED",
    )


fn generic_mlc_import_admissible() -> Bool:
    return False


fn theorem_tags_block_final_proof_until_checked() -> Bool:
    return True


fn next_priority_after_theorem_tag_ledger() -> String:
    return "TheoremTagAssumptionPayloads"
