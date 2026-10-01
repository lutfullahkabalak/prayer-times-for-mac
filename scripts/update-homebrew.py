#!/usr/bin/env python3
"""Verify a published release and synchronize the developer's Homebrew cask."""
import argparse
import base64
import hashlib
import json
import re
import subprocess
import urllib.request

APP_REPO = "lutfullahkabalak/prayer-times-for-mac"
TAP_REPO = "lutfullahkabalak/homebrew-tap"
CASK_PATH = "Casks/prayer-times.rb"


def gh(*args, payload=None):
    result = subprocess.run(
        ["gh", *args],
        input=json.dumps(payload) if payload is not None else None,
        text=True, capture_output=True, check=True,
    )
    return json.loads(result.stdout)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--tag", help="Published tag; defaults to the latest stable release")
    parser.add_argument("--check", action="store_true", help="Verify without updating GitHub")
    args = parser.parse_args()
    endpoint = f"repos/{APP_REPO}/releases/" + (
        f"tags/{args.tag}" if args.tag else "latest"
    )
    release = gh("api", endpoint)
    if release["draft"] or release["prerelease"]:
        raise ValueError("Only published stable releases can update this cask")
    match = re.fullmatch(r"v(\d+\.\d+\.\d+)", release["tag_name"])
    if not match:
        raise ValueError("Expected a stable release tag such as v1.0.2")
    version = match[1]
    name = f"PrayerTimes-{version}.zip"
    assets = [a for a in release["assets"] if a["name"] == name]
    if len(assets) != 1:
        raise ValueError(f"Expected exactly one release asset named {name}")
    asset = assets[0]
    expected_url = f"https://github.com/{APP_REPO}/releases/download/v{version}/{name}"
    if asset["browser_download_url"] != expected_url:
        raise ValueError("Release asset URL does not match the cask URL template")
    checksum = hashlib.sha256()
    with urllib.request.urlopen(expected_url, timeout=60) as response:
        while chunk := response.read(1024 * 1024):
            checksum.update(chunk)
    digest = checksum.hexdigest()
    published_digest = asset.get("digest")
    if published_digest and published_digest != f"sha256:{digest}":
        raise ValueError("Downloaded ZIP does not match GitHub's published digest")
    endpoint = f"repos/{TAP_REPO}/contents/{CASK_PATH}"
    existing = gh("api", endpoint + "?ref=main")
    source = base64.b64decode(existing["content"]).decode()
    old_version = re.search(r'^  version "(\d+\.\d+\.\d+)"$', source, re.M)
    if not old_version:
        raise ValueError("Cannot identify the cask version")
    if tuple(map(int, version.split('.'))) < tuple(map(int, old_version[1].split('.'))):
        raise ValueError("Refusing to downgrade the cask")
    updated, versions = re.subn(r'^  version "[^"]+"$', f'  version "{version}"', source, flags=re.M)
    updated, hashes = re.subn(r'^  sha256 "[0-9a-f]{64}"$', f'  sha256 "{digest}"', updated, flags=re.M)
    if versions != 1 or hashes != 1:
        raise ValueError("Expected exactly one version and one SHA-256 stanza")
    if updated == source:
        print(f"Homebrew cask is current: {version}; published ZIP checksum verified.")
        return
    if args.check:
        print(f"Homebrew cask needs updating to {version}; SHA-256: {digest}")
        raise SystemExit(1)
    gh("api", "--method", "PUT", endpoint, "--input", "-", payload={
        "message": f"Update Prayer Times to {version}",
        "content": base64.b64encode(updated.encode()).decode(),
        "sha": existing["sha"], "branch": "main",
    })
    print(f"Updated {TAP_REPO} to {version}; published ZIP checksum verified.")


if __name__ == "__main__":
    main()
