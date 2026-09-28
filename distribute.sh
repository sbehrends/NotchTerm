#!/usr/bin/env bash
#
# distribute.sh — build, package, and sign a NotchTerm release for auto-update.
#
# Pipeline:  xcodegen → archive (ad-hoc) → extract .app → zip → EdDSA-sign → appcast.xml
#
# No Apple Developer Program / Developer ID / notarization required. The app is
# ad-hoc signed ("-"); update integrity is guaranteed by Sparkle's EdDSA signature
# (private key lives in your login Keychain, public key is baked into Info.plist).
#
# One-time setup already done:
#   • EdDSA key pair generated (private key in Keychain, public key in project.yml).
#   • Sparkle keys present in Info.plist (SUFeedURL / SUPublicEDKey / SU* cadence).
#
# Sparkle decides "is this newer?" by comparing CFBundleVersion (the build number,
# CURRENT_PROJECT_VERSION), NOT the marketing version. Every release must raise it.
#
# Usage:
#   ./distribute.sh                            # versions from project.yml
#   ./distribute.sh --version 0.4 --build 4    # override both
#
set -euo pipefail

# ── Config ─────────────────────────────────────────────────────────────────────

APP_NAME="NotchTerm"
SCHEME="NotchTerm"
PROJECT="${APP_NAME}.xcodeproj"
BUILD_DIR="build"
ARCHIVE_PATH="${BUILD_DIR}/${APP_NAME}.xcarchive"
RELEASES_DIR="releases"          # zips + appcast.xml accumulate here (commit these)

# GitHub repo the appcast download links point at.
REPO_OWNER="sbehrends"
REPO_NAME="NotchTerm"
# All release zips are uploaded as assets of a single, stable GitHub release tag
# ("updates") so the download-URL prefix is constant across versions.
UPDATE_TAG="updates"
DOWNLOAD_URL_PREFIX="https://github.com/${REPO_OWNER}/${REPO_NAME}/releases/download/${UPDATE_TAG}/"

# ── Version ──────────────────────────────────────────────────────────────────

VERSION=""
BUILD=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --version) VERSION="$2"; shift 2 ;;
        --build) BUILD="$2"; shift 2 ;;
        *) echo "Unknown argument: $1"; exit 1 ;;
    esac
done

if [[ -z "$VERSION" ]]; then
    # Match only the setting assignment (MARKETING_VERSION: "x.y"), not the
    # CFBundleShortVersionString: $(MARKETING_VERSION) reference in the info block.
    VERSION=$(grep -E '^[[:space:]]*MARKETING_VERSION:[[:space:]]*"' project.yml | head -1 | awk -F'"' '{print $2}')
fi

if [[ -z "$BUILD" ]]; then
    BUILD=$(grep -E '^[[:space:]]*CURRENT_PROJECT_VERSION:[[:space:]]*"' project.yml | head -1 | awk -F'"' '{print $2}')
fi

if [[ -z "$VERSION" || -z "$BUILD" ]]; then
    echo "✗ Could not determine version/build from project.yml (MARKETING_VERSION / CURRENT_PROJECT_VERSION)."
    exit 1
fi

# Refuse to ship a build number that is not above the newest one in the feed:
# existing installs would silently never see it.
if [[ -f appcast.xml ]]; then
    LATEST_BUILD=$(grep -oE '<sparkle:version>[0-9]+</sparkle:version>' appcast.xml \
        | grep -oE '[0-9]+' | sort -n | tail -1)
    if [[ -n "$LATEST_BUILD" && "$BUILD" -le "$LATEST_BUILD" ]]; then
        echo "✗ Build number ${BUILD} is not greater than the latest in appcast.xml (${LATEST_BUILD})."
        echo "  Bump CURRENT_PROJECT_VERSION in project.yml (or pass --build)."
        exit 1
    fi
fi

echo "┌──────────────────────────────────────────┐"
echo "│  ${APP_NAME}  v${VERSION} (build ${BUILD})  (ad-hoc + Sparkle)"
echo "└──────────────────────────────────────────┘"

# ── Locate Sparkle tools (resolved SPM artifacts) ───────────────────────────────

SPARKLE_BIN=$(find ~/Library/Developer/Xcode/DerivedData \
    -path "*artifacts/sparkle/Sparkle/bin" -type d 2>/dev/null | head -1)

if [[ -z "${SPARKLE_BIN}" || ! -x "${SPARKLE_BIN}/generate_appcast" ]]; then
    echo "✗ Sparkle tools not found. Run once to resolve packages:"
    echo "    xcodebuild -project ${PROJECT} -scheme ${SCHEME} -resolvePackageDependencies"
    exit 1
fi
echo "  Sparkle tools: ${SPARKLE_BIN}"

# ── 1. Generate project ─────────────────────────────────────────────────────────

echo ""
echo "→ Generating Xcode project..."
xcodegen generate --quiet

# ── 2. Archive (Release, ad-hoc signed) ─────────────────────────────────────────

echo "→ Archiving (Release, ad-hoc)..."
rm -rf "${ARCHIVE_PATH}"
xcodebuild archive \
    -project "${PROJECT}" \
    -scheme "${SCHEME}" \
    -configuration Release \
    -archivePath "${ARCHIVE_PATH}" \
    -destination "generic/platform=macOS" \
    -skipPackagePluginValidation \
    MARKETING_VERSION="${VERSION}" \
    CURRENT_PROJECT_VERSION="${BUILD}" \
    CODE_SIGN_STYLE=Manual \
    CODE_SIGN_IDENTITY="-" \
    | grep -E "^(Archive|error:|\*\* |Build succeeded)" || true

APP_PATH="${ARCHIVE_PATH}/Products/Applications/${APP_NAME}.app"
if [[ ! -d "${APP_PATH}" ]]; then
    echo "✗ Archive failed — ${APP_PATH} not found"
    exit 1
fi

# ── 3. Zip (Sparkle-compatible: ditto, keeps bundle + resource forks) ───────────

echo "→ Zipping..."
mkdir -p "${RELEASES_DIR}"
ZIP_PATH="${RELEASES_DIR}/${APP_NAME}-${VERSION}.zip"
rm -f "${ZIP_PATH}"
ditto -c -k --sequesterRsrc --keepParent "${APP_PATH}" "${ZIP_PATH}"
echo "  ${ZIP_PATH} ($(du -sh "${ZIP_PATH}" | awk '{print $1}'))"

# ── 4. Generate + EdDSA-sign appcast ────────────────────────────────────────────
#
# generate_appcast reads the private key from the Keychain, computes the EdDSA
# signature for every zip in ${RELEASES_DIR}, reads each app's version from its
# Info.plist, and writes/updates ${RELEASES_DIR}/appcast.xml.

echo "→ Generating appcast..."
"${SPARKLE_BIN}/generate_appcast" \
    --download-url-prefix "${DOWNLOAD_URL_PREFIX}" \
    "${RELEASES_DIR}"

echo ""
echo "✓ Built and signed:"
echo "    ${ZIP_PATH}"
echo "    ${RELEASES_DIR}/appcast.xml"
echo ""
echo "── Publish (with the GitHub CLI) ───────────────────────────────────────────"
echo ""
echo "  # 1. Upload the zip as an asset of the stable '${UPDATE_TAG}' release:"
echo "  gh release create ${UPDATE_TAG} --title 'Updates' --notes 'Auto-update assets' 2>/dev/null || true"
echo "  gh release upload ${UPDATE_TAG} '${ZIP_PATH}' --clobber"
echo ""
echo "  # 2. Commit the appcast so SUFeedURL (raw main) serves the new version:"
echo "  cp '${RELEASES_DIR}/appcast.xml' appcast.xml"
echo "  git add appcast.xml && git commit -m 'Release v${VERSION}' && git push"
echo ""
echo "  Also create a normal, human-facing GitHub Release (tag v${VERSION}) with the"
echo "  same zip if you want a changelog page — Sparkle only needs the two steps above."
