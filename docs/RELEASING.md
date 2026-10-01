# Publishing a release

1. Bump `MARKETING_VERSION` and `CURRENT_PROJECT_VERSION` in `project.yml`.
2. Generate the Xcode project and run the application tests.
3. Run `scripts/release.sh` to build, sign, notarize, package, and update `appcast.xml`.
4. Publish the stable GitHub release with its matching `dist/PrayerTimes-VERSION.zip`.
5. Commit and push `appcast.xml` so Sparkle clients can discover the published ZIP.
6. Synchronize the Homebrew tap with the published release:

   ```sh
   python3 scripts/update-homebrew.py
   ```

The Homebrew command requires Python 3 and an authenticated GitHub CLI (`gh`)
with write access to `lutfullahkabalak/homebrew-tap`. It downloads the actual
published ZIP, calculates SHA-256, compares it with GitHub's digest when available,
and updates only the cask version and checksum. It refuses draft/prerelease
releases and downgrades. An already-current cask produces no commit.

Use `--check` to verify without writing, or `--tag v1.0.2` to select a specific
published release. Check mode exits with status 1 when an update is needed.

Publishing a GitHub release automatically redeploys the website with direct
download links to the latest stable release ZIP. The Pages workflow resolves
these URLs before upload, so no manual website version update is needed. Publish the release asset before making it visible in appcast
or Homebrew; the local build ZIP alone is not sufficient for Homebrew updates.
