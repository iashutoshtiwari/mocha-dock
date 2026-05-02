Installation
============

## Dependencies

Before compiling, you must install the dependencies for Qt6, KF6, and Plasma 6.

### Arch Linux

```bash
sudo pacman -Syu
sudo pacman -S cmake extra-cmake-modules python \
    qt6-base qt6-declarative qt6-wayland qt6-5compat \
    plasma-wayland-protocols libplasma plasma-desktop \
    kf6-kwindowsystem kf6-ki18n kf6-kconfig kf6-kcoreaddons \
    kf6-kiconthemes kf6-ksvg kf6-kio kf6-kdbusaddons \
    kf6-knotifications kf6-knewstuff kf6-kpackage kf6-kcmutils \
    wayland-protocols
```

### Fedora

```bash
sudo dnf install cmake extra-cmake-modules \
    qt6-qtbase-devel qt6-qtdeclarative-devel qt6-qtwayland-devel qt6-qt5compat-devel \
    kf6-kwindowsystem-devel kf6-ki18n-devel kf6-kconfig-devel kf6-kcoreaddons-devel \
    kf6-kiconthemes-devel kf6-ksvg-devel kf6-kio-devel kf6-kdbusaddons-devel \
    kf6-knotifications-devel kf6-knewstuff-devel kf6-kpackage-devel \
    libplasma-devel plasma-wayland-protocols
```

### Ubuntu (24.04+)

```bash
sudo apt install cmake extra-cmake-modules \
    qt6-base-dev qt6-declarative-dev qt6-wayland-dev qt6-5compat-dev \
    libkf6windowsystem-dev libkf6i18n-dev libkf6config-dev libkf6coreaddons-dev \
    libkf6iconthemes-dev libkf6svg-dev libkf6io-dev libkf6dbusaddons-dev \
    libkf6notifications-dev libkf6newstuff-dev libkf6package-dev \
    libplasma-dev plasma-wayland-protocols
```

## Building and Installing

```bash
cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=RelWithDebInfo
cmake --build build
sudo cmake --install build
```

## Local Testing (without install)

You can run Mocha Dock locally within a Wayland session:

```bash
export QML2_IMPORT_PATH=$PWD/build/bin:$QML2_IMPORT_PATH
QT_QPA_PLATFORM=wayland ./build/bin/mocha-dock --debug
```
