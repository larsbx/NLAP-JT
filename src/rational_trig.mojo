# rational_trig.mojo
#
# Rational-trigonometry substrate for the finite-regime Mandelbrot project.
#
# Hard rule: core code must not call or define sin/cos/tan/atan/angle APIs.
# Use quadrance, spread, dot/cross determinants, and symbolic rational-angle
# doubling instead.
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
    # Dot product is algebraic. It is allowed.
    return a.x.mul(b.x).add(a.y.mul(b.y))


fn cross_det(a: Vec2Q, b: Vec2Q) -> Rat:
    # 2D determinant. This replaces oriented angle measurement.
    return a.x.mul(b.y).sub(a.y.mul(b.x))


fn quadrance(v: Vec2Q) -> Rat:
    # Rational-trig quadrance: Q(v) = x^2 + y^2.
    # No square roots.
    return v.x.square().add(v.y.square())


fn spread(a: Vec2Q, b: Vec2Q) -> Rat:
    # Rational-trig spread between two vectors:
    #   s(a,b) = det(a,b)^2 / (Q(a) Q(b)).
    # This is the algebraic replacement for sin(theta)^2.
    # It does not compute theta and does not invoke trigonometric functions.
    var d = cross_det(a, b)
    var qa = quadrance(a)
    var qb = quadrance(b)
    return d.square().div(qa.mul(qb))


fn dot_ratio(a: Vec2Q, b: Vec2Q) -> Rat:
    # Algebraic replacement for cos(theta)^2 when squared by caller:
    #   dot(a,b)^2 / (Q(a) Q(b)).
    # Kept separate so callers are explicit about what invariant they need.
    var d = dot(a, b)
    return d.square().div(quadrance(a).mul(quadrance(b)))


struct RotorQ:
    var c: Rat
    var s: Rat

    fn __init__(inout self, c: Rat, s: Rat):
        # These names are algebraic coordinates, not calls to cosine/sine.
        # A valid rotor must satisfy c^2 + s^2 = 1, checked by valid_rotor().
        self.c = c
        self.s = s


fn valid_rotor(r: RotorQ) -> Bool:
    var lhs = r.c.square().add(r.s.square())
    # Temporary exact equality without normalization. Bigint/gcd pass should
    # normalize before comparing.
    return lhs.num == lhs.den


fn rotate_by_rotor(v: Vec2Q, r: RotorQ) -> Vec2Q:
    # Algebraic SO_2 action using a rational point on c^2+s^2=1.
    # No angle argument exists in this API.
    return Vec2Q(v.x.mul(r.c).sub(v.y.mul(r.s)), v.x.mul(r.s).add(v.y.mul(r.c)))


struct RatAngle:
    var num: Int64
    var den: Int64

    fn __init__(inout self, num: Int64, den: Int64):
        # Symbolic external angle in Q/Z. This is combinatorics, not measured
        # geometric angle. Normalization modulo den is deferred to bigint pass.
        self.num = num
        self.den = den


fn double_angle(theta: RatAngle) -> RatAngle:
    # External-ray combinatorics: D(theta)=2 theta mod 1.
    # This is integer modular arithmetic, not trigonometry.
    var doubled = 2 * theta.num
    var reduced = doubled % theta.den
    return RatAngle(reduced, theta.den)


fn demo_spread_orthogonal_axes() -> Rat:
    var e1 = Vec2Q(Rat.one(), Rat.zero())
    var e2 = Vec2Q(Rat.zero(), Rat.one())
    return spread(e1, e2)


fn demo_angle_doubling_half() -> RatAngle:
    return double_angle(RatAngle(1, 2))
