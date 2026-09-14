from pathlib import Path
import sys


ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))

from source_tokens import mask_comments_and_strings


def test_mask_preserves_code_and_line_numbers():
    source = 'fn degree(p: Poly) -> Int:\n    return p.degree # angle and sin\n'
    masked = mask_comments_and_strings(source)
    assert "fn degree" in masked
    assert "return p.degree" in masked
    assert "angle" not in masked
    assert masked.count("\n") == source.count("\n")


def test_mask_removes_single_and_multiline_string_literals():
    source = 'var label = "sin degrees"\n"""polar angle\nunit circle"""\ncos(x)\n'
    masked = mask_comments_and_strings(source)
    assert "sin" not in masked
    assert "degrees" not in masked
    assert "polar angle" not in masked
    assert "unit circle" not in masked
    assert "cos(x)" in masked
    assert masked.count("\n") == source.count("\n")


def test_mask_handles_escaped_quotes():
    source = 'var label = "not \\"cos\\" code"\ntan(x)\n'
    masked = mask_comments_and_strings(source)
    assert "cos" not in masked
    assert "tan(x)" in masked
