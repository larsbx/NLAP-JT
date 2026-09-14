# Mojo-native dynamic-limb signed integers, migration phase one.
# Specification: docs/rational-interval-arithmetic-spec.md (section 1.5).
#
# Limbs are little-endian in base 10^9. Dynamic List storage removes the fixed
# Int64 magnitude bound. This phase implements exact construction, add, sub,
# mul, equality, order, quotient/remainder, exact division, and Euclidean gcd.
# Canonical serialization uses sign, fixed-width byte length, and minimal
# big-endian magnitude. Higher rational and certificate layers remain separate.

comptime BIGZ_BASE = UInt64(1000000000)


struct BigZ(Copyable):
    var sign: Int
    var limbs: List[UInt64]

    def __init__(out self):
        self.sign = 0
        self.limbs = List[UInt64]()

    def normalize(mut self):
        while len(self.limbs) > 0 and self.limbs[len(self.limbs) - 1] == 0:
            _ = self.limbs.pop()
        if len(self.limbs) == 0:
            self.sign = 0

    def is_zero(self) -> Bool:
        return self.sign == 0

    def limb_count(self) -> Int:
        return len(self.limbs)

    def limb(self, index: Int) -> UInt64:
        if index < 0 or index >= len(self.limbs):
            return 0
        return self.limbs[index]


struct BigZDivModResult(Copyable):
    var quotient: BigZ
    var remainder: BigZ
    var rejected: Bool

    def __init__(out self):
        self.quotient = BigZ()
        self.remainder = BigZ()
        self.rejected = False


struct BigZExactDivisionResult(Copyable):
    var quotient: BigZ
    var rejected: Bool

    def __init__(out self):
        self.quotient = BigZ()
        self.rejected = False


struct BigZCanonicalBytes(Copyable):
    var bytes: List[UInt8]
    var rejected: Bool

    def __init__(out self):
        self.bytes = List[UInt8]()
        self.rejected = False


def bigz_zero() -> BigZ:
    return BigZ()


def bigz_from_i64(value: Int64) -> BigZ:
    var out = BigZ()
    if value == 0:
        return out^
    var magnitude: UInt64
    if value < 0:
        out.sign = -1
        magnitude = UInt64(-(value + 1)) + 1
    else:
        out.sign = 1
        magnitude = UInt64(value)
    while magnitude > 0:
        out.limbs.append(magnitude % BIGZ_BASE)
        magnitude = magnitude // BIGZ_BASE
    return out^


def bigz_abs_compare(a: BigZ, b: BigZ) -> Int:
    if len(a.limbs) < len(b.limbs):
        return -1
    if len(a.limbs) > len(b.limbs):
        return 1
    var idx = len(a.limbs) - 1
    while idx >= 0:
        if a.limbs[idx] < b.limbs[idx]:
            return -1
        if a.limbs[idx] > b.limbs[idx]:
            return 1
        idx -= 1
    return 0


def bigz_abs_add(a: BigZ, b: BigZ) -> BigZ:
    var out = BigZ()
    out.sign = 1
    var width = len(a.limbs)
    if len(b.limbs) > width:
        width = len(b.limbs)
    var carry = UInt64(0)
    for idx in range(width):
        var total = a.limb(idx) + b.limb(idx) + carry
        out.limbs.append(total % BIGZ_BASE)
        carry = total // BIGZ_BASE
    if carry > 0:
        out.limbs.append(carry)
    out.normalize()
    return out^


def bigz_abs_sub(a: BigZ, b: BigZ) -> BigZ:
    # Caller contract: abs(a) >= abs(b).
    var out = BigZ()
    out.sign = 1
    var borrow = UInt64(0)
    for idx in range(len(a.limbs)):
        var ai = a.limbs[idx]
        var bi = b.limb(idx) + borrow
        if ai >= bi:
            out.limbs.append(ai - bi)
            borrow = 0
        else:
            out.limbs.append(ai + BIGZ_BASE - bi)
            borrow = 1
    out.normalize()
    return out^


def bigz_neg(a: BigZ) -> BigZ:
    var out = a.copy()
    out.sign = -out.sign
    return out^


def bigz_abs(a: BigZ) -> BigZ:
    var out = a.copy()
    if out.sign < 0:
        out.sign = 1
    return out^


def bigz_add(a: BigZ, b: BigZ) -> BigZ:
    if a.sign == 0:
        return b.copy()
    if b.sign == 0:
        return a.copy()
    if a.sign == b.sign:
        var same_sign = bigz_abs_add(a, b)
        same_sign.sign = a.sign
        return same_sign^
    var order = bigz_abs_compare(a, b)
    if order == 0:
        return bigz_zero()
    if order > 0:
        var left = bigz_abs_sub(a, b)
        left.sign = a.sign
        return left^
    var right = bigz_abs_sub(b, a)
    right.sign = b.sign
    return right^


def bigz_sub(a: BigZ, b: BigZ) -> BigZ:
    return bigz_add(a, bigz_neg(b))


def bigz_mul(a: BigZ, b: BigZ) -> BigZ:
    if a.sign == 0 or b.sign == 0:
        return bigz_zero()
    var out = BigZ()
    out.sign = a.sign * b.sign
    for _ in range(len(a.limbs) + len(b.limbs)):
        out.limbs.append(0)
    for i in range(len(a.limbs)):
        var carry = UInt64(0)
        for j in range(len(b.limbs)):
            var index = i + j
            var total = out.limbs[index] + a.limbs[i] * b.limbs[j] + carry
            out.limbs[index] = total % BIGZ_BASE
            carry = total // BIGZ_BASE
        var carry_index = i + len(b.limbs)
        while carry > 0:
            var total = out.limbs[carry_index] + carry
            out.limbs[carry_index] = total % BIGZ_BASE
            carry = total // BIGZ_BASE
            carry_index += 1
    out.normalize()
    return out^


def bigz_eq(a: BigZ, b: BigZ) -> Bool:
    if a.sign != b.sign or len(a.limbs) != len(b.limbs):
        return False
    for idx in range(len(a.limbs)):
        if a.limbs[idx] != b.limbs[idx]:
            return False
    return True


def bigz_lt(a: BigZ, b: BigZ) -> Bool:
    if a.sign != b.sign:
        return a.sign < b.sign
    if a.sign == 0:
        return False
    var order = bigz_abs_compare(a, b)
    if a.sign > 0:
        return order < 0
    return order > 0


def bigz_abs_div_small(a: BigZ, divisor: UInt64) -> BigZ:
    # Internal use requires divisor > 0 and a >= 0.
    var out = BigZ()
    if a.sign == 0 or divisor == 0:
        return out^
    out.sign = 1
    for _ in range(len(a.limbs)):
        out.limbs.append(0)
    var carry = UInt64(0)
    var idx = len(a.limbs) - 1
    while idx >= 0:
        var current = carry * BIGZ_BASE + a.limbs[idx]
        out.limbs[idx] = current // divisor
        carry = current % divisor
        idx -= 1
    out.normalize()
    return out^


def bigz_abs_mod_small(a: BigZ, divisor: UInt64) -> UInt64:
    if divisor == 0:
        return 0
    var carry = UInt64(0)
    var idx = len(a.limbs) - 1
    while idx >= 0:
        var current = carry * BIGZ_BASE + a.limbs[idx]
        carry = current % divisor
        idx -= 1
    return carry


def rejected_bigz_divmod() -> BigZDivModResult:
    var out = BigZDivModResult()
    out.rejected = True
    return out^


def bigz_abs_divmod(dividend: BigZ, divisor: BigZ) -> BigZDivModResult:
    if divisor.sign == 0:
        return rejected_bigz_divmod()
    var out = BigZDivModResult()
    var remainder = bigz_abs(dividend)
    var positive_divisor = bigz_abs(divisor)
    if bigz_abs_compare(remainder, positive_divisor) < 0:
        out.remainder = remainder.copy()
        return out^

    var shifted = positive_divisor.copy()
    var power = bigz_from_i64(1)
    while bigz_abs_compare(shifted, remainder) <= 0:
        shifted = bigz_abs_add(shifted, shifted)
        power = bigz_abs_add(power, power)

    var quotient = bigz_zero()
    while not power.is_zero():
        shifted = bigz_abs_div_small(shifted, 2)
        power = bigz_abs_div_small(power, 2)
        if not power.is_zero() and bigz_abs_compare(shifted, remainder) <= 0:
            remainder = bigz_abs_sub(remainder, shifted)
            quotient = bigz_abs_add(quotient, power)

    out.quotient = quotient.copy()
    out.remainder = remainder.copy()
    return out^


def bigz_divmod(dividend: BigZ, divisor: BigZ) -> BigZDivModResult:
    var out = bigz_abs_divmod(dividend, divisor)
    if out.rejected:
        return out^
    if not out.quotient.is_zero():
        out.quotient.sign = dividend.sign * divisor.sign
    if not out.remainder.is_zero():
        out.remainder.sign = dividend.sign
    return out^


def bigz_div_exact(dividend: BigZ, divisor: BigZ) -> BigZExactDivisionResult:
    var out = BigZExactDivisionResult()
    var division = bigz_divmod(dividend, divisor)
    if division.rejected or not division.remainder.is_zero():
        out.rejected = True
        return out^
    out.quotient = division.quotient.copy()
    return out^


def bigz_gcd(a: BigZ, b: BigZ) -> BigZ:
    var left = bigz_abs(a)
    var right = bigz_abs(b)
    while not right.is_zero():
        var division = bigz_abs_divmod(left, right)
        if division.rejected:
            return bigz_zero()
        left = right.copy()
        right = division.remainder.copy()
    return left^


def bigz_divmod_identity_holds(dividend: BigZ, divisor: BigZ) -> Bool:
    var division = bigz_divmod(dividend, divisor)
    if division.rejected or divisor.is_zero():
        return False
    var reconstructed = bigz_add(bigz_mul(division.quotient, divisor), division.remainder)
    return (
        bigz_eq(reconstructed, dividend) and
        bigz_abs_compare(bigz_abs(division.remainder), bigz_abs(divisor)) < 0 and
        (division.remainder.is_zero() or division.remainder.sign == dividend.sign)
    )


def bigz_is_canonical(value: BigZ) -> Bool:
    if value.sign < -1 or value.sign > 1:
        return False
    if value.sign == 0:
        return len(value.limbs) == 0
    if len(value.limbs) == 0 or value.limbs[len(value.limbs) - 1] == 0:
        return False
    for limb in value.limbs:
        if limb >= BIGZ_BASE:
            return False
    return True


def rejected_bigz_canonical_bytes() -> BigZCanonicalBytes:
    var out = BigZCanonicalBytes()
    out.rejected = True
    return out^


def bigz_canonical_bytes(value: BigZ) -> BigZCanonicalBytes:
    # Z(sign, byte_len, big_endian_magnitude). Sign codes are 0, 1, 2 for
    # zero, positive, and negative. byte_len is an unsigned 64-bit big-endian
    # count. The magnitude has no leading zero byte.
    if not bigz_is_canonical(value):
        return rejected_bigz_canonical_bytes()
    var out = BigZCanonicalBytes()
    var sign_code = UInt8(0)
    if value.sign > 0:
        sign_code = 1
    elif value.sign < 0:
        sign_code = 2
    out.bytes.append(sign_code)

    var magnitude = bigz_abs(value)
    var reversed_magnitude = List[UInt8]()
    while not magnitude.is_zero():
        reversed_magnitude.append(UInt8(bigz_abs_mod_small(magnitude, 256)))
        magnitude = bigz_abs_div_small(magnitude, 256)

    var byte_len = UInt64(len(reversed_magnitude))
    var length_index = 7
    while length_index >= 0:
        out.bytes.append(UInt8((byte_len >> UInt64(length_index * 8)) & 255))
        length_index -= 1

    var magnitude_index = len(reversed_magnitude) - 1
    while magnitude_index >= 0:
        out.bytes.append(reversed_magnitude[magnitude_index])
        magnitude_index -= 1
    return out^


def canonical_bytes_equal(a: BigZCanonicalBytes, b: BigZCanonicalBytes) -> Bool:
    if a.rejected or b.rejected or len(a.bytes) != len(b.bytes):
        return False
    for idx in range(len(a.bytes)):
        if a.bytes[idx] != b.bytes[idx]:
            return False
    return True


def bigint_z_phase_one_smoke() -> Bool:
    var q7_max = bigz_from_i64(17999433372)
    var q7_square = bigz_mul(q7_max, q7_max)
    var beyond_i64 = bigz_add(bigz_from_i64(9223372036854775807), bigz_from_i64(1))
    return (
        q7_square.sign == 1 and q7_square.limb_count() == 3 and
        q7_square.limb(0) == 67290384 and q7_square.limb(1) == 979601713 and
        q7_square.limb(2) == 323 and
        beyond_i64.limb_count() == 3 and bigz_lt(bigz_from_i64(9223372036854775807), beyond_i64) and
        bigz_eq(bigz_add(bigz_from_i64(-7), bigz_from_i64(10)), bigz_from_i64(3)) and
        bigz_eq(bigz_sub(bigz_from_i64(7), bigz_from_i64(10)), bigz_from_i64(-3)) and
        bigz_eq(bigz_mul(bigz_from_i64(-7), bigz_from_i64(-9)), bigz_from_i64(63)) and
        bigz_lt(bigz_from_i64(-10), bigz_from_i64(-7)) and
        bigz_from_i64(-9223372036854775807 - 1).sign == -1
    )


def bigint_z_phase_two_smoke() -> Bool:
    var q7_max = bigz_from_i64(17999433372)
    var q7_square = bigz_mul(q7_max, q7_max)
    var recovered = bigz_div_exact(q7_square, q7_max)
    var negative = bigz_div_exact(bigz_from_i64(-63), bigz_from_i64(9))
    var non_division = bigz_div_exact(bigz_from_i64(10), bigz_from_i64(3))
    var zero_divisor = bigz_div_exact(bigz_from_i64(10), bigz_zero())
    var beyond_i64 = bigz_add(bigz_from_i64(9223372036854775807), bigz_from_i64(1))
    var common = bigz_mul(beyond_i64, bigz_from_i64(7))
    var gcd_value = bigz_gcd(
        bigz_mul(beyond_i64, bigz_from_i64(21)),
        bigz_mul(beyond_i64, bigz_from_i64(14)),
    )
    var signed_remainder = bigz_divmod(bigz_from_i64(-10), bigz_from_i64(3))
    var negative_divisor = bigz_div_exact(bigz_from_i64(63), bigz_from_i64(-9))
    return (
        not recovered.rejected and bigz_eq(recovered.quotient, q7_max) and
        not negative.rejected and bigz_eq(negative.quotient, bigz_from_i64(-7)) and
        non_division.rejected and zero_divisor.rejected and
        not negative_divisor.rejected and bigz_eq(negative_divisor.quotient, bigz_from_i64(-7)) and
        bigz_eq(gcd_value, common) and
        not signed_remainder.rejected and
        bigz_eq(signed_remainder.quotient, bigz_from_i64(-3)) and
        bigz_eq(signed_remainder.remainder, bigz_from_i64(-1)) and
        bigz_divmod_identity_holds(q7_square, q7_max) and
        bigz_divmod_identity_holds(bigz_from_i64(10), bigz_from_i64(3)) and
        bigz_divmod_identity_holds(bigz_from_i64(-10), bigz_from_i64(3)) and
        bigz_divmod_identity_holds(bigz_from_i64(10), bigz_from_i64(-3))
    )


def bigint_z_phase_three_smoke() -> Bool:
    var zero = bigz_canonical_bytes(bigz_zero())
    var one = bigz_canonical_bytes(bigz_from_i64(1))
    var negative = bigz_canonical_bytes(bigz_from_i64(-1000000001))
    var q7_square = bigz_canonical_bytes(bigz_mul(bigz_from_i64(17999433372), bigz_from_i64(17999433372)))
    var malformed = BigZ()
    malformed.sign = 1
    malformed.limbs.append(0)
    var rejected = bigz_canonical_bytes(malformed)
    return (
        not zero.rejected and len(zero.bytes) == 9 and zero.bytes[0] == 0 and zero.bytes[8] == 0 and
        not one.rejected and len(one.bytes) == 10 and one.bytes[0] == 1 and one.bytes[8] == 1 and one.bytes[9] == 1 and
        not negative.rejected and len(negative.bytes) == 13 and negative.bytes[0] == 2 and
        negative.bytes[8] == 4 and negative.bytes[9] == 59 and negative.bytes[10] == 154 and
        negative.bytes[11] == 202 and negative.bytes[12] == 1 and
        not q7_square.rejected and len(q7_square.bytes) == 18 and q7_square.bytes[8] == 9 and
        q7_square.bytes[9] == 17 and q7_square.bytes[10] == 144 and q7_square.bytes[17] == 16 and
        rejected.rejected and
        canonical_bytes_equal(one, bigz_canonical_bytes(bigz_from_i64(1)))
    )
