# Shared finite-math kernel migration

Status: implemented consumer migration; no theorem-status change.

NLAP-JT vendors `finite_exact/`, `substitution_dynamics/`, and the
`audit/claim_governance` package from `larsbx/finite-math-kernels` at the one
full commit recorded in `vendored.toml` (currently the merge commit of the
tuning-substitutions pull request, which added `substitution_dynamics/tuning.mojo`
and `sadic.mojo`). `tools/check_vendored_sync.py` verifies every vendored Mojo
and Python file by SHA-256 in CI. Arithmetic consumers import the
package-qualified modules under `src/finite_exact/`; the former root-level
implementations were removed. The residual directive carrier
(`src/C1_residual_directive_carrier.mojo`) imports `substitution_dynamics.tuning`,
`substitution_dynamics.sadic`, and `substitution_dynamics.substitution`; the
other modules of that package are pinned but not yet in the compile closure.

This changes ownership, not mathematical semantics:

- `BigZ` and `Q` remain exact, unbounded, and fail closed;
- interval predicates remain conservative and distinct from exact acceptance;
- certificate acceptance remains a consumer responsibility;
- tuning patterns and directive prefixes are finite combinatorics; the
  identification with Douady–Hubbard tuning is a theorem-tag import
  (`KneadingFormOfTuning` in `docs/C1_theorem_tag_import_ledger.md`);
- C1 and every source-pending theorem dependency remain unresolved unless a
  separate proof record says otherwise.

The old standalone library repositories may be archived only after the PSC
consumer migration is merged and repository-wide reference checks show no
live pin to them.

