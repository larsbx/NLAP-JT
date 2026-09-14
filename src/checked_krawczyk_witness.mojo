# Rejection-aware checked Krawczyk witness for P_{2,1} at c = -2.
# Specification: docs/rational-interval-arithmetic-spec.md (binding 6.2).
#
# Arithmetic rejection and a valid non-contraction are distinct outcomes.
# Neither outcome is accepted as a localization witness.

from checked_int64_backend import checked_mul_i64
from checked_q import normalize_checked_q, checked_q_add, checked_q_sub, checked_q_neg
from checked_interval_q import make_checked_iq
from checked_complex_interval import CheckedComplexIQResult, rejected_complex_iq, make_checked_complex_iq, checked_complex_point, checked_complex_add, checked_complex_sub, checked_complex_mul, checked_complex_strict_subset_of, eval_checked_p21, eval_checked_p21_derivative


struct CheckedKrawczykResult(ImplicitlyCopyable):
    var contraction_verified: Bool
    var rejected: Bool

    def __init__(out self, contraction_verified: Bool, rejected: Bool):
        self.contraction_verified = contraction_verified
        self.rejected = rejected

    def accepted(self) -> Bool:
        return self.contraction_verified and not self.rejected


def checked_c_minus_2_box(half_width_den_power: Int) -> CheckedComplexIQResult:
    if half_width_den_power < 0:
        return rejected_complex_iq()
    var den = Int64(1)
    for _ in range(half_width_den_power):
        var doubled = checked_mul_i64(den, 2)
        if doubled.overflowed:
            return rejected_complex_iq()
        den = doubled.value
    var h = normalize_checked_q(1, den)
    var center = normalize_checked_q(-2, 1)
    var neg_h = checked_q_neg(h)
    var re = make_checked_iq(checked_q_sub(center, h), checked_q_add(center, h))
    var im = make_checked_iq(neg_h, h)
    return make_checked_complex_iq(re, im)


def checked_p21_krawczyk_image(beta: CheckedComplexIQResult) -> CheckedComplexIQResult:
    if beta.rejected:
        return rejected_complex_iq()
    # K(beta)=m-A P(m)+(1-A P'(beta))(beta-m), m=-2, A=-1/2.
    var m = checked_complex_point(-2, 1, 0, 1)
    var a = checked_complex_point(-1, 2, 0, 1)
    var one = checked_complex_point(1, 1, 0, 1)
    var p_m = eval_checked_p21(m)
    var beta_minus_m = checked_complex_sub(beta, m)
    var one_minus_a_dp = checked_complex_sub(one, checked_complex_mul(a, eval_checked_p21_derivative(beta)))
    return checked_complex_add(
        checked_complex_sub(m, checked_complex_mul(a, p_m)),
        checked_complex_mul(one_minus_a_dp, beta_minus_m),
    )


def verify_checked_p21_krawczyk(half_width_den_power: Int) -> CheckedKrawczykResult:
    var beta = checked_c_minus_2_box(half_width_den_power)
    var image = checked_p21_krawczyk_image(beta)
    if beta.rejected or image.rejected:
        return CheckedKrawczykResult(False, True)
    var strict = checked_complex_strict_subset_of(image, beta)
    if strict.rejected:
        return CheckedKrawczykResult(False, True)
    return CheckedKrawczykResult(strict.value, False)


def checked_krawczyk_smoke() -> Bool:
    var witness = verify_checked_p21_krawczyk(8)
    var invalid_half_width = verify_checked_p21_krawczyk(-1)
    var overflow_half_width = verify_checked_p21_krawczyk(63)
    var beta = checked_c_minus_2_box(8)
    var self_strict = checked_complex_strict_subset_of(beta, beta)
    return (
        witness.accepted() and
        invalid_half_width.rejected and not invalid_half_width.accepted() and
        overflow_half_width.rejected and not overflow_half_width.accepted() and
        not self_strict.rejected and not self_strict.value
    )
