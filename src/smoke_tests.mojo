# smoke_tests.mojo
# Specification: docs/rational-interval-arithmetic-spec.md (binding 6.2).
#
# Smoke-test harness for the finite-regime Mandelbrot computation layer.
#
# These tests are intentionally narrow. They preserve the computations already
# used in the research notes while marking the gap between arithmetic smoke
# tests and a full proof-carrying validator.

from poly_z import smoke_poly_identities
from cert_types import MisCertHeader, JointBoxWitness, TheoremTags
from rat_q import Q, demo_q_normalization, demo_q_order
from interval_q import IQ, ComplexIQ, demo_interval_mul, demo_complex_quadrance_point
from poly_interval_eval import eval_p21, demo_poly_interval_eval_status
from krawczyk_witness import verify_p21_krawczyk_c_minus_2
from C1_final_proof_block_ledger import FinalEvidencePolicy, canonical_final_evidence_policy, final_evidence_policy_valid, final_ledger_ready_for_c1, current_priority_block, next_immediate_block
from C1_residual_closure_no_missing_links import FinalExitKind, accepted_final_exit, rejected_final_exit
from C1_theorem_tag_assumption_payloads import AssumptionPayloadKind, PayloadConclusionKind, PayloadStrengthClass, allowed_payload_kind, allowed_payload_conclusion, allowed_payload_strength, theorem_tag_payload_admissible, rational_parameter_ray_landing_payload_scaffold, fiber_definition_payload_scaffold, generic_mlc_payload_rejected, bounded_search_payload_rejected
from C1_theorem_tag_import_ledger import ImportConclusionKind, ImportStrengthClass, ImportStatus, allowed_conclusion_kind, allowed_strength_class, forbidden_strength_class, rational_parameter_ray_landing_tag_ready, fiber_definition_equivalence_tag_ready, known_trivial_fiber_class_tag_ready, theorem_tag_admissible_for_final
from integer_gcd import gcd_int, gcd_i64, gcd_i64_or_one
from ray_address import RayAddr, RayAddr64, same_ray_addr, ray_addr_before
from rational_trig import demo_spread_orthogonal_axes, demo_ray_addr_doubling_half
from alignment_audit_status import AlignmentPolicy, canonical_alignment_policy, alignment_policy_valid
from mojo_optimization_contract import OptimizationPolicy, canonical_optimization_policy, optimization_policy_valid
from C1_final_proof_object_skeleton import C1FinalProofObject, FinalProofAcceptancePolicy, canonical_final_proof_acceptance_policy, final_proof_acceptance_policy_valid, accepts_c1_final_proof_object, rejects_missing_link_final_exit, skeleton_alone_proves_c1
from checked_int64_backend import checked_i64_boundary_smoke
from checked_q import checked_q_smoke
from checked_interval_q import checked_iq_smoke
from checked_complex_interval import checked_complex_horner_smoke
from checked_interval_exclusion import checked_interval_exclusion_smoke
from checked_krawczyk_witness import checked_krawczyk_smoke
from cert_backend import cert_backend_smoke
from certificate_arithmetic_migration_gate import certificate_arithmetic_migration_smoke
from checked_ray_address import checked_ray_address_smoke
from checked_finite_certificate_gate import checked_finite_certificate_gate_smoke
from C1_theorem_tag_payload_instances import theorem_tag_payload_instances_smoke
from checked_landing_target_adapter import checked_landing_target_adapter_smoke
from bigint_z import bigint_z_phase_one_smoke, bigint_z_phase_two_smoke
from bigint_adapter import bigint_adapter_phase_one_smoke, bigint_adapter_phase_two_smoke


def test_rational_field_laws() -> Bool:
    # docs/rational-interval-arithmetic-spec.md section 1.3: decidable
    # equality, associativity, distributivity, lossless cancellation.
    var a = Q(1, 3)
    var b = Q(1, 7)
    var c = Q(-2, 9)
    return (
        Q(1, 10).add(Q(2, 10)).eq(Q(3, 10)) and
        a.add(b).add(c).eq(a.add(b.add(c))) and
        a.mul(b.add(c)).eq(a.mul(b).add(a.mul(c))) and
        a.add(b).sub(b).eq(a) and
        Q(1, 3).lt(Q(1, 2))
    )


def test_interval_enclosure_laws() -> Bool:
    # docs/rational-interval-arithmetic-spec.md sections 2.2 to 2.5: the
    # dependency problem, subdistributivity, and the tighter square.
    var x = IQ(Q(1, 1), Q(3, 1))
    var y = IQ(Q(-1, 1), Q(2, 1))
    var z = IQ(Q(2, 1), Q(5, 1))
    var d = x.sub(x)
    var lhs = x.mul(y.add(z))
    var rhs = x.mul(y).add(x.mul(z))
    return (
        d.lo.eq(Q(-2, 1)) and d.hi.eq(Q(2, 1)) and d.contains_zero() and
        lhs.subset_of(rhs) and
        y.square().subset_of(y.mul(y)) and not y.mul(y).subset_of(y.square()) and
        x.excludes_zero() and not y.excludes_zero()
    )


def test_interval_polynomial_evaluation() -> Bool:
    var c_minus_2 = ComplexIQ.point(Q(-2, 1), Q.zero())
    var value = eval_p21(c_minus_2)
    var status = demo_poly_interval_eval_status()
    return (
        value.re.lo.eq(Q.zero()) and value.re.hi.eq(Q.zero()) and
        value.im.lo.eq(Q.zero()) and value.im.hi.eq(Q.zero()) and
        status.scaffold_accepted() and not status.certificate_ready()
    )


def test_final_proof_ledger_policy() -> Bool:
    var canonical = canonical_final_evidence_policy()
    var unsafe = FinalEvidencePolicy(True, False, False, False, False)
    return (
        final_evidence_policy_valid(canonical) and
        not final_evidence_policy_valid(unsafe) and
        not final_ledger_ready_for_c1() and
        current_priority_block() == "ResidualClosureNoMissingLinks" and
        next_immediate_block() == "TheoremTagPayloadInstances"
    )


def test_typed_final_exit_kinds() -> Bool:
    return (
        accepted_final_exit(FinalExitKind.finite_separation()) and
        accepted_final_exit(FinalExitKind.boundary_equality()) and
        accepted_final_exit(FinalExitKind.established_trivial_fiber()) and
        rejected_final_exit(FinalExitKind.missing_theorem_catalogue_link()) and
        rejected_final_exit(FinalExitKind.open_analytic_assumption()) and
        rejected_final_exit(FinalExitKind.bounded_search_failure()) and
        rejected_final_exit(FinalExitKind.label_equality_only()) and
        not accepted_final_exit(FinalExitKind(99))
    )


def test_typed_theorem_payload_kinds() -> Bool:
    return (
        allowed_payload_kind(AssumptionPayloadKind.rational_ray_landing()) and
        allowed_payload_conclusion(PayloadConclusionKind.ray_landing()) and
        allowed_payload_strength(PayloadStrengthClass.adapter_only()) and
        allowed_payload_strength(PayloadStrengthClass.local_landing()) and
        allowed_payload_strength(PayloadStrengthClass.class_specific_fiber_triviality()) and
        allowed_payload_strength(PayloadStrengthClass.class_specific_local_connectivity()) and
        not allowed_payload_kind(AssumptionPayloadKind(99)) and
        not allowed_payload_conclusion(PayloadConclusionKind(99)) and
        not allowed_payload_strength(PayloadStrengthClass(99)) and
        theorem_tag_payload_admissible(rational_parameter_ray_landing_payload_scaffold()) and
        theorem_tag_payload_admissible(fiber_definition_payload_scaffold()) and
        generic_mlc_payload_rejected() and
        bounded_search_payload_rejected()
    )


def test_typed_theorem_import_kinds() -> Bool:
    return (
        allowed_conclusion_kind(ImportConclusionKind.rational_ray_landing()) and
        allowed_strength_class(ImportStrengthClass.finite_only()) and
        forbidden_strength_class(ImportStrengthClass.global_mlc()) and
        not allowed_conclusion_kind(ImportConclusionKind(99)) and
        not allowed_strength_class(ImportStrengthClass(99)) and
        not theorem_tag_admissible_for_final(rational_parameter_ray_landing_tag_ready()) and
        not theorem_tag_admissible_for_final(fiber_definition_equivalence_tag_ready()) and
        not theorem_tag_admissible_for_final(known_trivial_fiber_class_tag_ready()) and
        ImportStatus.checked().code != ImportStatus.scaffolded().code
    )


def test_canonical_gcd_helpers() -> Bool:
    return (
        gcd_int(-54, 24) == 6 and
        gcd_int(0, 0) == 0 and
        gcd_i64(-54, 24) == 6 and
        gcd_i64(0, 0) == 0 and
        gcd_i64_or_one(0, 0) == 1
    )


def test_canonical_ray_addresses() -> Bool:
    var one_third = RayAddr(1, 3)
    var one_half = RayAddr(1, 2)
    var doubled = one_third.doubled()
    var doubled64 = RayAddr64(1, 2).doubled()
    return (
        one_third.normalized() and
        not RayAddr(2, 4).normalized() and
        doubled.num == 2 and doubled.den == 3 and
        ray_addr_before(one_half, one_third) and
        same_ray_addr(one_third, RayAddr(1, 3)) and
        doubled64.num == 0 and doubled64.den == 2
    )


def test_canonical_rational_geometry() -> Bool:
    var spread_value = demo_spread_orthogonal_axes()
    var doubled_half = demo_ray_addr_doubling_half()
    return (
        spread_value.eq(Q.one()) and
        doubled_half.num == 0 and doubled_half.den == 2
    )


def test_alignment_policy_data() -> Bool:
    var canonical = canonical_alignment_policy()
    var unsafe = AlignmentPolicy(True, True, True, True, False, False, False, True, True)
    return alignment_policy_valid(canonical) and not alignment_policy_valid(unsafe)


def test_optimization_policy_data() -> Bool:
    var canonical = canonical_optimization_policy()
    var unsafe = OptimizationPolicy("Mojo", "Mojo", True, False, False, True, True, True, True, True)
    return optimization_policy_valid(canonical) and not optimization_policy_valid(unsafe)


def test_final_proof_object_policy_data() -> Bool:
    var policy = canonical_final_proof_acceptance_policy()
    var unsafe_policy = FinalProofAcceptancePolicy(False, True, True, True, True, False, False)
    var complete = C1FinalProofObject(True, True, True, True, True, True, True, True, True, True, True, True, True)
    var missing_link = C1FinalProofObject(True, True, True, True, True, True, True, True, False, True, True, True, True)
    return (
        final_proof_acceptance_policy_valid(policy) and
        not final_proof_acceptance_policy_valid(unsafe_policy) and
        accepts_c1_final_proof_object(complete) and
        not accepts_c1_final_proof_object(missing_link) and
        rejects_missing_link_final_exit(policy) and
        not skeleton_alone_proves_c1(policy)
    )


def test_headers() -> Bool:
    # c = -2: critical type (ell,k)=(2,1), angle preperiod lambda=1, ray period n=1.
    var c_minus_2 = MisCertHeader(2, 1, 3, 1)
    if not c_minus_2.header_ok():
        return False

    # M_{4,1}: critical type (ell,k)=(4,1), horizon H=6, ray period n=3.
    # This checks the corrected distinction: ray period n can exceed orbit period k.
    var m41 = MisCertHeader(4, 1, 6, 3)
    if not m41.header_ok():
        return False

    return True


def test_joint_box_gate() -> Bool:
    # The gate must reject unless the same beta supports both localization and
    # forbidden-collision exclusion.
    var ok = JointBoxWitness(True, True, True)
    if not ok.accepts():
        return False

    var no_exclusion = JointBoxWitness(True, False, True)
    if no_exclusion.accepts():
        return False

    var wrong_box = JointBoxWitness(True, True, False)
    if wrong_box.accepts():
        return False

    return True


def test_theorem_tags() -> Bool:
    var ok = TheoremTags(True, True)
    if not ok.accepts():
        return False

    var missing_fiber = TheoremTags(True, False)
    if missing_fiber.accepts():
        return False

    return True


def run_smoke_tests() -> Bool:
    if not smoke_poly_identities():
        return False
    if not test_headers():
        return False
    if not test_joint_box_gate():
        return False
    if not test_theorem_tags():
        return False
    if not demo_q_normalization() or not demo_q_order():
        return False
    if not demo_interval_mul() or not demo_complex_quadrance_point():
        return False
    if not test_rational_field_laws():
        return False
    if not test_interval_enclosure_laws():
        return False
    if not test_interval_polynomial_evaluation():
        return False
    if not verify_p21_krawczyk_c_minus_2(8):
        return False
    if not test_final_proof_ledger_policy():
        return False
    if not test_typed_final_exit_kinds():
        return False
    if not test_typed_theorem_payload_kinds():
        return False
    if not test_typed_theorem_import_kinds():
        return False
    if not test_canonical_gcd_helpers():
        return False
    if not test_canonical_ray_addresses():
        return False
    if not test_canonical_rational_geometry():
        return False
    if not test_alignment_policy_data():
        return False
    if not test_optimization_policy_data():
        return False
    if not test_final_proof_object_policy_data():
        return False
    if not checked_i64_boundary_smoke():
        return False
    if not checked_q_smoke():
        return False
    if not checked_iq_smoke():
        return False
    if not checked_complex_horner_smoke():
        return False
    if not checked_interval_exclusion_smoke():
        return False
    if not checked_krawczyk_smoke():
        return False
    if not cert_backend_smoke():
        return False
    if not certificate_arithmetic_migration_smoke():
        return False
    if not checked_ray_address_smoke():
        return False
    if not checked_finite_certificate_gate_smoke():
        return False
    if not theorem_tag_payload_instances_smoke():
        return False
    if not checked_landing_target_adapter_smoke():
        return False
    if not bigint_z_phase_one_smoke():
        return False
    if not bigint_adapter_phase_one_smoke():
        return False
    if not bigint_z_phase_two_smoke():
        return False
    if not bigint_adapter_phase_two_smoke():
        return False
    return True


def require_smoke_success(ok: Bool) raises:
    if not ok:
        raise Error("finite-regime Mandelbrot smoke tests: FAIL")


def main() raises:
    require_smoke_success(run_smoke_tests())
    print("finite-regime Mandelbrot smoke tests: PASS")
