# Theorem-tag assumption payload checker.
#
# Internal C1 proof infrastructure. This module makes theorem-tag imports depend
# on finite assumption payloads rather than names alone.

struct TheoremTagPayload:
    var tag_name: String
    var payload_kind: String
    var conclusion_kind: String
    var strength_class: String
    var has_finite_witness_payload: Bool
    var has_adapter_payload: Bool
    var has_source_family: Bool
    var excludes_generic_boundary_assertion: Bool
    var excludes_residual_closure_claim: Bool
    var uses_generic_mlc: Bool
    var uses_bounded_search_only: Bool

    fn __init__(
        inout self,
        tag_name: String,
        payload_kind: String,
        conclusion_kind: String,
        strength_class: String,
        has_finite_witness_payload: Bool,
        has_adapter_payload: Bool,
        has_source_family: Bool,
        excludes_generic_boundary_assertion: Bool,
        excludes_residual_closure_claim: Bool,
        uses_generic_mlc: Bool,
        uses_bounded_search_only: Bool,
    ):
        self.tag_name = tag_name
        self.payload_kind = payload_kind
        self.conclusion_kind = conclusion_kind
        self.strength_class = strength_class
        self.has_finite_witness_payload = has_finite_witness_payload
        self.has_adapter_payload = has_adapter_payload
        self.has_source_family = has_source_family
        self.excludes_generic_boundary_assertion = excludes_generic_boundary_assertion
        self.excludes_residual_closure_claim = excludes_residual_closure_claim
        self.uses_generic_mlc = uses_generic_mlc
        self.uses_bounded_search_only = uses_bounded_search_only


fn allowed_payload_kind(kind: String) -> Bool:
    return (
        kind == "RationalParameterRayLandingPayload" or
        kind == "FiberDefinitionPayload" or
        kind == "KnownTrivialFiberPayload" or
        kind == "YoccozPuzzlePayload" or
        kind == "AprioriBoundsPayload"
    )


fn allowed_payload_conclusion(kind: String) -> Bool:
    return (
        kind == "RayLanding" or
        kind == "SeparatorInterpretation" or
        kind == "FiberDefinitionAdapter" or
        kind == "ClassSpecificTrivialFiber" or
        kind == "BoundaryEqualityAdapter"
    )


fn allowed_payload_strength(strength: String) -> Bool:
    return (
        strength == "AdapterOnly" or
        strength == "LocalLanding" or
        strength == "ClassSpecificFiberTriviality" or
        strength == "ClassSpecificLocalConnectivity"
    )


fn forbidden_payload_tag(name: String) -> Bool:
    return (
        name == "GenericMLC" or
        name == "AllFibersTrivial" or
        name == "ResidualClosureNoMissingLinks" or
        name == "EveryPersistentNonSeparationCollapses" or
        name == "BoundedSearchTermination"
    )


fn payload_has_required_core_fields(payload: TheoremTagPayload) -> Bool:
    return (
        payload.has_finite_witness_payload and
        payload.has_adapter_payload and
        payload.has_source_family and
        payload.excludes_generic_boundary_assertion and
        payload.excludes_residual_closure_claim
    )


fn theorem_tag_payload_admissible(payload: TheoremTagPayload) -> Bool:
    if forbidden_payload_tag(payload.tag_name):
        return False
    if not allowed_payload_kind(payload.payload_kind):
        return False
    if not allowed_payload_conclusion(payload.conclusion_kind):
        return False
    if not allowed_payload_strength(payload.strength_class):
        return False
    if payload.uses_generic_mlc:
        return False
    if payload.uses_bounded_search_only:
        return False
    return payload_has_required_core_fields(payload)


fn rational_parameter_ray_landing_payload_scaffold() -> TheoremTagPayload:
    return TheoremTagPayload(
        "RationalParameterRayLanding",
        "RationalParameterRayLandingPayload",
        "RayLanding",
        "LocalLanding",
        True,
        True,
        True,
        True,
        True,
        False,
        False,
    )


fn fiber_definition_payload_scaffold() -> TheoremTagPayload:
    return TheoremTagPayload(
        "FiberDefinitionEquivalence",
        "FiberDefinitionPayload",
        "FiberDefinitionAdapter",
        "AdapterOnly",
        True,
        True,
        True,
        True,
        True,
        False,
        False,
    )


fn generic_mlc_payload_rejected() -> Bool:
    var payload = TheoremTagPayload(
        "GenericMLC",
        "KnownTrivialFiberPayload",
        "ClassSpecificTrivialFiber",
        "ClassSpecificFiberTriviality",
        True,
        True,
        True,
        True,
        True,
        True,
        False,
    )
    return not theorem_tag_payload_admissible(payload)


fn bounded_search_payload_rejected() -> Bool:
    var payload = TheoremTagPayload(
        "BoundedSearchTermination",
        "KnownTrivialFiberPayload",
        "ClassSpecificTrivialFiber",
        "ClassSpecificFiberTriviality",
        True,
        True,
        True,
        True,
        True,
        False,
        True,
    )
    return not theorem_tag_payload_admissible(payload)


fn next_priority_block() -> String:
    return "TheoremTagPayloadInstances"
