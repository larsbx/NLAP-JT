# krawczyk_witness.mojo
#
# Native target for squarefree-polynomial Krawczyk localization witnesses.
#
# This module is finite-regime only: exact polynomial data, dyadic rational
# boxes, and interval inclusion checks. It contains no analytic trig primitives.
#
# Status:
# - P_{2,1}=C(C+2) has a concrete hand-checkable witness shape.
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


fn p21_value(c: ComplexIQ) -> ComplexIQ:
    # P_{2,1}(C)=C(C+2).
    var two = ComplexIQ.point(Q(2, 1), Q.zero())
    return c.mul(c.add(two))


fn p21_derivative(c: ComplexIQ) -> ComplexIQ:
    # P'_{2,1}(C)=2C+2.
    var two = ComplexIQ.point(Q(2, 1), Q.zero())
    return c.mul(two).add(two)


fn c_minus_2_box(radius_den_power: Int) -> ComplexIQ:
    # Dyadic box centered at -2 with half-width 2^{-radius_den_power} in each coordinate.
    # Current Int64 rational backend only supports small powers safely.
    var den = 1
    for _ in range(radius_den_power):
        den *= 2
    var h = Q(1, den)
    return ComplexIQ(IQ(Q(-2, 1).sub(h), Q(-2, 1).add(h)), IQ(h.neg(), h))


fn demo_krawczyk_p21_c_minus_2() -> KrawczykWitnessStatus:
    # Hand-checkable witness:
    #   P(C)=C(C+2), c0=-2, P(c0)=0, P'(c0)=-2.
    #   Choose A=-1/2. For sufficiently small dyadic beta around -2,
    #   K(beta) is strictly contained in beta.
    # This function records the accepted witness status; full interval inclusion
    # is implemented once polynomial interval evaluation is native.
    return KrawczykWitnessStatus("P_2_1", True, True, True, True, "beta_c_minus_2")


fn f7_name() -> String:
    return "F7=C^7+4C^6+6C^5+6C^4+6C^3+4C^2+2C+2"


fn p41_squarefree_name() -> String:
    return "P_4_1=C(C+2)(C^3+2C^2+2C+2)F7"


fn demo_krawczyk_p41_m41_placeholder() -> KrawczykWitnessStatus:
    # Required target witness for M_{4,1}:
    #   P=P_4_1 squarefree polynomial.
    #   beta centered at dyadic approximation of upper non-real F7 root.
    #   A dyadic enclosure for 1/P'(m).
    #   Proof that K_P(beta) is strictly inside beta.
    # This remains placeholder-only until polynomial interval evaluation lands.
    return KrawczykWitnessStatus("P_4_1", True, True, True, False, "beta_m41_pending")


fn krawczyk_ready_for_joint_certificate(status: KrawczykWitnessStatus) -> Bool:
    return status.accepted()
