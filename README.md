# ModernQtBrowser

ModernQtBrowser is a native desktop web browser written in C++17 using the Qt 6 framework. It combines the Chromium rendering engine with native desktop widgets to deliver a fast, privacy-focused browsing experience that integrates directly with the host operating system and KDE Plasma themes.

This project was vibecoded by Gemini Argon.

---

## Architecture and Engine

### Rendering Engine
ModernQtBrowser is built on **Qt WebEngine** (`QtWebEngineCore` and `QtWebEngineWidgets`), which embeds the **Chromium** browser platform (the Blink layout engine and the V8 JavaScript engine) into native Qt C++ classes. Process isolation, sandboxing, GPU-accelerated rendering, and network socket management are handled through Chromium's multi-process `QtWebEngineProcess` architecture.

### Core Implementation Details
* **Native System and KDE Plasma Theme Integration**: Instead of hardcoding custom QSS stylesheets, the browser uses the native system `QStyle` and `QPalette`. Under KDE Plasma, it automatically adopts the Breeze widget style and `QIcon::fromTheme()` Freedesktop icon specifications. The main window listens for `QEvent::PaletteChange` and `QEvent::ApplicationPaletteChange` events to synchronize Chromium's `prefers-color-scheme` media query with the active desktop light or dark color scheme in real time.
* **Network-Level Ad and Tracker Blocker**: Subclasses `QWebEngineUrlRequestInterceptor` (`AdBlockInterceptor`) to inspect every HTTP and HTTPS request on Chromium's network IO thread before dispatch. It aborts HTML5 `<a ping>` click-tracking requests, appends `DNT: 1` and `Sec-GPC: 1` privacy headers, and checks request hostnames in O(1) time against a `QSet<QString>` hash table protected by a `QReadWriteLock`.
* **Automated EasyList Synchronization**: Uses `QNetworkAccessManager` to download and parse EasyList filter rules into `QStandardPaths::AppDataLocation`. The local cache (`easylist_cache.txt`) is loaded immediately at startup and refreshed automatically in the background when the file is older than 24 hours.
* **Cosmetic DOM Filtering**: Injects a `QWebEngineScript` (`CosmeticAdBlock`) at `DocumentReady` across main frames and subframes to hide empty ad containers and placeholder iframes via CSS selectors.
* **Omnibox Auto-Completion**: Attaches a `QCompleter` backed by a `QStandardItemModel` (`Qt::MatchContains` and `Qt::CaseInsensitive`) to the address bar, providing live dropdown suggestions from saved bookmarks and browsing history.
* **Multi-Tab Management**: Subclasses `QWebEngineView` and overrides `createWindow()` so `target="_blank"` links and JavaScript pop-ups open in new tabs. The `QTabBar` includes a custom context menu for pinning tabs, muting tab audio (`QWebEnginePage::setAudioMuted`), duplicating tabs, and closing multiple tabs.

---

## Features

* Multi-tab interface with movable tabs, pinned tabs, and automatic speaker/mute status icons
* Smart Omnibox with automatic URL detection, DuckDuckGo search routing, and history/bookmark auto-completion
* Network-level ad and tracker blocker with one-click shield toggle and EasyList auto-updates
* Private browsing windows backed by isolated, off-the-record `QWebEngineProfile` instances in memory
* Dockable Library sidebar (`Ctrl+H`) with searchable history, bookmarks, and a download manager with progress bars
* Split-screen Chromium Developer Tools inspector (`F12`)
* In-page text finder (`Ctrl+F`)

---

## Project Structure

```text
ModernQtBrowser/
├── build.sh                        # Automated project generator and interactive build script
└── ModernQtBrowser/                # Generated source directory
    ├── CMakeLists.txt              # CMake build, deployment, and CPack/NSIS configuration
    ├── main.cpp                    # Complete browser and ad-blocker implementation
    ├── packaging/
    │   ├── LICENSE.txt             # MIT License file for NSIS installer
    │   ├── icon.png                # 256x256 application icon
    │   └── modernqtbrowser.desktop # Linux Freedesktop launcher specification
    └── build/                      # Compilation and packaging output directory
```

---

## Keyboard Shortcuts

| Shortcut | Action |
| :--- | :--- |
| `Ctrl + T` | Open a new tab |
| `Ctrl + W` | Close the current tab (unpinned tabs only) |
| `Ctrl + L` | Focus and highlight the Omnibox address bar |
| `Ctrl + D` | Bookmark the active page |
| `Ctrl + H` | Toggle the Library sidebar (History, Bookmarks, Downloads) |
| `Ctrl + M` | Mute or unmute audio on the active tab |
| `Ctrl + F` | Open the Find-in-Page bar |
| `F12` | Toggle the Chromium Developer Tools inspector |
| `Ctrl + +` / `Ctrl + -` | Zoom in or zoom out |
| `Ctrl + 0` | Reset page zoom to 100% |

---

## Building and Installing on Linux

### 1. Install Build Dependencies

**Ubuntu / Debian:**
```bash
sudo apt update
sudo apt install -y build-essential cmake ninja-build wget file imagemagick \
                    qt6-base-dev qt6-webengine-dev qmake6 breeze-icon-theme
```

**Fedora:**
```bash
sudo dnf install -y gcc-c++ cmake ninja-build wget file ImageMagick \
                    qt6-qtbase-devel qt6-qtwebengine-devel breeze-icon-theme
```

**Arch Linux:**
```bash
sudo pacman -Sy --needed base-devel cmake ninja wget file imagemagick \
                         qt6-base qt6-webengine breeze-icons
```

### 2. Build Using the Automated Script
Make `build.sh` executable and launch the interactive builder:
```bash
chmod +x build.sh
./build.sh
```
* Select **Option 2** to install missing Linux dependencies automatically.
* Select **Option 3** to generate the project files and compile the native release binary at `ModernQtBrowser/build/ModernQtBrowser`.
* Select **Option 6** to launch the compiled browser.

### 3. Manual CMake Build
If you have already generated the `ModernQtBrowser` directory and want to compile manually:
```bash
cd ModernQtBrowser
mkdir -p build && cd build
cmake -G Ninja -DCMAKE_BUILD_TYPE=Release ..
cmake --build . --parallel
./ModernQtBrowser
```

---

## Creating a Portable Linux AppImage

### 1. Generate the AppImage
To bundle the browser, its Qt 6 WebEngine libraries, `QtWebEngineProcess`, and resource packs into a single portable `.AppImage` file:

* **Via `build.sh`**: Run `./build.sh` and select **Option 4 (Build Portable Linux .AppImage)**.
* **Manually**:
  ```bash
  cd ModernQtBrowser
  mkdir -p build && cd build
  cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr ..
  cmake --build . --parallel
  DESTDIR=AppDir cmake --install .

  wget -c [https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage](https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage)
  wget -c [https://github.com/linuxdeploy/linuxdeploy-plugin-qt/releases/download/continuous/linuxdeploy-plugin-qt-x86_64.AppImage](https://github.com/linuxdeploy/linuxdeploy-plugin-qt/releases/download/continuous/linuxdeploy-plugin-qt-x86_64.AppImage)
  chmod +x linuxdeploy-x86_64.AppImage linuxdeploy-plugin-qt-x86_64.AppImage

  export QMAKE=$(command -v qmake6 || command -v qmake)
  ./linuxdeploy-x86_64.AppImage --appdir AppDir --plugin qt --output appimage
  ```
  The packaged binary will be output as `ModernQtBrowser/build/ModernQtBrowser-x86_64.AppImage`.

### 2. Integrating the AppImage into the Desktop Menu with Gear Lever
Portable `.AppImage` files do not automatically register themselves in your desktop environment's application launcher. Using the **Gear Lever** Flatpak application (`it.mijorus.gearlever`) is recommended to integrate the AppImage into your KDE Plasma or Linux application menu:

1. Install Gear Lever from Flathub:
   ```bash
   flatpak install flathub it.mijorus.gearlever
   ```
2. Launch Gear Lever and drag `ModernQtBrowser-x86_64.AppImage` into its window, or integrate it directly from the terminal:
   ```bash
   flatpak run it.mijorus.gearlever --integrate ModernQtBrowser/build/ModernQtBrowser-x86_64.AppImage
   ```
3. Click **Move to the app menu** inside Gear Lever. It will move the AppImage into your managed AppImage folder, extract the embedded `.desktop` entry and icon, and add ModernQtBrowser to your system application launcher.

---

## Creating the Windows Executable (.exe) and Installer

Because Chromium and `QtWebEngine` on Windows require the **Microsoft Visual C++ (MSVC)** compiler and Windows SDK (MinGW is not supported by upstream Chromium), you can create the Windows `.exe` and NSIS installer from a Linux machine using any of the three approaches below.

### Method 1: Automated Cloud Build via GitHub Actions (Recommended on Linux)
You can build the 64-bit Windows `.exe` and NSIS setup wizard directly from a Linux machine without installing Windows locally by pushing the generated `ModernQtBrowser` folder to GitHub and adding `.github/workflows/windows-release.yml`:

```yaml
name: Build Windows Executable

on:
  push:
    branches: [ main ]
  workflow_dispatch:

jobs:
  build-windows:
    runs-on: windows-latest
    steps:
      - name: Checkout Source
        uses: actions/checkout@v4

      - name: Install Qt 6 with QtWebEngine
        uses: jurplel/install-qt-action@v4
        with:
          version: '6.8.0'
          arch: 'win64_msvc2022_64'
          modules: 'qtwebengine qtpositioning qtwebchannel'

      - name: Configure and Build Release Binary
        run: |
          mkdir build
          cd build
          cmake .. -DCMAKE_BUILD_TYPE=Release
          cmake --build . --config Release --parallel

      - name: Package Windows NSIS Installer and Portable ZIP
        run: |
          cd build
          cpack -G "NSIS;ZIP" -C Release

      - name: Upload Compiled Windows Artifacts
        uses: actions/upload-artifact@v4
        with:
          name: ModernQtBrowser-Windows-x64
          path: |
            build/ModernQtBrowser-*.exe
            build/ModernQtBrowser-*.zip
```

### Method 2: Cross-Compiling Locally on Linux Using `msvc-wine` and `aqtinstall`
If you want to compile the Windows `.exe` locally on your Linux machine without a virtual machine:

1. Install `aqtinstall` and download the official Windows Qt 6 MSVC libraries onto your Linux host:
   ```bash
   pip install aqtinstall
   aqt install-qt windows desktop 6.8.0 win64_msvc2022_64 -m qtwebengine qtpositioning qtwebchannel -O ~/QtWin
   ```
2. Install Wine, `msitools`, and `nsis` from your Linux package manager, then download the MSVC compiler and Windows SDK using [msvc-wine](https://github.com/mstorsjo/msvc-wine):
   ```bash
   git clone [https://github.com/mstorsjo/msvc-wine.git](https://github.com/mstorsjo/msvc-wine.git)
   cd msvc-wine
   ./vsdownload.py --dest ~/my_msvc/opt/msvc
   ./install.sh ~/my_msvc/opt/msvc
   ```
3. Add `~/my_msvc/opt/msvc/bin/x64` to your `PATH` and run CMake targeting Windows:
   ```bash
   export PATH=~/my_msvc/opt/msvc/bin/x64:$PATH
   cd ModernQtBrowser
   mkdir build-win && cd build-win
   CC=cl CXX=cl cmake -G Ninja .. \
     -DCMAKE_BUILD_TYPE=Release \
     -DCMAKE_SYSTEM_NAME=Windows \
     -DCMAKE_PREFIX_PATH="$HOME/QtWin/6.8.0/msvc2022_64"
   cmake --build . --parallel
   cpack -G "NSIS;ZIP" -C Release
   ```

### Method 3: Building on a Native Windows Host or Windows VM
1. Install **Visual Studio 2022** (with the **Desktop development with C++** workload), **Qt 6 (MSVC 2022 64-bit + Qt WebEngine)**, and **NSIS**.
2. Open **Git Bash** from an **x64 Native Tools Command Prompt for VS 2022**.
3. Run `./build.sh` and select **Option 5 (Build Windows .exe + NSIS Installer)**.
4. The script compiles `ModernQtBrowser.exe`, runs `windeployqt.exe` to bundle the required Qt DLLs and `QtWebEngineProcess.exe`, and executes `cpack` to generate `ModernQtBrowser-1.0.0-win64.exe`.

---

## Runtime Storage Locations

* **Linux EasyList Cache**: `~/.local/share/ModernQtBrowser/easylist_cache.txt`
* **Linux History and Bookmarks**: `~/.config/ModernQt/BrowserData.conf`
* **Windows EasyList Cache**: `%LOCALAPPDATA%\ModernQtBrowser\easylist_cache.txt`
* **Windows History and Bookmarks**: `HKEY_CURRENT_USER\Software\ModernQt\BrowserData`

---

## License

This project is released under the MIT License. See `packaging/LICENSE.txt` for full license terms.
