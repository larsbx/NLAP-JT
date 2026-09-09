# C1 proof barrier and conditional theorem

Status: proof-boundary note.

The current top conjecture is deliberately positioned at the known frontier:

```text
finite rational-ray nest stabilization
  <=> triviality of Mandelbrot fibers
  <=> MLC-style local-connectivity frontier
```

This file records what can be proved from the finite grammar already introduced, and what cannot be honestly marked proven without resolving the classical generic-boundary problem.

## What is now reducible to local finite lemmas

The repository has decomposed catalogue extensionality into local obligations:

1. admissible rational separator coding;
2. landing-tag coverage for allowed rational-ray separators;
3. side-witness extraction;
4. fair finite enumeration;
5. opposite-side separation soundness;
6. finite-prefix existential introduction.

When these are discharged, the project may claim the following conditional theorem.

## Conditional theorem C1-local

For incidence objects `A` and `B`, assuming the local obligations above:

```text
ClassicallySeparated(A,B)
  <=> exists k. Separated_k(A,B)
```

This is catalogue extensionality. It is not MLC.

## Conditional theorem C1-global

Assuming catalogue extensionality and using the classical fiber definition by rational-ray separation:

```text
SameFiberStream(A,B)
  <=> not exists k. Separated_k(A,B)
```

A finite nest stabilizes to a singleton incidence object exactly when the corresponding classical fiber is trivial.

## The barrier

The generic assertion

```text
for every boundary incidence object A, the fiber of A is trivial
```

is not available from the finite grammar. It is precisely the classical global frontier. Marking it proven would be equivalent to claiming a proof of the Mandelbrot local connectivity conjecture or its fiber-triviality counterpart.

## Allowed established cases

The project may provide theorem-tagged examples for cases where classical work already supplies triviality of fibers, including:

- Misiurewicz parameters;
- points on boundaries of hyperbolic components;
- other literature-backed families only when a stable theorem tag is added.

## Disallowed claims

No file may claim:

- all generic boundary fibers are trivial;
- finite-prefix non-separation proves same fiber;
- finite-prefix shrinkage proves MLC;
- fair enumeration proves stabilization;
- a renderer proves local connectivity;
- a numerical image proves a fiber statement.

## Current conclusion

The current conjecture is neither proved nor disproved by the repository. The honest research state is:

```text
C1 is reduced to catalogue extensionality plus the classical generic fiber-triviality frontier.
```

The next productive move is not to keep adding implementation scaffolding. It is to discharge the remaining local catalogue-extensionality lemmas and then state the global result as conditional on fiber triviality/MLC, with established cases separated from open cases.
