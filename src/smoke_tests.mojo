# smoke_tests.mojo
#
# Smoke-test harness for the finite-regime Mandelbrot computation layer.
#
# These tests are intentionally narrow. They preserve the computations already
# used in the research notes while marking the gap between arithmetic smoke
# tests and a full proof-carrying validator.

from poly_z import smoke_poly_identities
from cert_types import MisCertHeader, JointBoxWitness, TheoremTags


fn test_headers() -> Bool:
    # c = -2: critical type (ell,k)=(2,1), angle preperiod lambda=1, ray period n=1.
    let c_minus_2 = MisCertHeader(2, 1, 3, 1)
    if not c_minus_2.header_ok():
        return False

    # M_{4,1}: critical type (ell,k)=(4,1), horizon H=6, ray period n=3.
    # This checks the corrected distinction: ray period n can exceed orbit period k.
    let m41 = MisCertHeader(4, 1, 6, 3)
    if not m41.header_ok():
        return False

    return True


fn test_joint_box_gate() -> Bool:
    # The gate must reject unless the same beta supports both localization and
    # forbidden-collision exclusion.
    let ok = JointBoxWitness(True, True, True)
    if not ok.accepts():
        return False

    let no_exclusion = JointBoxWitness(True, False, True)
    if no_exclusion.accepts():
        return False

    let wrong_box = JointBoxWitness(True, True, False)
    if wrong_box.accepts():
        return False

    return True


fn test_theorem_tags() -> Bool:
    let ok = TheoremTags(True, True)
    if not ok.accepts():
        return False

    let missing_fiber = TheoremTags(True, False)
    if missing_fiber.accepts():
        return False

    return True


fn run_smoke_tests() -> Bool:
    if not smoke_poly_identities():
        return False
    if not test_headers():
        return False
    if not test_joint_box_gate():
        return False
    if not test_theorem_tags():
        return False
    return True


fn main():
    if run_smoke_tests():
        print("finite-regime Mandelbrot smoke tests: PASS")
    else:
        print("finite-regime Mandelbrot smoke tests: FAIL")
