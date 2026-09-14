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

0. Use `src/checked_int64_backend.mojo` to fail closed during migration. Its
   compiled Q_8 growth control confirms the present bounded backend cannot
   complete the intended recurrence. This layer does not itself permit
   certificate acceptance and `Q` has not yet been migrated to it.
   `src/checked_q.mojo` now supplies the normalized, rejection-aware rational
   API over that transition layer. `src/checked_interval_q.mojo` now propagates
   rejection through the real rational-interval operations.
   `src/checked_complex_interval.mojo` now carries rejection through rank-2
   interval arithmetic and `P_{2,1}` Horner evaluation.
   `src/checked_krawczyk_witness.mojo` now propagates rejection through strict
   inclusion and the complete `P_{2,1}` contraction calculation. The next slice
   `src/checked_interval_exclusion.mojo` now computes all five forbidden
   `P_{2,1}` orbit collisions on the same checked c=-2 box and fails closed on
   arithmetic rejection or ambiguous zero containment.
   `src/certificate_arithmetic_migration_gate.mojo` separates checked-width
   localization acceptance from proof-grade acceptance and binds the checked
   contraction to that computed exact-type result on the same box. The next
   slice inventories the remaining downstream predicates in
   `docs/certificate-predicate-migration-inventory.md`.
   `src/checked_ray_address.mojo` computes the c=-2 rational ray orbit with
   fixed-width overflow rejection, and `src/checked_finite_certificate_gate.mojo`
   now proves that checked finite inputs are insufficient for proof-grade use.
   `src/checked_landing_target_adapter.mojo` derives the bounded-width `1/2` to
   c=-2 association from exact-type uniqueness; theorem-tag instances now fail
   only at proof-grade classification. Do not replace `Q` until every downstream
   arithmetic predicate propagates failure.
1. **Selected:** Mojo-native dynamic base-`10^9` limbs in `src/bigint_z.mojo`.
2. **Complete:** the integer layer implements unbounded signed storage, exact
   add/sub/mul/order, quotient/remainder, rejected non-divisions, Euclidean gcd,
   and canonical `Z(sign, byte_len, big_endian_magnitude)` serialization.
3. **Next:** replace `Q(Int64, Int64)` internals with `Q(BigZ, BigZ)` while preserving public arithmetic names.
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
