# krawczyk_witness.mojo
#
# Native target for squarefree-polynomial Krawczyk localization witnesses.
#
# This module is finite-regime only: exact polynomial data, dyadic rational
# boxes, and interval inclusion checks. It contains no analytic trig primitives.
#
# Status:
# - P_{2,1}=C(C+2) has a native interval Krawczyk computation.
# - P_{4,1}=C(C+2)(C^3+2C^2+2C+2)F7 is represented by its required
#   witness fields, but full interval polynomial evaluation remains pending.

from interval_q import ComplexIQ, IQ
from rat_q import Q


struct KrawczykWitnessStatus:
    var polynomial_name: String
    var used_squarefree_polynomial: Bool
    var used_dyadic_center: Bool
    var used_dyadic_inverse: Bool
    var krawczyk_subset_interior: Bool
    var root_box_name: String

    fn __init__(inout self, polynomial_name: String, used_squarefree_polynomial: Bool, used_dyadic_center: Bool, used_dyadic_inverse: Bool, krawczyk_subset_interior: Bool, root_box_name: String):
        self.polynomial_name = polynomial_name
        self.used_squarefree_polynomial = used_squarefree_polynomial
        self.used_dyadic_center = used_dyadic_center
        self.used_dyadic_inverse = used_dyadic_inverse
        self.krawczyk_subset_interior = krawczyk_subset_interior
        self.root_box_name = root_box_name

    fn accepted(self) -> Bool:
        return (
            self.used_squarefree_polynomial and
            self.used_dyadic_center and
            self.used_dyadic_inverse and
            self.krawczyk_subset_interior
        )


fn complex_neg(z: ComplexIQ) -> ComplexIQ:
    return ComplexIQ(z.re.neg(), z.im.neg())


fn complex_one() -> ComplexIQ:
    return ComplexIQ.point(Q.one(), Q.zero())


fn complex_two() -> ComplexIQ:
    return ComplexIQ.point(Q(2, 1), Q.zero())


fn complex_minus_half() -> ComplexIQ:
    return ComplexIQ.point(Q(-1, 2), Q.zero())


fn complex_minus_two_point() -> ComplexIQ:
    return ComplexIQ.point(Q(-2, 1), Q.zero())


fn p21_value(c: ComplexIQ) -> ComplexIQ:
    # P21(C)=C(C+2).
    return c.mul(c.add(complex_two()))


fn p21_derivative(c: ComplexIQ) -> ComplexIQ:
    # dP21(C)=2C+2.
    return c.mul(complex_two()).add(complex_two())


fn c_minus_2_box(radius_den_power: Int) -> ComplexIQ:
    # Dyadic box centered at -2 with half-width 2^{-radius_den_power} in each coordinate.
    # Current Int64 rational backend only supports small powers safely.
    var den = 1
    for _ in range(radius_den_power):
        den *= 2
    var h = Q(1, den)
    return ComplexIQ(IQ(Q(-2, 1).sub(h), Q(-2, 1).add(h)), IQ(h.neg(), h))


fn p21_krawczyk_image(beta: ComplexIQ) -> ComplexIQ:
    # K(beta)=m-A P(m)+(1-A P'(beta))(beta-m)
    # for m=-2 and A=-1/2.
    var m = complex_minus_two_point()
    var a = complex_minus_half()
    var p_m = p21_value(m)
    var beta_minus_m = beta.sub(m)
    var one_minus_a_dp = complex_one().sub(a.mul(p21_derivative(beta)))
    return m.sub(a.mul(p_m)).add(one_minus_a_dp.mul(beta_minus_m))


fn verify_p21_krawczyk_c_minus_2(radius_den_power: Int) -> Bool:
    var beta = c_minus_2_box(radius_den_power)
    var image = p21_krawczyk_image(beta)
    return image.strict_subset_of(beta)


fn demo_krawczyk_p21_c_minus_2() -> KrawczykWitnessStatus:
    # Computed native interval witness for beta centered at -2.
    # The default radius 2^-8 is intentionally small enough for the current
    # Int64 rational scaffold and still large enough for readable debugging.
    var ok = verify_p21_krawczyk_c_minus_2(8)
    return KrawczykWitnessStatus("P_2_1", True, True, True, ok, "beta_c_minus_2")


fn f7_name() -> String:
    return "F7=C^7+4C^6+6C^5+6C^4+6C^3+4C^2+2C+2"


fn p41_squarefree_name() -> String:
    return "P_4_1=C(C+2)(C^3+2C^2+2C+2)F7"


fn demo_krawczyk_p41_m41_placeholder() -> KrawczykWitnessStatus:
    # Required target witness for M_{4,1}:
    #   P=P_4_1 squarefree polynomial.
    #   beta centered at dyadic approximation of upper non-real F7 root.
    #   A dyadic enclosure for inverse derivative at the center.
    #   Proof that K_P(beta) is strictly inside beta.
    # This remains placeholder-only until polynomial interval evaluation lands.
    return KrawczykWitnessStatus("P_4_1", True, True, True, False, "beta_m41_pending")


fn krawczyk_ready_for_joint_certificate(status: KrawczykWitnessStatus) -> Bool:
    return status.accepted()
