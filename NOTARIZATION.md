# Notarization Quick Start Guide

## 🔐 One-Time Setup

### Step 1: Apple Developer Account
1. Join Apple Developer Program: https://developer.apple.com/programs/
2. Cost: $99/year
3. Wait for approval (usually 24-48 hours)

### Step 2: Developer ID Certificate
1. Open **Keychain Access**
2. Menu: **Keychain Access** → **Certificate Assistant** → **Request a Certificate from a Certificate Authority**
3. Fill in your email, name, select "Saved to disk"
4. Save the `.certSigningRequest` file

5. Go to: https://developer.apple.com/account/resources/certificates/add
6. Select **Developer ID Application**
7. Upload your `.certSigningRequest` file
8. Download the certificate
9. Double-click to install in Keychain

### Step 3: App-Specific Password
1. Go to: https://appleid.apple.com/account/manage
2. Sign in with your Apple ID
3. Under **Security** → **App-Specific Passwords** → **Generate Password**
4. Label: "LauncherHub Notarization"
5. Copy the generated password (format: `xxxx-xxxx-xxxx-xxxx`)

### Step 4: Find Your Team ID
1. Go to: https://developer.apple.com/account
2. Click **Membership** in sidebar
3. Copy your **Team ID** (10 characters, e.g., `6V83R77Q59`)

### Step 5: Find Your Developer ID Name
In Terminal:
```bash
security find-identity -v -p codesigning
```

Look for line like:
```
1) ABC123... "Developer ID Application: Your Name (TEAM_ID)"
```

Copy the entire quoted part: `Developer ID Application: Your Name (TEAM_ID)`

## 📝 Configure Credentials

Create `.notarization-credentials.sh` in project root:

```bash
#!/bin/bash
export APPLE_ID="your-email@example.com"
export APPLE_PASSWORD="xxxx-xxxx-xxxx-xxxx"
export TEAM_ID="YOUR_TEAM_ID"
export DEVELOPER_ID="Developer ID Application: Your Name (TEAM_ID)"
```

**IMPORTANT**: This file is git-ignored. Never commit credentials!

## 🚀 Build & Notarize

```bash
# Load credentials
source .notarization-credentials.sh

# Build, sign, and notarize (takes 10-15 minutes)
./notarize.sh
```

This creates:
- `LauncherHub-v1.0.0-notarized.zip` - For GitHub releases
- `LauncherHub-v1.0.0.dmg` - Signed & notarized installer

## ✅ Verify Notarization

```bash
# Check app signature
codesign -vvv --deep --strict LauncherHub.app

# Check notarization
spctl -a -vvv -t install LauncherHub.app

# Should show: "accepted" and "notarized"
```

## 🐛 Troubleshooting

### "No identity found" error
- Certificate not installed in Keychain
- Run: `security find-identity -v -p codesigning`
- If empty, repeat Step 2

### "Invalid credentials" error
- Check APPLE_ID matches your developer account
- Verify app-specific password is correct
- Ensure TEAM_ID is exactly 10 characters

### Notarization rejected
```bash
# Check detailed log
xcrun notarytool log <submission-id> \
  --apple-id "$APPLE_ID" \
  --password "$APPLE_PASSWORD" \
  --team-id "$TEAM_ID"
```

Common issues:
- Missing hardened runtime (`--options runtime` in codesign)
- Invalid entitlements
- Unsigned frameworks

## 📚 Resources

- Apple Developer Portal: https://developer.apple.com
- Notarization Guide: https://developer.apple.com/documentation/security/notarizing_macos_software_before_distribution
- Code Signing: https://developer.apple.com/support/code-signing/

## 💡 Tips

1. **First time takes longer**: 10-15 minutes for notarization
2. **Keep credentials safe**: Never commit `.notarization-credentials.sh`
3. **Test locally first**: Use `./build.sh && ./run.sh` before notarizing
4. **Automate releases**: Create GitHub Actions workflow (advanced)
