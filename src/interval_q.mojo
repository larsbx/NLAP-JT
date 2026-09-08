# interval_q.mojo
#
# Rational interval arithmetic scaffold for certificate witnesses.
# Endpoints are normalized rationals represented with Int64 until bigint lands.

from rat_q import Q, q_min, q_max


struct IQ:
    var lo: Q
    var hi: Q

    fn __init__(inout self, lo: Q, hi: Q):
        # Caller contract: lo <= hi.
        self.lo = lo
        self.hi = hi

    fn point(x: Q) -> IQ:
        return IQ(x, x)

    fn contains_zero(self) -> Bool:
        return self.lo.le(Q.zero()) and Q.zero().le(self.hi)

    fn excludes_zero(self) -> Bool:
        return not self.contains_zero()

    fn add(self, other: IQ) -> IQ:
        return IQ(self.lo.add(other.lo), self.hi.add(other.hi))

    fn sub(self, other: IQ) -> IQ:
        return IQ(self.lo.sub(other.hi), self.hi.sub(other.lo))

    fn neg(self) -> IQ:
        return IQ(self.hi.neg(), self.lo.neg())

    fn mul(self, other: IQ) -> IQ:
        var p1 = self.lo.mul(other.lo)
        var p2 = self.lo.mul(other.hi)
        var p3 = self.hi.mul(other.lo)
        var p4 = self.hi.mul(other.hi)
        var lo = q_min(q_min(p1, p2), q_min(p3, p4))
        var hi = q_max(q_max(p1, p2), q_max(p3, p4))
        return IQ(lo, hi)

    fn square(self) -> IQ:
        if self.contains_zero():
            var a = self.lo.square()
            var b = self.hi.square()
            return IQ(Q.zero(), q_max(a, b))
        return self.mul(self)

    fn subset_of(self, other: IQ) -> Bool:
        return other.lo.le(self.lo) and self.hi.le(other.hi)

    fn strict_subset_of(self, other: IQ) -> Bool:
        return other.lo.lt(self.lo) and self.hi.lt(other.hi)


struct ComplexIQ:
    var re: IQ
    var im: IQ

    fn __init__(inout self, re: IQ, im: IQ):
        self.re = re
        self.im = im

    fn point(re: Q, im: Q) -> ComplexIQ:
        return ComplexIQ(IQ.point(re), IQ.point(im))

    fn add(self, other: ComplexIQ) -> ComplexIQ:
        return ComplexIQ(self.re.add(other.re), self.im.add(other.im))

    fn sub(self, other: ComplexIQ) -> ComplexIQ:
        return ComplexIQ(self.re.sub(other.re), self.im.sub(other.im))

    fn mul(self, other: ComplexIQ) -> ComplexIQ:
        var real_part = self.re.mul(other.re).sub(self.im.mul(other.im))
        var imag_part = self.re.mul(other.im).add(self.im.mul(other.re))
        return ComplexIQ(real_part, imag_part)

    fn square(self) -> ComplexIQ:
        return self.mul(self)

    fn quadrance(self) -> IQ:
        return self.re.square().add(self.im.square())

    fn subset_of(self, other: ComplexIQ) -> Bool:
        return self.re.subset_of(other.re) and self.im.subset_of(other.im)

    fn strict_subset_of(self, other: ComplexIQ) -> Bool:
        return self.re.strict_subset_of(other.re) and self.im.strict_subset_of(other.im)


fn demo_interval_mul() -> Bool:
    var a = IQ(Q(1, 1), Q(2, 1))
    var b = IQ(Q(3, 1), Q(5, 1))
    var c = a.mul(b)
    return c.lo.eq(Q(3, 1)) and c.hi.eq(Q(10, 1))


fn demo_complex_quadrance_point() -> Bool:
    var z = ComplexIQ.point(Q(3, 1), Q(4, 1))
    var q = z.quadrance()
    return q.lo.eq(Q(25, 1)) and q.hi.eq(Q(25, 1))
