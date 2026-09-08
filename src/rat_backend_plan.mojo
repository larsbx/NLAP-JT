# rat_backend_plan.mojo
#
# Migration plan from Int64 rational scaffolding to proof-grade Q over Z.
#
# This file is intentionally contract-shaped. It records the exact API that the
# existing interval, polynomial, Krawczyk, and rational-trig modules rely on.
# The future implementation must preserve these names while replacing bounded
# integer storage.

from bigint_adapter import BigIntBackendStatus, int64_demo_backend_status


struct RationalBackendStatus:
    var backend: BigIntBackendStatus
    var normalized_after_every_operation: Bool
    var denominator_strictly_positive: Bool
    var denominator_nonzero_checked: Bool
    var equality_cross_multiply_safe: Bool
    var order_cross_multiply_safe: Bool
    var canonical_fraction_serialization: Bool

    fn __init__(inout self, backend: BigIntBackendStatus, normalized_after_every_operation: Bool, denominator_strictly_positive: Bool, denominator_nonzero_checked: Bool, equality_cross_multiply_safe: Bool, order_cross_multiply_safe: Bool, canonical_fraction_serialization: Bool):
        self.backend = backend
        self.normalized_after_every_operation = normalized_after_every_operation
        self.denominator_strictly_positive = denominator_strictly_positive
        self.denominator_nonzero_checked = denominator_nonzero_checked
        self.equality_cross_multiply_safe = equality_cross_multiply_safe
        self.order_cross_multiply_safe = order_cross_multiply_safe
        self.canonical_fraction_serialization = canonical_fraction_serialization

    fn proof_ready(self) -> Bool:
        return (
            self.backend.proof_ready() and
            self.normalized_after_every_operation and
            self.denominator_strictly_positive and
            self.denominator_nonzero_checked and
            self.equality_cross_multiply_safe and
            self.order_cross_multiply_safe and
            self.canonical_fraction_serialization
        )


fn current_q_backend_status() -> RationalBackendStatus:
    return RationalBackendStatus(
        int64_demo_backend_status(),
        True,
        True,
        True,
        False,
        False,
        True,
    )


# Required future Q API over bigint Z:
#
# struct Q:
#     var num: Z
#     var den: Z
#
#     fn __init__(inout self, num: Z, den: Z)
#     fn zero() -> Q
#     fn one() -> Q
#     fn add(self, other: Q) -> Q
#     fn sub(self, other: Q) -> Q
#     fn mul(self, other: Q) -> Q
#     fn div(self, other: Q) -> Q
#     fn neg(self) -> Q
#     fn square(self) -> Q
#     fn eq(self, other: Q) -> Bool
#     fn lt(self, other: Q) -> Bool
#     fn le(self, other: Q) -> Bool
#     fn canonical_bytes(self) -> String
#
# Normalization rule:
#   gcd(abs(num), den)=1 and den>0 after construction and every operation.
#
# Safety rule:
#   eq/lt/le may use cross multiplication only over unbounded Z. The current
#   Int64 implementation must not be proof-grade because cross products can
#   overflow silently.


fn q_backend_blocks_proof_acceptance(status: RationalBackendStatus) -> Bool:
    return not status.proof_ready()
