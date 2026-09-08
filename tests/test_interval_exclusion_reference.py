from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]


def test_interval_exclusion_reference_passes():
    result = subprocess.run(
        [sys.executable, str(ROOT / "tools" / "interval_exclusion_reference.py")],
        cwd=ROOT,
        text=True,
        capture_output=True,
        check=False,
    )
    assert result.returncode == 0, result.stdout + result.stderr
    assert "c=-2: 5/5" in result.stdout
    assert "M_4,1: 18/18" in result.stdout


def test_interval_oracle_uses_fraction_not_float():
    text = (ROOT / "tools" / "interval_exclusion_reference.py").read_text()
    assert "from fractions import Fraction" in text
    assert "float(" not in text
    assert "math." not in text


def test_same_box_language_present():
    text = (ROOT / "tools" / "interval_exclusion_reference.py").read_text()
    assert "same-box" in text
    assert "forbidden collision" in text
