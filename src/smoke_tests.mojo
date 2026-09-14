# smoke_tests.mojo
#
# Smoke-test harness for the finite-regime Mandelbrot computation layer.
#
# These tests are intentionally narrow. They preserve the computations already
# used in the research notes while marking the gap between arithmetic smoke
# tests and a full proof-carrying validator.

from poly_z import smoke_poly_identities
from cert_types import MisCertHeader, JointBoxWitness, TheoremTags
from rat_q import Q, demo_q_normalization, demo_q_order
from interval_q import ComplexIQ, demo_interval_mul, demo_complex_quadrance_point
from poly_interval_eval import eval_p21, demo_poly_interval_eval_status
from krawczyk_witness import verify_p21_krawczyk_c_minus_2
from C1_final_proof_block_ledger import FinalEvidencePolicy, canonical_final_evidence_policy, final_evidence_policy_valid, final_ledger_ready_for_c1, current_priority_block, next_immediate_block
from C1_residual_closure_no_missing_links import FinalExitKind, accepted_final_exit, rejected_final_exit


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
    if not test_interval_polynomial_evaluation():
        return False
    if not verify_p21_krawczyk_c_minus_2(8):
        return False
    if not test_final_proof_ledger_policy():
        return False
    if not test_typed_final_exit_kinds():
        return False
    return True


def require_smoke_success(ok: Bool) raises:
    if not ok:
        raise Error("finite-regime Mandelbrot smoke tests: FAIL")


def main() raises:
    require_smoke_success(run_smoke_tests())
    print("finite-regime Mandelbrot smoke tests: PASS")
