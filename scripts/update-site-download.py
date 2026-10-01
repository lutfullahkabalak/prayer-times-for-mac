#!/usr/bin/env python3
"""Resolve the latest stable release ZIP before publishing the static site."""
import json
from pathlib import Path
import re
import subprocess

REPO = "lutfullahkabalak/prayer-times-for-mac"


def download_url(release):
    match = re.fullmatch(r"v(\d+\.\d+\.\d+)", release["tagName"])
    if not match:
        raise ValueError("Expected a stable release tag such as v1.0.2")
    version = match[1]
    name = f"PrayerTimes-{version}.zip"
    assets = [a for a in release["assets"] if a["name"] == name and a["state"] == "uploaded"]
    expected = f"https://github.com/{REPO}/releases/download/v{version}/{name}"
    if len(assets) != 1 or assets[0]["url"] != expected:
        raise ValueError(f"Published release must contain {name} at the expected URL")
    return expected


def replace_links(html, url):
    pattern = re.escape(f"https://github.com/{REPO}/releases/") + (
        r'(?:latest|download/v\d+\.\d+\.\d+/PrayerTimes-\d+\.\d+\.\d+\.zip)(?=["\s<])'
    )
    updated, count = re.subn(pattern, lambda _: url, html)
    if count != 5:
        raise ValueError(f"Expected 3 download links and 2 schema URLs; found {count}")
    return updated


def main():
    result = subprocess.run(
        ["gh", "release", "view", "--repo", REPO, "--json", "tagName,assets"],
        capture_output=True, text=True, check=True,
    )
    url = download_url(json.loads(result.stdout))
    path = Path(__file__).resolve().parents[1] / "docs/index.html"
    updated = replace_links(path.read_text(), url)
    path.write_text(updated)
    print(f"Site download links: {url}")


if __name__ == "__main__":
    main()
