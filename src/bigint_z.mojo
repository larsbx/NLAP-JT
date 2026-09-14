# Mojo-native dynamic-limb signed integers, migration phase one.
# Specification: docs/rational-interval-arithmetic-spec.md (section 1.5).
#
# Limbs are little-endian in base 10^9. Dynamic List storage removes the fixed
# Int64 magnitude bound. This phase implements exact construction, add, sub,
# mul, equality, and order. GCD, exact division, and canonical serialization
# remain separate blockers, so this module cannot enable certificate acceptance.

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
