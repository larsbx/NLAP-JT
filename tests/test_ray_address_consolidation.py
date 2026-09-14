from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_ray_address_value_types_are_centralized():
    canonical = (ROOT / "src" / "ray_address.mojo").read_text(encoding="utf-8")
    assert "struct RayAddr(" in canonical
    assert "struct RayAddr64(" in canonical
    for relative in [
        "src/separation_grammar.mojo",
        "src/C1_separator_codes.mojo",
        "src/C1_rational_separator_coding.mojo",
        "src/rational_trig.mojo",
    ]:
        text = (ROOT / relative).read_text(encoding="utf-8")
        assert "struct RayAddrFinite" not in text
        assert "struct RayAddrCode" not in text
        assert "struct RayAddr:" not in text


def test_ray_address_metadata_record_remains_distinct():
    metadata = (ROOT / "src" / "misiurewicz_certificate.mojo").read_text(encoding="utf-8")
    assert "struct RayAddressDatum" in metadata
    assert "var preperiod: Int" in metadata
    assert "var ray_period: Int" in metadata
