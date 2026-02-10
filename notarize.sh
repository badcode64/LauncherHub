#!/bin/bash
# LauncherHub Notarization Script
# This script signs with Developer ID and notarizes the app with Apple
# 
# SECURITY: Credentials are passed via environment variables, NEVER hardcoded!
# 
# Prerequisites:
# 1. Apple Developer Program ($99/year)
# 2. Developer ID Application certificate installed in Keychain
# 3. App-specific password for notarization
#
# Usage:
#   export APPLE_ID="your-email@example.com"
#   export APPLE_PASSWORD="xxxx-xxxx-xxxx-xxxx"  # App-specific password
#   export TEAM_ID="ABCD123456"
#   export DEVELOPER_ID="Developer ID Application: Your Name (ABCD123456)"
#   ./notarize.sh

set -e  # Exit on error

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🔐 LauncherHub Notarization Script"
echo "================================"

# Check required environment variables
if [ -z "$APPLE_ID" ]; then
    echo -e "${RED}❌ APPLE_ID environment variable not set${NC}"
    echo "Example: export APPLE_ID=\"your-email@example.com\""
    exit 1
fi

if [ -z "$APPLE_PASSWORD" ]; then
    echo -e "${RED}❌ APPLE_PASSWORD environment variable not set${NC}"
    echo "Create app-specific password at: https://appleid.apple.com/account/manage"
    exit 1
fi

if [ -z "$TEAM_ID" ]; then
    echo -e "${RED}❌ TEAM_ID environment variable not set${NC}"
    echo "Find it at: https://developer.apple.com/account"
    exit 1
fi

if [ -z "$DEVELOPER_ID" ]; then
    echo -e "${RED}❌ DEVELOPER_ID environment variable not set${NC}"
    echo "Example: export DEVELOPER_ID=\"Developer ID Application: John Doe (ABCD123456)\""
    echo "List available: security find-identity -v -p codesigning"
    exit 1
fi

# Build app
echo ""
echo "🔨 Building app..."
./build.sh

# Sign with Developer ID
echo ""
echo "🔏 Signing with Developer ID..."
codesign --force --deep \
  --sign "$DEVELOPER_ID" \
  --identifier "hu.webgeneral.LauncherHub" \
  --timestamp \
  --options runtime \
  LauncherHub.app

# Verify signature
echo ""
echo "✅ Verifying signature..."
codesign -vvv --deep --strict LauncherHub.app
echo "(Note: App is signed but not yet notarized - will notarize now)"

# Create zip for notarization
echo ""
echo "📦 Creating notarization zip..."
rm -f LauncherHub-notarize.zip
zip -r LauncherHub-notarize.zip LauncherHub.app -x "*.DS_Store"

# Submit for notarization
echo ""
echo "📤 Submitting to Apple for notarization..."
echo -e "${YELLOW}This may take 5-10 minutes...${NC}"

xcrun notarytool submit LauncherHub-notarize.zip \
  --apple-id "$APPLE_ID" \
  --password "$APPLE_PASSWORD" \
  --team-id "$TEAM_ID" \
  --wait

# Staple the notarization ticket
echo ""
echo "📎 Stapling notarization ticket..."
xcrun stapler staple LauncherHub.app

# Verify notarization
echo ""
echo "✅ Verifying notarization..."
spctl -a -vvv -t install LauncherHub.app

# Create final release files
echo ""
echo "📦 Creating release files..."
VERSION=$(grep -A1 'CFBundleShortVersionString' LauncherHub.app/Contents/Info.plist | grep string | sed 's/.*<string>\(.*\)<\/string>/\1/')

# 1. Create notarized ZIP
RELEASE_ZIP="LauncherHub-v${VERSION}-notarized.zip"
rm -f "$RELEASE_ZIP"
zip -r "$RELEASE_ZIP" LauncherHub.app -x "*.DS_Store"
echo "  ✅ Created: $RELEASE_ZIP"

# 2. Create notarized DMG
echo ""
echo "📦 Creating DMG installer..."
./create-dmg.sh
RELEASE_DMG="LauncherHub-v${VERSION}.dmg"

# Notarize the DMG
echo ""
echo "📤 Submitting DMG to Apple for notarization..."
echo -e "${YELLOW}This may take 5-10 minutes...${NC}"

xcrun notarytool submit "$RELEASE_DMG" \
  --apple-id "$APPLE_ID" \
  --password "$APPLE_PASSWORD" \
  --team-id "$TEAM_ID" \
  --wait

# Staple the DMG
echo ""
echo "📎 Stapling notarization ticket to DMG..."
xcrun stapler staple "$RELEASE_DMG"

# Verify DMG notarization
echo ""
echo "✅ Verifying DMG notarization..."
spctl -a -vvv -t install "$RELEASE_DMG"

# Cleanup temporary zip
rm -f LauncherHub-notarize.zip

echo ""
echo -e "${GREEN}✅ NOTARIZATION COMPLETE!${NC}"
echo ""
echo "📁 Release files:"
echo "   - $RELEASE_ZIP (for quick download)"
echo "   - $RELEASE_DMG (professional installer)"
echo ""
echo "🎉 Both files are now:"
echo "   - Signed with Developer ID"
echo "   - Notarized by Apple"
echo "   - Ready for distribution"
echo "   - No right-click required for users!"
echo ""
echo -e "${YELLOW}⚠️  SECURITY REMINDER:${NC}"
echo "   - Never commit credentials to git!"
echo "   - Store APPLE_PASSWORD securely"
echo "   - Use app-specific passwords only"
