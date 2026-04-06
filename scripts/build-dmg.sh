#!/bin/bash
set -euo pipefail

# Build OpenFlow.app and package it as a DMG for distribution.
# Usage: ./scripts/build-dmg.sh [--sign "Developer ID Application: ..."]

APP_NAME="OpenFlow"
SCHEME="OpenFlow"
BUILD_DIR="build"
DMG_NAME="${APP_NAME}.dmg"
ARCHIVE_PATH="${BUILD_DIR}/${APP_NAME}.xcarchive"
EXPORT_PATH="${BUILD_DIR}/export"
APP_PATH="${EXPORT_PATH}/${APP_NAME}.app"
VERSION=$(grep MARKETING_VERSION project.yml | head -1 | awk -F'"' '{print $2}')
DMG_FINAL="${BUILD_DIR}/${APP_NAME}-${VERSION}.dmg"

SIGN_IDENTITY=""
while [[ $# -gt 0 ]]; do
    case $1 in
        --sign)
            SIGN_IDENTITY="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

echo "==> Building ${APP_NAME} v${VERSION}..."

# Clean build directory
rm -rf "${BUILD_DIR}"
mkdir -p "${BUILD_DIR}"

# Archive
echo "==> Archiving..."
xcodebuild archive \
    -project "${APP_NAME}.xcodeproj" \
    -scheme "${SCHEME}" \
    -configuration Release \
    -archivePath "${ARCHIVE_PATH}" \
    -destination 'generic/platform=macOS' \
    CODE_SIGN_IDENTITY="${SIGN_IDENTITY:--}" \
    ENABLE_APP_SANDBOX=NO \
    | tail -3

# Export
echo "==> Exporting app..."
mkdir -p "${EXPORT_PATH}"

if [[ -n "${SIGN_IDENTITY}" ]]; then
    # Export with signing
    cat > "${BUILD_DIR}/export-options.plist" << 'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>developer-id</string>
</dict>
</plist>
PLIST
    xcodebuild -exportArchive \
        -archivePath "${ARCHIVE_PATH}" \
        -exportPath "${EXPORT_PATH}" \
        -exportOptionsPlist "${BUILD_DIR}/export-options.plist" \
        | tail -3
else
    # No signing — just copy from archive
    cp -R "${ARCHIVE_PATH}/Products/Applications/${APP_NAME}.app" "${APP_PATH}"
fi

# Verify app exists
if [[ ! -d "${APP_PATH}" ]]; then
    echo "ERROR: ${APP_PATH} not found"
    exit 1
fi

echo "==> Creating DMG..."

# Create a temporary DMG directory with the app and Applications symlink
DMG_STAGING="${BUILD_DIR}/dmg-staging"
rm -rf "${DMG_STAGING}"
mkdir -p "${DMG_STAGING}"
cp -R "${APP_PATH}" "${DMG_STAGING}/"
ln -s /Applications "${DMG_STAGING}/Applications"

# Create DMG
hdiutil create \
    -volname "${APP_NAME}" \
    -srcfolder "${DMG_STAGING}" \
    -ov \
    -format UDZO \
    "${DMG_FINAL}"

# Cleanup staging
rm -rf "${DMG_STAGING}"

echo ""
echo "==> Done! DMG created at: ${DMG_FINAL}"
echo "    Size: $(du -h "${DMG_FINAL}" | cut -f1)"

# If signed, notarize
if [[ -n "${SIGN_IDENTITY}" ]]; then
    echo ""
    echo "==> To notarize, run:"
    echo "    xcrun notarytool submit ${DMG_FINAL} --apple-id YOUR_APPLE_ID --team-id YOUR_TEAM_ID --password YOUR_APP_SPECIFIC_PASSWORD --wait"
    echo "    xcrun stapler staple ${DMG_FINAL}"
fi
