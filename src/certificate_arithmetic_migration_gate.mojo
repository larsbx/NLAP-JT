# Arithmetic provenance gate for migration of finite certificate acceptance.
#
# Checked-width acceptance means that the bounded calculation completed without
# rejection. Proof-grade acceptance additionally requires an unbounded backend.

from cert_backend import CertIntBackend, int64_demo_backend, checked_int64_transition_backend
from checked_krawczyk_witness import CheckedKrawczykResult, verify_checked_p21_krawczyk


struct ExactTypeExclusionEvidence(ImplicitlyCopyable):
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


struct CheckedLocalizationEnvelope(ImplicitlyCopyable):
    var box_name: String
    var krawczyk_box_name: String
    var krawczyk: CheckedKrawczykResult
    var exclusions: ExactTypeExclusionEvidence
    var backend: CertIntBackend

    def __init__(out self, box_name: String, krawczyk_box_name: String, krawczyk: CheckedKrawczykResult, exclusions: ExactTypeExclusionEvidence, backend: CertIntBackend):
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
        ExactTypeExclusionEvidence(box_name, 5, 5, False),
        checked_int64_transition_backend(),
    )


def certificate_arithmetic_migration_smoke() -> Bool:
    var checked = c_minus_2_checked_localization()
    var rejected_arithmetic = CheckedLocalizationEnvelope(
        "beta_c_minus_2", "beta_c_minus_2", verify_checked_p21_krawczyk(-1),
        ExactTypeExclusionEvidence("beta_c_minus_2", 5, 5, False),
        checked_int64_transition_backend(),
    )
    var incomplete_exclusions = CheckedLocalizationEnvelope(
        "beta_c_minus_2", "beta_c_minus_2", verify_checked_p21_krawczyk(8),
        ExactTypeExclusionEvidence("beta_c_minus_2", 4, 5, False),
        checked_int64_transition_backend(),
    )
    var mismatched_box = CheckedLocalizationEnvelope(
        "beta_c_minus_2", "different_box", verify_checked_p21_krawczyk(8),
        ExactTypeExclusionEvidence("beta_c_minus_2", 5, 5, False),
        checked_int64_transition_backend(),
    )
    var demo = CheckedLocalizationEnvelope(
        "beta_c_minus_2", "beta_c_minus_2", verify_checked_p21_krawczyk(8),
        ExactTypeExclusionEvidence("beta_c_minus_2", 5, 5, False),
        int64_demo_backend(),
    )
    return (
        checked.checked_width_accepted() and not checked.proof_grade_accepted() and
        not rejected_arithmetic.checked_width_accepted() and
        not incomplete_exclusions.checked_width_accepted() and
        not mismatched_box.checked_width_accepted() and
        not demo.checked_width_accepted() and not demo.proof_grade_accepted()
    )
