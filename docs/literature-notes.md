# Literature Notes

This file tracks theorem boundaries for the finite-regime Mandelbrot research program.

## Schleicher — rational parameter rays

Use for the theorem tag:

```text
RationalRayLanding
```

Role in this project:

- rational parameter rays land;
- ray combinatorics relate to critical-orbit dynamics;
- ray period and orbit/kneading period must be distinguished.

Design consequence:

The finite verifier checks rational-angle combinatorics and exact Misiurewicz type. The theorem tag discharges the analytic conclusion that the corresponding rays land at the isolated parameter.

## Schleicher — fibers and local connectivity

Use for the theorem tag:

```text
MisiurewiczFiberTriviality
```

Role in this project:

- fibers are defined by separation using rational rays / separation lines;
- Misiurewicz fibers are trivial;
- hyperbolic-component boundary fibers are trivial;
- local connectivity of the Mandelbrot set is equivalent to triviality of all fibers in Schleicher's framework.

Design consequence:

Separation-completeness is not an extra premise. It is built into the fiber definition. The open frontier is singleton stabilization/triviality of fibers at generic boundary points.

## Douady-Hubbard tradition

Use as classical background for:

- parameter rays;
- landing of rational rays;
- orbit portraits;
- Misiurewicz and parabolic boundary structure;
- Mandelbrot local connectivity formulation.

## Tuning in kneading form

Douady and Hubbard, *Étude dynamique des polynômes complexes* (tuning);
Derrida, Gervois, and Pomeau, the star product of unimodal kneading sequences;
Milnor, *Periodic orbits, external rays and the Mandelbrot set* (from rational
ray addresses to kneading sequences).

Use as the source family of the `KneadingFormOfTuning` theorem tag only:

- tuning by a centre of period `p` acts on kneading sequences as the
  constant-length-`p` substitution `A' . (s xor dgp(A'))`, real slice;
- the kneading letters of a periodic ray address are its itinerary under
  doubling relative to the two cut points `theta/2` and `(theta+1)/2`.

Not covered by that tag: the postcritical odometer of bounded-type infinitely
renormalizable maps (Lyubich), Dekking's coincidence theorem for
constant-length substitutions, and every a priori-bounds statement. Each
needs its own tag before any ledger uses it.

## Interval / Krawczyk methods

Use for finite localization witnesses.

Role in this project:

- certify existence and uniqueness of a root in a dyadic complex box;
- provide finite rational proof objects;
- avoid floating-point trust.

Design consequence:

Krawczyk localizes the algebraic parameter only. It does not prove ray landing or fiber triviality.

## Fixed-point and integer rendering tradition

Historical relevance:

- early fractal renderers used integer/fixed-point arithmetic;
- these show that Mandelbrot-like images can be generated without floating-point arithmetic.

Design difference:

This project is not just integer rendering. It is proof-carrying finite certification.

## Finite-field arithmetic dynamics

Relevant but secondary.

Finite fields do not support escape, because every orbit is eventually periodic. Therefore finite-field Mandelbrot analogues are shadows, not replacements for the classical escape-defined set.

Possible use:

- study reductions of critical-orbit polynomials;
- analyze orbit statistics;
- use modular checks for exploratory algebra.
