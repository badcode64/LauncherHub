# 📋 LauncherHub - Quick Reference

## 🚀 Gyors Parancsok

### Fejlesztés
```bash
./build.sh              # Fordítás
./run.sh                # Futtatás
```

### Distribúció
```bash
./create-dmg.sh         # DMG készítése (unsigned)
./sign.sh              # Csak aláírás (notarize nélkül)
./notarize.sh          # Teljes: sign + notarize + DMG
```

### Git & GitHub
```bash
# Setup
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/USERNAME/LauncherHub.git
git push -u origin main

# Release
git tag -a v1.0.0 -m "Version 1.0.0"
git push origin v1.0.0
```

## 📁 Fájlok Áttekintése

### Core App
- `LauncherHub.swift` - Fő alkalmazás logika (602 sor)
- `Resources/main.html` - Főablak UI (dark theme, compact)
- `Resources/dialog.html` - Add/Edit dialog UI

### Build Scripts
- `build.sh` - Swift fordítás → .app bundle
- `run.sh` - Alkalmazás futtatása
- `create-dmg.sh` - DMG installer készítése
- `sign.sh` - Code signing (gyors, lokális teszt)
- `notarize.sh` - Teljes notarization flow (~15 perc)

### Credentials (GIT-IGNORED!)
- `.notarization-credentials.sh` - Apple Developer credentials
  - **SOHA ne commitold!**
  - Már a .gitignore-ban van

### Documentation
- `README.md` - Projekt leírás, features, install
- `CHANGELOG.md` - Verzió történet
- `GITHUB.md` - GitHub publikálási útmutató (🇭🇺)
- `NOTARIZATION.md` - Notarization lépésről lépésre
- `LICENSE` - MIT License

### Config
- `.gitignore` - Credentials, build outputs kizárása
- `Info.plist` - App metadata (verzió, bundle ID)

## 🎯 Jelenlegi Állapot

### ✅ Kész Funkciók
- 6 link típus (App, VS Code, Finder, Chrome, Terminal, Shell)
- Drag & drop groups
- Drag & drop links (csoporton belül és között)
- Smart path memory (utolsó mappa típusonként)
- Dark theme
- Ultra compact UI (180px groups)
- 220+ icons, 12 colors
- UserDefaults persistence
- DMG installer

### 📦 Build Info
- Compiled size: ~113KB DMG
- macOS 12.0+ (Monterey)
- Native Swift + WebKit
- No dependencies

## 🔐 Notarization Flow

```
1. build.sh           → LauncherHub.app
2. codesign           → Signed .app
3. zip                → LauncherHub-notarize.zip
4. notarytool submit  → Apple servers (5-10 min)
5. stapler            → Notarization ticket attached
6. create-dmg.sh      → LauncherHub-v1.0.0.dmg
7. notarytool DMG     → DMG notarized (5-10 min)
8. stapler DMG        → Final notarized DMG
```

**Total time**: ~15-20 minutes

## 📤 GitHub Publikálás

### 1. Repository Setup
```bash
# GitHub.com → New repository → LauncherHub
git remote add origin https://github.com/USERNAME/LauncherHub.git
git push -u origin main
```

### 2. Release készítése
```bash
# Build notarized files
source .notarization-credentials.sh
./notarize.sh

# Tag és push
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0

# GitHub releases → Upload DMG
```

### 3. Repository beállítások
- Topics: `macos`, `swift`, `launcher`, `menu-bar`, `productivity`
- About: Description + website
- Enable: Issues, Discussions
- Social preview: Screenshot upload

## 🐛 Troubleshooting

### Build Error
```bash
# Check Swift compiler
swiftc --version

# Check Xcode CLI tools
xcode-select --install
```

### Signature Error
```bash
# List available identities
security find-identity -v -p codesigning

# Verify app signature
codesign -vvv --deep --strict LauncherHub.app
```

### Notarization Failed
```bash
# Check detailed log
xcrun notarytool log <submission-id> \
  --apple-id "$APPLE_ID" \
  --password "$APPLE_PASSWORD" \
  --team-id "$TEAM_ID"
```

### Git Issues
```bash
# Check status
git status

# Check remote
git remote -v

# Unstage file
git reset HEAD filename
```

## 🎨 Customization

### UI Changes
1. Edit `Resources/main.html` vagy `Resources/dialog.html`
2. Run `./build.sh`
3. Run `./run.sh` to test

### Swift Changes
1. Edit `LauncherHub.swift`
2. Run `./build.sh`
3. Run `./run.sh` to test

### Color Scheme
`Resources/main.html` → CSS section:
- Background: `#1a1d23` → `#2d3748`
- Groups: `#2d3748`
- Headers: `#1a202c`

## 📊 Stats

- **Lines of Code**: ~1400 total
  - Swift: 602 lines
  - HTML/CSS/JS (main): 322 lines
  - HTML/CSS/JS (dialog): 670 lines
- **Files**: 15 total
- **Size**: 113KB DMG
- **Dependencies**: 0 (pure Swift + WebKit)

## 🎓 Next Steps

1. ✅ Build and test locally
2. ✅ Create .gitignore (done)
3. ✅ Update README (done)
4. ⬜ Add screenshots
5. ⬜ Push to GitHub
6. ⬜ Create first release
7. ⬜ Sign & notarize (optional)
8. ⬜ Share on Reddit, HN

## 💡 Tips

- **Test before notarize**: Build → Run → Test thoroughly
- **Keep credentials safe**: Never commit `.notarization-credentials.sh`
- **Version bumps**: Update in `create-dmg.sh` (VERSION variable)
- **Quick rebuild**: `./build.sh && ./run.sh`
- **Clean build**: `rm -rf LauncherHub.app && ./build.sh`

---

Created: 2026-02-10
Version: 1.0.0
