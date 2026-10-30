#!/usr/bin/env python3
"""Finish native SDK-generated files without overwriting application code.
Run locally after installing Flutter: python tool/bootstrap.py
"""
from pathlib import Path
import os
import shutil
import subprocess
import tempfile

root = Path(__file__).resolve().parents[1]
flutter = shutil.which('flutter')
if not flutter:
    raise SystemExit('Flutter was not found. Install Flutter 3.35.7 or a compatible stable version and add its bin directory to PATH.')

def run(args, cwd):
    subprocess.run([flutter, *args], cwd=cwd, check=True, shell=os.name == 'nt')

# Flutter generates wrapper binaries and SDK-specific metadata on your machine.
# Only missing platform files are copied. Existing app code and icons are preserved.
with tempfile.TemporaryDirectory(prefix='still_bootstrap_') as temp:
    project = Path(temp) / 'still_finance'
    run(['create', '--platforms=ios,android,web', '--org=com.kadhir',
         '--project-name=still_finance', '--no-pub', str(project)], temp)
    for platform in ['ios', 'android', 'web']:
        source = project / platform
        for path in source.rglob('*'):
            if not path.is_file():
                continue
            target = root / platform / path.relative_to(source)
            if not target.exists():
                target.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(path, target)
    for name in ['.metadata']:
        if (project / name).exists() and not (root / name).exists():
            shutil.copy2(project / name, root / name)
run(['pub', 'get'], root)
print('Ready. Run flutter analyze, flutter test, then flutter run -d <device-id>.')
