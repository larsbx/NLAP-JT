# rational_trig.mojo
#
# Rational geometry substrate for the finite-regime Mandelbrot project.
#
# Core arithmetic uses quadrance, spread, dot/cross determinants, algebraic
# rotor coordinates, and symbolic Q/Z ray-address doubling.
#
# NOTE: This file is intentionally Mojo-shaped scaffolding. It preserves the
# exact computations and API boundary for coding agents. The next pass should
# replace Int64 with arbitrary-precision integer/rational types once the repo
# chooses its bigint backend.


struct Rat:
    var num: Int64
    var den: Int64

    fn __init__(inout self, num: Int64, den: Int64):
        # Caller must provide den != 0. Normalization is stubbed until bigint/gcd
        # backend is selected.
        self.num = num
        self.den = den

    fn zero() -> Rat:
        return Rat(0, 1)

    fn one() -> Rat:
        return Rat(1, 1)

    fn add(self, other: Rat) -> Rat:
        return Rat(self.num * other.den + other.num * self.den, self.den * other.den)

    fn sub(self, other: Rat) -> Rat:
        return Rat(self.num * other.den - other.num * self.den, self.den * other.den)

    fn mul(self, other: Rat) -> Rat:
        return Rat(self.num * other.num, self.den * other.den)

    fn div(self, other: Rat) -> Rat:
        return Rat(self.num * other.den, self.den * other.num)

    fn neg(self) -> Rat:
        return Rat(-self.num, self.den)

    fn square(self) -> Rat:
        return self.mul(self)


struct Vec2Q:
    var x: Rat
    var y: Rat

    fn __init__(inout self, x: Rat, y: Rat):
        self.x = x
        self.y = y


fn dot(a: Vec2Q, b: Vec2Q) -> Rat:
    return a.x.mul(b.x).add(a.y.mul(b.y))


fn cross_det(a: Vec2Q, b: Vec2Q) -> Rat:
    return a.x.mul(b.y).sub(a.y.mul(b.x))


fn quadrance(v: Vec2Q) -> Rat:
    # Q(v) = x^2 + y^2.
    return v.x.square().add(v.y.square())


fn spread(a: Vec2Q, b: Vec2Q) -> Rat:
    # s(a,b) = det(a,b)^2 / (Q(a) Q(b)).
    var d = cross_det(a, b)
    var qa = quadrance(a)
    var qb = quadrance(b)
    return d.square().div(qa.mul(qb))


fn dot_ratio(a: Vec2Q, b: Vec2Q) -> Rat:
    # d(a,b)^2 / (Q(a) Q(b)).
    var d = dot(a, b)
    return d.square().div(quadrance(a).mul(quadrance(b)))


struct RotorQ:
    var u: Rat
    var v: Rat

    fn __init__(inout self, u: Rat, v: Rat):
        # A valid rotor satisfies u^2 + v^2 = 1, checked by valid_rotor().
        self.u = u
        self.v = v


fn valid_rotor(r: RotorQ) -> Bool:
    var lhs = r.u.square().add(r.v.square())
    # Temporary exact equality without normalization. Bigint/gcd pass should
    # normalize before comparing.
    return lhs.num == lhs.den


fn rotate_by_rotor(v: Vec2Q, r: RotorQ) -> Vec2Q:
    return Vec2Q(v.x.mul(r.u).sub(v.y.mul(r.v)), v.x.mul(r.v).add(v.y.mul(r.u)))


struct RayAddr:
    var num: Int64
    var den: Int64

    fn __init__(inout self, num: Int64, den: Int64):
        # Symbolic external-ray address in Q/Z. Normalization modulo den is
        # deferred to bigint pass.
        self.num = num
        self.den = den


fn double_ray_addr(theta: RayAddr) -> RayAddr:
    var doubled = 2 * theta.num
    var reduced = doubled % theta.den
    return RayAddr(reduced, theta.den)


fn demo_spread_orthogonal_axes() -> Rat:
    var e1 = Vec2Q(Rat.one(), Rat.zero())
    var e2 = Vec2Q(Rat.zero(), Rat.one())
    return spread(e1, e2)


fn demo_ray_addr_doubling_half() -> RayAddr:
    return double_ray_addr(RayAddr(1, 2))
