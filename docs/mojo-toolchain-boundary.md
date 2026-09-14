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
- `src/cert_backend.mojo`.
- `src/certificate_arithmetic_migration_gate.mojo`.

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
queries. It is not yet connected to certificate consumers.
The checked complex interval layer propagates component rejection through
rank-2 arithmetic and Horner evaluation of `P_{2,1}` and its derivative. The
checked Krawczyk acceptance path remains pending.
The checked `P_{2,1}` Krawczyk path now distinguishes verified contraction,
valid non-contraction, and arithmetic rejection. This bounded checked path does
not satisfy the repository's unbounded proof-grade backend requirement.
The arithmetic migration gate accepts the checked-width `P_{2,1}` localization
only when the contraction, exact-type exclusion counts, same-box identity, and
checked backend all agree. It separately rejects proof-grade acceptance because
the backend is bounded.
Passing it does not imply that
every `.mojo` file compiles, that the Int64 coefficient backend is proof-grade,
or that any open C1 theorem obligation has been discharged.

Remaining modules retain legacy syntax until they enter an explicitly listed,
dependency-closed compile target. The compile frontier must expand by adding
real imports and executable assertions, not by treating source-text inspection
as type checking.
