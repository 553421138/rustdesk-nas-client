#!/usr/bin/env python3
"""Set the visible bundle name while retaining upgrade, launch, and config identities."""
import json
import os
import plistlib
import sys
from pathlib import Path

app = Path(sys.argv[1])
name = os.environ["RUSTDESK_NAS_DISPLAY_NAME"]
if os.environ.get("RUSTDESK_NAS_EDITION") == "customer":
    name += "（顾客版）"
plist_path = app / "Contents/Info.plist"
with plist_path.open("rb") as stream:
    metadata = plistlib.load(stream)
# Finder requires the unlocalized value to match the on-disk bundle name.
metadata["CFBundleDisplayName"] = app.stem
with plist_path.open("wb") as stream:
    plistlib.dump(metadata, stream)
for locale in ("en", "zh-Hans", "zh-Hant"):
    directory = app / "Contents/Resources" / (locale + ".lproj")
    directory.mkdir(parents=True, exist_ok=True)
    content = "".join(
        json.dumps(key) + " = " + json.dumps(name, ensure_ascii=False) + ";\n"
        for key in ("CFBundleDisplayName", "CFBundleName")
    )
    (directory / "InfoPlist.strings").write_text(content, encoding="utf-8")
print(json.dumps({"bundle": app.name, "display_name": name}, ensure_ascii=False))
