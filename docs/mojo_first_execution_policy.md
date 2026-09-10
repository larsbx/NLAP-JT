# Mojo-first execution policy

Status: repository policy.

Mojo is the default first-class language for executable finite-regime computations in NLAP-JT.

## What Mojo owns

Mojo should be the primary implementation language for:

- integer/rational arithmetic adapters;
- rank-2 coordinate-record arithmetic;
- quadrance scalar computations;
- interval and polynomial kernels;
- separator-code normalization;
- finite catalogue scans;
- witness structs and status structs;
- canonical certificate encodings;
- performance-critical finite combinatorics.

Python remains acceptable for:

- CI linting;
- reference oracles;
- repository audits;
- test harnesses while Mojo tooling matures;
- migration scaffolds.

Python must not become the source of truth for certificate computation once a Mojo implementation exists.

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
- clear backend boundaries for arbitrary-precision integer support.

## Proof boundary

Mojo is an execution and certificate-checking language in this repository. It is not, by itself, the trusted mathematical theorem kernel.

A Mojo function may establish a finite witness predicate only inside its declared layer. Any import from classical complex dynamics requires an external theorem dependency and an adapter lemma.

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
