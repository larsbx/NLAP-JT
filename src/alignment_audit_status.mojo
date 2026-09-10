# Alignment-audit status and Mojo theorem-kernel trust boundary.
#
# This module records repository status semantics. Mojo is the first-class
# execution language and the finite proof-object theorem kernel. It still does
# not re-prove imported analytic complex-dynamics theorems.

struct TheoremStatus:
    var name: String
    var proof_skeleton_present: Bool
    var local_obligations_disclosed: Bool
    var local_obligations_proved: Bool
    var open_frontier: Bool
    var mlc_strength_candidate: Bool
    var theorem_proved: Bool

    fn __init__(inout self, name: String, proof_skeleton_present: Bool, local_obligations_disclosed: Bool, local_obligations_proved: Bool, open_frontier: Bool, mlc_strength_candidate: Bool, theorem_proved: Bool):
        self.name = name
        self.proof_skeleton_present = proof_skeleton_present
        self.local_obligations_disclosed = local_obligations_disclosed
        self.local_obligations_proved = local_obligations_proved
        self.open_frontier = open_frontier
        self.mlc_strength_candidate = mlc_strength_candidate
        self.theorem_proved = theorem_proved


fn c1_separator_catalogue_adequacy_status() -> TheoremStatus:
    return TheoremStatus(
        "SeparatorCatalogueAdequacy",
        True,   # proof skeleton exists
        True,   # local obligations are listed
        False,  # local obligations are not yet proved
        False,  # adequacy itself is bridge work, not the residual frontier
        False,
        False,
    )


fn c1_residual_frontier_status() -> TheoremStatus:
    return TheoremStatus(
        "ResidualFrontierRefinement",
        True,
        True,
        False,
        True,
        True,
        False,
    )


fn mojo_is_first_class_execution_language() -> Bool:
    return True


fn mojo_is_finite_theorem_kernel() -> Bool:
    return True


fn mojo_reproves_imported_analytic_theorems() -> Bool:
    return False


fn theorem_tags_require_import_validation() -> Bool:
    return True


fn bounded_search_proves_global_termination() -> Bool:
    return False


fn finite_state_alone_proves_well_foundedness() -> Bool:
    return False


fn rank2_circle_primitive_available() -> Bool:
    return False


fn rank2_higher_layer_adapter_required() -> Bool:
    return True


fn legacy_catalogue_extensionality_name_retired_for_new_work() -> Bool:
    return True
