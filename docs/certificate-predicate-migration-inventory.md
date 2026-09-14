# Certificate predicate migration inventory

Status: executable-boundary inventory during BigZ-backed c=-2 replay.

This inventory separates finite computations, imported classical results, and
the global C1 obligation. A green bounded-width computation is not a
proof-grade certificate and cannot discharge an imported theorem or C1.

| Predicate | Current executable source | State | Acceptance consequence |
| --- | --- | --- | --- |
| Squarefree `P_{2,1}` evaluation and strict localization | `src/krawczyk_witness.mojo` | replayed on unbounded BigZ rational intervals; rejection distinct from non-contraction | accepts the finite arithmetic replay only; proof-grade acceptance is explicitly false |
| Same-box forbidden collisions | `src/interval_orbit.mojo` | replayed 5/5 on the same parameterized BigZ box constructor as localization; rejection distinct from ambiguity | accepts the finite exact-type arithmetic replay only |
| Rational ray-address orbit for `1/2` | `src/bigq_ray_address.mojo` | replayed with normalized BigZ-backed `Q`, including a representation whose inputs exceed `Int64`; malformed and out-of-range values reject | accepts finite symbolic address data only |
| Rational parameter-ray landing target | `src/bigq_landing_target_adapter.mojo` | composes same-exponent BigZ localization, exact-type exclusion, and symbolic address replay; correspondence citation remains metadata | finite association only; theorem import and certificate acceptance are explicitly false |
| Squarefree `P_{2,1}` evaluation and strict localization | `src/checked_krawczyk_witness.mojo` | computed, checked-width | accepts bounded localization only |
| Same-box forbidden collisions | `src/checked_interval_exclusion.mojo` | computed 5/5, checked-width | accepts bounded exact-type evidence only |
| Joint arithmetic localization | `src/certificate_arithmetic_migration_gate.mojo` | computed, same-box, checked-width | proof-grade acceptance remains false |
| Rational ray-address orbit for `1/2` | `src/checked_ray_address.mojo` | computed preperiod 1, period 1; overflow rejects | accepts bounded finite ray data only |
| Rational parameter-ray landing target | `src/checked_landing_target_adapter.mojo` | exact `P_{2,1}` factorization, lower-type rejection, ray orbit, and source correspondence checked at bounded width | proof-grade association remains false |
| Rational parameter-ray landing import | `src/C1_theorem_tag_payload_instances.mojo` | source scope and landing-target association checked at bounded width | proof-grade classification blocks final import |
| Known trivial-fiber class import | `src/C1_theorem_tag_payload_instances.mojo` | Misiurewicz source scope matched at checked width; proof-grade classification absent | blocks finite-certificate acceptance |
| Checked finite-certificate composition | `src/checked_finite_certificate_gate.mojo` | finite inputs accepted; theorem tags rejected | full certificate remains rejected |
| Incidence packaging | legacy `src/certificate_incidence.mojo` | not in checked acceptance path | migrate only after theorem-tag bindings are checked |
| Integer backend | `src/bigint_z.mojo` | dynamic limbs with exact ring/order/division/gcd and canonical integer serialization | rational and core intervals migrated; remaining consumers still block proof-grade acceptance |
| `ResidualClosureNoMissingLinks` | `src/C1_residual_closure_no_missing_links.mojo` | open | blocks C1 independently of finite certificates |

## Next obligations

1. Re-run the remaining certificate predicates on the
   backend; bounded-width success remains transitional evidence only.
2. Port incidence packaging only after item 1, preserving the rule that
   an emitted point is a finite vertex whose carrier is a set of vertices.
3. Keep the C1 residual-closure proof track separate; no finite example or
   successful certificate implies the missing global closure statement.
