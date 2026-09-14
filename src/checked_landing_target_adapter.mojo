# Finite landing-target adapter for the checked c=-2 certificate path.
#
# This module does not prove analytic ray landing. It checks the finite inputs
# to the Schleicher preperiodic-ray correspondence and proves that P_{2,1} has
# only one exact-type candidate after the lower-type root C=0 is removed.

from poly_z import PolyZ, critical_orbit_poly, raw_return_poly, expected_R_2_1, expected_P_2_1_squarefree, equal_poly
from checked_ray_address import CheckedRayOrbitStatus, verify_checked_one_half_orbit
from certificate_arithmetic_migration_gate import CheckedLocalizationEnvelope, c_minus_2_checked_localization


struct P21ExactTypeUniqueness(ImplicitlyCopyable):
    var polynomial_identity_verified: Bool
    var squarefree_factorization_verified: Bool
    var zero_candidate_verified: Bool
    var minus_two_candidate_verified: Bool
    var zero_is_lower_type: Bool
    var minus_two_exact_type_checked_width: Bool

    def __init__(out self, polynomial_identity_verified: Bool, squarefree_factorization_verified: Bool, zero_candidate_verified: Bool, minus_two_candidate_verified: Bool, zero_is_lower_type: Bool, minus_two_exact_type_checked_width: Bool):
        self.polynomial_identity_verified = polynomial_identity_verified
        self.squarefree_factorization_verified = squarefree_factorization_verified
        self.zero_candidate_verified = zero_candidate_verified
        self.minus_two_candidate_verified = minus_two_candidate_verified
        self.zero_is_lower_type = zero_is_lower_type
        self.minus_two_exact_type_checked_width = minus_two_exact_type_checked_width

    def checked_width_accepted(self) -> Bool:
        return (
            self.polynomial_identity_verified and self.squarefree_factorization_verified and
            self.zero_candidate_verified and self.minus_two_candidate_verified and
            self.zero_is_lower_type and self.minus_two_exact_type_checked_width
        )


struct LandingCorrespondenceRule(ImplicitlyCopyable):
    var source_citation_key: String
    var critical_orbit_preperiod_offset: Int
    var period_preserved: Bool
    var covers_strictly_preperiodic_addresses: Bool

    def __init__(out self, source_citation_key: String, critical_orbit_preperiod_offset: Int, period_preserved: Bool, covers_strictly_preperiodic_addresses: Bool):
        self.source_citation_key = source_citation_key
        self.critical_orbit_preperiod_offset = critical_orbit_preperiod_offset
        self.period_preserved = period_preserved
        self.covers_strictly_preperiodic_addresses = covers_strictly_preperiodic_addresses

    def valid_for_p21(self) -> Bool:
        return (
            self.source_citation_key == "SchleicherRationalParameterRays" and
            self.critical_orbit_preperiod_offset == 1 and self.period_preserved and
            self.covers_strictly_preperiodic_addresses
        )


struct LandingTargetAssociation(ImplicitlyCopyable):
    var correspondence: LandingCorrespondenceRule
    var rays: CheckedRayOrbitStatus
    var localization: CheckedLocalizationEnvelope
    var uniqueness: P21ExactTypeUniqueness
    var ell: Int
    var period: Int

    def __init__(out self, correspondence: LandingCorrespondenceRule, rays: CheckedRayOrbitStatus, localization: CheckedLocalizationEnvelope, uniqueness: P21ExactTypeUniqueness, ell: Int, period: Int):
        self.correspondence = correspondence
        self.rays = rays
        self.localization = localization
        self.uniqueness = uniqueness
        self.ell = ell
        self.period = period

    def checked_width_associated(self) -> Bool:
        return (
            self.correspondence.valid_for_p21() and
            self.rays.accepted() and self.localization.checked_width_accepted() and
            self.rays.preperiod + self.correspondence.critical_orbit_preperiod_offset == self.ell and
            self.rays.period == self.period and
            self.ell == 2 and self.period == 1 and
            self.localization.box_name == "beta_c_minus_2" and
            self.uniqueness.checked_width_accepted()
        )

    def proof_grade_associated(self) -> Bool:
        return self.checked_width_associated() and self.localization.proof_grade_accepted()


def eval_poly_at_int(p: PolyZ, value: Int) -> Int:
    var acc = 0
    var idx = p.degree
    while idx >= 0:
        acc = acc * value + p.coefficient(idx)
        idx -= 1
    return acc


def verify_p21_exact_type_uniqueness(localization: CheckedLocalizationEnvelope) -> P21ExactTypeUniqueness:
    var relation = raw_return_poly(2, 1)
    var squarefree = expected_P_2_1_squarefree()
    var q0 = critical_orbit_poly(0)
    var q1 = critical_orbit_poly(1)
    var factorization = (
        squarefree.degree == 2 and squarefree.coefficient(0) == 0 and
        squarefree.coefficient(1) == 2 and squarefree.coefficient(2) == 1
    )
    return P21ExactTypeUniqueness(
        equal_poly(relation, expected_R_2_1()),
        factorization,
        eval_poly_at_int(squarefree, 0) == 0,
        eval_poly_at_int(squarefree, -2) == 0,
        eval_poly_at_int(q0, 0) == eval_poly_at_int(q1, 0),
        localization.checked_width_accepted() and localization.exclusions.accepted(),
    )


def schleicher_preperiodic_correspondence() -> LandingCorrespondenceRule:
    return LandingCorrespondenceRule("SchleicherRationalParameterRays", 1, True, True)


def verify_c_minus_2_landing_target_association() -> LandingTargetAssociation:
    var localization = c_minus_2_checked_localization()
    return LandingTargetAssociation(
        schleicher_preperiodic_correspondence(),
        verify_checked_one_half_orbit(),
        localization,
        verify_p21_exact_type_uniqueness(localization),
        2,
        1,
    )


def checked_landing_target_adapter_smoke() -> Bool:
    var association = verify_c_minus_2_landing_target_association()
    var wrong_correspondence = LandingTargetAssociation(
        LandingCorrespondenceRule("SchleicherRationalParameterRays", 0, True, True),
        association.rays,
        association.localization,
        association.uniqueness,
        association.ell,
        association.period,
    )
    return (
        association.uniqueness.checked_width_accepted() and
        association.checked_width_associated() and
        not association.proof_grade_associated() and
        not wrong_correspondence.checked_width_associated()
    )
