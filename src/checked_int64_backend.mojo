# Checked fixed-width integer primitives for the rational-backend migration.
# Specification: docs/rational-interval-arithmetic-spec.md (section 1.5).
#
# This is a fail-closed transition layer, not a bigint implementation. A result
# with `overflowed == True` carries no arithmetic value suitable for a
# certificate. Proof-grade acceptance remains disabled in backend.toml.

comptime I64_MAX = Int64(9223372036854775807)
comptime I64_MIN = Int64(-9223372036854775807 - 1)


struct CheckedI64Result(ImplicitlyCopyable):
    var value: Int64
    var overflowed: Bool

    def __init__(out self, value: Int64, overflowed: Bool):
        self.value = value
        self.overflowed = overflowed

    def accepted(self) -> Bool:
        return not self.overflowed


def overflow_result() -> CheckedI64Result:
    return CheckedI64Result(0, True)


def checked_add_i64(a: Int64, b: Int64) -> CheckedI64Result:
    if b > 0 and a > I64_MAX - b:
        return overflow_result()
    if b < 0 and a < I64_MIN - b:
        return overflow_result()
    return CheckedI64Result(a + b, False)


def checked_sub_i64(a: Int64, b: Int64) -> CheckedI64Result:
    if b > 0 and a < I64_MIN + b:
        return overflow_result()
    if b < 0 and a > I64_MAX + b:
        return overflow_result()
    return CheckedI64Result(a - b, False)


def checked_neg_i64(a: Int64) -> CheckedI64Result:
    if a == I64_MIN:
        return overflow_result()
    return CheckedI64Result(-a, False)


def checked_mul_i64(a: Int64, b: Int64) -> CheckedI64Result:
    if a == 0 or b == 0:
        return CheckedI64Result(0, False)
    if (a == I64_MIN and b == -1) or (b == I64_MIN and a == -1):
        return overflow_result()
    if a > 0:
        if b > 0 and a > I64_MAX // b:
            return overflow_result()
        if b < 0 and b < I64_MIN // a:
            return overflow_result()
    else:
        if b > 0 and a < I64_MIN // b:
            return overflow_result()
        if b < 0 and b < I64_MAX // a:
            return overflow_result()
    return CheckedI64Result(a * b, False)


def denominator_is_valid_i64(denominator: Int64) -> Bool:
    return denominator != 0 and denominator != I64_MIN


def q8_growth_must_overflow_i64() -> Bool:
    # The maximum Q_7 coefficient is 17,999,433,372. Its square already
    # exceeds Int64, so the Q_8 recurrence cannot be admitted by this backend.
    return checked_mul_i64(17999433372, 17999433372).overflowed


def checked_i64_boundary_smoke() -> Bool:
    return (
        checked_add_i64(I64_MAX, 1).overflowed and
        checked_sub_i64(I64_MIN, 1).overflowed and
        checked_neg_i64(I64_MIN).overflowed and
        checked_mul_i64(I64_MIN, -1).overflowed and
        checked_mul_i64(-1, I64_MIN).overflowed and
        checked_mul_i64(I64_MAX, 2).overflowed and
        checked_mul_i64(I64_MIN, 2).overflowed and
        checked_mul_i64(3037000499, 3037000499).accepted() and
        checked_mul_i64(-3037000499, 3037000499).accepted() and
        checked_mul_i64(-3037000499, -3037000499).accepted() and
        not denominator_is_valid_i64(0) and
        not denominator_is_valid_i64(I64_MIN) and
        denominator_is_valid_i64(1) and
        q8_growth_must_overflow_i64()
    )
