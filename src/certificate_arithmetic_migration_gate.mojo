# Arithmetic provenance gate for migration of finite certificate acceptance.
#
# Checked-width acceptance means that the bounded calculation completed without
# rejection. Proof-grade acceptance additionally requires an unbounded backend.

from cert_backend import CertIntBackend, int64_demo_backend, checked_int64_transition_backend
from checked_krawczyk_witness import CheckedKrawczykResult, verify_checked_p21_krawczyk
from checked_interval_exclusion import CheckedExactTypeExclusionResult, checked_p21_exact_type_exclusions


struct CheckedLocalizationEnvelope(ImplicitlyCopyable):
    var box_name: String
    var krawczyk_box_name: String
    var krawczyk: CheckedKrawczykResult
    var exclusions: CheckedExactTypeExclusionResult
    var backend: CertIntBackend

    def __init__(out self, box_name: String, krawczyk_box_name: String, krawczyk: CheckedKrawczykResult, exclusions: CheckedExactTypeExclusionResult, backend: CertIntBackend):
        self.box_name = box_name
        self.krawczyk_box_name = krawczyk_box_name
        self.krawczyk = krawczyk
        self.exclusions = exclusions
        self.backend = backend

    def same_box(self) -> Bool:
        return self.box_name == self.krawczyk_box_name and self.box_name == self.exclusions.box_name

    def checked_width_accepted(self) -> Bool:
        return (
            self.backend.checked_execution_ready() and self.krawczyk.accepted() and
            self.exclusions.accepted() and self.same_box()
        )

    def proof_grade_accepted(self) -> Bool:
        return self.checked_width_accepted() and self.backend.certificate_ready()


def c_minus_2_checked_localization() -> CheckedLocalizationEnvelope:
    var box_name = "beta_c_minus_2"
    return CheckedLocalizationEnvelope(
        box_name,
        box_name,
        verify_checked_p21_krawczyk(8),
        checked_p21_exact_type_exclusions(8),
        checked_int64_transition_backend(),
    )


def certificate_arithmetic_migration_smoke() -> Bool:
    var checked = c_minus_2_checked_localization()
    var rejected_arithmetic = CheckedLocalizationEnvelope(
        "beta_c_minus_2", "beta_c_minus_2", verify_checked_p21_krawczyk(-1),
        checked_p21_exact_type_exclusions(8),
        checked_int64_transition_backend(),
    )
    var ambiguous_exclusions = CheckedLocalizationEnvelope(
        "beta_c_minus_2", "beta_c_minus_2", verify_checked_p21_krawczyk(8),
        checked_p21_exact_type_exclusions(0),
        checked_int64_transition_backend(),
    )
    var mismatched_box = CheckedLocalizationEnvelope(
        "beta_c_minus_2", "different_box", verify_checked_p21_krawczyk(8),
        checked_p21_exact_type_exclusions(8),
        checked_int64_transition_backend(),
    )
    var demo = CheckedLocalizationEnvelope(
        "beta_c_minus_2", "beta_c_minus_2", verify_checked_p21_krawczyk(8),
        checked_p21_exact_type_exclusions(8),
        int64_demo_backend(),
    )
    return (
        checked.checked_width_accepted() and not checked.proof_grade_accepted() and
        not rejected_arithmetic.checked_width_accepted() and
        not ambiguous_exclusions.checked_width_accepted() and
        not mismatched_box.checked_width_accepted() and
        not demo.checked_width_accepted() and not demo.proof_grade_accepted()
    )
