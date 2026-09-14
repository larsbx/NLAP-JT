# Mojo toolchain boundary

Status: compiling initial slice; repository-wide port incomplete.

The repository pins Mojo 1.0.0 and pytest 8.3.5 through `pixi.toml` and
`pixi.lock`. CI performs both a JIT smoke run and an ahead-of-time build.

The compiler-checked dependency closure currently consists of:

- `src/smoke_tests.mojo`;
- `src/poly_z.mojo`;
- `src/cert_types.mojo`.

This slice checks the preserved polynomial identities, certificate-header
constraints, the same-box joint-witness gate, and imported-theorem-tag
acceptance. Passing it does not imply that every `.mojo` file compiles, that the
Int coefficient backend is proof-grade, or that any open C1 theorem obligation
has been discharged.

Remaining modules retain legacy syntax until they enter an explicitly listed,
dependency-closed compile target. The compile frontier must expand by adding
real imports and executable assertions, not by treating source-text inspection
as type checking.
