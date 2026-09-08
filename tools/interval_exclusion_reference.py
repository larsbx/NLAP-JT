#!/usr/bin/env python3
"""Reference checker for exact-type interval exclusions.

This is a temporary Python oracle for the finite-regime Mandelbrot project. It
checks the same-box exclusion requirement for H_{i,j}(beta)=Q_j(beta)-Q_i(beta)
using rational interval arithmetic. It is not the final Mojo certificate engine.

Core invariant preserved here:
  squarefree-localize on R_{ell,k}, then prove exact type by pointwise exclusion
  of every forbidden collision on the same box beta.
"""

from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction
from itertools import combinations


@dataclass(frozen=True)
class I:
    lo: Fraction
    hi: Fraction

    def __post_init__(self) -> None:
        if self.lo > self.hi:
            raise ValueError("empty interval")

    def add(self, other: "I") -> "I":
        return I(self.lo + other.lo, self.hi + other.hi)

    def sub(self, other: "I") -> "I":
        return I(self.lo - other.hi, self.hi - other.lo)

    def mul(self, other: "I") -> "I":
        vals = [self.lo * other.lo, self.lo * other.hi, self.hi * other.lo, self.hi * other.hi]
        return I(min(vals), max(vals))

    def contains_zero(self) -> bool:
        return self.lo <= 0 <= self.hi


@dataclass(frozen=True)
class CI:
    re: I
    im: I

    def add(self, other: "CI") -> "CI":
        return CI(self.re.add(other.re), self.im.add(other.im))

    def sub(self, other: "CI") -> "CI":
        return CI(self.re.sub(other.re), self.im.sub(other.im))

    def mul(self, other: "CI") -> "CI":
        # (a+bi)(c+di) = (ac-bd) + (ad+bc)i, all interval operations.
        real = self.re.mul(other.re).sub(self.im.mul(other.im))
        imag = self.re.mul(other.im).add(self.im.mul(other.re))
        return CI(real, imag)

    def square(self) -> "CI":
        return self.mul(self)

    def excludes_zero(self) -> bool:
        return (not self.re.contains_zero()) or (not self.im.contains_zero())


def q_orbit_box(c: CI, horizon: int) -> list[CI]:
    zero = CI(I(Fraction(0), Fraction(0)), I(Fraction(0), Fraction(0)))
    out = [zero]
    z = zero
    for _ in range(horizon):
        z = z.square().add(c)
        out.append(z)
    return out


def intended_pairs(ell: int, period: int, horizon: int) -> set[tuple[int, int]]:
    return {
        (i, j)
        for i, j in combinations(range(horizon + 1), 2)
        if i >= ell and (j - i) % period == 0
    }


def forbidden_pairs(ell: int, period: int, horizon: int) -> set[tuple[int, int]]:
    all_pairs = set(combinations(range(horizon + 1), 2))
    return all_pairs - intended_pairs(ell, period, horizon)


def excluded_count(cbox: CI, ell: int, period: int, horizon: int) -> tuple[int, int, list[tuple[int, int]]]:
    q = q_orbit_box(cbox, horizon)
    failures: list[tuple[int, int]] = []
    pairs = sorted(forbidden_pairs(ell, period, horizon))
    for i, j in pairs:
        hij = q[j].sub(q[i])
        if not hij.excludes_zero():
            failures.append((i, j))
    return (len(pairs) - len(failures), len(pairs), failures)


def dyadic_box(center_re_num: int, center_im_num: int, center_exp: int, half_exp: int) -> CI:
    den = 2 ** center_exp
    h = Fraction(1, 2 ** half_exp)
    re = Fraction(center_re_num, den)
    im = Fraction(center_im_num, den)
    return CI(I(re - h, re + h), I(im - h, im + h))


def c_minus_2_box() -> CI:
    return CI(I(Fraction(-33, 16), Fraction(-31, 16)), I(Fraction(-1, 16), Fraction(1, 16)))


def m41_box() -> CI:
    # Center from the project notes, half-width 2^-25.
    return dyadic_box(-56912193317957, 538341446717435, 49, 25)


def main() -> int:
    ok, total, failures = excluded_count(c_minus_2_box(), 2, 1, 3)
    assert total == 5, (total, failures)
    assert ok == total, failures

    ok, total, failures = excluded_count(m41_box(), 4, 1, 6)
    assert total == 18, (total, failures)
    assert ok == total, failures

    print("OK: interval exclusion reference checks passed")
    print("  c=-2: 5/5 forbidden collisions excluded on same box")
    print("  M_4,1: 18/18 forbidden collisions excluded on same box")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
