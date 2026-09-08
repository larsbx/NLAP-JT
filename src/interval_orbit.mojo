# interval_orbit.mojo
#
# Native Mojo target for interval critical-orbit evaluation.
#
# This file mirrors tools/interval_exclusion_reference.py but remains scaffolded
# until rat_q.mojo is backed by a certificate-ready arbitrary-precision integer
# implementation. It is intentionally free of analytic trig APIs.


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
    # Intended tail equalities begin at ell and repeat with the claimed period.
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


# Native target once interval_q.mojo and rat_q.mojo are certificate-ready:
#
# fn build_interval_orbit(c_box: ComplexIntervalQ, horizon: Int) -> List[ComplexIntervalQ]:
#     Q[0] = 0
#     for n in 0 .. horizon-1:
#         Q[n+1] = Q[n] * Q[n] + c_box
#     return Q
#
# fn collision_interval(Q: List[ComplexIntervalQ], i: Int, j: Int) -> ComplexIntervalQ:
#     return Q[j] - Q[i]
#
# fn excludes_zero(z: ComplexIntervalQ) -> Bool:
#     return z.real.excludes_zero() or z.imag.excludes_zero()
#
# fn verify_exact_type_exclusions(c_box: ComplexIntervalQ, ell: Int, period: Int, horizon: Int) -> IntervalOrbitStatus:
#     Q = build_interval_orbit(c_box, horizon)
#     count all forbidden pairs where excludes_zero(collision_interval(Q, i, j))
#     return status requiring all forbidden pairs excluded on the same c_box


fn demo_c_minus_2_status() -> IntervalOrbitStatus:
    let ell = 2
    let period = 1
    let horizon = 3
    return IntervalOrbitStatus(True, True, True, 5, forbidden_count(ell, period, horizon))


fn demo_m41_status() -> IntervalOrbitStatus:
    let ell = 4
    let period = 1
    let horizon = 6
    return IntervalOrbitStatus(True, True, True, 18, forbidden_count(ell, period, horizon))
