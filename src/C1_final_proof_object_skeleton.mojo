# Internal final proof-object skeleton for the priority conjecture.
#
# This module is deliberately finite and syntactic. It records which checked
# blocks must be present before the final theorem status may be accepted.

struct C1FinalProofObject:
    var separator_catalogue_soundness_checked: Bool
    var separator_catalogue_completeness_checked: Bool
    var fiber_definition_adapter_checked: Bool
    var residual_closure_no_missing_links_checked: Bool
    var exit_closure_checked: Bool
    var boundary_equality_soundness_checked: Bool
    var theorem_tag_import_soundness_checked: Bool
    var covered_domain_declared: Bool
    var missing_link_exit_absent: Bool
    var imported_theorem_tags_checked: Bool
    var no_bounded_search_shortcut_used: Bool
    var no_rank2_locus_primitive_used: Bool
    var no_label_only_equality_used: Bool

    fn __init__(
        inout self,
        separator_catalogue_soundness_checked: Bool,
        separator_catalogue_completeness_checked: Bool,
        fiber_definition_adapter_checked: Bool,
        residual_closure_no_missing_links_checked: Bool,
        exit_closure_checked: Bool,
        boundary_equality_soundness_checked: Bool,
        theorem_tag_import_soundness_checked: Bool,
        covered_domain_declared: Bool,
        missing_link_exit_absent: Bool,
        imported_theorem_tags_checked: Bool,
        no_bounded_search_shortcut_used: Bool,
        no_rank2_locus_primitive_used: Bool,
        no_label_only_equality_used: Bool,
    ):
        self.separator_catalogue_soundness_checked = separator_catalogue_soundness_checked
        self.separator_catalogue_completeness_checked = separator_catalogue_completeness_checked
        self.fiber_definition_adapter_checked = fiber_definition_adapter_checked
        self.residual_closure_no_missing_links_checked = residual_closure_no_missing_links_checked
        self.exit_closure_checked = exit_closure_checked
        self.boundary_equality_soundness_checked = boundary_equality_soundness_checked
        self.theorem_tag_import_soundness_checked = theorem_tag_import_soundness_checked
        self.covered_domain_declared = covered_domain_declared
        self.missing_link_exit_absent = missing_link_exit_absent
        self.imported_theorem_tags_checked = imported_theorem_tags_checked
        self.no_bounded_search_shortcut_used = no_bounded_search_shortcut_used
        self.no_rank2_locus_primitive_used = no_rank2_locus_primitive_used
        self.no_label_only_equality_used = no_label_only_equality_used


fn all_required_blocks_checked(proof: C1FinalProofObject) -> Bool:
    return (
        proof.separator_catalogue_soundness_checked and
        proof.separator_catalogue_completeness_checked and
        proof.fiber_definition_adapter_checked and
        proof.residual_closure_no_missing_links_checked and
        proof.exit_closure_checked and
        proof.boundary_equality_soundness_checked and
        proof.theorem_tag_import_soundness_checked
    )


fn all_final_guards_checked(proof: C1FinalProofObject) -> Bool:
    return (
        proof.covered_domain_declared and
        proof.missing_link_exit_absent and
        proof.imported_theorem_tags_checked and
        proof.no_bounded_search_shortcut_used and
        proof.no_rank2_locus_primitive_used and
        proof.no_label_only_equality_used
    )


fn accepts_c1_final_proof_object(proof: C1FinalProofObject) -> Bool:
    return all_required_blocks_checked(proof) and all_final_guards_checked(proof)


fn rejects_missing_link_final_exit() -> Bool:
    return True


fn final_proof_requires_covered_domain() -> Bool:
    return True


fn final_proof_rejects_bounded_search_shortcut() -> Bool:
    return True


fn final_proof_rejects_rank2_locus_primitive() -> Bool:
    return True


fn final_proof_rejects_label_only_equality() -> Bool:
    return True


fn final_proof_reproves_imported_analytic_theorems() -> Bool:
    return False


fn skeleton_alone_proves_c1() -> Bool:
    return False


fn next_priority_target() -> String:
    return "FinalProofBlockLedger"
