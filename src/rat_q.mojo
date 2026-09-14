# rat_q.mojo
#
# Normalized rational arithmetic scaffold for finite-regime Mandelbrot work.
# This module avoids floating point and analytic trig primitives.
#
# Current backend: Int64 for scaffolding.
# Required hardening: replace Int64 with a bigint backend before relying on this
# for high-depth orbit or polynomial certificates.

from integer_gcd import gcd_i64_or_one


struct Q(ImplicitlyCopyable):
    var num: Int64
    var den: Int64

    def __init__(out self, n: Int64, d: Int64):
        # Caller contract: d != 0.
        var nn = n
        var dd = d
        if dd < 0:
            nn = -nn
            dd = -dd
        var g = gcd_i64_or_one(nn, dd)
        self.num = nn // g
        self.den = dd // g

    @staticmethod
    def zero() -> Q:
        return Q(0, 1)

    @staticmethod
    def one() -> Q:
        return Q(1, 1)

    @staticmethod
    def from_int(n: Int64) -> Q:
        return Q(n, 1)

    def neg(self) -> Q:
        return Q(-self.num, self.den)

    def add(self, other: Q) -> Q:
        return Q(self.num * other.den + other.num * self.den, self.den * other.den)

    def sub(self, other: Q) -> Q:
        return Q(self.num * other.den - other.num * self.den, self.den * other.den)

    def mul(self, other: Q) -> Q:
        return Q(self.num * other.num, self.den * other.den)

    def div(self, other: Q) -> Q:
        return Q(self.num * other.den, self.den * other.num)

    def square(self) -> Q:
        return self.mul(self)

    def eq(self, other: Q) -> Bool:
        # Both sides normalized.
        return self.num == other.num and self.den == other.den

    def lt(self, other: Q) -> Bool:
        return self.num * other.den < other.num * self.den

    def le(self, other: Q) -> Bool:
        return self.num * other.den <= other.num * self.den


def q_abs(x: Q) -> Q:
    if x.num < 0:
        return Q(-x.num, x.den)
    return x


def q_min(a: Q, b: Q) -> Q:
    if a.le(b):
        return a
    return b


def q_max(a: Q, b: Q) -> Q:
    if a.le(b):
        return b
    return a


def demo_q_normalization() -> Bool:
    return Q(2, 4).eq(Q(1, 2))


def demo_q_order() -> Bool:
    return Q(1, 3).lt(Q(1, 2))
