# Rejection-aware complex rational intervals and checked Horner evaluation.
# Specification: docs/rational-interval-arithmetic-spec.md (binding 6.2).
#
# Complex values are rank-2 coordinate interval records. Any rejected real
# interval operation rejects the whole result; no partial enclosure is emitted.

from checked_q import CheckedQBoolResult, normalize_checked_q
from checked_interval_q import CheckedIQResult, rejected_iq, make_checked_iq, checked_iq_point, checked_iq_add, checked_iq_sub, checked_iq_mul, checked_iq_square, checked_iq_subset_of


struct CheckedComplexIQResult(ImplicitlyCopyable):
    var re: CheckedIQResult
    var im: CheckedIQResult
    var rejected: Bool

    def __init__(out self, re: CheckedIQResult, im: CheckedIQResult, rejected: Bool):
        self.re = re
        self.im = im
        self.rejected = rejected

    def accepted(self) -> Bool:
        return not self.rejected


def rejected_complex_iq() -> CheckedComplexIQResult:
    return CheckedComplexIQResult(rejected_iq(), rejected_iq(), True)


def make_checked_complex_iq(re: CheckedIQResult, im: CheckedIQResult) -> CheckedComplexIQResult:
    if re.rejected or im.rejected:
        return rejected_complex_iq()
    return CheckedComplexIQResult(re, im, False)


def checked_complex_point(re_num: Int64, re_den: Int64, im_num: Int64, im_den: Int64) -> CheckedComplexIQResult:
    return make_checked_complex_iq(
        checked_iq_point(normalize_checked_q(re_num, re_den)),
        checked_iq_point(normalize_checked_q(im_num, im_den)),
    )


def checked_complex_add(a: CheckedComplexIQResult, b: CheckedComplexIQResult) -> CheckedComplexIQResult:
    if a.rejected or b.rejected:
        return rejected_complex_iq()
    return make_checked_complex_iq(checked_iq_add(a.re, b.re), checked_iq_add(a.im, b.im))


def checked_complex_sub(a: CheckedComplexIQResult, b: CheckedComplexIQResult) -> CheckedComplexIQResult:
    if a.rejected or b.rejected:
        return rejected_complex_iq()
    return make_checked_complex_iq(checked_iq_sub(a.re, b.re), checked_iq_sub(a.im, b.im))


def checked_complex_mul(a: CheckedComplexIQResult, b: CheckedComplexIQResult) -> CheckedComplexIQResult:
    if a.rejected or b.rejected:
        return rejected_complex_iq()
    var real_part = checked_iq_sub(checked_iq_mul(a.re, b.re), checked_iq_mul(a.im, b.im))
    var imag_part = checked_iq_add(checked_iq_mul(a.re, b.im), checked_iq_mul(a.im, b.re))
    return make_checked_complex_iq(real_part, imag_part)


def checked_complex_square(a: CheckedComplexIQResult) -> CheckedComplexIQResult:
    return checked_complex_mul(a, a)


def checked_complex_quadrance(a: CheckedComplexIQResult) -> CheckedIQResult:
    if a.rejected:
        return rejected_iq()
    return checked_iq_add(checked_iq_square(a.re), checked_iq_square(a.im))


def checked_complex_subset_of(a: CheckedComplexIQResult, b: CheckedComplexIQResult) -> CheckedQBoolResult:
    if a.rejected or b.rejected:
        return CheckedQBoolResult(False, True)
    var re_subset = checked_iq_subset_of(a.re, b.re)
    var im_subset = checked_iq_subset_of(a.im, b.im)
    if re_subset.rejected or im_subset.rejected:
        return CheckedQBoolResult(False, True)
    return CheckedQBoolResult(re_subset.value and im_subset.value, False)


def checked_complex_int_constant(value: Int64) -> CheckedComplexIQResult:
    return checked_complex_point(value, 1, 0, 1)


def eval_checked_poly_ascending_horner(c_box: CheckedComplexIQResult, coeffs: List[Int64]) -> CheckedComplexIQResult:
    if c_box.rejected:
        return rejected_complex_iq()
    var acc = checked_complex_int_constant(0)
    var idx = len(coeffs) - 1
    while idx >= 0:
        acc = checked_complex_add(checked_complex_mul(acc, c_box), checked_complex_int_constant(coeffs[idx]))
        if acc.rejected:
            return rejected_complex_iq()
        idx -= 1
    return acc


def eval_checked_p21(c_box: CheckedComplexIQResult) -> CheckedComplexIQResult:
    # P_{2,1}=C(C+2)=C^2+2C, ascending coefficients.
    return eval_checked_poly_ascending_horner(c_box, [0, 2, 1])


def eval_checked_p21_derivative(c_box: CheckedComplexIQResult) -> CheckedComplexIQResult:
    # P'_{2,1}=2C+2, explicitly listed to avoid unchecked coefficient products.
    return eval_checked_poly_ascending_horner(c_box, [2, 2])


def checked_complex_horner_smoke() -> Bool:
    var c_minus_two = checked_complex_point(-2, 1, 0, 1)
    var value = eval_checked_p21(c_minus_two)
    var derivative = eval_checked_p21_derivative(c_minus_two)
    var quadrance = checked_complex_quadrance(checked_complex_point(3, 1, 4, 1))
    var huge = checked_complex_point(3037000500, 1, 3037000500, 1)
    var overflow_value = eval_checked_p21(huge)
    var invalid = checked_complex_point(1, 0, 0, 1)
    return (
        value.accepted() and value.re.lo.num == 0 and value.re.hi.num == 0 and
        value.im.lo.num == 0 and value.im.hi.num == 0 and
        derivative.accepted() and derivative.re.lo.num == -2 and derivative.re.hi.num == -2 and
        quadrance.accepted() and quadrance.lo.num == 25 and quadrance.hi.num == 25 and
        overflow_value.rejected and invalid.rejected and
        eval_checked_p21(invalid).rejected
    )
