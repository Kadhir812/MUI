"""Local structural checks, not a substitute for Flutter compilation."""
from pathlib import Path
import json
import plistlib
import re
import xml.etree.ElementTree as ET
root = Path(__file__).resolve().parents[1]
checks = 0
for path in root.rglob('*.dart'):
    text = path.read_text()
    for uri in re.findall(r"(?:import|export)\s+'([^']+)'", text):
        if ':' not in uri:
            assert (path.parent / uri).resolve().is_file(), (path, uri)
            checks += 1
for platform in ['ios','android','web']:
    for path in (root / platform).rglob('*'):
        if not path.is_file(): continue
        if path.suffix in ['.xml','.storyboard','.xcworkspacedata','.xcscheme','.xcsettings']:
            ET.parse(path); checks += 1
        if path.suffix == '.plist':
            with path.open('rb') as f: plistlib.load(f)
            checks += 1
        if path.suffix == '.json':
            json.loads(path.read_text()); checks += 1
        if path.suffix != '.png':
            assert '{{' not in path.read_text(), f'Unresolved template: {path}'
print(f'PASS {checks} relative import and native syntax checks')
