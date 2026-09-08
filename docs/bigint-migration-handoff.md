# BigInt Migration Handoff

## Purpose

The current repository has useful finite-regime scaffolding, but its rational arithmetic still sits on bounded `Int64` demos. That is acceptable for smoke tests only. No proof-grade certificate may be accepted until the integer backend is unbounded and canonical.

## Non-negotiable invariant

Do not change the certificate semantics to fit the backend.

The backend must satisfy the calculus, not the other way around.

## Required integer backend properties

A certificate-ready backend must provide:

1. unbounded signed integers;
2. exact addition, subtraction, multiplication, and negation;
3. exact order comparison;
4. Euclidean gcd;
5. exact divisibility with rejected non-divisions;
6. deterministic canonical serialization;
7. an explicit `allows_certificate_acceptance=true` gate.

## Required rational backend properties

`Q` must become a normalized fraction over the bigint backend:

```text
Q = num / den
where den > 0 and gcd(abs(num), den) = 1
```

Every constructor and operation must normalize. Equality and order may use cross multiplication only after the bigint backend is active.

## Files that define the gate

- `src/bigint_adapter.mojo`
- `src/rat_backend_plan.mojo`
- `src/cert_backend.mojo`
- `src/proof_grade_gate.mojo`
- `tests/test_backend_migration.py`
- `tests/test_proof_grade_gate.py`

## Migration sequence

1. Choose a Mojo-compatible bigint source.
2. Implement `Z` behind `bigint_adapter.mojo`.
3. Replace `Q(Int64, Int64)` internals with `Q(Z, Z)` while preserving public arithmetic names.
4. Re-run interval arithmetic against bigint-backed `Q`.
5. Promote coordinate-record polynomial evaluation from pending to certificate-ready.
6. Only then allow `ProofGradeCertificateStatus.accepted()` to return true.

## Forbidden shortcuts

Do not use:

- bounded integer overflow assumptions;
- floating approximations;
- analytic trigonometry;
- analytic point membership;
- lower-factor gcd stripping for exact type.

The accepted pipeline remains:

```text
squarefree localization
+ same-box forbidden collision exclusions
+ rational ray-address combinatorics
+ theorem tags
+ PointVertex incidence packaging
+ proof-grade bigint/rational backend
```
