# Exact arithmetic public boundary (pointer)

Status: pointer. The public boundary of the exact arithmetic was declared here while `BigZ`, `Q`, `IQ`, and `ComplexIQ` lived in `src/`; it moved with the code when the arithmetic was extracted, and is now maintained in two places:

| Layer | Boundary document | Vendored here as |
| --- | --- | --- |
| `BigZ`, `Q` (integers, rationals, canonical bytes) | `larsbx/finite_exact:docs/exact-arithmetic-public-boundary.md` | `src/finite_exact/` |
| `IQ`, `ComplexIQ` (closed intervals, rank-2 boxes) | `larsbx/interval_q:docs/exact-arithmetic-public-boundary.md` | `src/interval_q/` |

Both copies are pinned by upstream commit and SHA-256 digest in `vendored.toml` and checked by `tools/check_vendored_sync.py` in CI, so the boundary that applies to this repository is the one at the pinned commits. What the boundary promises is unchanged: exactness, canonical form, explicit and sticky rejection, a three-valued interval sign, truncating division, injective encodings, and no relation between arithmetic acceptance and certificate acceptance. Arithmetic readiness is a property of the packages; acceptance is decided by the consumers named in `docs/bigint-migration-handoff.md`, and nothing in either package changes `backend.toml` or `ProofGradeCertificateStatus`.

Verification that used to run here (the randomized property probe against the Python `int`/`Fraction` oracle) runs in the CI of the two upstream repositories; this repository re-runs the law smokes under its own toolchain in `src/smoke_tests.mojo`. The binding rows and the hook are in `docs/rational-interval-arithmetic-spec.md`.
