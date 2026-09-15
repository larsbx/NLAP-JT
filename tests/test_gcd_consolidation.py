from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CANONICAL = ROOT / "src" / "integer_gcd.mojo"


def test_gcd_implementations_are_centralized():
    canonical = CANONICAL.read_text(encoding="utf-8")
    assert "def gcd_int(" in canonical
    assert "def gcd_i64(" in canonical
    assert "def gcd_i64_or_one(" in canonical

    retired_definitions = {
        "src/finite_exact/rat_q.mojo": ["def gcd_i64(", "fn gcd_i64("],
        "src/big_int_boundary.mojo": ["def gcd_i64(", "fn gcd_i64("],
        "src/certificate_sets.mojo": ["def gcd_int(", "fn gcd_int("],
        "src/C1_rational_separator_coding.mojo": ["def gcd_i(", "fn gcd_i("],
    }
    for relative, forbidden_definitions in retired_definitions.items():
        text = (ROOT / relative).read_text(encoding="utf-8")
        for definition in forbidden_definitions:
            assert definition not in text


def test_zero_case_policy_is_explicit_for_rational_normalization():
    rational = (ROOT / "src" / "finite_exact" / "rat_q.mojo").read_text(encoding="utf-8")
    assert "if nn.is_zero():" in rational
    assert "var common = bigz_gcd(nn, dd)" in rational
    assert "bigz_div_exact(nn, common)" in rational
    assert "bigz_div_exact(dd, common)" in rational
