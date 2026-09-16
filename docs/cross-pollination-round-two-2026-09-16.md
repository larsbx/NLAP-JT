# Cross-pollination, round two: PSC, NLAP-JT, finite-math-kernels, and four adjacent repositories

**Status:** comparative audit dated 2026-09-16, continuing `docs/cross-program-bridge-psc-nlapjt-2026-09-12.md`. It records what round one produced, what the overlap route now makes visible between the two research programs, and which of the user's other repositories share structure with them. It proves nothing, promotes no claim, and changes no ledger. Status labels follow section 0.2 of the round-one document. Project terms are governed by `docs/terminology-registry.md` in NLAP-JT and by `claim_governance.toml` in PSC.

Repositories read in this session, all at their `main` heads on 2026-09-16:

| Tag | Repository | Role |
| --- | --- | --- |
| `PSC:` | `larsbx/pisot-substitution-conjecture-research` @ `6b0b577` | research program, overlap route |
| `NLAP:` | `larsbx/NLAP-JT` @ `d00c64d` | research program, finite separation certificates |
| `FMK:` | `larsbx/finite-math-kernels` @ `807ae7e` | monorepo consolidating `finite_exact`, `finite_linear_algebra`, `substitution_dynamics`, `proof_records`, `audit/claim_governance`; the six source repositories are retired with provenance |
| `SG:` | `larsbx/sprucegoose` | Elixir/Ash orchestration control plane with a content-addressed constitutional kernel |
| `CC:` | `larsbx/crypto-composer` | Zig composition-graph checker with proof-driven tests |
| `TS:` | `larsbx/tui-story` | Elixir semantic-relationship graph with TLA+ specifications |
| `ORM:` | `larsbx/objective-review-metasytem` | manifestos with machine-readable rulings, Vale and GitHub integrations |

`larsbx/coop_substrate` is private and was not read. Markers: `[V]` verified here by reading or executing; `[L]` literature statement that must be pinned before any ledger uses it.

## 0. Round-one ledger `[V]`

| Round-one item | State on 2026-09-16 | Residual |
| --- | --- | --- |
| B1 overlap transport of `G1b-2` | adopted and surpassed: seed-patch overlap graph finite by bounded discrepancy (Theorem 2.1 / manuscript 4.22); coincidence density and dense-good-set equivalence (Lemma 5.36); Barge–Štimac–Williams imported; the route's single open premise is `OverlapProductivity` | the open gate itself; G1b-2 demoted to a parallel program |
| B2 one Galois lemma for both | NLAP corrected §3 (PR #8); PSC resolved the source question by irreducibility of the exterior-square characteristic polynomial (`docs/galois-aux-b-source-resolution-2026-09-13.md`), so the Galois step is no longer a separate theorem | the Lean layer is unchanged (six files, no Galois or exterior-square lemma), so the irreducibility statement is proved in prose only |
| B3 TLA+ ledger port to NLAP | not done; NLAP built Mojo ledgers (`C1_final_proof_block_ledger`, theorem-tag import ledger, payload instances) and FMK shipped `proof_records` instead | see R2: generate every ledger from proof records |
| B4 NLAP Mojo toolchain and CI | done: Mojo 1.0.0 pinned, compiled closure of 36 modules, smoke, property probe, all audits, full pytest; CI green | modules outside the closure remain (`mojo_theorem_kernel.mojo`, `canonical_serialization.mojo`) |
| B5 per-instance certificates and import metadata | partial: `claim_governance.toml` gives PSC a status vocabulary with an `imported` class enforced across five surfaces; `tla/ProofArchitecture.tla` still has no `Imported` set; issue #2 (deterministic census export) still open | R2 |
| B6 exact-type catalogue and counting identity | not done: the rationale was corrected, the catalogue object and the angle-count regression were not built | R7 |
| B7 shared real times 2-adic box kernel | partial: `PSC: mojo/psc/finite_cokernel_address.mojo` computes `Z^3 / M^k Z^3` classes; no p-adic module in FMK | R7 |
| B8 Hubbard-tree core-entropy census | not done | R7 |
| B9 PSC firewall linter and terminology registry | partial: `claim_governance` runs in CI with risky-phrase and no-float rules; PSC deliberately keeps no terminology registry (`claim_governance.toml` comment) | R6 |
| B10 NLAP gate green | done | none |

Two round-one predictions were confirmed by later independent audits: `NLAP: docs/project-audit-2026-09-14.md` F2 and F9 reproduce C3 and C1 of the bridge document; `PSC: docs/audit-2026-09-15.md` F8 asks that cross-repository paths be qualified, which this document does.

## 1. What the overlap route now makes visible between the two programs

### N1. NLAP's residual class is substitution dynamics `[L]`, and FMK already ships the kernel `[V]`

The NLAP theorem-tag ledger now names its residual class exactly: after `YoccozPuzzleLocalConnectivityUnderHypotheses` (non-renormalizable and finitely renormalizable parameters) and the Misiurewicz, parabolic, and hyperbolic-boundary tags, persistent non-separation between distinct parameters can only occur inside the infinitely renormalizable class (`NLAP: docs/C1_theorem_tag_import_ledger.md`, "Renormalization with a priori bounds", strength class `CLASSICAL_IMPORTED_CLASS_SPECIFIC`).

That class has a finite-combinatorial description that is literally the object of `FMK: substitution_dynamics`:

- Douady–Hubbard tuning by a centre of period `p` acts on kneading sequences as a constant-length-`p` substitution on the two-letter itinerary alphabet; an infinitely renormalizable parameter is described by an infinite directive sequence of such substitutions, and its kneading sequence is the corresponding S-adic limit `[L]`.
- The restriction of `f_c` to the postcritical set of an infinitely renormalizable quadratic polynomial of bounded type is an odometer, and the itinerary subshift is an almost one-to-one extension of it `[L]`. That is the two-letter, constant-length instance of the PSC objects: the odometer is the maximal equicontinuous factor, and "almost one-to-one" is coincidence rank one. For constant-length substitutions the coincidence criterion is Dekking's theorem `[L]`.

Consequences.

1. Two infinitely renormalizable parameters lie in one Schleicher fibre only if they share the entire directive sequence (every finite prefix is decided by rational-ray separators at the corresponding renormalization level) `[L]`. So NLAP's `PersistentNonSeparation(A,B)` on the residual class is the statement "same S-adic directive sequence", and the "carrier" NLAP has been trying to define abstractly is a directive sequence with a finite prefix at each stage. Carrier refinement is one more renormalization level, which is one more substitution in the directive sequence.
2. The frontier comparison becomes precise rather than analogical: PSC's open gate asks whether a Pisot inflation hierarchy forces coincidence (fibre collapse in the tiling space); the open part of MLC asks whether a renormalization hierarchy of unbounded combinatorics forces the nested tuned copies to shrink (fibre collapse in parameter space). Both are "does hierarchical self-similarity force collapse", and in both the bounded-type case is a theorem and the unbounded case is the frontier. Leak: the substitution picture describes the *dynamical* plane of a residual parameter; the *parameter-plane* shrinking needs a priori bounds, which no substitution computation supplies. The dictionary organizes the frontier; it does not move it.
3. Executable deliverable: a `tuning(p, kneading_word)` constructor in `FMK: substitution_dynamics/substitution.mojo` (the API already takes an arbitrary alphabet size `[V]`), a Dekking coincidence check for constant-length substitutions (a special case of the existing balanced-pair machinery), and, in NLAP, a residual-class carrier represented as a directive-sequence prefix rather than an untyped incidence record. NLAP's exact rational-angle machinery (`checked_ray_address`, `bigq_ray_address`) already computes the kneading data the constructor needs.

Status: the tuning-as-substitution and odometer facts are THEOREM-grade in the literature and must be pinned (Douady–Hubbard; Milnor's orbit portraits; Dekking 1978; Lyubich's renormalization papers for the odometer statement). The reformulation of the residual carrier is DEFINITION-level. The frontier comparison is ANALOGY with the leak stated.

### N2. Coincidence density has a parameter-space twin, and there it is a theorem `[L]`

The overlap route now carries a quantitative fibre-collapse measure: the common fraction `f_m(T)` and its limit `delta(T)`, with `delta(s) = 1` for one legal seed sufficient for pure discrete spectrum through the imported Barge–Štimac–Williams theorem. The measure-theoretic conclusion suffices because pure discrete spectrum is itself a measure-theoretic statement.

NLAP's natural measure is harmonic measure on the boundary of `M`, that is, Lebesgue measure on external angles. The literature reports that for harmonic-measure-almost every boundary parameter the Mandelbrot set is locally connected at that parameter and the fibre is trivial (Graczyk–Świątek, *Harmonic measure and expansion on the boundary of the Mandelbrot set*; Smirnov, *Symbolic dynamics and Collet–Eckmann conditions*) `[L]`. If that pin holds, NLAP has a measure-one island exactly where PSC has its density theorem, and MLC differs from it by a harmonic-measure-zero set that contains the infinitely renormalizable parameters of N1. The correct NLAP statement is then

```text
PersistentNonSeparation(A,B) and A != B  =>  A, B in a harmonic-measure-null class
```

as an imported theorem tag with an explicit measure-zero scope, not a triviality claim.

Deliverable: one theorem-tag record `HarmonicMeasureAlmostEveryFibreTrivial` with source, hypotheses, and the leak "measure zero is not empty", and a `density` field on NLAP carriers giving the angle measure of the separated set at prefix `k`, the analogue of PSC's `f_m`. Status: THEOREM-grade in the literature pending the pin; the carrier field is DEFINITION.

### N3. PSC's obstruction normal form is NLAP's F1 route, executed `[V]`

`PSC: docs/p1-overlap-minimal-obstruction-2026-09-14.md` and `mojo/psc/overlap_obstruction.mojo` do, on a finite graph, what `NLAP: docs/C1_F1_obstruction_extraction.md` describes abstractly: take the forward-closed nonproductive set, extract a sink SCC, prove it PF-critical and full-rank, split it by a dichotomy, and retain the smallest countermodel with a fail-closed extractor. The dichotomy transfers term by term:

| PSC (overlap graph) | NLAP (separator catalogue) |
| --- | --- |
| aligned obstruction: `(i,j,0)` in `S`, an explicitly non-eventually-coincident letter pair | `BoundaryEqualityCandidate`: the object may lie on the separator |
| strict-zipper obstruction: no zero-shift state, one side advances at each boundary | `CarrierTooCoarse` / interior wake ambiguity: no separator boundary is hit |
| `common_child_start_count` exact boundary-hit test | side-assignment witness extraction |
| `nonproductive_sink_sccs` fails closed on capped graphs | `UW-2`: a bounded failed search is not persistent evidence |

The transfer is concrete because NLAP now has finite graphs to run it on: for the Misiurewicz class, the exact-type catalogue of round-one B6 gives a finite set of parameters per `(l,k)`, their rational-angle separators form a finite catalogue prefix, and the extractor can be run verbatim. On that class every obstruction must be empty by the imported triviality tag, which gives NLAP its first executable negative control of the PSC kind. Status: DEFINITION for the table; executable target.

### N4. Krawczyk for Perron enclosures `[V]`

PSC encloses the Perron root by an integer sign-change bracket and rational bisection (`mojo/psc/perron_interval.mojo`), with a Sturm–Tarski fallback for sign decisions. NLAP's compiled `checked_krawczyk_witness.mojo` and the BigZ interval layer now vendored through FMK give a certified contraction with uniqueness and quadratic convergence. A Krawczyk step on the cubic at the bisection bracket would shrink the enclosure that the overlap-interval audit reports as "interval-certified" and reduce the fallback count in `overlap_interval_audit`. Small, mechanical, and the first place a NLAP kernel would run inside PSC's proof-relevant path.

## 2. Adjacent repositories

### A1. Three content-addressed evidence ledgers `[V]`

| Concept | `SG:` kernel | `FMK: proof_records` | `CC:` |
| --- | --- | --- | --- |
| identity | `ContentID`, SHA-256 of canonical bytes; `Canonical` with sorted string-keyed maps | `record_id` verified against a preimage that excludes it; length-prefixed fields, maps prohibited | `MANIFEST.SHA256` over tracked files |
| statement unit | `Proposition` (predicate, referent, input identity) | `Record.statement` and `scope` | test name plus `Proof{statement, argument, constraints}` |
| evidence | `Evidence` committed by a certified historical event | `evidence` keys per kind: `replay`, `digest`, `source`, `hypotheses_checked`, `domain` | `requireProof`, `tdd_ledger` red/green rows with command and exit code |
| derived claim | `Claim → Justification → Norm/Grant → Resolution → Authorization` | dependency closure over identity-bearing edges | constraint findings C1–C6 |
| outcome vocabulary | `Source/static PASS`, `Boot-free behavioral PASS`, `Dirty build exercise` (non-transferable), `Transferable clean release`, `UNEXECUTED` (neither PASS nor FAIL) | `accepted`, `bounded`, `incomplete`, `open`, `refuted`, `rejected` | `red`, `green` |
| authority separation | constitutive / historical / evidentiary / derived planes; a projection never authorizes | policy is consumer-supplied; bounded evidence never closes a general claim | proof statement required before a test may exist |

Sprucegoose's `UNEXECUTED` is PSC's "a capped run is inconclusive, never a counterexample" and `proof_records`' `incomplete`; its `Dirty build exercise: non-transferable` is `bounded_experiment`; its "derived plane is never accepted as authority input" is the rule PSC's `claim_governance` enforces by checking five hand-maintained status surfaces against one ledger. The three systems were written for orchestration, mathematics, and cryptography and converge on the same shape.

Opportunities, in order of cost:

1. **One canonical encoding.** Three incompatible canonical byte encodings exist for the same idea (sorted-key JSON in SG, length-prefixed no-map records in FMK, ordered-field envelopes in `NLAP: docs/canonical-serialization.md`). FMK's is the most restrictive and already has golden vectors (`fixtures/vectors.json`). Cross-test SG's `Canonical` against those vectors, or adopt FMK's codec for SG evidence receipts. `FMK: audit/POST_CONSOLIDATION_AUDIT_2026-09-15.md` FMK-AUDIT-001 says the FMK identity contract is itself still lagging its specification, so this is the moment to converge rather than after each hardens separately.
2. **One outcome vocabulary.** Map SG's five evidence classes onto `proof_records`' six states and record the map in both repositories; SG's release-provenance receipts then become `verified_finite_computation` records and PSC's CI census runs become SG-style receipts. The research repositories gain the historical plane they lack (their CI history is not a ledger today), and SG gains a validated dependency-closure algorithm it currently implements inside `Workflows.Graph` for a different DAG.
3. **Authority planes as documentation structure.** Rewrite `PSC: docs/verification-architecture.md` and `NLAP: docs/mojo-toolchain-boundary.md` in SG's four-plane vocabulary: constitutive (ledgers, policies, manuscripts), historical (CI runs, census outputs with digests), evidentiary (retained countermodels, replay vectors), derived (README counts, status tables). The claim-governance consistency check then has a stated principle: derived surfaces are regenerated, never edited.

### A2. Proof-driven tests link tests to claims `[V]`

`CC: test/harness.zig` refuses a test without a proof statement, argument, and the constraint identifiers it guards, and `tdd_ledger.zig` records every red/green transition with command and exit code. The research repositories have the same intent (AGENTS.md review gate: "Mojo regression coverage for the theorem/invariant contract") but no mechanism: nothing links a `mojo/tests/test_*.mojo` to the claim in `claim_governance.toml` or the node in `tla/Ledger.tla` it supports. A `claim_id` argument on each Mojo test (the PSC analogue of `requireProof`) and a check that every `proved` claim names at least one passing test would close that gap and make FMK-AUDIT-style audits mechanical. Conversely, `tdd_ledger` is a `proof_records` instance with two kinds and no dependency closure; crypto-composer would gain closure validation and bounded-versus-general discipline by consuming the FMK package, and the library-extraction audit already named it as a consumer of the canonical integer encoding.

### A3. Typed relationship graphs and the bridge vocabulary `[V]`

`TS:` stores concept relationships with nine typed edges (contradictory, implicative, hierarchical, evolutionary, analogous, synonymous, antonymous, part-whole, causal) and a certainty score, checked by `specs/SemanticGraphConstraints.tla`. The research repositories store the same kind of object as prose: NLAP's terminology declarations (genealogy, bridge claim, known leaks, use discipline), its `spec/regime_correspondences.toml` (class, status, preserves, does not inherit, domain conditions), the round-one correspondence table with THEOREM / CONDITIONAL / DEFINITION / ANALOGY labels, and PSC's status surfaces.

Two transfers:

1. **Export the registries as a typed graph.** `regime_correspondences.toml` entries are `analogous` or `implicative` edges with a status; terminology declarations are `synonymous`/`analogous` edges with declared leaks; contradictory status statements across surfaces (round-one C5: "routes around the contracting space" against "contracting address is the live target") are `contradictory` edges. A `TS:` graph built from the two ledgers would make such contradictions a queryable edge type instead of an audit finding. The `TS:` MCP server mode makes that graph available to the review agents already used on these repositories.
2. **Import provenance into the graph.** `TS:` edges are LLM-asserted with a certainty score and no provenance class. The research repositories' four-way status (theorem-backed, conditional on named lemmas, definition-only, analogy) and the "known leaks" field are exactly what an LLM-derived semantic graph lacks. Adding `provenance` and `leaks` attributes to the `TS:` edge schema, with the TLA+ constraint that a `synonymous` or `implicative` edge of provenance `theorem-backed` must name its source, would let the same graph carry verified and speculative relationships without conflating them.

### A4. Manifestos and prose linting `[V]`

`ORM:` publishes manifestos with machine-readable rulings (OBLIGATORY / ENCOURAGED / OPTIONAL / DISCOURAGED / PROHIBITED), a `semantic-relationships.yaml` between manifestos, Vale styles, and a GitHub workflow example; its Formal Verification Manifesto stops at software. The research repositories are a working instance of proof-carrying research hygiene with rules nobody has written down as a manifesto: every statement carries a status label; bounded evidence never becomes a general claim; imported theorems carry hypotheses and leaks; capped computations are inconclusive; countermodels are retained, never deleted; status surfaces are regenerated from one ledger. Writing that as an `ORM:` manifesto with rulings gives the rules a home outside two repositories' `AGENTS.md` files, and `claim_governance` becomes its reference implementation.

In the other direction, `NLAP: tools/audit_paper_language.py` and the risky-phrase lists in `claim_governance` are prose linters written in Python; `TS:` already runs Vale, and `ORM:` ships Vale styles. Porting the banned-term and risky-phrase lists to Vale vocabularies would let the same rules run on manuscripts, documentation, and the semantic graph with one tool, and keep `claim_governance` for the checks Vale cannot express (status consistency across surfaces, promotion of open claims).

### A5. TLA+ across repositories

PSC's `ProofArchitecture.tla` is a generic typed-DAG dependency-closure specification; `TS:` has three TLA+ modules for graph constraints, validation, and retry; `SG:` specifies its kernel in prose (`docs/deontic-spec-contract.md`, non-operative). The `proof_records` closure validator, the SG `Justification` chain, and the `TS:` graph constraints are all instances of one specification: a finite DAG of typed nodes with per-edge required outcomes and a closure predicate. One shared module would let TLC check FMK-AUDIT-001's corrected contract before it is implemented twice more. Status: engineering proposal; low cost once FMK's contract is final.

## 3. Ranked next contributions

| Rank | Contribution | Repositories | Kind | First file |
| --- | --- | --- | --- | --- |
| R1 | Tuning substitutions and the residual-class carrier as a directive sequence (N1) | FMK, NLAP | mathematics, executable | `FMK: substitution_dynamics/substitution.mojo` (constructor), then `NLAP: docs/C1_unresolved_wake_to_carrier_obstruction.md` |
| R2 | Generate every ledger from proof records: `tla/Ledger.tla`, the `[claims]` table of `claim_governance.toml`, NLAP's Mojo ledgers, the docs index | FMK, PSC, NLAP | infrastructure | `FMK: tools/` new generator; closes PSC issue #3 and NLAP audit F5 by construction |
| R3 | Harmonic-measure island and a `density` carrier field (N2) | NLAP | ledger, mathematics | `NLAP: docs/C1_theorem_tag_import_ledger.md` |
| R4 | One canonical encoding and one outcome vocabulary across SG, FMK, CC, NLAP (A1 items 1–2) | SG, FMK, CC, NLAP | infrastructure | `FMK: docs/canonical-encoding.md`, `SG: docs/release-provenance.md` |
| R5 | Obstruction extractor and boundary/interior dichotomy on NLAP's Misiurewicz prefix graphs (N3), which requires the exact-type catalogue (round-one B6) | NLAP | executable, negative control | new `NLAP: src/misiurewicz_catalogue.mojo` |
| R6 | Research-hygiene manifesto in ORM with `claim_governance` as reference implementation; Vale port of the prose rules (A4) | ORM, FMK, NLAP, TS | tooling | `ORM:` new manifesto directory; `FMK: audit/docs/policy-format.md` |
| R7 | Remaining round-one items: Lean lemma for irreducibility of the exterior-square characteristic polynomial (the statement PSC now actually uses); degree-`n` Pisot screen; Hubbard-tree core-entropy census; p-adic module | PSC, FMK | mathematics | `PSC: PscVerif/PscVerif/Spectral.lean`; `PSC: mojo/psc/pisot.mojo` |
| R8 | `claim_id` on every Mojo test and a "proved claims have passing tests" check (A2); typed-graph export of the registries (A3) | PSC, NLAP, CC, TS | tooling | `PSC: mojo/tests/`, `NLAP: spec/regime_correspondences.toml` |

R1 is ranked first because it is the only item that changes what NLAP's residual object *is*, and it consumes a library both programs already vendor. R2 is ranked second because every audit since 2026-09-10 in both repositories has found status drift between hand-maintained surfaces, and FMK now has the record type that makes generation possible.

## 4. Non-claims

- N1 and N2 rest on literature statements marked `[L]`; nothing here promotes them, and the residual-class reformulation is a definition, not a theorem.
- The frontier comparison in N1 is an analogy with a stated leak: substitution dynamics describes the dynamical plane of a residual parameter, and parameter-plane shrinking needs a priori bounds.
- Section 2 concerns engineering structure; none of it bears on `OverlapProductivity`, `ResidualClosureNoMissingLinks`, or any conjecture status.
- `coop_substrate` was not read and is not assessed.

## 5. Citation targets to pin before any ledger uses them

- Douady, Hubbard, *Étude dynamique des polynômes complexes*, tuning; Milnor, *Periodic orbits, external rays and the Mandelbrot set*, for the kneading form of tuning.
- Dekking, *The spectrum of dynamical systems arising from substitutions of constant length* (1978).
- Lyubich, *Dynamics of quadratic polynomials I–II* and *Feigenbaum–Coullet–Tresser universality and Milnor's hairiness conjecture*, for the postcritical odometer of bounded-type infinitely renormalizable maps.
- Graczyk, Świątek, *Harmonic measure and expansion on the boundary of the Mandelbrot set* (Inventiones 2000); Smirnov, *Symbolic dynamics and Collet–Eckmann conditions* (IMRN 2000), for harmonic-measure-almost-everywhere statements.
- Barge, Štimac, Williams, *Pure discrete spectrum in substitution tiling spaces* (already imported in PSC).
