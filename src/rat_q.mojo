# rat_q.mojo
# Specification: docs/rational-interval-arithmetic-spec.md (binding 6.2).
# Normalized rational arithmetic over the dynamic-limb BigZ backend.
# Invalid construction and division propagate a rejected state. This module
# does not enable certificate acceptance or discharge any theorem obligation.

from bigint_z import BigZ, bigz_add, bigz_canonical_bytes, bigz_div_exact, bigz_eq, bigz_from_i64, bigz_gcd, bigz_is_canonical, bigz_lt, bigz_mul, bigz_neg, bigz_sub, bigz_zero


struct Q(Copyable):
    var num: BigZ
    var den: BigZ
    var rejected: Bool

    def __init__(out self):
        self.num = bigz_zero()
        self.den = bigz_from_i64(1)
        self.rejected = False

    def __init__(out self, n: Int64, d: Int64):
        self.num = bigz_zero()
        self.den = bigz_from_i64(1)
        self.rejected = False
        self = q_normalize_bigz(bigz_from_i64(n), bigz_from_i64(d))

    @staticmethod
    def zero() -> Q:
        return Q(0, 1)

    @staticmethod
    def one() -> Q:
        return Q(1, 1)

    @staticmethod
    def from_int(n: Int64) -> Q:
        return Q(n, 1)

    def accepted(self) -> Bool:
        return not self.rejected

    def neg(self) -> Q:
        if self.rejected:
            return q_rejected()
        return q_normalize_bigz(bigz_neg(self.num), self.den)

    def add(self, other: Q) -> Q:
        if self.rejected or other.rejected:
            return q_rejected()
        return q_normalize_bigz(
            bigz_add(bigz_mul(self.num, other.den), bigz_mul(other.num, self.den)),
            bigz_mul(self.den, other.den),
        )

    def sub(self, other: Q) -> Q:
        if self.rejected or other.rejected:
            return q_rejected()
        return q_normalize_bigz(
            bigz_sub(bigz_mul(self.num, other.den), bigz_mul(other.num, self.den)),
            bigz_mul(self.den, other.den),
        )

    def mul(self, other: Q) -> Q:
        if self.rejected or other.rejected:
            return q_rejected()
        return q_normalize_bigz(bigz_mul(self.num, other.num), bigz_mul(self.den, other.den))

    def div(self, other: Q) -> Q:
        if self.rejected or other.rejected or other.num.is_zero():
            return q_rejected()
        return q_normalize_bigz(bigz_mul(self.num, other.den), bigz_mul(self.den, other.num))

    def square(self) -> Q:
        return self.mul(self)

    def eq(self, other: Q) -> Bool:
        return not self.rejected and not other.rejected and bigz_eq(self.num, other.num) and bigz_eq(self.den, other.den)

    def lt(self, other: Q) -> Bool:
        if self.rejected or other.rejected:
            return False
        return bigz_lt(bigz_mul(self.num, other.den), bigz_mul(other.num, self.den))

    def le(self, other: Q) -> Bool:
        if self.rejected or other.rejected:
            return False
        return not bigz_lt(bigz_mul(other.num, self.den), bigz_mul(self.num, other.den))


struct QCanonicalBytes(Copyable):
    var bytes: List[UInt8]
    var rejected: Bool

    def __init__(out self):
        self.bytes = List[UInt8]()
        self.rejected = False

    def accepted(self) -> Bool:
        return not self.rejected


def q_rejected() -> Q:
    var out = Q()
    out.rejected = True
    return out^


def q_normalize_bigz(n: BigZ, d: BigZ) -> Q:
    if not bigz_is_canonical(n) or not bigz_is_canonical(d):
        return q_rejected()
    if d.is_zero():
        return q_rejected()
    var nn = n.copy()
    var dd = d.copy()
    if dd.sign < 0:
        nn = bigz_neg(nn)
        dd = bigz_neg(dd)
    if nn.is_zero():
        return Q()
    var common = bigz_gcd(nn, dd)
    var reduced_num = bigz_div_exact(nn, common)
    var reduced_den = bigz_div_exact(dd, common)
    if reduced_num.rejected or reduced_den.rejected:
        return q_rejected()
    var out = Q()
    out.num = reduced_num.quotient.copy()
    out.den = reduced_den.quotient.copy()
    return out^


def q_from_bigz(n: BigZ, d: BigZ) -> Q:
    return q_normalize_bigz(n, d)


def q_canonical_bytes(value: Q) -> QCanonicalBytes:
    var out = QCanonicalBytes()
    if value.rejected:
        out.rejected = True
        return out^
    var numerator = bigz_canonical_bytes(value.num)
    var denominator = bigz_canonical_bytes(value.den)
    if numerator.rejected or denominator.rejected or denominator.bytes[0] != 1:
        out.rejected = True
        return out^
    for byte in numerator.bytes:
        out.bytes.append(byte)
    for byte in denominator.bytes:
        out.bytes.append(byte)
    return out^


def q_abs(x: Q) -> Q:
    if x.rejected:
        return q_rejected()
    if x.num.sign < 0:
        return x.neg()
    return x.copy()


def q_min(a: Q, b: Q) -> Q:
    if a.rejected or b.rejected:
        return q_rejected()
    if a.le(b):
        return a.copy()
    return b.copy()


def q_max(a: Q, b: Q) -> Q:
    if a.rejected or b.rejected:
        return q_rejected()
    if a.le(b):
        return b.copy()
    return a.copy()


def bigq_storage_smoke() -> Bool:
    var beyond_i64 = bigz_add(bigz_from_i64(9223372036854775807), bigz_from_i64(1))
    var half = q_from_bigz(beyond_i64, bigz_mul(beyond_i64, bigz_from_i64(2)))
    var negative_denominator = q_from_bigz(bigz_from_i64(2), bigz_from_i64(-4))
    var zero_denominator = q_from_bigz(bigz_from_i64(1), bigz_zero())
    var division_by_zero = Q(1, 2).div(Q.zero())
    var malformed = bigz_from_i64(1)
    malformed.sign = 2
    var malformed_input = q_from_bigz(malformed, bigz_from_i64(1))
    var encoded = q_canonical_bytes(half)
    return (
        half.eq(Q(1, 2)) and negative_denominator.eq(Q(-1, 2)) and
        zero_denominator.rejected and division_by_zero.rejected and malformed_input.rejected and
        not encoded.rejected and len(encoded.bytes) == 20 and
        q_canonical_bytes(zero_denominator).rejected
    )


def demo_q_normalization() -> Bool:
    return Q(2, 4).eq(Q(1, 2))


def demo_q_order() -> Bool:
    return Q(1, 3).lt(Q(1, 2))
