# C1 residual directive carrier: the residual (infinitely renormalizable) class
# carried as a finite directive prefix of tuning substitutions.
# This file is terminology-governed by docs/C1_residual_directive_carrier.md.
#
# Each level is an exact periodic rational ray address (the angle of a
# renormalization centre) together with the tuning pattern it determines: the
# 0/1 kneading prefix of the address and the twist fixed by the internal-address
# continuation rule. The kneading prefix of the whole carrier is the vendored
# `substitution_dynamics.tuning.kneading_prefix` of its patterns. Nothing here
# decides fibre membership; see the non-claims at the end of the file.
#
# Identifying the pattern's substitution with Douady-Hubbard tuning on kneading
# sequences is the theorem tag `TuningKneadingSubstitution` in
# src/C1_theorem_tag_import_ledger.mojo, scaffolded, not checked.

from checked_int64_backend import CheckedI64Result, checked_add_i64, checked_mul_i64
from checked_ray_address import checked_double_ray_addr, make_checked_ray_addr
from substitution_dynamics.tuning import TuningPattern, kneading_prefix

comptime MAX_CARRIER_PERIOD = 62


struct KneadingPrefixResult(Copyable, Movable):
    """`prefix` is the 0/1 kneading sequence of a periodic address up to, not
    including, its `*` at position `period`; `rejected` carries no data."""

    var prefix: List[Int]
    var period: Int
    var rejected: Bool

    def __init__(out self, prefix: List[Int], period: Int, rejected: Bool):
        self.prefix = prefix.copy()
        self.period = period
        self.rejected = rejected

    def accepted(self) -> Bool:
        return not self.rejected


def rejected_kneading_prefix() -> KneadingPrefixResult:
    return KneadingPrefixResult(List[Int](), 0, True)


def _cross(a: Int64, b: Int64) -> CheckedI64Result:
    return checked_mul_i64(a, b)


# Regime correspondence: angle-kneading-prefix
def checked_kneading_prefix(num: Int64, den: Int64) -> KneadingPrefixResult:
    """0/1 kneading sequence of the periodic address `num/den`: letter `k` is 1
    when `2^k theta` lies strictly between `theta/2` and `(theta+1)/2` modulo
    one, 0 when it lies strictly outside, and the sequence stops at the first
    boundary hit, which is position `period - 1`. Rejects addresses outside
    `(0, 1)`, addresses with an even reduced denominator (not periodic), any
    fixed-width overflow, and periods beyond `MAX_CARRIER_PERIOD`."""
    var theta = make_checked_ray_addr(num, den)
    if theta.rejected or theta.num == 0 or theta.den % 2 == 0:
        return rejected_kneading_prefix()
    var two_den = checked_mul_i64(theta.den, 2)
    var upper_num = checked_add_i64(theta.num, theta.den)
    if two_den.overflowed or upper_num.overflowed:
        return rejected_kneading_prefix()
    var prefix = List[Int]()
    var current = theta
    for k in range(MAX_CARRIER_PERIOD + 1):
        # Compare current = a/b with theta/2 = num/(2 den) and (theta+1)/2 = (num+den)/(2 den).
        var lhs = _cross(current.num, two_den.value)
        var low = _cross(theta.num, current.den)
        var high = _cross(upper_num.value, current.den)
        if lhs.overflowed or low.overflowed or high.overflowed:
            return rejected_kneading_prefix()
        if lhs.value == low.value or lhs.value == high.value:
            return KneadingPrefixResult(prefix, k + 1, False)
        prefix.append(1 if (lhs.value > low.value and lhs.value < high.value) else 0)
        current = checked_double_ray_addr(current)
        if current.rejected:
            return rejected_kneading_prefix()
    return rejected_kneading_prefix()


def _rho(nu: List[Int], m: Int) -> Int:
    """`min {k > m : nu_k != nu_(k-m)}` over the periodic extension of `nu`
    (1-indexed), or 0 when no such `k` exists within one full comparison cycle."""
    var n = len(nu)
    for k in range(m + 1, m + 4 * n + 2):
        if nu[(k - 1) % n] != nu[(k - m - 1) % n]:
            return k
    return 0


def _internal_address_contains(nu: List[Int], target: Int) -> Bool:
    """Whether `target` occurs in the internal address `1 -> rho(1) -> rho(rho(1)) -> ...`
    of the periodic sequence `nu`."""
    var m = 1
    while True:
        if m == target:
            return True
        var r = _rho(nu, m)
        if r == 0 or r > target:
            return False
        m = r


struct ContinuationResult(ImplicitlyCopyable):
    """The last letter of `A(nu)`, the periodic continuation of `nu_1 ... nu_(n-1) *`
    whose internal address contains `n`; `rejected` when not exactly one
    continuation qualifies."""

    var last_letter: Int
    var rejected: Bool

    def __init__(out self, last_letter: Int, rejected: Bool):
        self.last_letter = last_letter
        self.rejected = rejected


# Regime correspondence: angle-kneading-prefix
def continuation_last_letter(prefix: List[Int]) -> ContinuationResult:
    var n = len(prefix) + 1
    var found = -1
    for b in range(2):
        var nu = prefix.copy()
        nu.append(b)
        if _internal_address_contains(nu, n):
            if found >= 0:
                return ContinuationResult(0, True)
            found = b
    if found < 0:
        return ContinuationResult(0, True)
    return ContinuationResult(found, False)


struct DirectiveLevel(Copyable, Movable):
    """One renormalization level: the reduced periodic address and its tuning pattern."""

    var num: Int64
    var den: Int64
    var pattern: TuningPattern

    def __init__(out self, num: Int64, den: Int64, pattern: TuningPattern):
        self.num = num
        self.den = den
        self.pattern = pattern.copy()

    def same_address(self, other: DirectiveLevel) -> Bool:
        return self.num == other.num and self.den == other.den


struct DirectiveLevelResult(Copyable, Movable):
    var level: DirectiveLevel
    var rejected: Bool

    def __init__(out self, level: DirectiveLevel, rejected: Bool):
        self.level = level.copy()
        self.rejected = rejected


def _placeholder_level() -> DirectiveLevel:
    var one: List[Int] = [1]
    return DirectiveLevel(0, 1, TuningPattern(one, False))


# Regime correspondence: angle-kneading-prefix
def checked_directive_level(num: Int64, den: Int64) -> DirectiveLevelResult:
    """The tuning pattern of a periodic address: prefix its kneading prefix,
    twist chosen so that the image of `1` is `A(nu)` (the continuation whose
    internal address contains the period). Fails closed on any rejection."""
    var kneading = checked_kneading_prefix(num, den)
    if kneading.rejected or len(kneading.prefix) == 0:
        return DirectiveLevelResult(_placeholder_level(), True)
    var continuation = continuation_last_letter(kneading.prefix)
    if continuation.rejected:
        return DirectiveLevelResult(_placeholder_level(), True)
    var theta = make_checked_ray_addr(num, den)
    # tau(1) = prefix . (1 xor twist) must equal A(nu) = prefix . last_letter.
    var twist = continuation.last_letter == 0
    try:
        var pattern = TuningPattern.checked(kneading.prefix, twist)
        return DirectiveLevelResult(DirectiveLevel(theta.num, theta.den, pattern), False)
    except:
        return DirectiveLevelResult(_placeholder_level(), True)


struct ResidualDirectiveCarrier(Copyable, Movable):
    """A finite directive prefix: levels in renormalization order. Refinement
    appends a level and returns a new carrier; the carrier is never mutated."""

    var levels: List[DirectiveLevel]

    def __init__(out self, levels: List[DirectiveLevel]):
        self.levels = levels.copy()

    @staticmethod
    def empty() -> ResidualDirectiveCarrier:
        return ResidualDirectiveCarrier(List[DirectiveLevel]())

    def depth(self) -> Int:
        return len(self.levels)

    def refined(self, level: DirectiveLevel) -> ResidualDirectiveCarrier:
        var levels = self.levels.copy()
        levels.append(level.copy())
        return ResidualDirectiveCarrier(levels)

    def agrees_to_depth(self, other: ResidualDirectiveCarrier, k: Int) -> Bool:
        """Both carriers have at least `k` levels and the first `k` addresses agree."""
        if k < 0 or self.depth() < k or other.depth() < k:
            return False
        for i in range(k):
            if not self.levels[i].same_address(other.levels[i]):
                return False
        return True

    def kneading_word(self) raises -> List[Int]:
        """The kneading prefix of `A_1 * ... * A_n`: the first `p_1 ... p_n - 1`
        letters shared by every tuning of these levels (vendored kernel)."""
        var patterns = List[TuningPattern]()
        for i in range(len(self.levels)):
            patterns.append(self.levels[i].pattern.copy())
        return kneading_prefix(patterns)

    def period(self) -> Int:
        var p = 1
        for i in range(len(self.levels)):
            p *= self.levels[i].pattern.period()
        return p


# --- non-claims ---------------------------------------------------------------


def carrier_agreement_proves_same_fiber() -> Bool:
    return False


def directive_prefix_decides_residual_membership() -> Bool:
    return False


def dgp_parity_twist_is_general() -> Bool:
    # The parity twist of the vendored `TuningPattern.dgp` reproduces the
    # continuation rule on real centres only; the rabbit (1/7) refutes it.
    return False


# --- smoke ------------------------------------------------------------------------


def _same(a: List[Int], b: List[Int]) -> Bool:
    if len(a) != len(b):
        return False
    for i in range(len(a)):
        if a[i] != b[i]:
            return False
    return True


def _carrier(nums: List[Int64], dens: List[Int64]) -> ResidualDirectiveCarrier:
    var carrier = ResidualDirectiveCarrier.empty()
    for i in range(len(nums)):
        var level = checked_directive_level(nums[i], dens[i])
        if level.rejected:
            return ResidualDirectiveCarrier.empty()
        carrier = carrier.refined(level.level)
    return carrier


def _tuned_matches(nums: List[Int64], dens: List[Int64], tuned_num: Int64, tuned_den: Int64) -> Bool:
    """The carrier's kneading prefix equals the kneading prefix of the address
    obtained by exact angle tuning (pinned in tools/kneading_reference.py)."""
    var carrier = _carrier(nums, dens)
    if carrier.depth() != len(nums):
        return False
    var expected = checked_kneading_prefix(tuned_num, tuned_den)
    try:
        return expected.accepted() and _same(carrier.kneading_word(), expected.prefix)
    except:
        return False


def residual_directive_carrier_smoke() -> Bool:
    var doubling = checked_kneading_prefix(1, 3)
    var airplane = checked_kneading_prefix(3, 7)
    var rabbit = checked_kneading_prefix(1, 7)
    var expected_doubling: List[Int] = [1]
    var expected_airplane: List[Int] = [1, 0]
    var expected_rabbit: List[Int] = [1, 1]
    if not (doubling.accepted() and doubling.period == 2 and _same(doubling.prefix, expected_doubling)):
        return False
    if not (airplane.accepted() and airplane.period == 3 and _same(airplane.prefix, expected_airplane)):
        return False
    if not (rabbit.accepted() and rabbit.period == 3 and _same(rabbit.prefix, expected_rabbit)):
        return False
    # Rejections: zero, preperiodic, malformed, out of range.
    if checked_kneading_prefix(0, 1).accepted() or checked_kneading_prefix(1, 2).accepted():
        return False
    if checked_kneading_prefix(1, 0).accepted() or checked_kneading_prefix(7, 5).accepted():
        return False
    # Twists: the rabbit's continuation A(11*) = 110 (twist on), the airplane's A(10*) = 100 (twist on),
    # the satellite period-4 centre 2/5 has A(101*) = 1011 (twist off).
    var rabbit_level = checked_directive_level(1, 7)
    var airplane_level = checked_directive_level(3, 7)
    var satellite_level = checked_directive_level(2, 5)
    if rabbit_level.rejected or airplane_level.rejected or satellite_level.rejected:
        return False
    if not (rabbit_level.level.pattern.twist and airplane_level.level.pattern.twist and not satellite_level.level.pattern.twist):
        return False
    # Exact angle tuning agrees with the substitution kneading prefix.
    var n1: List[Int64] = [1, 1]
    var d1: List[Int64] = [3, 3]
    var n2: List[Int64] = [1, 1, 1]
    var d2: List[Int64] = [3, 3, 3]
    var n3: List[Int64] = [7, 1]
    var d3: List[Int64] = [15, 3]
    var n4: List[Int64] = [1, 1]
    var d4: List[Int64] = [7, 3]
    var n5: List[Int64] = [1, 3]
    var d5: List[Int64] = [7, 7]
    if not _tuned_matches(n1, d1, 2, 5):
        return False
    if not _tuned_matches(n2, d2, 7, 17):
        return False
    if not _tuned_matches(n3, d3, 8, 17):
        return False
    if not _tuned_matches(n4, d4, 10, 63):
        return False
    if not _tuned_matches(n5, d5, 82, 511):
        return False
    # Refinement is strict and agreement is prefix-wise.
    var base = _carrier(n1, d1)
    var deeper = _carrier(n2, d2)
    if not (base.depth() == 2 and deeper.depth() == 3 and deeper.period() == 8):
        return False
    if not (base.agrees_to_depth(deeper, 2) and not base.agrees_to_depth(deeper, 3)):
        return False
    var other = _carrier(n4, d4)
    if other.agrees_to_depth(base, 1) or not other.agrees_to_depth(base, 0):
        return False
    return (
        not carrier_agreement_proves_same_fiber()
        and not directive_prefix_decides_residual_membership()
        and not dgp_parity_twist_is_general()
    )
