# Rational and interval arithmetic: NLAP-JT binding

**Status:** repository invariant in `larsbx/NLAP-JT`; authoritative only for NLAP-JT. The specification itself (sections 0 to 5: the problem, layer ℚ, layer I, combining the layers, the decision table, and the conformance criteria C1 to C7) was written here and moved, unchanged, to `larsbx/finite_exact:docs/rational-interval-arithmetic-spec.md` when the arithmetic was extracted. This file keeps what section 6 of that specification asks each consumer to keep: its own binding rows and the hook that enforces them. Section numbers below match the specification so that cross-references from the C1 documents stay valid.

## 0. Where the specification lives

| Content | Location |
| --- | --- |
| Sections 0 to 5, 8, references | `larsbx/finite_exact:docs/rational-interval-arithmetic-spec.md` |
| Public boundary of `BigZ`, `Q` | `larsbx/finite_exact:docs/exact-arithmetic-public-boundary.md` |
| Public boundary of `IQ`, `ComplexIQ` | `larsbx/interval_q:docs/exact-arithmetic-public-boundary.md` |
| Canonical `Z`/`Q` byte encoding | `larsbx/finite_exact:docs/canonical-encoding.md` (this repository's composite schemas stay in `docs/canonical-serialization.md`) |
| The vendored code | `src/finite_exact/`, `src/interval_q/`, pinned in `vendored.toml` |
| PSC's binding rows | `larsbx/pisot-substitution-conjecture-research:docs/exact-arithmetic-binding.md` |

Terminology in this file is field-recognizable; no novel bridge term is introduced.

## 6. Repository binding

The binding table lists every module that instantiates a layer, its conformance class, and the criteria it currently fails. Classes:

| Class | Meaning |
| --- | --- |
| CONFORMS | meets C1 to C7 with an unbounded backend |
| CONFORMS-CHECKED | meets C1 to C7 with a checked fail-closed fixed-width backend (1.5) |
| DEMO | unchecked fixed-width backend; algebra conformant; barred from certificate acceptance |
| QUARANTINED | uses floating point; allowlisted; barred from every certificate path; scheduled for replacement |

### 6.2 `larsbx/NLAP-JT`

| Spec item | Module | Class | Notes |
| --- | --- | --- | --- |
| 1.1–1.3 ℚ | `src/finite_exact/rat_q.mojo` (`Q`) | CONFORMS | vendored from `larsbx/finite_exact` at the commit pinned in `vendored.toml`; normalized `BigZ` numerator/positive denominator storage; addition, subtraction, and order scale by denominator cofactors of `gcd(den, den')`, multiplication cross-cancels (`q_cross_terms`); zero denominators and division by zero propagate rejection; certificate acceptance remains disabled pending consumer replay |
| 1.1 integer backend | `src/finite_exact/bigint_z.mojo` (`BigZ`) | CONFORMS | vendored from `larsbx/finite_exact`; dynamic base-`10^9` limbs; exact signed ring/order operations, quotient/remainder by schoolbook long division (Knuth Algorithm D) with the shift-and-subtract routine retained as an in-process reference, rejected non-divisions, Euclidean gcd, and canonical integer serialization; rational and core interval consumers are migrated, while certificate replay remains pending |
| 1.1–1.5 ℚ, checked transition | `src/checked_q.mojo` (`CheckedQResult`) | CONFORMS-CHECKED | normalized accepted results; zero denominator, division by zero, unrepresentable magnitude, arithmetic overflow, and unsafe comparison all return explicit rejected no-results; feeds the checked interval certificate transition path |
| 2.1–2.5 I_Q, checked transition | `src/checked_interval_q.mojo` (`CheckedIQResult`) | CONFORMS-CHECKED | enforces J1; propagates rejected endpoints and comparisons; reciprocal rejects intervals containing zero; sign is three-valued with a separate rejected state; feeds checked Krawczyk and exact-type exclusion predicates |
| 2.1–2.5 complex I_Q and Horner, checked transition | `src/checked_complex_interval.mojo` (`CheckedComplexIQResult`) | CONFORMS-CHECKED | rank-2 interval coordinate arithmetic and ascending-coefficient Horner evaluation propagate every rejected component; used by checked `P_{2,1}` Krawczyk and orbit-exclusion calculations |
| 2.4 checked strict inclusion witness | `src/checked_krawczyk_witness.mojo` (`CheckedKrawczykResult`) | CONFORMS-CHECKED | computes the `P_{2,1}` Krawczyk image at the dyadic box centered on -2; distinguishes arithmetic rejection from a valid non-contraction; does not enable proof-grade certificate acceptance |
| 2.4 checked exact-type exclusions | `src/checked_interval_exclusion.mojo` (`CheckedExactTypeExclusionResult`) | CONFORMS-CHECKED | computes all 5 forbidden collisions for `(ell, period, horizon) = (2, 1, 3)` on the same checked c=-2 box; ambiguity and arithmetic rejection fail closed; bounded result does not enable proof-grade acceptance |
| finite rational ray-address dynamics, checked transition | `src/checked_ray_address.mojo` (`CheckedRayAddrResult`) | CONFORMS-CHECKED | canonical modular doubling for the c=-2 address; malformed inputs and fixed-width multiplication overflow reject; not a measured angle |
| finite rational ray-address dynamics | `src/bigq_ray_address.mojo` (`BigQRayAddr`) | CONFORMS | normalized BigZ-backed `Q` values modulo one; malformed and out-of-range inputs reject; finite symbolic addresses only, not measured angles |
| finite theorem-instance data | `src/bigq_theorem_tag_payload_instances.mojo` | CONFORMS | normalized BigZ-backed `Q` address data and finite source-scope matching; classification-proof attachment and final import remain explicitly false |
| 2.1–2.5 I_Q, complex boxes | `src/interval_q/closed_q.mojo` (`IQ`, `ComplexIQ`) | CONFORMS | vendored from `larsbx/interval_q` at the commit pinned in `vendored.toml`; BigZ endpoints; `singleton` constructors for degenerate boxes; J1 and endpoint rejection enforced; reciprocal rejects zero-containing intervals; sign and containment/inclusion predicates preserve an explicit rejected state |
| 1–2 property probe and oracle | (upstream) | CONFORMS | the randomized probe of `BigZ`, `Q`, and `IQ` against the Python `int`/`Fraction` oracle runs in the CI of `larsbx/finite_exact` and `larsbx/interval_q` at the pinned commits; this repository re-runs the law smokes under its own toolchain in `src/smoke_tests.mojo` |
| 2.3 natural extension, Horner | `src/poly_interval_eval.mojo` | DEMO | ascending-coefficient Horner over `ComplexIQ` |
| 2.4 strict inclusion witness | `src/krawczyk_witness.mojo` | DEMO | Krawczyk contraction on `P_{2,1}`; `P_{4,1}` pending |
| 1–2 direct arithmetic consumers | `src/complex_inverse.mojo`, `src/coord_record_eval.mojo`, `src/interval_orbit.mojo`, `src/rank2_operator.mojo`, `src/rational_trig.mojo`, `src/smoke_tests.mojo` | DEMO | direct `Q` or `IQ` consumers now inherit BigZ arithmetic, but remain barred from certificate acceptance until each acceptance-bearing consumer is replayed and promoted explicitly |
| 2.4 exclusion oracle (secondary) | `tools/interval_exclusion_reference.py` | CONFORMS | Python `Fraction` endpoints; reference for `src/interval_orbit.mojo` |
| — | `src/complex_box.mojo` (`C64`, `ComplexBox`), `src/finite_mandelbrot.mojo`, `src/run_examples.mojo` | QUARANTINED | `Float64` demo substrate; replacement target is dyadic-rational endpoints per `docs/interval-orbit-native-target.md` |

Promotion of any DEMO row to CONFORMS requires the unbounded backend gate in `backend.toml` and `docs/bigint-migration-handoff.md`; promotion to CONFORMS-CHECKED requires overflow-checked operations in the constructor and every arithmetic method, with every unsafe case returning an explicit rejected result (`src/checked_q.mojo` above is the reference implementation). A second rational or interval type beside the vendored packages is a binding violation.

## 7. Hook: how the specification is enforced

The specification is a hook, not a note. This repository wires it into its control surfaces as follows; the regression tests fail if any wire is removed.

1. **Vendoring pin.** `vendored.toml` pins `src/finite_exact/` and `src/interval_q/` by upstream commit and SHA-256 digest; `tools/check_vendored_sync.py` (shipped by `larsbx/finite_exact`) verifies them in CI (`pixi run vendored`). A change to the arithmetic is made upstream, then re-vendored; a local patch fails the build.
2. **Audit script** (`tools/audit_exact_arithmetic.py`). Lexically scans `src/` (vendored packages included) for floating-point type tokens and decimal literal forms outside comments and strings, fails on any hit not in the allowlist, discovers direct arithmetic consumers (`from finite_exact.rat_q import`, `from interval_q.closed_q import`) and requires a binding row for each, and verifies that every module named in section 6 exists and cites this file by path (C7), including quarantined modules. Run in CI.
3. **Allowlist** (`tools/exact_arithmetic_allowlist.md`). The only place QUARANTINED files may be named. Adding a file here requires a matching QUARANTINED row in section 6.
4. **Law tests.** `src/smoke_tests.mojo` executes 1.3 (`test_rational_field_laws`) and 2.2 to 2.5 (`test_interval_enclosure_laws`) against the vendored kernels under this repository's toolchain, together with the upstream smoke entry points; `tests/test_exact_arithmetic_spec.py` executes the same laws against the secondary Python oracle. The randomized property probe runs upstream at the pinned commits.
5. **Policy pointers.** `README.md` and `docs/mojo_first_execution_policy.md` name this file as the arithmetic policy; `backend.toml` carries `exact_arithmetic_spec` and `no_float_certificate_arithmetic = true`.

## 8. Non-goals

- This specification does not select an arbitrary-precision integer library; that remains the backend handoff in each repository.
- It does not introduce affine or Taylor-model arithmetic.
- It does not claim that exact arithmetic proves any theorem. Exactness removes one class of error from a computation; the epistemic status of the computation is governed by each repository's verification-architecture and claim-status documents.

## References

- IEEE Std 754-2019, *IEEE Standard for Floating-Point Arithmetic*.
- R. E. Moore, R. B. Kearfott, M. J. Cloud, *Introduction to Interval Analysis*, SIAM 2009 (inclusion theorem, dependency problem, natural extension).
- W. Tucker, *Validated Numerics*, Princeton 2011.
- J. R. Shewchuk, *Adaptive Precision Floating-Point Arithmetic and Fast Robust Geometric Predicates*, Discrete Comput. Geom. 18 (1997) (filter-then-exact).
- CGAL Editorial Board, *CGAL User and Reference Manual*, "Exact Geometric Computation" and filtered kernels.
- T. C. Hales et al., *A formal proof of the Kepler conjecture*, Forum Math. Pi 5 (2017).
- W. Tucker, *A rigorous ODE solver and Smale's 14th problem*, Found. Comput. Math. 2 (2002).
- L. H. de Figueiredo, J. Stolfi, *Affine arithmetic: concepts and applications*, Numer. Algorithms 37 (2004).
