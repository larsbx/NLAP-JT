# rat_q.mojo
#
# Normalized rational arithmetic scaffold for finite-regime Mandelbrot work.
# This module avoids floating point and analytic trig primitives.
#
# Current backend: Int64 for scaffolding.
# Required hardening: replace Int64 with a bigint backend before relying on this
# for high-depth orbit or polynomial certificates.


fn abs_i64(x: Int64) -> Int64:
    if x < 0:
        return -x
    return x


fn gcd_i64(a0: Int64, b0: Int64) -> Int64:
    var a = abs_i64(a0)
    var b = abs_i64(b0)
    while b != 0:
        var r = a % b
        a = b
        b = r
    if a == 0:
        return 1
    return a


struct Q:
    var num: Int64
    var den: Int64

    fn __init__(inout self, n: Int64, d: Int64):
        # Caller contract: d != 0.
        var nn = n
        var dd = d
        if dd < 0:
            nn = -nn
            dd = -dd
        var g = gcd_i64(nn, dd)
        self.num = nn // g
        self.den = dd // g

    fn zero() -> Q:
        return Q(0, 1)

    fn one() -> Q:
        return Q(1, 1)

    fn from_int(n: Int64) -> Q:
        return Q(n, 1)

    fn neg(self) -> Q:
        return Q(-self.num, self.den)

    fn add(self, other: Q) -> Q:
        return Q(self.num * other.den + other.num * self.den, self.den * other.den)

    fn sub(self, other: Q) -> Q:
        return Q(self.num * other.den - other.num * self.den, self.den * other.den)

    fn mul(self, other: Q) -> Q:
        return Q(self.num * other.num, self.den * other.den)

    fn div(self, other: Q) -> Q:
        return Q(self.num * other.den, self.den * other.num)

    fn square(self) -> Q:
        return self.mul(self)

    fn eq(self, other: Q) -> Bool:
        # Both sides normalized.
        return self.num == other.num and self.den == other.den

    fn lt(self, other: Q) -> Bool:
        return self.num * other.den < other.num * self.den

    fn le(self, other: Q) -> Bool:
        return self.num * other.den <= other.num * self.den


fn q_abs(x: Q) -> Q:
    if x.num < 0:
        return Q(-x.num, x.den)
    return x


fn q_min(a: Q, b: Q) -> Q:
    if a.le(b):
        return a
    return b


fn q_max(a: Q, b: Q) -> Q:
    if a.le(b):
        return b
    return a


fn demo_q_normalization() -> Bool:
    return Q(2, 4).eq(Q(1, 2))


fn demo_q_order() -> Bool:
    return Q(1, 3).lt(Q(1, 2))
