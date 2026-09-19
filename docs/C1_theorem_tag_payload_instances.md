# C1 theorem tag payload instances

Status: next proof slice after `TheoremTagAssumptionPayloads`.

This document compares the current proof ledger with the next admissible proof work. The repository already has schemas for theorem-tag assumption payloads. The missing step is to instantiate those schemas for the first imported theorem families without allowing the instances to smuggle in generic Mandelbrot local connectivity, global fiber triviality, bounded-search evidence, or renderer evidence.

## Current state on main

The current final proof ledger says:

```text
current_priority_block() = ResidualClosureNoMissingLinks
next_immediate_block() = TheoremTagPayloadInstances
final_ledger_ready_for_c1() = false
```

The current theorem-tag schema layer is present:

```text
TheoremTagImportLedger          created
TheoremTagAssumptionPayloads    created
TheoremTagPayloadInstances      missing / scaffolded
```

Therefore the next safe PR is not a new conjecture statement. It is a payload-instance PR for the first theorem-tag families.

## Scope of this PR slice

This slice introduces finite payload instances for:

1. `RationalParameterRayLanding`
   - conclusion kind: rational parameter-ray landing / separator-ray landing;
   - strength class: local landing;
   - admissible use: certify landing assumptions used by finite rational-ray separator certificates.

2. `FiberDefinitionEquivalence`
   - conclusion kind: fiber-definition adapter;
   - strength class: adapter-only;
   - admissible use: connect persistent non-separation by admitted rational-ray separators to the chosen classical fiber relation.

These instances remain scaffolded until the source-level assumptions are verified against the cited literature and encoded in source-specific payload records. They do not prove the priority conjecture.

## Explicit non-goals

This slice does not introduce final proof acceptance. It does not assert:

- generic Mandelbrot local connectivity;
- all fibers are trivial;
- every persistent non-separation collapses;
- bounded search proves termination;
- numerical pictures or renderers certify fibers;
- rank-2 polynomial constraints supply analytic loci.

## Acceptance criteria

The PR is acceptable only if the new payload instances satisfy all of the following:

```text
has_finite_witness_payload        true
has_adapter_payload               true
has_source_family                 true
excludes_generic_boundary_claim   true
excludes_residual_closure_claim   true
uses_generic_mlc                  false
uses_bounded_search_only          false
```

and the instances are still marked as not final proof imports until their source assumptions are checked.

## Next suggested step after this PR

After this PR, the next target should be:

```text
RationalLandingPayloadSourceChecks
```

That step should bind the `RationalParameterRayLanding` payload to exact source statements and verify the finite assumption fields required for use in separator certificates.
