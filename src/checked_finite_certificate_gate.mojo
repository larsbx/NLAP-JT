# Checked finite-certificate boundary after arithmetic localization migration.
#
# The finite arithmetic inputs for c=-2 can be checked at bounded width. Full
# certificate acceptance remains false until the required classical theorem-tag
# import records carry checked, source-specific payloads.

from certificate_arithmetic_migration_gate import CheckedLocalizationEnvelope, c_minus_2_checked_localization
from checked_ray_address import CheckedRayOrbitStatus, verify_checked_one_half_orbit
from C1_theorem_tag_import_ledger import TheoremTagRecord, theorem_tag_admissible_for_final, rational_parameter_ray_landing_tag_ready, known_trivial_fiber_class_tag_ready


struct CheckedFiniteCertificateStatus(ImplicitlyCopyable):
    var localization: CheckedLocalizationEnvelope
    var rays: CheckedRayOrbitStatus
    var landing_tag: TheoremTagRecord
    var fiber_tag: TheoremTagRecord

    def __init__(out self, localization: CheckedLocalizationEnvelope, rays: CheckedRayOrbitStatus, landing_tag: TheoremTagRecord, fiber_tag: TheoremTagRecord):
        self.localization = localization
        self.rays = rays
        self.landing_tag = landing_tag
        self.fiber_tag = fiber_tag

    def checked_finite_inputs_accepted(self) -> Bool:
        return self.localization.checked_width_accepted() and self.rays.accepted()

    def theorem_tags_accepted(self) -> Bool:
        return (
            theorem_tag_admissible_for_final(self.landing_tag) and
            theorem_tag_admissible_for_final(self.fiber_tag)
        )

    def certificate_accepted(self) -> Bool:
        return self.checked_finite_inputs_accepted() and self.theorem_tags_accepted()

    def proof_grade_accepted(self) -> Bool:
        return self.certificate_accepted() and self.localization.proof_grade_accepted()


def c_minus_2_checked_finite_certificate() -> CheckedFiniteCertificateStatus:
    return CheckedFiniteCertificateStatus(
        c_minus_2_checked_localization(),
        verify_checked_one_half_orbit(),
        rational_parameter_ray_landing_tag_ready(),
        known_trivial_fiber_class_tag_ready(),
    )


def checked_finite_certificate_gate_smoke() -> Bool:
    var status = c_minus_2_checked_finite_certificate()
    return (
        status.checked_finite_inputs_accepted() and
        not status.theorem_tags_accepted() and
        not status.certificate_accepted() and
        not status.proof_grade_accepted()
    )
