# Certificate predicate migration inventory

Status: executable-boundary inventory after checked c=-2 localization.

This inventory separates finite computations, imported classical results, and
the global C1 obligation. A green bounded-width computation is not a
proof-grade certificate and cannot discharge an imported theorem or C1.

| Predicate | Current executable source | State | Acceptance consequence |
| --- | --- | --- | --- |
| Squarefree `P_{2,1}` evaluation and strict localization | `src/checked_krawczyk_witness.mojo` | computed, checked-width | accepts bounded localization only |
| Same-box forbidden collisions | `src/checked_interval_exclusion.mojo` | computed 5/5, checked-width | accepts bounded exact-type evidence only |
| Joint arithmetic localization | `src/certificate_arithmetic_migration_gate.mojo` | computed, same-box, checked-width | proof-grade acceptance remains false |
| Rational ray-address orbit for `1/2` | `src/checked_ray_address.mojo` | computed preperiod 1, period 1; overflow rejects | accepts bounded finite ray data only |
| Rational parameter-ray landing target | `src/checked_landing_target_adapter.mojo` | exact `P_{2,1}` factorization, lower-type rejection, ray orbit, and source correspondence checked at bounded width | proof-grade association remains false |
| Rational parameter-ray landing import | `src/C1_theorem_tag_payload_instances.mojo` | source scope and landing-target association checked at bounded width | proof-grade classification blocks final import |
| Known trivial-fiber class import | `src/C1_theorem_tag_payload_instances.mojo` | Misiurewicz source scope matched at checked width; proof-grade classification absent | blocks finite-certificate acceptance |
| Checked finite-certificate composition | `src/checked_finite_certificate_gate.mojo` | finite inputs accepted; theorem tags rejected | full certificate remains rejected |
| Incidence packaging | legacy `src/certificate_incidence.mojo` | not in checked acceptance path | migrate only after theorem-tag bindings are checked |
| Integer backend | `src/bigint_z.mojo` | dynamic limbs with exact add/sub/mul/order; gcd, exact division, and serialization pending | blocks proof-grade acceptance |
| `ResidualClosureNoMissingLinks` | `src/C1_residual_closure_no_missing_links.mojo` | open | blocks C1 independently of finite certificates |

## Next obligations

1. Complete Euclidean gcd, exact division, and canonical serialization for the
   selected dynamic-limb `BigZ` backend.
2. Replay localization, exact-type uniqueness, and landing association on that
   backend; bounded-width success remains transitional evidence only.
3. Port incidence packaging only after items 1 and 2, preserving the rule that
   an emitted point is a finite vertex whose carrier is a set of vertices.
4. Keep the C1 residual-closure proof track separate; no finite example or
   successful certificate implies the missing global closure statement.
