#!/usr/bin/env python3
"""Mechanical size/format exports; requires rsvg-convert and Pillow."""
import shutil
import subprocess
from pathlib import Path
from PIL import Image

root = Path(__file__).resolve().parents[2]
branding = root / 'res/branding'

def render(source, target, size):
    subprocess.run(['rsvg-convert', '--width', str(size), '--height', str(size),
                    '--output', str(root / target), str(branding / source)], check=True)

for filename, size in [('icon.png',1024), ('mac-icon.png',1024), ('32x32.png',32),
                       ('64x64.png',64), ('128x128.png',128), ('128x128@2x.png',256)]:
    render('app-icon.svg', 'res/' + filename, size)
render('app-icon.svg', 'flutter/assets/icon.png', 512)
shutil.copyfile(branding / 'app-icon.svg', root / 'res/scalable.svg')
icon = Image.open(root / 'res/icon.png')
for target in ['res/icon.ico', 'res/tray-icon.ico',
               'flutter/windows/runner/resources/app_icon.ico']:
    icon.save(root / target, sizes=[(n,n) for n in (16,24,32,48,64,128,256)])
icon.save(root / 'flutter/macos/Runner/AppIcon.icns')
render('symbol.svg', 'res/mac-tray-dark-x2.png', 60)
for folder in (root / 'flutter/android/app/src/main/res').glob('mipmap-*'):
    for name in ('ic_launcher.png', 'ic_launcher_round.png', 'ic_launcher_foreground.png', 'ic_stat_logo.png'):
        target = folder / name
        if target.is_file():
            size = Image.open(target).width
            render('symbol.svg' if name in ('ic_launcher_foreground.png','ic_stat_logo.png')
                   else 'app-icon.svg', target.relative_to(root), size)
print('Exported desktop, Flutter, macOS and Android application icons.')
