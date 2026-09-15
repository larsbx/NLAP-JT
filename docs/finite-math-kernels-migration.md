# Shared finite-math kernel migration

Status: implemented consumer migration; no theorem-status change.

NLAP-JT vendors `finite_exact/` from `larsbx/finite-math-kernels` at the full
commit recorded in `vendored.toml`. `tools/check_vendored_sync.py` verifies
every vendored Mojo file by SHA-256 in CI. Arithmetic consumers import the
package-qualified modules under `src/finite_exact/`; the former root-level
implementations were removed.

This changes ownership, not mathematical semantics:

- `BigZ` and `Q` remain exact, unbounded, and fail closed;
- interval predicates remain conservative and distinct from exact acceptance;
- certificate acceptance remains a consumer responsibility;
- C1 and every source-pending theorem dependency remain unresolved unless a
  separate proof record says otherwise.

The old standalone library repositories may be archived only after the PSC
consumer migration is merged and repository-wide reference checks show no
live pin to them.

