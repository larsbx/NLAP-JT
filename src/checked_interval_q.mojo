# Rejection-aware rational interval transition layer.
# Specification: docs/rational-interval-arithmetic-spec.md (binding 6.2).
#
# Accepted intervals enforce lo <= hi. Every endpoint failure or unsafe
# comparison propagates as an explicit rejected no-result.

from checked_q import CheckedQResult, CheckedQBoolResult, rejected_q, normalize_checked_q, checked_q_add, checked_q_sub, checked_q_mul, checked_q_div, checked_q_neg, checked_q_eq, checked_q_lt


struct CheckedIQResult(ImplicitlyCopyable):
    var lo: CheckedQResult
    var hi: CheckedQResult
    var rejected: Bool

    def __init__(out self, lo: CheckedQResult, hi: CheckedQResult, rejected: Bool):
        self.lo = lo
        self.hi = hi
        self.rejected = rejected

    def accepted(self) -> Bool:
        return not self.rejected


struct CheckedSignResult(ImplicitlyCopyable):
    # code is -1 for strictly negative, 1 for strictly positive, and 0 for
    # unknown. A rejected result is not a mathematical sign.
    var code: Int
    var rejected: Bool

    def __init__(out self, code: Int, rejected: Bool):
        self.code = code
        self.rejected = rejected


def rejected_iq() -> CheckedIQResult:
    return CheckedIQResult(rejected_q(), rejected_q(), True)


def checked_q_le(a: CheckedQResult, b: CheckedQResult) -> CheckedQBoolResult:
    var less = checked_q_lt(a, b)
    if less.rejected:
        return CheckedQBoolResult(False, True)
    if less.value:
        return CheckedQBoolResult(True, False)
    return checked_q_eq(a, b)


def make_checked_iq(lo: CheckedQResult, hi: CheckedQResult) -> CheckedIQResult:
    if lo.rejected or hi.rejected:
        return rejected_iq()
    var ordered = checked_q_le(lo, hi)
    if ordered.rejected or not ordered.value:
        return rejected_iq()
    return CheckedIQResult(lo, hi, False)


def checked_iq_point(value: CheckedQResult) -> CheckedIQResult:
    return make_checked_iq(value, value)


def checked_q_min(a: CheckedQResult, b: CheckedQResult) -> CheckedQResult:
    var order = checked_q_lt(a, b)
    if order.rejected:
        return rejected_q()
    if order.value:
        return a
    return b


def checked_q_max(a: CheckedQResult, b: CheckedQResult) -> CheckedQResult:
    var order = checked_q_lt(a, b)
    if order.rejected:
        return rejected_q()
    if order.value:
        return b
    return a


def checked_iq_add(a: CheckedIQResult, b: CheckedIQResult) -> CheckedIQResult:
    if a.rejected or b.rejected:
        return rejected_iq()
    return make_checked_iq(checked_q_add(a.lo, b.lo), checked_q_add(a.hi, b.hi))


def checked_iq_sub(a: CheckedIQResult, b: CheckedIQResult) -> CheckedIQResult:
    if a.rejected or b.rejected:
        return rejected_iq()
    return make_checked_iq(checked_q_sub(a.lo, b.hi), checked_q_sub(a.hi, b.lo))


def checked_iq_neg(a: CheckedIQResult) -> CheckedIQResult:
    if a.rejected:
        return rejected_iq()
    return make_checked_iq(checked_q_neg(a.hi), checked_q_neg(a.lo))


def checked_iq_mul(a: CheckedIQResult, b: CheckedIQResult) -> CheckedIQResult:
    if a.rejected or b.rejected:
        return rejected_iq()
    var p1 = checked_q_mul(a.lo, b.lo)
    var p2 = checked_q_mul(a.lo, b.hi)
    var p3 = checked_q_mul(a.hi, b.lo)
    var p4 = checked_q_mul(a.hi, b.hi)
    if p1.rejected or p2.rejected or p3.rejected or p4.rejected:
        return rejected_iq()
    var lo = checked_q_min(checked_q_min(p1, p2), checked_q_min(p3, p4))
    var hi = checked_q_max(checked_q_max(p1, p2), checked_q_max(p3, p4))
    return make_checked_iq(lo, hi)


def checked_iq_sign(a: CheckedIQResult) -> CheckedSignResult:
    if a.rejected:
        return CheckedSignResult(0, True)
    var zero = normalize_checked_q(0, 1)
    var positive = checked_q_lt(zero, a.lo)
    var negative = checked_q_lt(a.hi, zero)
    if positive.rejected or negative.rejected:
        return CheckedSignResult(0, True)
    if positive.value:
        return CheckedSignResult(1, False)
    if negative.value:
        return CheckedSignResult(-1, False)
    return CheckedSignResult(0, False)


def checked_iq_contains_zero(a: CheckedIQResult) -> CheckedQBoolResult:
    var sign = checked_iq_sign(a)
    if sign.rejected:
        return CheckedQBoolResult(False, True)
    return CheckedQBoolResult(sign.code == 0, False)


def checked_iq_reciprocal(a: CheckedIQResult) -> CheckedIQResult:
    var contains = checked_iq_contains_zero(a)
    if contains.rejected or contains.value:
        return rejected_iq()
    var one = normalize_checked_q(1, 1)
    return make_checked_iq(checked_q_div(one, a.hi), checked_q_div(one, a.lo))


def checked_iq_square(a: CheckedIQResult) -> CheckedIQResult:
    var contains = checked_iq_contains_zero(a)
    if contains.rejected:
        return rejected_iq()
    if contains.value:
        var lo_square = checked_q_mul(a.lo, a.lo)
        var hi_square = checked_q_mul(a.hi, a.hi)
        return make_checked_iq(normalize_checked_q(0, 1), checked_q_max(lo_square, hi_square))
    return checked_iq_mul(a, a)


def checked_iq_subset_of(a: CheckedIQResult, b: CheckedIQResult) -> CheckedQBoolResult:
    if a.rejected or b.rejected:
        return CheckedQBoolResult(False, True)
    var lower = checked_q_le(b.lo, a.lo)
    var upper = checked_q_le(a.hi, b.hi)
    if lower.rejected or upper.rejected:
        return CheckedQBoolResult(False, True)
    return CheckedQBoolResult(lower.value and upper.value, False)


def checked_iq_smoke() -> Bool:
    var x = make_checked_iq(normalize_checked_q(1, 1), normalize_checked_q(3, 1))
    var y = make_checked_iq(normalize_checked_q(-1, 1), normalize_checked_q(2, 1))
    var z = make_checked_iq(normalize_checked_q(2, 1), normalize_checked_q(5, 1))
    var product = checked_iq_mul(x, y)
    var dependency = checked_iq_sub(x, x)
    var lhs = checked_iq_mul(x, checked_iq_add(y, z))
    var rhs = checked_iq_add(checked_iq_mul(x, y), checked_iq_mul(x, z))
    var subset = checked_iq_subset_of(lhs, rhs)
    var positive = checked_iq_sign(x)
    var negative = checked_iq_sign(make_checked_iq(normalize_checked_q(-3, 1), normalize_checked_q(-1, 1)))
    var unknown = checked_iq_sign(y)
    var overflowing = checked_iq_mul(
        checked_iq_point(normalize_checked_q(3037000500, 1)),
        checked_iq_point(normalize_checked_q(3037000500, 1)),
    )
    return (
        product.accepted() and product.lo.num == -3 and product.hi.num == 6 and
        dependency.accepted() and dependency.lo.num == -2 and dependency.hi.num == 2 and
        subset.rejected == False and subset.value and
        positive.code == 1 and not positive.rejected and
        negative.code == -1 and not negative.rejected and
        unknown.code == 0 and not unknown.rejected and
        make_checked_iq(normalize_checked_q(2, 1), normalize_checked_q(1, 1)).rejected and
        checked_iq_reciprocal(y).rejected and
        overflowing.rejected
    )
