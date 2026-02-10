#!/bin/bash
# Quick Sign Script (without notarization)
# For local testing and development

set -e

echo "🔏 Signing LauncherHub.app..."

# Check if credentials are loaded
if [ -z "$DEVELOPER_ID" ]; then
    echo "Loading credentials from .notarization-credentials.sh..."
    source .notarization-credentials.sh
fi

# Build first
./build.sh

# Sign the app
codesign --force --deep \
  --sign "$DEVELOPER_ID" \
  --identifier "hu.webgeneral.LauncherHub" \
  --timestamp \
  --options runtime \
  LauncherHub.app

# Verify
echo ""
echo "✅ Verifying signature..."
codesign -vvv --deep --strict LauncherHub.app

echo ""
echo "✅ App signed successfully!"
echo ""
echo "⚠️  Note: App is signed but NOT notarized."
echo "   For distribution, run: ./notarize.sh"
echo ""
echo "To test locally:"
echo "   ./run.sh"
