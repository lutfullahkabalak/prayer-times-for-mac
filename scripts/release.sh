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

echo
spctl -a -vvv -t exec "$APP"
shasum -a 256 "$ZIP"
echo "Release ready: $ZIP"
