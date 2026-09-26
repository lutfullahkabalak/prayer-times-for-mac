#!/bin/bash
set -euo pipefail

# Builds, Developer ID signs, notarizes and staples a release zip.
# Requires a "Developer ID Application" certificate in the keychain and a
# notarytool credential profile (default name below, override with NOTARY_PROFILE).

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
NOTARY_PROFILE="${NOTARY_PROFILE:-prayertimes-notary}"
DERIVED="$ROOT/build/release"
APP="$DERIVED/Build/Products/Release/PrayerTimes.app"

cd "$ROOT"

IDENTITY="$(security find-identity -v -p codesigning \
  | sed -n 's/.*"\(Developer ID Application: .*\)"/\1/p' | head -1)"
if [ -z "$IDENTITY" ]; then
  echo "No 'Developer ID Application' certificate found in the keychain." >&2
  echo "Create one in Xcode > Settings > Accounts > Manage Certificates." >&2
  exit 1
fi
TEAM_ID="$(echo "$IDENTITY" | sed -n 's/.*(\([A-Z0-9]*\))$/\1/p')"
echo "Signing with: $IDENTITY"

resign_sparkle() {
  local app="$1"
  local identity="$2"
  local fw="$app/Contents/Frameworks/Sparkle.framework"
  local current="$fw/Versions/Current"
  if [ ! -d "$current" ]; then
    echo "Sparkle.framework is missing from the app." >&2
    exit 1
  fi

  local entitlements
  entitlements="$(mktemp)"
  codesign -d --entitlements :- "$app" > "$entitlements"

  codesign -f -s "$identity" -o runtime --timestamp "$current/XPCServices/Installer.xpc"
  if [ -d "$current/XPCServices/Downloader.xpc" ]; then
    codesign -f -s "$identity" -o runtime --timestamp --preserve-metadata=entitlements \
      "$current/XPCServices/Downloader.xpc"
  fi
  codesign -f -s "$identity" -o runtime --timestamp "$current/Autoupdate"
  codesign -f -s "$identity" -o runtime --timestamp "$current/Updater.app"
  codesign -f -s "$identity" -o runtime --timestamp "$fw"
  codesign -f -s "$identity" -o runtime --timestamp --entitlements "$entitlements" "$app"
  rm -f "$entitlements"
}

update_appcast() {
  local app="$1"
  local zip="$2"
  local version="$3"
  local tools="$ROOT/build/sparkle-tools"
  local sparkle_version="2.10.0"
  if [ ! -x "$tools/bin/sign_update" ]; then
    mkdir -p "$tools"
    curl -fsSL -o "$tools/Sparkle.tar.xz" \
      "https://github.com/sparkle-project/Sparkle/releases/download/${sparkle_version}/Sparkle-${sparkle_version}.tar.xz"
    tar -xf "$tools/Sparkle.tar.xz" -C "$tools"
  fi

  local signed build pubdate
  signed="$("$tools/bin/sign_update" "$zip")"
  build="$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "$app/Contents/Info.plist")"
  pubdate="$(date -u +"%a, %d %b %Y %H:%M:%S +0000")"
  python3 - "$ROOT/appcast.xml" "$version" "$build" "$pubdate" "$signed" <<'PY'
import sys
path, version, build, pubdate, signed = sys.argv[1:]
signature = signed.split('edSignature="', 1)[1].split('"', 1)[0]
length = signed.split('length="', 1)[1].split('"', 1)[0]
url = (
    "https://github.com/lutfullahkabalak/prayer-times-for-mac/releases/download/"
    f"v{version}/PrayerTimes-{version}.zip"
)
notes = f"https://github.com/lutfullahkabalak/prayer-times-for-mac/releases/tag/v{version}"
xml = f"""<?xml version="1.0" encoding="utf-8"?>
<rss version="2.0" xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle" xmlns:dc="http://purl.org/dc/elements/1.1/">
  <channel>
    <title>Prayer Times</title>
    <link>https://github.com/lutfullahkabalak/prayer-times-for-mac</link>
    <description>Prayer Times updates</description>
    <language>en</language>
    <item>
      <title>Version {version}</title>
      <sparkle:version>{build}</sparkle:version>
      <sparkle:shortVersionString>{version}</sparkle:shortVersionString>
      <sparkle:minimumSystemVersion>14.0</sparkle:minimumSystemVersion>
      <sparkle:releaseNotesLink>{notes}</sparkle:releaseNotesLink>
      <pubDate>{pubdate}</pubDate>
      <enclosure
        url="{url}"
        length="{length}"
        type="application/octet-stream"
        sparkle:edSignature="{signature}" />
    </item>
  </channel>
</rss>
"""
with open(path, "w", encoding="utf-8") as handle:
    handle.write(xml)
PY
}

rm -rf "$DERIVED"
xcodebuild -scheme PrayerTimes \
  -configuration Release \
  -destination 'generic/platform=macOS' \
  -derivedDataPath "$DERIVED" \
  ARCHS="arm64 x86_64" \
  ONLY_ACTIVE_ARCH=NO \
  CODE_SIGN_STYLE=Manual \
  CODE_SIGN_IDENTITY="$IDENTITY" \
  DEVELOPMENT_TEAM="$TEAM_ID" \
  ENABLE_HARDENED_RUNTIME=YES \
  CODE_SIGN_INJECT_BASE_ENTITLEMENTS=NO \
  OTHER_CODE_SIGN_FLAGS="--timestamp" \
  build

# The build action injects com.apple.security.get-task-allow, which notarization rejects,
# hence CODE_SIGN_INJECT_BASE_ENTITLEMENTS=NO above.
if codesign -d --entitlements - --xml "$APP" 2>/dev/null | grep -q "get-task-allow"; then
  echo "Signed app still carries get-task-allow; notarization would fail." >&2
  exit 1
fi

# Xcode's build action re-signs Sparkle.framework but leaves its XPC services and
# helper tools ad-hoc. Notarization needs those signed inside-out, then the app again.
resign_sparkle "$APP" "$IDENTITY"

codesign --verify --deep --strict --verbose=2 "$APP"

VERSION="$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "$APP/Contents/Info.plist")"
ZIP="$ROOT/dist/PrayerTimes-$VERSION.zip"
mkdir -p "$ROOT/dist"

# notarytool needs a zip; --sequesterRsrc is omitted so no __MACOSX folder is added.
rm -f "$ZIP"
ditto -c -k --keepParent "$APP" "$ZIP"

LOG="$(xcrun notarytool submit "$ZIP" --keychain-profile "$NOTARY_PROFILE" --wait 2>&1)"
echo "$LOG"
if ! echo "$LOG" | grep -q "status: Accepted"; then
  echo "Notarization failed. Inspect it with:" >&2
  echo "  xcrun notarytool log <submission-id> --keychain-profile $NOTARY_PROFILE" >&2
  exit 1
fi

xcrun stapler staple "$APP"

# Re-package so the shipped zip carries the stapled ticket.
rm -f "$ZIP"
ditto -c -k --keepParent "$APP" "$ZIP"

update_appcast "$APP" "$ZIP" "$VERSION"

echo
spctl -a -vvv -t exec "$APP"
shasum -a 256 "$ZIP"
echo "Release ready: $ZIP"
echo "appcast.xml was updated. Commit and push it so clients can see this release."
