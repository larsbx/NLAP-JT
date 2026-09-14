# Fail-closed normalized rational transition layer.
# Specification: docs/rational-interval-arithmetic-spec.md (binding 6.2).
#
# Accepted results satisfy positive-denominator and gcd-normalization invariants.
# Rejected results are explicit no-results and must never enter a certificate.
# The minimum signed value is conservatively rejected because its magnitude is
# not representable by the checked Int64 transition backend.

from checked_int64_backend import I64_MIN, checked_add_i64, checked_sub_i64, checked_mul_i64, checked_neg_i64, denominator_is_valid_i64
from integer_gcd import gcd_i64_or_one


struct CheckedQResult(ImplicitlyCopyable):
    var num: Int64
    var den: Int64
    var rejected: Bool

    def __init__(out self, num: Int64, den: Int64, rejected: Bool):
        self.num = num
        self.den = den
        self.rejected = rejected

    def accepted(self) -> Bool:
        return not self.rejected


struct CheckedQBoolResult(ImplicitlyCopyable):
    var value: Bool
    var rejected: Bool

    def __init__(out self, value: Bool, rejected: Bool):
        self.value = value
        self.rejected = rejected


def rejected_q() -> CheckedQResult:
    return CheckedQResult(0, 1, True)


def normalize_checked_q(n: Int64, d: Int64) -> CheckedQResult:
    if n == I64_MIN or not denominator_is_valid_i64(d):
        return rejected_q()
    var nn = n
    var dd = d
    if dd < 0:
        var neg_n = checked_neg_i64(nn)
        var neg_d = checked_neg_i64(dd)
        if neg_n.overflowed or neg_d.overflowed:
            return rejected_q()
        nn = neg_n.value
        dd = neg_d.value
    if nn == 0:
        return CheckedQResult(0, 1, False)
    var divisor = gcd_i64_or_one(nn, dd)
    return CheckedQResult(nn // divisor, dd // divisor, False)


def checked_q_neg(a: CheckedQResult) -> CheckedQResult:
    if a.rejected:
        return rejected_q()
    var n = checked_neg_i64(a.num)
    if n.overflowed:
        return rejected_q()
    return CheckedQResult(n.value, a.den, False)


def checked_q_add(a: CheckedQResult, b: CheckedQResult) -> CheckedQResult:
    if a.rejected or b.rejected:
        return rejected_q()
    var common = gcd_i64_or_one(a.den, b.den)
    var a_scale = b.den // common
    var b_scale = a.den // common
    var left = checked_mul_i64(a.num, a_scale)
    var right = checked_mul_i64(b.num, b_scale)
    var den = checked_mul_i64(a.den, a_scale)
    if left.overflowed or right.overflowed or den.overflowed:
        return rejected_q()
    var num = checked_add_i64(left.value, right.value)
    if num.overflowed:
        return rejected_q()
    return normalize_checked_q(num.value, den.value)


def checked_q_sub(a: CheckedQResult, b: CheckedQResult) -> CheckedQResult:
    if a.rejected or b.rejected:
        return rejected_q()
    var common = gcd_i64_or_one(a.den, b.den)
    var a_scale = b.den // common
    var b_scale = a.den // common
    var left = checked_mul_i64(a.num, a_scale)
    var right = checked_mul_i64(b.num, b_scale)
    var den = checked_mul_i64(a.den, a_scale)
    if left.overflowed or right.overflowed or den.overflowed:
        return rejected_q()
    var num = checked_sub_i64(left.value, right.value)
    if num.overflowed:
        return rejected_q()
    return normalize_checked_q(num.value, den.value)


def checked_q_mul(a: CheckedQResult, b: CheckedQResult) -> CheckedQResult:
    if a.rejected or b.rejected:
        return rejected_q()
    # Cross-cancel before multiplication to avoid rejecting representable results.
    var g1 = gcd_i64_or_one(a.num, b.den)
    var g2 = gcd_i64_or_one(b.num, a.den)
    var num = checked_mul_i64(a.num // g1, b.num // g2)
    var den = checked_mul_i64(a.den // g2, b.den // g1)
    if num.overflowed or den.overflowed:
        return rejected_q()
    return normalize_checked_q(num.value, den.value)


def checked_q_div(a: CheckedQResult, b: CheckedQResult) -> CheckedQResult:
    if a.rejected or b.rejected or b.num == 0:
        return rejected_q()
    return checked_q_mul(a, normalize_checked_q(b.den, b.num))


def checked_q_eq(a: CheckedQResult, b: CheckedQResult) -> CheckedQBoolResult:
    if a.rejected or b.rejected:
        return CheckedQBoolResult(False, True)
    return CheckedQBoolResult(a.num == b.num and a.den == b.den, False)


def checked_q_lt(a: CheckedQResult, b: CheckedQResult) -> CheckedQBoolResult:
    if a.rejected or b.rejected:
        return CheckedQBoolResult(False, True)
    var left = checked_mul_i64(a.num, b.den)
    var right = checked_mul_i64(b.num, a.den)
    if left.overflowed or right.overflowed:
        return CheckedQBoolResult(False, True)
    return CheckedQBoolResult(left.value < right.value, False)


def checked_q_smoke() -> Bool:
    var half = normalize_checked_q(2, 4)
    var third = normalize_checked_q(1, 3)
    var sixth = checked_q_sub(half, third)
    var product = checked_q_mul(normalize_checked_q(3037000499, 2), normalize_checked_q(2, 3037000499))
    var order = checked_q_lt(third, half)
    return (
        half.accepted() and half.num == 1 and half.den == 2 and
        sixth.accepted() and sixth.num == 1 and sixth.den == 6 and
        product.accepted() and product.num == 1 and product.den == 1 and
        order.rejected == False and order.value and
        normalize_checked_q(1, 0).rejected and
        normalize_checked_q(I64_MIN, 1).rejected and
        checked_q_div(half, normalize_checked_q(0, 1)).rejected and
        checked_q_add(normalize_checked_q(9223372036854775807, 1), normalize_checked_q(1, 1)).rejected and
        checked_q_mul(normalize_checked_q(3037000500, 1), normalize_checked_q(3037000500, 1)).rejected and
        checked_q_lt(normalize_checked_q(9223372036854775807, 2), normalize_checked_q(9223372036854775807, 3)).rejected
    )
