# 📦 GitHub Publikálási Útmutató

## 🎯 Lépésről Lépésre

### 1️⃣ Git Repository Inicializálása

```bash
cd /Volumes/MUNKA/MUNKA/MACAPPS/BC64AppStart

# Git init (ha még nincs)
git init

# Nézd meg mi van a .gitignore-ban (credentials kizárva!)
cat .gitignore

# Add hozzá a fájlokat
git add .

# Első commit
git commit -m "Initial commit: LauncherHub v1.0.0

Features:
- Application launcher with 6 link types
- Drag & drop groups and links
- Dark theme with compact UI
- Smart path memory
- 220+ icons, 12 colors
- Native Swift, only 113KB"
```

### 2️⃣ GitHub Repository Létrehozása

1. **Nyisd meg**: https://github.com/new

2. **Töltsd ki**:
   - Repository name: `LauncherHub`
   - Description: `🚀 Lightweight menu bar launcher for macOS - Quick access to apps, folders, and commands`
   - **Public** (open source)
   - **NE** add hozzá a README, .gitignore, license (már megvan)

3. **Kattints**: "Create repository"

### 3️⃣ Push GitHub-ra

```bash
# Add remote (helyettesítsd a YOUR_USERNAME-t!)
git remote add origin https://github.com/YOUR_USERNAME/LauncherHub.git

# Ellenőrizd
git remote -v

# Push
git branch -M main
git push -u origin main
```

### 4️⃣ Repository Beállítások

#### About Section
1. Menj a repo főoldalára
2. Kattints a ⚙️ (Settings) gombra az "About" résznél
3. Töltsd ki:
   - **Description**: `Lightweight menu bar launcher for macOS`
   - **Website**: `https://github.com/YOUR_USERNAME/LauncherHub`
   - **Topics**: Add hozzá:
     - `macos`
     - `swift`
     - `webkit`
     - `launcher`
     - `menu-bar`
     - `menu-bar-app`
     - `productivity`
     - `shortcuts`
     - `quick-launcher`

#### Repository Settings
Menj: Settings (felső menü)

**General**:
- ✅ Issues
- ✅ Discussions (optional)
- ❌ Wiki (ha nem kell)
- ❌ Projects (ha nem kell)

**Features**:
- ✅ "Preserve this repository" (GitHub Archive Program)

### 5️⃣ Release Készítése

```bash
# 1. Build és notarize (opcionális, de ajánlott)
source .notarization-credentials.sh
./notarize.sh

# Vagy csak sign (gyorsabb)
source .notarization-credentials.sh
./sign.sh

# Vagy csak build (unsigned)
./build.sh
./create-dmg.sh
```

**GitHub Release létrehozása**:

1. Menj: https://github.com/YOUR_USERNAME/LauncherHub/releases/new

2. **Tag**: `v1.0.0`
   - Kattints "Choose a tag" → írj be: `v1.0.0`
   - Kattints "Create new tag: v1.0.0 on publish"

3. **Release title**: `LauncherHub v1.0.0 🚀`

4. **Description**:
```markdown
# LauncherHub v1.0.0

First public release! 🎉

## ✨ Features

- **6 Link Types**: Apps, VS Code, Finder, Chrome, Terminal, Shell
- **Drag & Drop**: Reorder links and move between groups
- **Smart Memory**: Remembers last used folders per type
- **Dark Theme**: Modern, eye-friendly interface
- **Ultra Compact**: 180px wide groups, optimized spacing
- **220+ Icons** & **12 Colors**
- **Native Swift**: Only 113KB DMG, no Electron!

## 📥 Installation

1. Download `LauncherHub-1.0.0.dmg`
2. Open the DMG
3. Drag LauncherHub to Applications
4. Launch from Applications
5. **First time**: Right-click → Open → Open

## 📋 Requirements

- macOS 12.0 (Monterey) or later

## 🐛 Known Issues

None reported yet!

## 📝 Changelog

See [CHANGELOG.md](https://github.com/YOUR_USERNAME/LauncherHub/blob/main/CHANGELOG.md)
```

5. **Upload Files**:
   - Húzd ide: `LauncherHub-1.0.0.dmg`
   - (Ha notarizáltad): `LauncherHub-v1.0.0-notarized.zip`

6. **Set as latest release**: ✅

7. **Kattints**: "Publish release"

### 6️⃣ Screenshot Készítése (Ajánlott)

```bash
# Indítsd el az appot
./run.sh

# Készíts egy szép screenshotot:
# - Cmd+Shift+4, aztán Space → kattints az ablakra
# - Vagy: Cmd+Shift+5 → Capture Selected Window

# Mentsd el: screenshot.png (1280x640 ideális)
```

**Upload screenshot GitHub-ra**:

1. Create `images` folder a repo-ban:
```bash
mkdir -p images
# Másold be a screenshot-ot
cp ~/Desktop/screenshot.png images/
git add images/
git commit -m "Add screenshot"
git push
```

2. Frissítsd a README.md-t:
```markdown
## 📸 Screenshots

![LauncherHub Screenshot](images/screenshot.png)
```

### 7️⃣ Social Preview Image

1. Menj: **Settings** → **Options**
2. Görgess le: **Social preview**
3. Upload image (1280x640px)
   - Használd a screenshot-ot, vagy
   - Készíts egy banner-t Canva-ban, Figma-ban

### 8️⃣ Clone és Test

```bash
# Test: klónozd le máshova
cd ~/Desktop
git clone https://github.com/YOUR_USERNAME/LauncherHub.git
cd LauncherHub

# Build & run
./build.sh
./run.sh

# Ha minden OK, törölheted
cd ..
rm -rf LauncherHub
```

## ✅ Checklist

Minden kész?

- [ ] Repository létrehozva GitHub-on
- [ ] Code pusholva
- [ ] .gitignore működik (credentials nem kerültek fel!)
- [ ] README.md friss és informatív
- [ ] LICENSE file megvan (MIT)
- [ ] CHANGELOG.md naprakész
- [ ] Topics hozzáadva a repo-hoz
- [ ] About section kitöltve
- [ ] v1.0.0 release publikálva
- [ ] DMG file feltöltve a release-hez
- [ ] Screenshot hozzáadva
- [ ] Social preview image beállítva
- [ ] Test: clone & build működik

## 🎉 Következő Lépések

### Marketing
- [ ] Post on Reddit: r/macapps, r/MacOS
- [ ] Post on Hacker News: https://news.ycombinator.com/submit
- [ ] Tweet about it
- [ ] Add to macOS app directories

### Development
- [ ] Setup GitHub Actions for CI/CD
- [ ] Add issue templates
- [ ] Add pull request template
- [ ] Create CONTRIBUTING.md
- [ ] Add badges to README (build status, downloads)

### Documentation
- [ ] Add more screenshots
- [ ] Create demo GIF/video
- [ ] Write detailed usage guide
- [ ] Add FAQ section

## 📞 Support

Ha elakadtál:
- GitHub Docs: https://docs.github.com
- Git Guide: https://rogerdudler.github.io/git-guide/
- Stack Overflow: https://stackoverflow.com

## 🎓 Git Quick Reference

```bash
# Status
git status

# Változások
git add .
git commit -m "message"
git push

# Tag (új release)
git tag -a v1.0.1 -m "Version 1.0.1"
git push origin v1.0.1

# Undo last commit (ha még nem pusholtad)
git reset --soft HEAD~1

# Pull latest
git pull origin main
```
