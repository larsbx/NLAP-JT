# Canonical finite rational-ray address value types.
# Neither type represents a measured angle.

from integer_gcd import gcd_int


struct RayAddr(ImplicitlyCopyable):
    var num: Int
    var den: Int

    def __init__(out self, num: Int, den: Int):
        self.num = num
        self.den = den

    def shape_valid(self) -> Bool:
        return self.den > 0 and self.num >= 0 and self.num < self.den

    def valid(self) -> Bool:
        return self.shape_valid()

    def normalized(self) -> Bool:
        return self.shape_valid() and gcd_int(self.num, self.den) == 1

    def doubled(self) -> Self:
        return Self((2 * self.num) % self.den, self.den)


def same_ray_addr(a: RayAddr, b: RayAddr) -> Bool:
    return a.num == b.num and a.den == b.den


def ray_addr_before(a: RayAddr, b: RayAddr) -> Bool:
    if a.den < b.den:
        return True
    if a.den > b.den:
        return False
    return a.num < b.num


struct RayAddr64(ImplicitlyCopyable):
    var num: Int64
    var den: Int64

    def __init__(out self, num: Int64, den: Int64):
        self.num = num
        self.den = den

    def doubled(self) -> Self:
        return Self((2 * self.num) % self.den, self.den)
