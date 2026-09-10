from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / "docs" / "terminology-use-manifest.md"
LINTER = ROOT / "tools" / "audit_terminology.py"


def text(path):
    return path.read_text(encoding="utf-8")


def test_manifest_has_required_control_sections():
    body = text(MANIFEST)
    for section in [
        "## Registered project terms currently allowed",
        "## Terms requiring local declaration outside C1 files",
        "## Terms requiring theorem-tag status",
        "## High-risk bridge phrases",
        "## Circle/rank-2 ban",
    ]:
        assert section in body


def test_manifest_scopes_c1_terms():
    body = text(MANIFEST)
    for term in [
        "finite rational-ray nest",
        "persistent non-separation",
        "persistent wake ambiguity",
        "wake ambiguity",
        "catalogue extensionality",
        "side-assignment witness",
        "separator code",
    ]:
        assert term in body
    assert "docs/C1_" in body
    assert "src/C1_" in body
    assert "tests/test_C1_" in body


def test_linter_reads_manifest_and_scoped_terms():
    body = text(LINTER)
    assert "USE_MANIFEST" in body
    assert "audit_use_manifest" in body
    assert "audit_c1_scoped_terms" in body
    assert "C1_SCOPED_TERMS" in body
    assert "C1_SCOPED_PREFIXES" in body


def test_manifest_preserves_rank2_circle_ban():
    body = text(MANIFEST)
    assert "circle" in body
    assert "not valid rank-2 objects" in body
    assert "quadrance" in body
    assert "polynomial constraint" in body
