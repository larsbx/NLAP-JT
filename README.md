# Finite-Regime Mandelbrot Research

This repository develops a finite, certificate-carrying formulation of Mandelbrot-set computation.

The project goal is not to replace the classical analytic Mandelbrot set with a false finite exact object. Instead, it formalizes a hierarchy of finite algebraic certificates that reproduce the observable content available at finite resolution while isolating the single generic-boundary obstruction as MLC / fiber triviality.

## Core thesis

A Mandelbrot generator can be specified without primitive reliance on real numbers, complex numbers, limits, transcendental functions, or infinite series by using:

- integer polynomial critical-orbit recurrences;
- dyadic rational boxes as finite interval objects;
- squarefree polynomial localization;
- pointwise exact-type exclusions;
- finite rational-angle combinatorics;
- named theorem tags for analytic landing/fiber results.

The resulting verifier is three-valued:

- `IN` for certified interior boxes;
- `OUT` for certified escape boxes;
- `BOUNDARY_CERT` / `LANDING_CERT` for algebraic boundary certificates;
- `UNKNOWN` for unresolved generic-boundary regions.

## Current focus

The current research focus is the finite certificate calculus for Misiurewicz landing and fiber triviality:

1. localize a root of `sqfree(Q_{l+k} - Q_l)` in a dyadic complex box;
2. prove exact type using pointwise interval exclusions for forbidden collisions;
3. verify rational-angle / kneading combinatorics;
4. discharge landing and fiber conclusions through named theorem tags;
5. keep the generic-boundary case as an explicit reduction to MLC / triviality of all fibers.

## Repository layout

```text
README.md
ROADMAP.md
docs/
  finite-certificate-calculus.md
  open-questions.md
  literature-notes.md
examples/
  misiurewicz-c-minus-2.md
  stress-test-m41.md
src/
  README.md
```

## Boundary of claims

This project does not claim an unconditional finite co-landing certificate for generic Mandelbrot boundary points. For generic boundary points, finite certificate streams can be produced, but their singleton stabilization is equivalent to the open MLC/fiber-triviality frontier.

## Status

Draft research scaffold. Mathematical specifications are being hardened before implementation.
