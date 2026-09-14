# Source-specific theorem-tag payload instances for the checked c=-2 path.
#
# The finite checks below verify source scope and instance data. Final import
# remains fail-closed when parameter association or proof-grade classification
# is absent. No analytic theorem is reproved here.

from certificate_arithmetic_migration_gate import CheckedLocalizationEnvelope, c_minus_2_checked_localization
from checked_ray_address import CheckedRayOrbitStatus, verify_checked_one_half_orbit


struct TheoremSourceRef(ImplicitlyCopyable):
    var citation_key: String
    var source_title: String
    var covered_class: String

    def __init__(out self, citation_key: String, source_title: String, covered_class: String):
        self.citation_key = citation_key
        self.source_title = source_title
        self.covered_class = covered_class

    def complete(self) -> Bool:
        return self.citation_key.byte_length() > 0 and self.source_title.byte_length() > 0 and self.covered_class.byte_length() > 0


struct RationalRayLandingInstance(ImplicitlyCopyable):
    var source: TheoremSourceRef
    var rays: CheckedRayOrbitStatus
    var address_num: Int64
    var address_den: Int64
    var landing_box_name: String
    var landing_target_association_checked: Bool
    var excludes_generic_boundary_use: Bool

    def __init__(out self, source: TheoremSourceRef, rays: CheckedRayOrbitStatus, address_num: Int64, address_den: Int64, landing_box_name: String, landing_target_association_checked: Bool, excludes_generic_boundary_use: Bool):
        self.source = source
        self.rays = rays
        self.address_num = address_num
        self.address_den = address_den
        self.landing_box_name = landing_box_name
        self.landing_target_association_checked = landing_target_association_checked
        self.excludes_generic_boundary_use = excludes_generic_boundary_use

    def source_scope_checked(self) -> Bool:
        return (
            self.source.complete() and self.source.citation_key == "SchleicherRationalParameterRays" and
            self.source.covered_class == "preperiodic rational parameter rays" and
            self.rays.accepted() and self.rays.preperiod == 1 and self.rays.period == 1 and
            self.address_num == 1 and self.address_den == 2 and
            self.landing_box_name == "beta_c_minus_2" and self.excludes_generic_boundary_use
        )

    def final_import_admissible(self) -> Bool:
        return self.source_scope_checked() and self.landing_target_association_checked


struct MisiurewiczTrivialFiberInstance(ImplicitlyCopyable):
    var source: TheoremSourceRef
    var localization: CheckedLocalizationEnvelope
    var ell: Int
    var period: Int
    var excludes_generic_boundary_use: Bool

    def __init__(out self, source: TheoremSourceRef, localization: CheckedLocalizationEnvelope, ell: Int, period: Int, excludes_generic_boundary_use: Bool):
        self.source = source
        self.localization = localization
        self.ell = ell
        self.period = period
        self.excludes_generic_boundary_use = excludes_generic_boundary_use

    def source_scope_checked_width(self) -> Bool:
        return (
            self.source.complete() and self.source.citation_key == "SchleicherFibersLC" and
            self.source.covered_class == "Misiurewicz parameters" and
            self.localization.checked_width_accepted() and
            self.localization.box_name == "beta_c_minus_2" and
            self.ell == 2 and self.period == 1 and self.excludes_generic_boundary_use
        )

    def final_import_admissible(self) -> Bool:
        return self.source_scope_checked_width() and self.localization.proof_grade_accepted()


def schleicher_rational_parameter_ray_source() -> TheoremSourceRef:
    return TheoremSourceRef(
        "SchleicherRationalParameterRays",
        "Rational Parameter Rays of the Mandelbrot Set",
        "preperiodic rational parameter rays",
    )


def schleicher_misiurewicz_fiber_source() -> TheoremSourceRef:
    return TheoremSourceRef(
        "SchleicherFibersLC",
        "On Fibers and Local Connectivity of Mandelbrot and Multibrot Sets",
        "Misiurewicz parameters",
    )


def c_minus_2_landing_instance() -> RationalRayLandingInstance:
    # The finite orbit and source scope are checked. A separate combinatorial
    # adapter must still associate this ray's landing target with the box.
    return RationalRayLandingInstance(
        schleicher_rational_parameter_ray_source(),
        verify_checked_one_half_orbit(),
        1,
        2,
        "beta_c_minus_2",
        False,
        True,
    )


def c_minus_2_trivial_fiber_instance() -> MisiurewiczTrivialFiberInstance:
    return MisiurewiczTrivialFiberInstance(
        schleicher_misiurewicz_fiber_source(),
        c_minus_2_checked_localization(),
        2,
        1,
        True,
    )


def theorem_tag_payload_instances_smoke() -> Bool:
    var landing = c_minus_2_landing_instance()
    var fiber = c_minus_2_trivial_fiber_instance()
    return (
        landing.source_scope_checked() and not landing.final_import_admissible() and
        fiber.source_scope_checked_width() and not fiber.final_import_admissible()
    )
