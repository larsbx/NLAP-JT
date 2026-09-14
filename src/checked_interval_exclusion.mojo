# Rejection-aware exact-type exclusions for the checked c = -2 transition box.
# Specification: docs/rational-interval-arithmetic-spec.md (binding 6.2).
#
# Every forbidden collision is evaluated on the same parameter box. Arithmetic
# rejection and failure to exclude zero are distinct, fail-closed outcomes.

from checked_q import CheckedQBoolResult
from checked_interval_q import checked_iq_contains_zero
from checked_complex_interval import CheckedComplexIQResult, rejected_complex_iq, checked_complex_point, checked_complex_add, checked_complex_sub, checked_complex_square
from checked_krawczyk_witness import checked_c_minus_2_box


struct CheckedOrbit4(ImplicitlyCopyable):
    var q0: CheckedComplexIQResult
    var q1: CheckedComplexIQResult
    var q2: CheckedComplexIQResult
    var q3: CheckedComplexIQResult
    var rejected: Bool

    def __init__(out self, q0: CheckedComplexIQResult, q1: CheckedComplexIQResult, q2: CheckedComplexIQResult, q3: CheckedComplexIQResult, rejected: Bool):
        self.q0 = q0
        self.q1 = q1
        self.q2 = q2
        self.q3 = q3
        self.rejected = rejected

    def at(self, idx: Int) -> CheckedComplexIQResult:
        if idx == 0:
            return self.q0
        if idx == 1:
            return self.q1
        if idx == 2:
            return self.q2
        if idx == 3:
            return self.q3
        return rejected_complex_iq()


struct CheckedExactTypeExclusionResult(ImplicitlyCopyable):
    var box_name: String
    var excluded_count: Int
    var required_count: Int
    var arithmetic_rejected: Bool

    def __init__(out self, box_name: String, excluded_count: Int, required_count: Int, arithmetic_rejected: Bool):
        self.box_name = box_name
        self.excluded_count = excluded_count
        self.required_count = required_count
        self.arithmetic_rejected = arithmetic_rejected

    def accepted(self) -> Bool:
        return (
            not self.arithmetic_rejected and self.required_count > 0 and
            self.excluded_count == self.required_count
        )


def checked_next_orbit_value(z: CheckedComplexIQResult, c_box: CheckedComplexIQResult) -> CheckedComplexIQResult:
    return checked_complex_add(checked_complex_square(z), c_box)


def build_checked_interval_orbit_h3(c_box: CheckedComplexIQResult) -> CheckedOrbit4:
    if c_box.rejected:
        var rejected = rejected_complex_iq()
        return CheckedOrbit4(rejected, rejected, rejected, rejected, True)
    var q0 = checked_complex_point(0, 1, 0, 1)
    var q1 = checked_next_orbit_value(q0, c_box)
    var q2 = checked_next_orbit_value(q1, c_box)
    var q3 = checked_next_orbit_value(q2, c_box)
    return CheckedOrbit4(q0, q1, q2, q3, q0.rejected or q1.rejected or q2.rejected or q3.rejected)


def checked_collision_excludes_zero(a: CheckedComplexIQResult, b: CheckedComplexIQResult) -> CheckedQBoolResult:
    var collision = checked_complex_sub(b, a)
    if collision.rejected:
        return CheckedQBoolResult(False, True)
    var re_contains = checked_iq_contains_zero(collision.re)
    var im_contains = checked_iq_contains_zero(collision.im)
    if re_contains.rejected or im_contains.rejected:
        return CheckedQBoolResult(False, True)
    return CheckedQBoolResult(not re_contains.value or not im_contains.value, False)


def checked_p21_exact_type_exclusions(radius_den_power: Int) -> CheckedExactTypeExclusionResult:
    var box_name = "beta_c_minus_2"
    var orbit = build_checked_interval_orbit_h3(checked_c_minus_2_box(radius_den_power))
    if orbit.rejected:
        return CheckedExactTypeExclusionResult(box_name, 0, 5, True)

    # For (ell, period, horizon) = (2, 1, 3), (2, 3) is the sole intended
    # collision. These are all five remaining pairs, evaluated on one orbit.
    var pairs_i = List[Int]([0, 0, 0, 1, 1])
    var pairs_j = List[Int]([1, 2, 3, 2, 3])
    var excluded = 0
    for pair_idx in range(5):
        var exclusion = checked_collision_excludes_zero(
            orbit.at(pairs_i[pair_idx]), orbit.at(pairs_j[pair_idx])
        )
        if exclusion.rejected:
            return CheckedExactTypeExclusionResult(box_name, excluded, 5, True)
        if exclusion.value:
            excluded += 1
    return CheckedExactTypeExclusionResult(box_name, excluded, 5, False)


def checked_interval_exclusion_smoke() -> Bool:
    var witness = checked_p21_exact_type_exclusions(8)
    var ambiguous = checked_p21_exact_type_exclusions(0)
    var invalid = checked_p21_exact_type_exclusions(-1)
    var overflow = checked_p21_exact_type_exclusions(63)
    return (
        witness.accepted() and witness.excluded_count == 5 and witness.required_count == 5 and
        not ambiguous.accepted() and not ambiguous.arithmetic_rejected and
        invalid.arithmetic_rejected and not invalid.accepted() and
        overflow.arithmetic_rejected and not overflow.accepted()
    )
