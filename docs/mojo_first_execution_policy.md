# Mojo-first execution and theorem-kernel policy

Status: repository policy.

Mojo is the default first-class language for executable finite-regime computations **and** for the finite proof-object theorem kernel in NLAP-JT.

This does not mean Mojo re-proves the analytic literature. It means the repository’s trusted internal checker for finite algebraic, combinatorial, separator-catalogue, witness, and carrier-refinement derivations is written in Mojo.

## What Mojo owns

Mojo should be the primary implementation language for:

- integer/rational arithmetic adapters;
- rank-2 coordinate-record arithmetic;
- quadrance scalar computations;
- interval and polynomial kernels;
- separator-code normalization;
- finite separator-catalogue scans;
- witness structs and status structs;
- canonical certificate encodings;
- performance-critical finite combinatorics;
- finite proof-object syntax;
- finite proof-rule checking;
- theorem-tag import validation;
- proof-grade derivation replay.

Python remains acceptable for:

- CI linting;
- reference oracles;
- repository audits;
- test harnesses while Mojo tooling matures;
- migration scaffolds.

Python must not become the source of truth for certificate computation or proof-object validity once a Mojo implementation exists.

## Mojo theorem kernel boundary

The Mojo theorem kernel is a small proof checker for finite derivations. It owns:

```text
ProofObject + RuleApplication + LocalAxiomTag + TheoremTagImport
  -> CheckedTheoremStatus
```

It may check project-internal finite statements such as:

- normalized rational-address validity;
- separator-code admissibility;
- finite-prefix existential separation;
- side-witness composition;
- canonical carrier-content comparison;
- strict carrier-refinement descent;
- proof-status propagation.

It must not silently assert analytic conclusions. Classical complex-dynamics results enter only as theorem tags with source metadata and declared assumptions.

## Trusted imports

A theorem tag is not an internal proof. It is an explicit import boundary.

Every imported theorem tag must carry:

- stable theorem identifier;
- source family or citation key;
- hypotheses required by the source theorem;
- conclusion made available to the finite kernel;
- leak note stating what the source theorem does not provide.

The Mojo kernel may verify that a finite derivation used an allowed theorem tag under declared hypotheses. It does not turn an unchecked tag into an internally proved theorem.

## Optimization discipline

Mojo implementations should prefer:

- value-like structs with explicit fields;
- normalized integer/rational representations;
- contiguous arrays or fixed-layout records where possible;
- explicit branch-minimized inner kernels;
- separation of debug/demo paths from proof-grade paths;
- allocation-light polynomial evaluation;
- Horner evaluation for polynomial kernels;
- batchable vector-style loops for catalogue and interval checks;
- clear backend boundaries for arbitrary-precision integer support;
- deterministic proof replay with no ambient mutable global theorem state.

## Layer rule for R2

At the R2 certificate layer, Mojo code may expose:

- coordinate records;
- coefficient operations;
- polynomial operations;
- polynomial predicates;
- quadrance scalar computations.

It must not expose primitive constructors, APIs, or inference rules for:

- circle;
- disk;
- arc;
- circumference;
- polar angle;
- connected component;
- interior;
- boundary;
- analytic locus.

These concepts may appear only through a registered higher-layer adapter.

## Naming rule

New C1 proof code should use:

```text
SeparatorCatalogueSoundness
SeparatorCatalogueCompleteness
SeparatorCatalogueAdequacy
```

rather than `catalogue extensionality`.

Legacy files may mention the old term only as migration history.
