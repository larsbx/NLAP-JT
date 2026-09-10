# Finite-Regime Mandelbrot Research

This repository develops a finite, certificate-carrying formulation of Mandelbrot-set computation.

The project goal is not to replace the classical analytic Mandelbrot set with a false finite exact object. Instead, it formalizes a hierarchy of finite algebraic certificates that reproduce the observable content available at finite resolution while isolating the single generic-boundary obstruction as MLC / fiber triviality.

## Core thesis

A Mandelbrot generator can be specified without primitive reliance on real numbers, analytic complex-number objects, limits, transcendental functions, trigonometric functions, circles as rank-2 primitives, or infinite series by using:

- integer polynomial critical-orbit recurrences;
- dyadic rational boxes as finite interval objects;
- squarefree polynomial localization;
- pointwise exact-type exclusions;
- symbolic rational ray-address combinatorics;
- rank-2 coordinate records for executable algebra;
- finite incidence objects instead of analytic point primitives;
- named external theorem dependencies for analytic landing/fiber results.

## Mojo-first implementation policy

Mojo is the default first-class language for executable finite computations and certificate encodings in this repository. Python remains acceptable for CI linting, reference oracles, and migration scaffolds, but Mojo owns the primary certificate kernels once a Mojo implementation exists.

Mojo code should prioritize:

- value-like structs with explicit fields;
- normalized integer/rational representations;
- allocation-light polynomial and interval kernels;
- Horner evaluation for polynomial computations;
- batchable catalogue and interval scans;
- explicit backend boundaries for arbitrary-precision integers;
- separation of debug/demo paths from proof-grade paths.

Mojo is not itself the trusted theorem kernel. A Mojo function may check finite witnesses; classical analytic conclusions require explicit external theorem dependencies and adapter lemmas.

## Current mathematical focus

The current research focus is C1, now phrased as separator catalogue adequacy plus the residual fiber-triviality frontier:

```text
SeparatorCatalogueSoundness:
  Separated_k(A,B) -> ClassicallySeparated(A,B)

SeparatorCatalogueCompleteness:
  ClassicallySeparated(A,B) -> exists k. Separated_k(A,B)

SeparatorCatalogueAdequacy:
  soundness + completeness
```

After adequacy, persistent finite non-separation presents the classical same-fiber relation on the covered domain. Therefore any theorem that eliminates all distinct persistent non-separation has fiber-triviality / MLC strength under global coverage. The repository marks this as `OPEN_FRONTIER`, not as solved.

## Rank-2 layer rule

At the rank-2 certificate layer, the available objects are coordinate records, coefficient operations, polynomial operations, polynomial predicates, and quadrance scalars.

The following are not primitive constructors, APIs, or inference rules at rank 2:

- circle;
- disk;
- arc;
- circumference;
- polar angle;
- connected component;
- interior;
- boundary;
- analytic locus.

Such concepts require an explicit higher-layer adapter and cannot be imported merely from the polynomial expression `Q(x,y)=x^2+y^2`.

## Repository layout

```text
README.md
ROADMAP.md
docs/
  alignment_audit_deep_research_findings.md
  mojo_first_execution_policy.md
  terminology-governance.md
  terminology-registry.md
  terminology-use-manifest.md
  finite-certificate-calculus.md
  literature-notes.md
  C1_*.md
examples/
  misiurewicz-c-minus-2.md
  stress-test-m41.md
src/
  *.mojo
tools/
  audit_*.py
tests/
  test_*.py
```

## Boundary of claims

This project does not claim an unconditional finite co-landing certificate for generic Mandelbrot boundary points. For generic boundary points, finite certificate streams can be produced, but their singleton stabilization is exactly the MLC/fiber-triviality frontier unless a new proof is supplied.

No finite bounded search, renderer, numerical picture, local carrier refinement, or terminology declaration proves C1 by itself.

## Status

Research scaffold with enforced terminology, rank-2 ontology, C1 proof-status gates, and Mojo-first executable certificate policy.