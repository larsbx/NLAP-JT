# Mojo toolchain boundary

Status: compiling initial slice; repository-wide port incomplete.

The repository pins Mojo 1.0.0 and pytest 8.3.5 through `pixi.toml` and
`pixi.lock`. CI performs both a JIT smoke run and an ahead-of-time build.

The compiler-checked dependency closure currently consists of:

- `src/smoke_tests.mojo`;
- `src/poly_z.mojo`;
- `src/cert_types.mojo`;
- `src/rat_q.mojo`;
- `src/integer_gcd.mojo`;
- `src/ray_address.mojo`;
- `src/rational_trig.mojo`;
- `src/alignment_audit_status.mojo`;
- `src/mojo_optimization_contract.mojo`;
- `src/interval_q.mojo`;
- `src/poly_interval_eval.mojo`;
- `src/krawczyk_witness.mojo`.
- `src/C1_final_proof_block_ledger.mojo`.
- `src/C1_residual_closure_no_missing_links.mojo`.
- `src/C1_theorem_tag_assumption_payloads.mojo`.
- `src/C1_theorem_tag_import_ledger.mojo`.
- `src/C1_final_proof_object_skeleton.mojo`.
- `src/checked_int64_backend.mojo`.
- `src/checked_q.mojo`.
- `src/checked_interval_q.mojo`.
- `src/checked_complex_interval.mojo`.
- `src/checked_krawczyk_witness.mojo`.
- `src/checked_interval_exclusion.mojo`.
- `src/cert_backend.mojo`.
- `src/certificate_arithmetic_migration_gate.mojo`.
- `src/checked_ray_address.mojo`.
- `src/checked_finite_certificate_gate.mojo`.
- `src/C1_theorem_tag_payload_instances.mojo`.
- `src/checked_landing_target_adapter.mojo`.
- `src/bigint_z.mojo`.
- `src/bigint_adapter.mojo`.

This slice checks the preserved polynomial identities, certificate-header
constraints, the same-box joint-witness gate, imported-theorem-tag acceptance,
normalized rational arithmetic, rational ordering, interval multiplication,
coordinate-record quadrance, normalized rational spread, symbolic ray-address
doubling, and interval Horner evaluation of the squarefree
localization polynomial, and the exact interval Krawczyk contraction for
`P_{2,1}` at the dyadic box centered on -2. It also checks the C1 final-ledger
readiness and final-evidence policy from explicit data, including an unsafe
negative control, and checks typed accepted and rejected residual exit kinds.
It also checks typed theorem assumption-payload families, conclusions, and
strength classes, including out-of-range, generic-MLC, and bounded-search
rejection paths.
The import ledger separately checks typed conclusion, strength, and status
vocabularies while retaining its scaffolded, non-final records.
The final proof-object skeleton checks its acceptance policy from explicit data,
including unsafe-policy and missing-link negative controls; this does not make
the current partial ledger ready for C1.
Repository alignment policy is checked from explicit data with an unsafe
theorem-import negative control.
Optimization policy is likewise checked from explicit data, including a
negative control that attempts to mark a debug path proof-grade.
The checked Int64 transition layer rejects boundary overflows, invalid
denominators, and the known Q_8 coefficient-growth case. It is not a bigint
backend and is not wired into `Q`, so proof-grade acceptance remains disabled.
The checked rational transition layer normalizes accepted values and explicitly
rejects unsafe construction, arithmetic, division, and comparison. Existing
`Q` and interval consumers remain on the demo path pending rejection-aware
migration.
The checked interval transition layer enforces ordered endpoints and propagates
rational rejection through interval arithmetic, reciprocal, sign, and subset
queries used by the checked certificate transition path.
The checked complex interval layer propagates component rejection through
rank-2 arithmetic, orbit recurrence, and Horner evaluation of `P_{2,1}` and its
derivative.
The checked `P_{2,1}` Krawczyk path now distinguishes verified contraction,
valid non-contraction, and arithmetic rejection. This bounded checked path does
not satisfy the repository's unbounded proof-grade backend requirement.
The checked exact-type path evaluates all five forbidden collisions for the
same c=-2 box. Arithmetic rejection and ambiguous zero containment both reject
the exclusion result.
The arithmetic migration gate accepts the checked-width `P_{2,1}` localization
only when the contraction, computed exact-type exclusions, same-box identity, and
checked backend all agree. It separately rejects proof-grade acceptance because
the backend is bounded.
The checked ray-address path computes the finite `1/2 -> 0 -> 0` doubling orbit
and rejects malformed or overflowing fixed-width inputs. The checked finite
certificate gate composes that result with localization but rejects full
acceptance. Source-specific theorem-tag instances match the checked finite data
to the Schleicher landing and Misiurewicz-fiber source families. The landing
adapter derives checked-width target uniqueness from `P_{2,1}=C(C+2)`, rejection
of the lower-type `C=0` root, and the typed preperiod correspondence. Both
imports remain rejected finally because the classification backend is bounded.
The completed `BigZ` integer backend uses dynamic base-`10^9` limbs and executes exact
signed construction, ring operations, order, quotient/remainder, rejected
non-divisions, and Euclidean gcd beyond `Int64` magnitude. Phase three adds a
canonical sign/8-byte-length/minimal-big-endian-magnitude encoding. Its complete
integer capability record permits rational migration, but no certificate path
uses it yet; bounded `Q` and downstream consumers still reject proof acceptance.
Passing it does not imply that
every `.mojo` file compiles, that the Int64 coefficient backend is proof-grade,
or that any open C1 theorem obligation has been discharged.

Remaining modules retain legacy syntax until they enter an explicitly listed,
dependency-closed compile target. The compile frontier must expand by adding
real imports and executable assertions, not by treating source-text inspection
as type checking.
