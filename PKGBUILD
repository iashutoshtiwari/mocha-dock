# Maintainer: Ashutosh Tiwari <contact@ashutoshtiwari.dev>
pkgname=mocha-dock
pkgver=0.1.0
pkgrel=1
pkgdesc="A Wayland-only dock based on Plasma frameworks (Port of Latte Dock to Plasma 6)"
arch=('x86_64' 'aarch64')
url="https://github.com/iashutoshtiwari/mocha-dock"
license=('GPL2')
depends=('qt6-base' 'qt6-declarative' 'qt6-wayland' 'qt6-5compat'
         'kwindowsystem' 'ki18n' 'kconfig' 'kcoreaddons' 'kiconthemes'
         'ksvg' 'kio' 'kdbusaddons' 'knotifications' 'knewstuff'
         'kpackage' 'kcmutils' 'karchive' 'kcrash' 'kglobalaccel'
         'kguiaddons' 'kxmlgui' 'plasma-desktop' 'plasma-workspace'
         'libplasma' 'layer-shell-qt' 'kwayland' 'plasma-activities'
         'wayland' 'plasma-wayland-protocols' 'kirigami')
makedepends=('cmake' 'extra-cmake-modules' 'ninja' 'gettext' 'python')
provides=('mocha-dock')
conflicts=('mocha-dock-git')

build() {
  cmake -B build -S "$startdir" \
    -G Ninja \
    -DCMAKE_BUILD_TYPE=Debug \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DKDE_INSTALL_LIBDIR=lib \
    -DBUILD_TESTING=OFF
  cmake --build build
}

package() {
  DESTDIR="$pkgdir" cmake --install build
}
