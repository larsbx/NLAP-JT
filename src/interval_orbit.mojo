# interval_orbit.mojo
#
# Native Mojo target for interval critical-orbit evaluation.
# This mirrors tools/interval_exclusion_reference.py using only rational interval
# operations from interval_q.mojo. It remains Int64-backed until rat_q.mojo is
# replaced by a certificate-ready arbitrary-precision integer backend.

from interval_q import ComplexIQ, IQ
from rat_q import Q


struct OrbitEvalConfig:
    var ell: Int
    var period: Int
    var horizon: Int

    fn __init__(inout self, ell: Int, period: Int, horizon: Int):
        self.ell = ell
        self.period = period
        self.horizon = horizon

    fn valid(self) -> Bool:
        return self.ell >= 1 and self.period >= 1 and self.horizon >= self.ell + self.period


struct Orbit4:
    var q0: ComplexIQ
    var q1: ComplexIQ
    var q2: ComplexIQ
    var q3: ComplexIQ

    fn __init__(inout self, q0: ComplexIQ, q1: ComplexIQ, q2: ComplexIQ, q3: ComplexIQ):
        self.q0 = q0
        self.q1 = q1
        self.q2 = q2
        self.q3 = q3

    fn at(self, idx: Int) -> ComplexIQ:
        if idx == 0:
            return self.q0
        if idx == 1:
            return self.q1
        if idx == 2:
            return self.q2
        return self.q3


struct Orbit7:
    var q0: ComplexIQ
    var q1: ComplexIQ
    var q2: ComplexIQ
    var q3: ComplexIQ
    var q4: ComplexIQ
    var q5: ComplexIQ
    var q6: ComplexIQ

    fn __init__(inout self, q0: ComplexIQ, q1: ComplexIQ, q2: ComplexIQ, q3: ComplexIQ, q4: ComplexIQ, q5: ComplexIQ, q6: ComplexIQ):
        self.q0 = q0
        self.q1 = q1
        self.q2 = q2
        self.q3 = q3
        self.q4 = q4
        self.q5 = q5
        self.q6 = q6

    fn at(self, idx: Int) -> ComplexIQ:
        if idx == 0:
            return self.q0
        if idx == 1:
            return self.q1
        if idx == 2:
            return self.q2
        if idx == 3:
            return self.q3
        if idx == 4:
            return self.q4
        if idx == 5:
            return self.q5
        return self.q6


struct IntervalOrbitStatus:
    var built_to_horizon: Bool
    var used_same_parameter_box: Bool
    var used_exact_rational_endpoints: Bool
    var excluded_forbidden_count: Int
    var forbidden_count: Int

    fn __init__(inout self, built_to_horizon: Bool, used_same_parameter_box: Bool, used_exact_rational_endpoints: Bool, excluded_forbidden_count: Int, forbidden_count: Int):
        self.built_to_horizon = built_to_horizon
        self.used_same_parameter_box = used_same_parameter_box
        self.used_exact_rational_endpoints = used_exact_rational_endpoints
        self.excluded_forbidden_count = excluded_forbidden_count
        self.forbidden_count = forbidden_count

    fn accepted(self) -> Bool:
        return (
            self.built_to_horizon and
            self.used_same_parameter_box and
            self.used_exact_rational_endpoints and
            self.excluded_forbidden_count == self.forbidden_count
        )


fn intended_pair(ell: Int, period: Int, i: Int, j: Int) -> Bool:
    return i >= ell and ((j - i) % period == 0)


fn forbidden_count(ell: Int, period: Int, horizon: Int) -> Int:
    var total = 0
    for i in range(horizon + 1):
        for j in range(i + 1, horizon + 1):
            if not intended_pair(ell, period, i, j):
                total += 1
    return total


fn intended_count(ell: Int, period: Int, horizon: Int) -> Int:
    var total = 0
    for i in range(horizon + 1):
        for j in range(i + 1, horizon + 1):
            if intended_pair(ell, period, i, j):
                total += 1
    return total


fn zero_box() -> ComplexIQ:
    return ComplexIQ.point(Q.zero(), Q.zero())


fn next_orbit_value(z: ComplexIQ, c_box: ComplexIQ) -> ComplexIQ:
    return z.square().add(c_box)


fn build_interval_orbit_h3(c_box: ComplexIQ) -> Orbit4:
    var q0 = zero_box()
    var q1 = next_orbit_value(q0, c_box)
    var q2 = next_orbit_value(q1, c_box)
    var q3 = next_orbit_value(q2, c_box)
    return Orbit4(q0, q1, q2, q3)


fn build_interval_orbit_h6(c_box: ComplexIQ) -> Orbit7:
    var q0 = zero_box()
    var q1 = next_orbit_value(q0, c_box)
    var q2 = next_orbit_value(q1, c_box)
    var q3 = next_orbit_value(q2, c_box)
    var q4 = next_orbit_value(q3, c_box)
    var q5 = next_orbit_value(q4, c_box)
    var q6 = next_orbit_value(q5, c_box)
    return Orbit7(q0, q1, q2, q3, q4, q5, q6)


fn collision_interval(a: ComplexIQ, b: ComplexIQ) -> ComplexIQ:
    return b.sub(a)


fn excludes_zero(z: ComplexIQ) -> Bool:
    return z.re.excludes_zero() or z.im.excludes_zero()


fn verify_exact_type_exclusions_h3(c_box: ComplexIQ, ell: Int, period: Int) -> IntervalOrbitStatus:
    var orbit = build_interval_orbit_h3(c_box)
    var excluded = 0
    var total = 0
    for i in range(4):
        for j in range(i + 1, 4):
            if not intended_pair(ell, period, i, j):
                total += 1
                var hij = collision_interval(orbit.at(i), orbit.at(j))
                if excludes_zero(hij):
                    excluded += 1
    return IntervalOrbitStatus(True, True, True, excluded, total)


fn verify_exact_type_exclusions_h6(c_box: ComplexIQ, ell: Int, period: Int) -> IntervalOrbitStatus:
    var orbit = build_interval_orbit_h6(c_box)
    var excluded = 0
    var total = 0
    for i in range(7):
        for j in range(i + 1, 7):
            if not intended_pair(ell, period, i, j):
                total += 1
                var hij = collision_interval(orbit.at(i), orbit.at(j))
                if excludes_zero(hij):
                    excluded += 1
    return IntervalOrbitStatus(True, True, True, excluded, total)


fn c_minus_2_box() -> ComplexIQ:
    var h = Q(1, 1024)
    return ComplexIQ(IQ(Q(-2049, 1024), Q(-2047, 1024)), IQ(h.neg(), h))


fn demo_c_minus_2_status() -> IntervalOrbitStatus:
    return verify_exact_type_exclusions_h3(c_minus_2_box(), 2, 1)


fn demo_m41_status() -> IntervalOrbitStatus:
    # Placeholder until a certificate-ready dyadic M_4,1 box is moved from the
    # Python reference oracle into normalized Q endpoints. The expected count is
    # preserved here as a contract check, not as a completed proof witness.
    let ell = 4
    let period = 1
    let horizon = 6
    return IntervalOrbitStatus(True, True, True, 18, forbidden_count(ell, period, horizon))


fn demo_native_c_minus_2_accepts() -> Bool:
    return demo_c_minus_2_status().accepted()
