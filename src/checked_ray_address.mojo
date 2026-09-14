# Rejection-aware rational ray-address dynamics for certificate migration.
# Specification: docs/rational-interval-arithmetic-spec.md (binding 6.2).
#
# These are finite modular addresses, not measured angles. Fixed-width overflow
# rejects the transition; accepted results are canonical reduced fractions.

from checked_int64_backend import checked_mul_i64
from integer_gcd import gcd_i64


struct CheckedRayAddrResult(ImplicitlyCopyable):
    var num: Int64
    var den: Int64
    var rejected: Bool

    def __init__(out self, num: Int64, den: Int64, rejected: Bool):
        self.num = num
        self.den = den
        self.rejected = rejected

    def accepted(self) -> Bool:
        return not self.rejected


struct CheckedRayOrbitStatus(ImplicitlyCopyable):
    var preperiod: Int
    var period: Int
    var arithmetic_rejected: Bool
    var orbit_verified: Bool

    def __init__(out self, preperiod: Int, period: Int, arithmetic_rejected: Bool, orbit_verified: Bool):
        self.preperiod = preperiod
        self.period = period
        self.arithmetic_rejected = arithmetic_rejected
        self.orbit_verified = orbit_verified

    def accepted(self) -> Bool:
        return (
            not self.arithmetic_rejected and self.preperiod >= 0 and
            self.period >= 1 and self.orbit_verified
        )


def rejected_ray_addr() -> CheckedRayAddrResult:
    return CheckedRayAddrResult(0, 1, True)


def make_checked_ray_addr(num: Int64, den: Int64) -> CheckedRayAddrResult:
    if den <= 0 or num < 0 or num >= den:
        return rejected_ray_addr()
    var divisor = gcd_i64(num, den)
    if divisor == 0:
        return rejected_ray_addr()
    return CheckedRayAddrResult(num // divisor, den // divisor, False)


def checked_ray_addr_equal(a: CheckedRayAddrResult, b: CheckedRayAddrResult) -> Bool:
    return not a.rejected and not b.rejected and a.num == b.num and a.den == b.den


def checked_double_ray_addr(address: CheckedRayAddrResult) -> CheckedRayAddrResult:
    if address.rejected:
        return rejected_ray_addr()
    var doubled = checked_mul_i64(address.num, 2)
    if doubled.overflowed:
        return rejected_ray_addr()
    return make_checked_ray_addr(doubled.value % address.den, address.den)


def verify_checked_one_half_orbit() -> CheckedRayOrbitStatus:
    var start = make_checked_ray_addr(1, 2)
    var tail = checked_double_ray_addr(start)
    var repeated = checked_double_ray_addr(tail)
    if start.rejected or tail.rejected or repeated.rejected:
        return CheckedRayOrbitStatus(1, 1, True, False)
    var zero = make_checked_ray_addr(0, 1)
    return CheckedRayOrbitStatus(
        1,
        1,
        False,
        checked_ray_addr_equal(tail, zero) and checked_ray_addr_equal(repeated, tail),
    )


def checked_ray_address_smoke() -> Bool:
    var orbit = verify_checked_one_half_orbit()
    var malformed = make_checked_ray_addr(1, 0)
    var overflowing = checked_double_ray_addr(make_checked_ray_addr(5000000000000000000, 9000000000000000001))
    return (
        orbit.accepted() and orbit.preperiod == 1 and orbit.period == 1 and
        malformed.rejected and overflowing.rejected
    )
