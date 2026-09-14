# Final proof block ledger for C1.
#
# This module records the status of required blocks for the final proof object.
# It is intentionally conservative: a scaffolded or open-frontier block rejects
# final acceptance.

struct ProofBlockStatus:
    var name: String
    var proved_or_imported_checked: Bool
    var scaffolded: Bool
    var open_frontier: Bool
    var research_only: Bool
    var required_for_final: Bool

    fn __init__(inout self, name: String, proved_or_imported_checked: Bool, scaffolded: Bool, open_frontier: Bool, research_only: Bool, required_for_final: Bool):
        self.name = name
        self.proved_or_imported_checked = proved_or_imported_checked
        self.scaffolded = scaffolded
        self.open_frontier = open_frontier
        self.research_only = research_only
        self.required_for_final = required_for_final


fn separator_catalogue_soundness_status() -> ProofBlockStatus:
    return ProofBlockStatus("SeparatorCatalogueSoundness", False, True, False, False, True)


fn separator_catalogue_completeness_status() -> ProofBlockStatus:
    return ProofBlockStatus("SeparatorCatalogueCompleteness", False, True, False, False, True)


fn fiber_definition_adapter_status() -> ProofBlockStatus:
    return ProofBlockStatus("FiberDefinitionAdapter", False, True, False, False, True)


fn residual_closure_no_missing_links_status() -> ProofBlockStatus:
    return ProofBlockStatus("ResidualClosureNoMissingLinks", False, False, True, False, True)


fn exit_closure_for_c1_status() -> ProofBlockStatus:
    return ProofBlockStatus("ExitClosureForC1", False, True, False, False, True)


fn boundary_equality_soundness_status() -> ProofBlockStatus:
    return ProofBlockStatus("BoundaryEqualitySoundness", False, True, False, False, True)


fn theorem_tag_import_soundness_status() -> ProofBlockStatus:
    return ProofBlockStatus("TheoremTagImportSoundness", False, True, False, False, True)


fn theorem_tag_import_ledger_status() -> ProofBlockStatus:
    return ProofBlockStatus("TheoremTagImportLedger", True, False, False, False, False)


fn theorem_tag_assumption_payloads_status() -> ProofBlockStatus:
    return ProofBlockStatus("TheoremTagAssumptionPayloads", True, False, False, False, False)


fn theorem_tag_payload_instances_status() -> ProofBlockStatus:
    return ProofBlockStatus("TheoremTagPayloadInstances", False, True, False, False, True)


fn block_ready_for_final(block: ProofBlockStatus) -> Bool:
    if not block.required_for_final:
        return True
    return block.proved_or_imported_checked and not block.scaffolded and not block.open_frontier and not block.research_only


fn final_ledger_ready_for_c1() -> Bool:
    return (
        block_ready_for_final(separator_catalogue_soundness_status()) and
        block_ready_for_final(separator_catalogue_completeness_status()) and
        block_ready_for_final(fiber_definition_adapter_status()) and
        block_ready_for_final(residual_closure_no_missing_links_status()) and
        block_ready_for_final(exit_closure_for_c1_status()) and
        block_ready_for_final(boundary_equality_soundness_status()) and
        block_ready_for_final(theorem_tag_import_soundness_status()) and
        block_ready_for_final(theorem_tag_payload_instances_status())
    )


fn current_priority_block() -> String:
    return "ResidualClosureNoMissingLinks"


fn next_immediate_block() -> String:
    return "TheoremTagPayloadInstances"


fn import_ledger_created() -> Bool:
    return True


fn assumption_payload_schema_created() -> Bool:
    return True


fn missing_link_exit_allowed_in_final() -> Bool:
    return False


fn bounded_search_allowed_as_final_evidence() -> Bool:
    return False


fn label_only_equality_allowed_as_final_evidence() -> Bool:
    return False


fn unchecked_theorem_tag_allowed_in_final() -> Bool:
    return False


fn rank2_locus_primitive_allowed_in_final() -> Bool:
    return False
