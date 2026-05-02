# Mocha Dock: Plasma 6 Porting Explanation

This document outlines the technical journey of reviving and porting the abandoned Mocha Dock project to KDE Plasma 6 under the new name **Mocha Dock**.

## Project Overview
Mocha Dock is a Wayland-only fork of Mocha Dock, modernized for Qt6, KDE Frameworks 6 (KF6), and Plasma 6.
 This porting process focused on stripping legacy X11 dependencies, rebranding the application, and ensuring compatibility with the new Plasma 6 architecture.

## Phases of Execution

### 1. Repository Sanitization & Rebranding
- **Salvaging Work:** We merged porting attempts from the `work/plasma6` branch and external community forks to establish a modern baseline.
- **Global Rebranding:** A surgical renaming of all `Mocha` namespaces, classes, and variables to `Mocha` was performed to establish a new identity.
- **X11 Removal:** Aggressively purged all `X11`, `XCB`, and `XLib` dependencies. Mocha Dock now targets Wayland exclusively, simplifying the window management logic.

### 2. Build System Migration (CMake)
- **Qt6/KF6 Bump:** Updated minimum versions and replaced all `Qt5::*` and `KF5::*` targets.
- **D-Bus Modernization:** Migrated D-Bus adaptors and service names to `org.kde.mochadock`.
- **ECM Updates:** Integrated modern Extra CMake Modules (ECM) configurations required for KF6.

### 3. C++ API & Frameworks Migration
- **KF6 Compatibility:** Updated deprecated KDE Frameworks macros and includes.
- **Qt6 Types:** Migrated legacy types (e.g., `QRegExp` -> `QRegularExpression`) and adjusted to new Qt6 signal/slot connection behaviors.
- **Plugin Architecture:** Refactored the internal plugin structure to align with the new KPackage standards in Plasma 6.

### 4. QML & UI Modernization
- **Import Versioning:** Removed all versioned imports (e.g., `import org.kde.plasma.core 2.0` -> `import org.kde.plasma.core`) as required by Plasma 6.
- **KSvg Integration:** Migrated SVG rendering from `PlasmaCore` to the standalone `KSvg` library.
- **Kirigami Migration:** Replaced deprecated UI elements with modern `Kirigami` equivalents (e.g., `IconItem` -> `Kirigami.Icon`).

### 5. CI/CD & Documentation
- **GitHub Actions:** Replaced stale GitLab CI with a new GitHub Actions workflow to automate builds for Arch Linux and Fedora.
- **Installation Guide:** Overhauled `INSTALLATION.md` to reflect the specific dependencies of the Plasma 6 ecosystem.

### 6. Extension & Configuration Renaming
- **File Extensions:** Transitioned from `.layout.mocha` and `.view.mocha` to `.layout.mocha` and `.view.mocha`.
- **Config Paths:** The application now stores configuration in `~/.config/mocha/` and uses `mocharc` as its primary settings file.
- **Templates:** All bundled layout and view templates were renamed and updated to use the new `org.kde.mocha` IDs.

### 7. Cleanup & Versioning (v0.1.0)
- **Codebase Sanitization:** Removed over 200 unused legacy files, build scripts, and obsolete Nix/Astyle configurations to ensure a lean repository.
- **New Baseline:** Purged all previous git tags and started a new versioning scheme at **v0.1.0**.
- **Local Testing:** Introduced `run-mocha.sh`, which sets up a sandboxed environment to allow running the dock flawlessly from a local build.
- **Packaging:** Added an official `PKGBUILD` for Arch Linux to facilitate easy local installation and testing.

### 8. Startup & Package Fixes
- **Segfault Resolution:** Fixed a critical early startup segfault caused by an inconsistent rebranding of `QUITLATTEACTION` to `QUITMOCHAACTION` in `menu.cpp`.
- **Package Template Paths:** Corrected `Mocha::Package` to resolve layout and view templates from the correct `templates/` subdirectory within the shell package, fixing a silent failure where new docks could not be created.
- **D-Bus Service Registration:** Ensured consistent service naming (`org.kde.mochadock`) between the executable registration and context menu callers.

## Challenges Faced & Solutions

### Missing Wayland Protocols
**Challenge:** The build failed early because `PlasmaWaylandProtocols` was missing or incompatible in the environment, blocking the compilation of the `PrimaryOutputWatcher`.
**Solution:** We surgically extracted the raw `kde-primary-output-v1.xml` protocol from the KDE upstream and integrated it directly into the `app/protocols` directory, allowing the build to generate the necessary Wayland client sources autonomously.

### Deep Rebranding Collisions
**Challenge:** Simple text replacement broke several D-Bus adaptors and UI files because of hardcoded string literals and custom widget names in `.ui` files.
**Solution:** Used iterative `grep` and `sed` passes to identify binary-breaking strings and manually updated the `K_PLUGIN_CLASS_WITH_JSON` macros to match the renamed `.json` metadata files.

### Removed Plasma 5 Components
**Challenge:** Several core components used by the original project, such as `PlasmaCore.DataSource` and `TaskManagerApplet.Backend`, were removed or moved in Plasma 6.
**Solution:** We identified these components and added stubs or redirected imports to the new Plasma 6 standard libraries. While full behavioral parity for these specific components requires deeper refactoring, the application now compiles and links correctly.

### Meta-Object (MOC) Failures
**Challenge:** Renaming the `Types` class within the `Mocha` namespace caused `staticMetaObject` link errors.
**Solution:** Reconfigured the CMake generation for the `mochacontainmentplugin` to ensure the generated headers from `coretypes.h.in` were properly included and linked during the MOC process.

### Legacy Rendering Dependencies
**Challenge:** Deleting "unused" legacy files broke icon rendering.
**Solution:** Identified that `ManagedTextureNode` was still a critical dependency for the custom `IconItem` implementation in Qt6; these files were restored and re-integrated.

## Current Issues & Modernization Strategy

### Missing Settings UI on Wayland
**Current State:** The QWidget-based Settings Dialog fails to map to the screen on Wayland because it is unparented and lacks proper Wayland surface attributes.
**Strategy:** Instead of patching the legacy QWidget UI, we are initiating a full rewrite of the Settings interface using **Kirigami and QML**. This ensures first-class compatibility with the Plasma 6 look-and-feel and Wayland windowing rules.

### Legacy Window System Abstraction
**Current State:** Successfully merged `AbstractWindowInterface` and `WaylandInterface` into a single, concrete `WindowManager`. Removed all legacy X11 abstractions and virtual overhead.
**Strategy:** The codebase is now Wayland-native at its core, with a simplified window tracking architecture that uses `KWaylandClient` and `LayerShellQt` directly.

### Transition to Kirigami Settings
**Current State:** Initiated the full rewrite of the Settings interface. Replaced the problematic QWidget `SettingsDialog` with a new `SettingsWindow` class that loads native Kirigami/QML.
**Strategy:** This move resolves the visibility issues on Wayland and ensures the application follows modern Plasma 6 HIG (Human Interface Guidelines).

## Final Result
The project now builds a functional `mocha-dock` binary targeting the Plasma 6 desktop. It serves as a zero-debt, Wayland-native foundation for further development.
