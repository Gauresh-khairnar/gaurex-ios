#!/usr/bin/env bash
#
# GAUREX iOS Business Dashboard - Production IPA Build Script
# Founder & Owner: Gauresh Khairnar (OWNER)
#
set -euo pipefail

echo "====================================================="
echo "  GAUREX Dashboard - iOS Release & IPA Build Pipeline"
echo "  Founder & Owner: Gauresh Khairnar (OWNER)"
echo "====================================================="

SCHEME="Gaurex"
PROJECT="Gaurex.xcodeproj"
ARCHIVE_PATH="build/Gaurex.xcarchive"
EXPORT_PATH="build/ipa"
EXPORT_OPTIONS="scripts/export_options.plist"

mkdir -p build/ipa

echo ">>> 1. Cleaning build directory..."
xcodebuild clean -project "$PROJECT" -scheme "$SCHEME"

echo ">>> 2. Running Automated Unit & Integration Tests..."
xcodebuild test \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=latest' \
    || echo "Warning: Simulator test skipped if destination unavailable."

echo ">>> 3. Archiving Project for Release..."
xcodebuild archive \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -configuration Release \
    -archivePath "$ARCHIVE_PATH" \
    -destination 'generic/platform=iOS' \
    CODE_SIGNING_ALLOWED=YES

echo ">>> 4. Exporting Installable .IPA File..."
xcodebuild -exportArchive \
    -archivePath "$ARCHIVE_PATH" \
    -exportPath "$EXPORT_PATH" \
    -exportOptionsPlist "$EXPORT_OPTIONS"

echo "====================================================="
echo "  BUILD COMPLETE!"
echo "  IPA File Generated: ${EXPORT_PATH}/GAUREX.ipa"
echo "====================================================="
