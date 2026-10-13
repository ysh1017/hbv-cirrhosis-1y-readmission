"""Read-only SHA-256 check for the public manuscript snapshot. Python 3 stdlib."""
import hashlib
import json
from pathlib import Path

root = Path(__file__).resolve().parents[1]
manifest = json.loads((root / '6_release' / 'FILE_SHA256.json').read_text(encoding='utf-8'))
failures = []
for item in manifest['files']:
    path = (root / item['path']).resolve()
    if not path.is_relative_to(root) or not path.is_file():
        failures.append((item['path'], 'missing or unsafe path'))
        continue
    digest = hashlib.sha256(path.read_bytes()).hexdigest()
    if digest != item['sha256'] or path.stat().st_size != item['bytes']:
        failures.append((item['path'], 'content mismatch'))
print(json.dumps({'files_checked': len(manifest['files']), 'failures': failures,
                  'status': 'PASS' if not failures else 'FAIL'}, ensure_ascii=False, indent=2))
raise SystemExit(1 if failures else 0)
