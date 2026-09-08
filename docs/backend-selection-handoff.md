# Backend Selection Handoff

Status: blocking for proof-grade certificates.

The repository now separates demo arithmetic from certificate arithmetic.

## Current state

`Int64DemoBackend` is allowed for small smoke tests only. It must never enable proof-grade acceptance, because the verifier requires unbounded exact arithmetic for:

- normalized rational endpoints;
- polynomial coefficients in `Z[C]`;
- Euclidean gcd and squarefree witnesses;
- exact divisibility checks;
- interval endpoint comparison;
- deterministic serialization of certificate data.

## Required backend contract

A proof backend must satisfy the `CertIntBackend` fields:

```text
unbounded_storage = true
exact_add_sub_mul = true
exact_order = true
euclidean_gcd = true
exact_divisibility = true
normalized_serialization = true
```

Only then may `BackendGate.allows_certificate_acceptance` be true.

## Candidate paths

1. Mojo-native bigint implementation.
2. Bindings to a mature arbitrary-precision integer library.
3. A two-layer path: reference Python `int`/`Fraction` oracle first, Mojo-native proof backend later.

The third path is acceptable for development, but Python remains a reference oracle, not the finite certificate engine.

## Regression rules

Do not:

- mark `Int64DemoBackend` certificate-ready;
- allow `M_{4,1}` proof-grade acceptance before Krawczyk, exact-type exclusions, theorem tags, and incidence all pass on a proof backend;
- replace rational interval endpoints with floats;
- introduce analytic trig or analytic point primitives.

## Next implementation target

Select the arbitrary-precision backend, then replace the `Q`/`Rat` storage layer with normalized backend integers while preserving existing public operations:

```text
add/sub/mul/div/square/eq/lt/le/gcd/normalize
```

After that, promote:

1. `SquarefreeWitness` from contract to executable witness.
2. `CoordRecord` evaluation for `P'_{4,1}` from pending to computed.
3. `M_{4,1}` Krawczyk from placeholder to computed inclusion.
