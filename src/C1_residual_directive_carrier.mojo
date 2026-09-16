# C1 residual-class carrier as a directive prefix of tuning patterns.
# Specification: docs/C1_residual_directive_carrier.md; arithmetic binding:
# docs/rational-interval-arithmetic-spec.md (binding 6.2); kernel contract:
# docs/tuning-substitutions-spec.md of larsbx/finite-math-kernels at the
# commit pinned in vendored.toml (package substitution_dynamics).
#
# A residual-class directive carrier is a finite list of DGP tuning patterns,
# one renormalization level per pattern, each computed from a periodic rational
# ray address by the exact BigZ-backed doubling kernel. The carrier decides no
# fibre, no landing, no a priori bound, and no spectral property. A rejected
# record is inconclusive, never evidence; a bounded period search that fails is
# a rejection, not a classification.

from finite_exact.bigint_z import bigz_from_i64
from finite_exact.rat_q import Q
from bigq_ray_address import BigQRayAddr, bigq_double_ray_addr, make_bigq_ray_addr
from substitution_dynamics.sadic import directive_composite
from substitution_dynamics.substitution import Substitution
from substitution_dynamics.tuning import TuningPattern, dgp_twist, kneading_prefix, star_product
from C1_theorem_tag_payload_instances import TheoremSourceRef


struct KneadingLetters(Copyable, Movable):
    """Itinerary `nu_0 ... nu_{p-2}` of a period-`p` address under doubling,
    relative to the two open arcs cut by `theta/2` and `(theta+1)/2`."""

    var period: Int
    var letters: List[Int]
    var rejected: Bool

    def __init__(out self, period: Int, letters: List[Int], rejected: Bool):
        self.period = period
        self.letters = letters.copy()
        self.rejected = rejected

    def accepted(self) -> Bool:
        return not self.rejected and self.period >= 2 and len(self.letters) == self.period - 1


def rejected_kneading_letters() -> KneadingLetters:
    return KneadingLetters(0, List[Int](), True)


def ray_addr_from_i64(num: Int64, den: Int64) -> BigQRayAddr:
    return make_bigq_ray_addr(bigz_from_i64(num), bigz_from_i64(den))


def ray_addr_period(address: BigQRayAddr, cap: Int) -> Int:
    """Least `p` in `1 .. cap` with `2^p theta = theta`, else 0. A zero result
    means "not found within the cap": the address may be preperiodic or the
    cap too small, and neither is evidence of anything."""
    if not address.accepted():
        return 0
    var x = address.copy()
    for p in range(1, cap + 1):
        x = bigq_double_ray_addr(x)
        if not x.accepted():
            return 0
        if x.value.eq(address.value):
            return p
    return 0


# Regime correspondence: residual-directive-prefix
def kneading_letters(address: BigQRayAddr, cap: Int) -> KneadingLetters:
    """Letters `nu_k` for `k = 0 .. p-2`: `1` when `2^k theta` lies in the open
    arc `(theta/2, (theta+1)/2)`, `0` when it lies in the complementary open arc.
    Rejects unless `p >= 2`, every `2^k theta` with `k < p-1` is off the two
    cut points, and `2^{p-1} theta` is one of them."""
    var p = ray_addr_period(address, cap)
    if p < 2:
        return rejected_kneading_letters()
    var lo = address.value.mul(Q(1, 2))
    var hi = address.value.add(Q.one()).mul(Q(1, 2))
    if lo.rejected or hi.rejected:
        return rejected_kneading_letters()
    var letters = List[Int]()
    var x = address.copy()
    for _ in range(p - 1):
        if not x.accepted():
            return rejected_kneading_letters()
        if lo.lt(x.value) and x.value.lt(hi):
            letters.append(1)
        elif x.value.lt(lo) or hi.lt(x.value):
            letters.append(0)
        else:
            return rejected_kneading_letters()
        x = bigq_double_ray_addr(x)
    if not x.accepted() or not (x.value.eq(lo) or x.value.eq(hi)):
        return rejected_kneading_letters()
    return KneadingLetters(p, letters, False)


struct AddressTuningPattern(Copyable, Movable):
    """The DGP pattern of a periodic address, or a rejection."""

    var pattern: TuningPattern
    var rejected: Bool

    def __init__(out self, pattern: TuningPattern, rejected: Bool):
        self.pattern = pattern.copy()
        self.rejected = rejected

    def accepted(self) -> Bool:
        return not self.rejected


def rejected_address_pattern() -> AddressTuningPattern:
    var placeholder: List[Int] = [1]
    return AddressTuningPattern(TuningPattern(placeholder, True), True)


def tuning_pattern_from_address(address: BigQRayAddr, cap: Int) -> AddressTuningPattern:
    var letters = kneading_letters(address, cap)
    if not letters.accepted():
        return rejected_address_pattern()
    try:
        return AddressTuningPattern(TuningPattern.dgp(letters.letters), False)
    except:
        return rejected_address_pattern()


def same_pattern(a: TuningPattern, b: TuningPattern) -> Bool:
    if a.twist != b.twist or len(a.prefix) != len(b.prefix):
        return False
    for i in range(len(a.prefix)):
        if a.prefix[i] != b.prefix[i]:
            return False
    return True


def is_word_prefix(shorter: List[Int], longer: List[Int]) -> Bool:
    if len(shorter) > len(longer):
        return False
    for i in range(len(shorter)):
        if shorter[i] != longer[i]:
            return False
    return True


# Regime correspondence: residual-directive-prefix
struct ResidualDirectiveCarrier(Copyable, Movable):
    """Directive prefix `[A_1, ..., A_n]` of DGP tuning patterns: level `n` is
    the number of renormalization levels the carrier resolves."""

    var patterns: List[TuningPattern]
    var rejected: Bool

    def __init__(out self, patterns: List[TuningPattern], rejected: Bool):
        self.patterns = patterns.copy()
        self.rejected = rejected

    def level(self) -> Int:
        return len(self.patterns)

    def accepted(self) -> Bool:
        return not self.rejected and self.level() >= 1

    def kneading_prefix(self) raises -> List[Int]:
        """First `p_1 ... p_n - 1` letters common to every tuning of the prefix."""
        return kneading_prefix(self.patterns)

    def composite(self) raises -> Substitution:
        """`tau_{A_1} o ... o tau_{A_n}`, of constant length `p_1 ... p_n`."""
        var subs = List[Substitution]()
        for i in range(self.level()):
            subs.append(self.patterns[i].substitution())
        return directive_composite(subs)

    def star_pattern(self) -> TuningPattern:
        """`A_1 * ... * A_n`; its substitution equals `composite()`."""
        var acc = self.patterns[0].copy()
        for i in range(1, self.level()):
            acc = star_product(acc, self.patterns[i])
        return acc^


def rejected_directive_carrier() -> ResidualDirectiveCarrier:
    return ResidualDirectiveCarrier(List[TuningPattern](), True)


def directive_carrier_extend(carrier: ResidualDirectiveCarrier, address: BigQRayAddr, cap: Int) -> ResidualDirectiveCarrier:
    """One more renormalization level: the pattern of `address` appended."""
    if carrier.rejected:
        return rejected_directive_carrier()
    var next = tuning_pattern_from_address(address, cap)
    if not next.accepted():
        return rejected_directive_carrier()
    var patterns = carrier.patterns.copy()
    patterns.append(next.pattern.copy())
    return ResidualDirectiveCarrier(patterns, False)


def directive_carrier_from_addresses(addresses: List[BigQRayAddr], cap: Int) -> ResidualDirectiveCarrier:
    var carrier = ResidualDirectiveCarrier(List[TuningPattern](), False)
    for i in range(len(addresses)):
        carrier = directive_carrier_extend(carrier, addresses[i], cap)
    if not carrier.accepted():
        return rejected_directive_carrier()
    return carrier^


def same_directive_prefix(a: ResidualDirectiveCarrier, b: ResidualDirectiveCarrier) -> Bool:
    if not a.accepted() or not b.accepted() or a.level() != b.level():
        return False
    for i in range(a.level()):
        if not same_pattern(a.patterns[i], b.patterns[i]):
            return False
    return True


def strict_directive_refinement(before: ResidualDirectiveCarrier, after: ResidualDirectiveCarrier) raises -> Bool:
    """`after` extends `before` by at least one level, and the kneading prefix
    of `before` is a proper prefix of that of `after` (spec section 1.5)."""
    if not before.accepted() or not after.accepted() or after.level() <= before.level():
        return False
    for i in range(before.level()):
        if not same_pattern(before.patterns[i], after.patterns[i]):
            return False
    var shorter = before.kneading_prefix()
    var longer = after.kneading_prefix()
    return len(shorter) < len(longer) and is_word_prefix(shorter, longer)


def directive_prefix_proves_same_fiber() -> Bool:
    return False


def directive_prefix_proves_c1() -> Bool:
    return False


def directive_prefix_supplies_apriori_bounds() -> Bool:
    return False


struct KneadingTuningInstance(Copyable, Movable):
    """Source-specific payload for the `KneadingFormOfTuning` theorem tag: one
    address, its DGP pattern, and the bibliography record the identification of
    `tau_{A', dgp}` with tuning on kneading sequences is imported from."""

    var source: TheoremSourceRef
    var address: BigQRayAddr
    var pattern: AddressTuningPattern
    var real_slice_convention_declared: Bool
    var excludes_generic_boundary_use: Bool
    var classification_proof_attached: Bool

    def __init__(out self, source: TheoremSourceRef, address: BigQRayAddr, pattern: AddressTuningPattern, real_slice_convention_declared: Bool, excludes_generic_boundary_use: Bool, classification_proof_attached: Bool):
        self.source = source
        self.address = address.copy()
        self.pattern = pattern.copy()
        self.real_slice_convention_declared = real_slice_convention_declared
        self.excludes_generic_boundary_use = excludes_generic_boundary_use
        self.classification_proof_attached = classification_proof_attached

    def source_scope_checked(self) -> Bool:
        return (
            self.source.complete() and self.source.citation_key == "DouadyHubbardTuning" and
            self.source.covered_class == "kneading sequences of real quadratic parameters under tuning" and
            self.address.accepted() and self.pattern.accepted() and
            self.pattern.pattern.twist == dgp_twist(self.pattern.pattern.prefix) and
            self.real_slice_convention_declared and self.excludes_generic_boundary_use
        )

    def final_import_admissible(self) -> Bool:
        return self.source_scope_checked() and self.classification_proof_attached


def douady_hubbard_tuning_source() -> TheoremSourceRef:
    return TheoremSourceRef(
        "DouadyHubbardTuning",
        "Etude dynamique des polynomes complexes",
        "kneading sequences of real quadratic parameters under tuning",
    )


def kneading_tuning_instance(address: BigQRayAddr, cap: Int) -> KneadingTuningInstance:
    return KneadingTuningInstance(
        douady_hubbard_tuning_source(),
        address,
        tuning_pattern_from_address(address, cap),
        True,
        True,
        False,
    )


def same_letters(letters: KneadingLetters, expected: List[Int]) -> Bool:
    return letters.accepted() and len(letters.letters) == len(expected) and is_word_prefix(expected, letters.letters)


def residual_directive_carrier_checks() raises -> Bool:
    var cap = 16
    var third = ray_addr_from_i64(1, 3)
    var two_fifths = ray_addr_from_i64(2, 5)
    var three_sevenths = ray_addr_from_i64(3, 7)
    var seven_fifteenths = ray_addr_from_i64(7, 15)
    var r: List[Int] = [1]
    var rlr: List[Int] = [1, 0, 1]
    var rl: List[Int] = [1, 0]
    var rll: List[Int] = [1, 0, 0]
    var cascade_three: List[Int] = [1, 0, 1, 1, 1, 0, 1]
    var itineraries = (
        same_letters(kneading_letters(third, cap), r) and
        same_letters(kneading_letters(two_fifths, cap), rlr) and
        same_letters(kneading_letters(three_sevenths, cap), rl) and
        same_letters(kneading_letters(seven_fifteenths, cap), rll)
    )
    var period_doubling = tuning_pattern_from_address(third, cap)
    var doubled_twice = tuning_pattern_from_address(two_fifths, cap)
    var patterns = (
        period_doubling.accepted() and period_doubling.pattern.twist and
        doubled_twice.accepted() and not doubled_twice.pattern.twist and
        same_pattern(star_product(period_doubling.pattern, period_doubling.pattern), doubled_twice.pattern)
    )
    var one = List[BigQRayAddr]()
    one.append(third.copy())
    var level_one = directive_carrier_from_addresses(one, cap)
    var level_two = directive_carrier_extend(level_one, third, cap)
    var level_three = directive_carrier_extend(level_two, third, cap)
    var composite = level_two.composite()
    var carriers = (
        level_one.accepted() and level_one.level() == 1 and
        level_two.accepted() and level_two.level() == 2 and
        is_word_prefix(rlr, level_two.kneading_prefix()) and len(level_two.kneading_prefix()) == 3 and
        is_word_prefix(cascade_three, level_three.kneading_prefix()) and len(level_three.kneading_prefix()) == 7 and
        same_pattern(level_two.star_pattern(), doubled_twice.pattern) and
        composite.size == 2 and len(composite.image(0)) == 4 and len(composite.image(1)) == 4 and
        composite.image(0)[3] == 0 and composite.image(1)[3] == 1 and
        strict_directive_refinement(level_one, level_two) and
        strict_directive_refinement(level_two, level_three) and
        not strict_directive_refinement(level_two, level_one) and
        not strict_directive_refinement(level_two, level_two) and
        same_directive_prefix(level_two, level_two) and
        not same_directive_prefix(level_one, level_two)
    )
    var rejections = (
        kneading_letters(ray_addr_from_i64(1, 2), cap).rejected and
        kneading_letters(ray_addr_from_i64(0, 1), cap).rejected and
        kneading_letters(ray_addr_from_i64(1, 0), cap).rejected and
        kneading_letters(seven_fifteenths, 3).rejected and
        directive_carrier_extend(level_one, ray_addr_from_i64(1, 2), cap).rejected and
        directive_carrier_from_addresses(List[BigQRayAddr](), cap).rejected
    )
    var instance = kneading_tuning_instance(third, cap)
    var rejected_instance = kneading_tuning_instance(ray_addr_from_i64(1, 2), cap)
    var imports = (
        instance.source_scope_checked() and not instance.final_import_admissible() and
        not rejected_instance.source_scope_checked() and
        not directive_prefix_proves_same_fiber() and not directive_prefix_proves_c1() and
        not directive_prefix_supplies_apriori_bounds()
    )
    return itineraries and patterns and carriers and rejections and imports


def residual_directive_carrier_smoke() -> Bool:
    """Non-raising entry for the smoke closure: a raised kernel error is a failure."""
    try:
        return residual_directive_carrier_checks()
    except:
        return False
