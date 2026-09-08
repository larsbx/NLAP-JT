# Serialization and Hash-Root Handoff

Status: next implementation target.

The repository now has a canonical serialization contract and Mojo-shaped schema scaffold. This is not yet a proof-grade hash-root layer.

## Current state

Implemented/scaffolded:

- deterministic schema tags;
- ordered record fields;
- finite-only primitive encodings;
- Misiurewicz certificate field order;
- debug serialization gate;
- proof-grade digest gate blocked by backend and hash-suite status.

Blocked:

- bigint-backed integer serialization;
- proof-grade rational normalization;
- selected hash suite;
- theorem-tag stable identifiers;
- byte-level encoder implementation;
- root/digest comparison test vectors.

## Required next implementation

1. Select bigint backend and set `backend.toml` only after proof-grade requirements are satisfied.
2. Implement canonical integer encoding:

```text
Z(sign, byte_len, big_endian_magnitude)
```

3. Implement rational encoding:

```text
Q(num, den)
```

with normalized numerator and positive denominator.

4. Implement composite encoders:

```text
Coord2
Box2
RayAddr
Vertex
PointVertex
KrawczykWitness
ExactTypeExclusionWitness
MisiurewiczCertificate
```

5. Select hash suite and add explicit suite id to the backend manifest.
6. Add golden vectors for:

```text
c=-2 smoke certificate
M_4_1 placeholder rejection record
```

7. Only then allow proof-grade digest acceptance.

## Non-regression rules

Do not serialize:

- floats;
- analytic points;
- measured-angle values;
- host object identities;
- unordered maps without schema-defined canonical ordering;
- lower-collision gcd-stripped exact-type projectors.

The finite object remains:

```text
PointVertex({RootHandle, RayAddressSet, DyadicBox})
```

and the rank-2 substrate remains:

```text
Coord2(x,y), star multiplication, quadrance, rotor predicate, symbolic ray addresses.
```
