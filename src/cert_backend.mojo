# cert_backend.mojo
#
# Certificate arithmetic backend contract.
#
# The finite-regime verifier may use small Int64-backed demos, but no certificate
# may be accepted as proof-grade until the integer backend is explicitly marked
# unbounded and exact. This file separates demo arithmetic from certificate
# arithmetic.


struct CertIntBackend:
    var name: String
    var unbounded_storage: Bool
    var exact_add_sub_mul: Bool
    var exact_order: Bool
    var euclidean_gcd: Bool
    var exact_divisibility: Bool
    var normalized_serialization: Bool

    fn __init__(inout self, name: String, unbounded_storage: Bool, exact_add_sub_mul: Bool, exact_order: Bool, euclidean_gcd: Bool, exact_divisibility: Bool, normalized_serialization: Bool):
        self.name = name
        self.unbounded_storage = unbounded_storage
        self.exact_add_sub_mul = exact_add_sub_mul
        self.exact_order = exact_order
        self.euclidean_gcd = euclidean_gcd
        self.exact_divisibility = exact_divisibility
        self.normalized_serialization = normalized_serialization

    fn certificate_ready(self) -> Bool:
        return (
            self.unbounded_storage and
            self.exact_add_sub_mul and
            self.exact_order and
            self.euclidean_gcd and
            self.exact_divisibility and
            self.normalized_serialization
        )


fn int64_demo_backend() -> CertIntBackend:
    return CertIntBackend(
        "Int64DemoBackend",
        False,
        True,
        True,
        True,
        True,
        True,
    )


fn proof_backend_pending() -> CertIntBackend:
    return CertIntBackend(
        "ProofBackendPending",
        False,
        False,
        False,
        False,
        False,
        False,
    )


struct BackendGate:
    var backend: CertIntBackend
    var allows_demo: Bool
    var allows_certificate_acceptance: Bool

    fn __init__(inout self, backend: CertIntBackend, allows_demo: Bool, allows_certificate_acceptance: Bool):
        self.backend = backend
        self.allows_demo = allows_demo
        self.allows_certificate_acceptance = allows_certificate_acceptance

    fn valid(self) -> Bool:
        if self.allows_certificate_acceptance:
            return self.backend.certificate_ready()
        return self.allows_demo


fn demo_gate() -> BackendGate:
    return BackendGate(int64_demo_backend(), True, False)


fn certificate_gate_pending() -> BackendGate:
    return BackendGate(proof_backend_pending(), False, False)


fn must_reject_certificate_on_int64_demo_backend() -> Bool:
    var gate = BackendGate(int64_demo_backend(), True, True)
    return not gate.valid()
