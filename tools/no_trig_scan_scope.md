# No-Trig Scan Scope

The audit guard is intentionally simple and lexical.

Current intended enforcement path:

- core Mojo source under `src/`
- implementation docs that are not explicitly allowlisted as policy/comparison material

Known cleanup task:

- remove explanatory forbidden tokens from `src/rational_trig.mojo` comments or add a code/comment-aware scanner before making this a hard blocking check.

The invariant itself is stronger than the current scanner: no core computation may depend on analytic circular functions, angle measurement, radians/degrees, or unit-circle machinery.
