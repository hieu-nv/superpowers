#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
MANIFEST="$REPO_ROOT/plugin.json"

python3 - "$MANIFEST" "$REPO_ROOT" <<'PY'
import json
import sys
from pathlib import Path

manifest_path = Path(sys.argv[1])
repo_root = Path(sys.argv[2])

if not manifest_path.is_file():
    raise AssertionError(f"Antigravity plugin manifest missing at {manifest_path}")

manifest = json.loads(manifest_path.read_text(encoding="utf-8"))

def assert_equal(actual, expected, label):
    if actual != expected:
        raise AssertionError(f"{label}: expected {expected!r}, got {actual!r}")

assert_equal(manifest.get("name"), "superpowers", "plugin name")

package_json = json.loads((repo_root / "package.json").read_text(encoding="utf-8"))
expected_version = package_json.get("version", "6.3.0")
assert_equal(manifest.get("version"), expected_version, "plugin version")

version_config = json.loads(
    (repo_root / ".version-bump.json").read_text(encoding="utf-8")
)
version_entries = version_config.get("files", [])
if not any(
    entry.get("path") == "plugin.json" and entry.get("field") == "version"
    for entry in version_entries
    if isinstance(entry, dict)
):
    raise AssertionError(".version-bump.json must track plugin.json version field")

print("Antigravity plugin manifest schema and version-bump checks passed")
PY

if command -v agy >/dev/null 2>&1; then
    output=$(agy plugin validate "$REPO_ROOT")
    echo "$output"
    if ! echo "$output" | grep -q "17 processed"; then
        echo "FAIL: Expected 17 skills processed by agy plugin validate" >&2
        exit 1
    fi
fi
