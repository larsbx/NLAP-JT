# Mojo toolchain boundary

Status: compiling initial slice; repository-wide port incomplete.

The repository pins Mojo 1.0.0 and pytest 8.3.5 through `pixi.toml` and
`pixi.lock`. CI performs both a JIT smoke run and an ahead-of-time build.

The compiler-checked dependency closure currently consists of:

- `src/smoke_tests.mojo`;
- `src/poly_z.mojo`;
- `src/cert_types.mojo`;
- `src/rat_q.mojo`;
- `src/interval_q.mojo`;
- `src/poly_interval_eval.mojo`;
- `src/krawczyk_witness.mojo`.
- `src/C1_final_proof_block_ledger.mojo`.
- `src/C1_residual_closure_no_missing_links.mojo`.

This slice checks the preserved polynomial identities, certificate-header
constraints, the same-box joint-witness gate, imported-theorem-tag acceptance,
normalized rational arithmetic, rational ordering, interval multiplication,
coordinate-record quadrance, and interval Horner evaluation of the squarefree
localization polynomial, and the exact interval Krawczyk contraction for
`P_{2,1}` at the dyadic box centered on -2. It also checks the C1 final-ledger
readiness and final-evidence policy from explicit data, including an unsafe
negative control, and checks typed accepted and rejected residual exit kinds.
Passing it does not imply that
every `.mojo` file compiles, that the Int64 coefficient backend is proof-grade,
or that any open C1 theorem obligation has been discharged.

Remaining modules retain legacy syntax until they enter an explicitly listed,
dependency-closed compile target. The compile frontier must expand by adding
real imports and executable assertions, not by treating source-text inspection
as type checking.
