# interval_q: closed rational intervals and rank-2 boxes over finite_exact.Q.
#
#   closed_q  IQ (closed interval with exact rational endpoints, lo <= hi),
#             ComplexIQ (a pair of IQ used as a rank-2 coordinate box),
#             IQSignResult and IQBoolResult (three-valued sign and boolean
#             predicates that carry an explicit rejected state).
#
# Public boundary: docs/exact-arithmetic-public-boundary.md.
# Specification: larsbx/finite_exact:docs/rational-interval-arithmetic-spec.md,
# sections 2 and 3. A sign of 0 means unknown, never equality; reversed or
# rejected endpoints and a reciprocal across zero are rejected, never widened.
# The package never raises, aborts, or decides certificate acceptance.
# Consumers vendor this directory together with finite_exact/ and pin both in
# their vendored.toml (see README.md).
