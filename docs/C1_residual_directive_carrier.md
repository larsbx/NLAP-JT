# C1 residual-class carrier as a directive prefix

Status: definition-level representation on the C1 frontier route; no theorem status changes.

This note gives the residual class of the C1 program a typed finite carrier. The residual class is the set of parameters left after the class-specific theorem tags of `docs/C1_theorem_tag_import_ledger.md` (Yoccoz-type local connectivity for non-renormalizable and finitely renormalizable parameters, Misiurewicz, parabolic, and hyperbolic-boundary classes): the infinitely renormalizable parameters. Item N1 of the round-two cross-pollination audit observed that this class is described combinatorially by iterated tuning, that tuning acts on kneading sequences as a constant-length substitution, and that `larsbx/finite-math-kernels` ships that kernel in its `substitution_dynamics` package (`docs/tuning-substitutions-spec.md` there, sections 1 and 2). NLAP-JT vendors that package at the commit pinned in `vendored.toml` and binds it here.

The representation is a definition. It moves no theorem: the identification of the finite pattern with Douady–Hubbard tuning is imported through the `KneadingFormOfTuning` theorem tag, and every statement about fibres, a priori bounds, or spectrum stays outside this file.

## Terminology declaration: residual-class directive carrier

Terminology declaration: A residual-class directive carrier is a non-empty finite list `[A_1, ..., A_n]` of tuning patterns with the parity twist of Derrida, Gervois, and Pomeau (DGP), each pattern computed from a periodic rational ray address by the exact doubling kernel of `src/bigq_ray_address.mojo`. Its level is `n`, one per renormalization level.

Genealogy: Douady–Hubbard tuning of quadratic polynomials; the kneading form of tuning as the star product of unimodal kneading theory (Derrida, Gervois, Pomeau); the S-adic vocabulary of substitution dynamics (a directive sequence of substitutions and its finite prefixes), as fixed in the kernel specification of `larsbx/finite-math-kernels`.

Bridge claim: Definition-only project term. The carrier is the finite object the C1 route calls "carrier" when the residual class is the one under study; its refinement is one more pattern, and its content is the directive prefix itself.

Known leaks: A directive prefix describes the dynamical plane of a residual parameter through its kneading sequence; it says nothing about parameter-plane shrinking of the nested tuned copies, which needs a priori bounds no substitution computation supplies. The DGP twist is the real-slice convention: the kneading kernel computes an itinerary for every periodic address, but the tuning identification is imported only for real quadratic parameters. Equality of two directive prefixes at every finite level is a definition of "same combinatorics", not a theorem about fibres.

Use discipline: Use only in C1 files and only with an explicit level. A rejected carrier (preperiodic address, period one, period beyond the declared cap, or a kernel rejection) is inconclusive and may not be cited as evidence of anything.

## Kneading letters from a periodic ray address

For a normalized address `theta` in `[0, 1)` of doubling period `p >= 2`, the two open arcs cut by `theta/2` and `(theta+1)/2` partition the address circle minus those two cut points. Write `nu_k = 1` when `2^k theta` lies in the open arc `(theta/2, (theta+1)/2)` and `nu_k = 0` when it lies in the complementary open arc. The kneading letters of `theta` are `nu_0 ... nu_{p-2}`; the kernel checks that no `2^k theta` with `k < p-1` is a cut point and that `2^{p-1} theta` is one. The DGP pattern of `theta` is `TuningPattern.dgp([nu_0, ..., nu_{p-2}])`, of period `p`.

`kneading_letters(address, cap)` searches the period only up to `cap`; a period not found within the cap rejects. Every comparison is exact `Q` arithmetic on `BigZ`; no fixed-width path is involved.

Values pinned by `residual_directive_carrier_smoke` and by the independent Python oracle in `tests/test_C1_residual_directive_carrier.py`:

| Address | Period | Letters | DGP twist | Reading |
| --- | --- | --- | --- | --- |
| `1/3` | 2 | `1` | 1 | period-doubling centre; substitution `0 -> 11`, `1 -> 10` |
| `2/5` | 4 | `101` | 0 | second period-doubling; equals the star square of `1/3` |
| `3/7` | 3 | `10` | 1 | real period-3 centre |
| `7/15` | 4 | `100` | 1 | real period-4 centre nearest `1/2` |
| `1/2` | none | rejected | | preperiodic |
| `0/1` | 1 | rejected | | period one is not a tuning |

The kernel also computes letters for addresses of non-real centres (`1/7` gives `11`); such a pattern lies outside the covered class of the theorem tag and is never bound to it.

## Objects

```text
KneadingLetters            := { period, letters, rejected }
AddressTuningPattern       := { pattern: TuningPattern, rejected }
ResidualDirectiveCarrier   := { patterns: List[TuningPattern], rejected }
  level()                  number of patterns
  kneading_prefix()        prefix of A_1 * ... * A_n, of length p_1 ... p_n - 1
  composite()              tau_{A_1} o ... o tau_{A_n}
  star_pattern()           A_1 * ... * A_n
directive_carrier_extend   one more level from one more address
same_directive_prefix      levels equal and patterns equal pairwise
strict_directive_refinement  after extends before and the kneading prefix grows
KneadingTuningInstance     := { source, address, pattern, real_slice_convention_declared,
                                excludes_generic_boundary_use, classification_proof_attached }
```

Identities exercised by the smoke target: the star product of the `1/3` pattern with itself equals the `2/5` pattern; the level-two carrier `[1/3, 1/3]` has composite images `1010` and `1011` and kneading prefix `101`; the level-three carrier has kneading prefix `1011101`; extending a carrier is a strict refinement and reversing or repeating it is not.

## Relation to the carrier grammar

| Carrier grammar (`docs/C1_unresolved_wake_to_carrier_obstruction.md`, `docs/C1_carrier_refinement_progress.md`) | Directive-prefix reading on the residual class |
| --- | --- |
| carrier content | the directive prefix `[A_1, ..., A_n]` |
| `CarrierTooCoarse` | level `n` does not separate the two representatives |
| `StrictCarrierRefinement` | `directive_carrier_extend`: one more renormalization level, witnessed by `strict_directive_refinement` |
| renaming-only change | `same_directive_prefix` |
| persistent non-separation on the residual class | one directive prefix shared at every level (definition; the classical reading is the `[L]` item N1 of the round-two audit and is not imported here) |

## Theorem-tag binding

The ledger records the tag family `KneadingFormOfTuning` with conclusion kind `TuningKneadingSubstitution` and strength class `CLASSICAL_IMPORTED_CLASS_SPECIFIC`. `kneading_tuning_instance(address, cap)` builds the source-specific payload: the `DouadyHubbardTuning` bibliography record, the address, its DGP pattern, the declared real-slice convention, and the exclusion of generic boundary use. `source_scope_checked` holds for the `1/3` instance and fails for a rejected address; `final_import_admissible` stays false because no classification proof is attached, so the tag remains `scaffolded` in `src/C1_theorem_tag_import_ledger.mojo`.

## Non-claims

- No directive prefix proves same fibre, C1, or `ResidualClosureNoMissingLinks` (`directive_prefix_proves_same_fiber`, `directive_prefix_proves_c1` return false).
- No directive prefix supplies a priori bounds (`directive_prefix_supplies_apriori_bounds` returns false).
- The column-coincidence kernel of the same package is not bound here: Dekking's theorem needs the height of the substitution, which the package does not yet compute (its specification, section 3.3).
- Nothing here concerns infinite directive sequences or S-adic limits.

## Next local target

Bind the composite of a carrier to the constant-length coincidence kernel as a finite fact about columns of its powers once the height kernel exists upstream, and add the harmonic-measure density field of round-two item R3 beside the level. Neither changes the status of any block in `docs/C1_final_proof_block_ledger.md`.
