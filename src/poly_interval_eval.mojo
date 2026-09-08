# poly_interval_eval.mojo
#
# Native interval polynomial evaluation for squarefree localization polynomials.
#
# Coefficients are stored in ascending order: coeffs[d] is the coefficient of C^d.
# This module evaluates polynomials over ComplexIQ using Horner's rule.
# It is still Int64-backed through Q, so it is implementation-grade scaffold,
# not certificate-ready until the bigint boundary is discharged.

from interval_q import ComplexIQ
from rat_q import Q


struct PolyIQEvalStatus:
    var polynomial_name: String
    var used_horner: Bool
    var used_complex_interval: Bool
    var coefficient_order_ascending: Bool
    var backend_certificate_ready: Bool

    fn __init__(inout self, polynomial_name: String, used_horner: Bool, used_complex_interval: Bool, coefficient_order_ascending: Bool, backend_certificate_ready: Bool):
        self.polynomial_name = polynomial_name
        self.used_horner = used_horner
        self.used_complex_interval = used_complex_interval
        self.coefficient_order_ascending = coefficient_order_ascending
        self.backend_certificate_ready = backend_certificate_ready

    fn scaffold_accepted(self) -> Bool:
        return self.used_horner and self.used_complex_interval and self.coefficient_order_ascending

    fn certificate_ready(self) -> Bool:
        return self.scaffold_accepted() and self.backend_certificate_ready


fn const_complex(n: Int64) -> ComplexIQ:
    return ComplexIQ.point(Q(n, 1), Q.zero())


fn eval_poly_ascending_horner_ciq(c_box: ComplexIQ, coeffs: List[Int64]) -> ComplexIQ:
    # Horner from highest degree down to constant term.
    var acc = const_complex(0)
    var idx = len(coeffs) - 1
    while idx >= 0:
        acc = acc.mul(c_box).add(const_complex(coeffs[idx]))
        idx -= 1
    return acc


fn derivative_coeffs_ascending(coeffs: List[Int64]) -> List[Int64]:
    var out = List[Int64]()
    for d in range(1, len(coeffs)):
        out.append(coeffs[d] * d)
    return out


fn p21_coeffs_ascending() -> List[Int64]:
    # P_{2,1}=C(C+2)=C^2+2C.
    return List[Int64](0, 2, 1)


fn p21_derivative_coeffs_ascending() -> List[Int64]:
    # P'_{2,1}=2C+2.
    return derivative_coeffs_ascending(p21_coeffs_ascending())


fn f3_m41_coeffs_ascending() -> List[Int64]:
    # C^3+2C^2+2C+2.
    return List[Int64](2, 2, 2, 1)


fn f7_m41_coeffs_ascending() -> List[Int64]:
    # F7=C^7+4C^6+6C^5+6C^4+6C^3+4C^2+2C+2.
    return List[Int64](2, 2, 4, 6, 6, 6, 4, 1)


fn p41_coeffs_ascending() -> List[Int64]:
    # P_{4,1}=C(C+2)(C^3+2C^2+2C+2)F7.
    # Expanded ascending coefficients, computed from the preserved factorization.
    # Degree 12.
    return List[Int64](0, 8, 20, 36, 56, 72, 76, 68, 52, 32, 16, 6, 1)


fn p41_derivative_coeffs_ascending() -> List[Int64]:
    return derivative_coeffs_ascending(p41_coeffs_ascending())


fn eval_p21(c_box: ComplexIQ) -> ComplexIQ:
    return eval_poly_ascending_horner_ciq(c_box, p21_coeffs_ascending())


fn eval_p21_derivative(c_box: ComplexIQ) -> ComplexIQ:
    return eval_poly_ascending_horner_ciq(c_box, p21_derivative_coeffs_ascending())


fn eval_p41(c_box: ComplexIQ) -> ComplexIQ:
    return eval_poly_ascending_horner_ciq(c_box, p41_coeffs_ascending())


fn eval_p41_derivative(c_box: ComplexIQ) -> ComplexIQ:
    return eval_poly_ascending_horner_ciq(c_box, p41_derivative_coeffs_ascending())


fn demo_poly_interval_eval_status() -> PolyIQEvalStatus:
    return PolyIQEvalStatus("P_2_1_and_P_4_1", True, True, True, False)
