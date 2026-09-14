# Checked finite-certificate boundary after arithmetic localization migration.
#
# The finite arithmetic inputs for c=-2 can be checked at bounded width. Full
# certificate acceptance remains false until the required classical theorem-tag
# import records carry checked, source-specific payloads.

from certificate_arithmetic_migration_gate import CheckedLocalizationEnvelope, c_minus_2_checked_localization
from checked_ray_address import CheckedRayOrbitStatus, verify_checked_one_half_orbit
from C1_theorem_tag_payload_instances import RationalRayLandingInstance, MisiurewiczTrivialFiberInstance, c_minus_2_landing_instance, c_minus_2_trivial_fiber_instance


struct CheckedFiniteCertificateStatus(ImplicitlyCopyable):
    var localization: CheckedLocalizationEnvelope
    var rays: CheckedRayOrbitStatus
    var landing_tag: RationalRayLandingInstance
    var fiber_tag: MisiurewiczTrivialFiberInstance

    def __init__(out self, localization: CheckedLocalizationEnvelope, rays: CheckedRayOrbitStatus, landing_tag: RationalRayLandingInstance, fiber_tag: MisiurewiczTrivialFiberInstance):
        self.localization = localization
        self.rays = rays
        self.landing_tag = landing_tag
        self.fiber_tag = fiber_tag

    def checked_finite_inputs_accepted(self) -> Bool:
        return self.localization.checked_width_accepted() and self.rays.accepted()

    def theorem_tags_accepted(self) -> Bool:
        return (
            self.landing_tag.final_import_admissible() and
            self.fiber_tag.final_import_admissible()
        )

    def certificate_accepted(self) -> Bool:
        return self.checked_finite_inputs_accepted() and self.theorem_tags_accepted()

    def proof_grade_accepted(self) -> Bool:
        return self.certificate_accepted() and self.localization.proof_grade_accepted()


def c_minus_2_checked_finite_certificate() -> CheckedFiniteCertificateStatus:
    return CheckedFiniteCertificateStatus(
        c_minus_2_checked_localization(),
        verify_checked_one_half_orbit(),
        c_minus_2_landing_instance(),
        c_minus_2_trivial_fiber_instance(),
    )


def checked_finite_certificate_gate_smoke() -> Bool:
    var status = c_minus_2_checked_finite_certificate()
    return (
        status.checked_finite_inputs_accepted() and
        not status.theorem_tags_accepted() and
        not status.certificate_accepted() and
        not status.proof_grade_accepted()
    )
