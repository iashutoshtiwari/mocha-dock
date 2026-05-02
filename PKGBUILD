# Maintainer: Ashutosh Tiwari <contact@ashutoshtiwari.dev>
pkgname=mocha-dock-git
_pkgname=mocha-dock
pkgver=0.1.0.r0.g$(git rev-parse --short HEAD)
pkgrel=1
pkgdesc="A Wayland-only dock based on Plasma frameworks (Port of Mocha Dock to Plasma 6)"
arch=('x86_64' 'aarch64')
url="https://github.com/iashutoshtiwari/mocha-dock"
license=('GPL2')
depends=('qt6-base' 'qt6-declarative' 'qt6-wayland' 'qt6-5compat' 
         'kwindowsystem' 'ki18n' 'kconfig' 'kcoreaddons' 'kiconthemes' 
         'ksvg' 'kio' 'kdbusaddons' 'knotifications' 'knewstuff' 
         'kpackage' 'kcmutils' 'karchive' 'kcrash' 'kglobalaccel' 
         'kguiaddons' 'kxmlgui' 'plasma-desktop' 'plasma-workspace' 
         'libplasma' 'layer-shell-qt' 'kwayland' 'plasma-activities'
         'wayland' 'plasma-wayland-protocols')
makedepends=('git' 'cmake' 'extra-cmake-modules' 'ninja' 'gettext' 'python')
provides=('mocha-dock')
conflicts=('mocha-dock' 'mocha-dock' 'mocha-dock-git')
source=("git+https://github.com/iashutoshtiwari/mocha-dock.git")
md5sums=('SKIP')

pkgver() {
  cd "$_pkgname"
  ( set -o pipefail
    git describe --long --tags 2>/dev/null | sed 's/^v//;s/\([^-]*-g\)/r\1/;s/-/./g' ||
    printf "0.1.0.r%s.%s" "$(git rev-list --count HEAD)" "$(git rev-parse --short HEAD)"
  )
}

build() {
  cmake -B build -S "$_pkgname" \
    -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DKDE_INSTALL_LIBDIR=lib \
    -DBUILD_TESTING=OFF
  cmake --build build
}

package() {
  DESTDIR="$pkgdir" cmake --install build
}
