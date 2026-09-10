# Mojo optimization contract for NLAP-JT finite computations.
#
# These functions are intentionally simple status hooks that tests can enforce
# while the optimized kernels mature.

struct KernelDiscipline:
    var name: String
    var uses_value_structs: Bool
    var separates_debug_from_proof_grade: Bool
    var avoids_heap_pressure: Bool
    var batchable: Bool
    var backend_boundary_explicit: Bool

    fn __init__(inout self, name: String, uses_value_structs: Bool, separates_debug_from_proof_grade: Bool, avoids_heap_pressure: Bool, batchable: Bool, backend_boundary_explicit: Bool):
        self.name = name
        self.uses_value_structs = uses_value_structs
        self.separates_debug_from_proof_grade = separates_debug_from_proof_grade
        self.avoids_heap_pressure = avoids_heap_pressure
        self.batchable = batchable
        self.backend_boundary_explicit = backend_boundary_explicit


fn polynomial_kernel_discipline() -> KernelDiscipline:
    return KernelDiscipline(
        "polynomial_horner_kernel",
        True,  # explicit value structs / arrays
        True,  # debug paths never proof-grade by default
        True,  # allocation-light target
        True,  # batchable over coefficient arrays / boxes
        True,  # arbitrary-precision backend boundary remains explicit
    )


fn separator_catalogue_kernel_discipline() -> KernelDiscipline:
    return KernelDiscipline(
        "separator_catalogue_scan",
        True,
        True,
        True,
        True,
        True,
    )


fn interval_kernel_discipline() -> KernelDiscipline:
    return KernelDiscipline(
        "interval_certificate_kernel",
        True,
        True,
        True,
        True,
        True,
    )


fn default_computation_language() -> String:
    return "Mojo"


fn python_reference_oracle_allowed() -> Bool:
    return True


fn python_primary_certificate_engine_allowed_after_mojo_port() -> Bool:
    return False


fn horner_polynomial_evaluation_required() -> Bool:
    return True


fn batchable_catalogue_scans_required() -> Bool:
    return True


fn debug_path_is_proof_grade() -> Bool:
    return False
