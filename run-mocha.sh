#!/usr/bin/env bash

# Local Execution Script for Mocha Dock
# This script sets up the necessary environment variables to run Mocha Dock from the local_install directory.

PROJECT_ROOT=$(pwd)
INSTALL_PREFIX="${PROJECT_ROOT}/local_install"

if [ ! -d "${INSTALL_PREFIX}" ]; then
    echo "Error: local_install directory not found. Please run 'cmake --build build --target install' first."
    exit 1
fi

# Paths for shared data (metadata.json, desktop files, icons)
export XDG_DATA_DIRS="${INSTALL_PREFIX}/share:${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"

# Paths for C++ plugins
export QT_PLUGIN_PATH="${INSTALL_PREFIX}/lib/plugins:${INSTALL_PREFIX}/lib/qt6/plugins:${QT_PLUGIN_PATH}"

# Paths for QML plugins and components
export QML2_IMPORT_PATH="${INSTALL_PREFIX}/lib/qml:${INSTALL_PREFIX}/lib/qt6/qml:${QML2_IMPORT_PATH}"

# Path for the binary
export PATH="${INSTALL_PREFIX}/bin:${PATH}"

# Force Wayland (since this is a Wayland-only port)
export QT_QPA_PLATFORM=wayland

# Debugging flags
export PLASMA_CORE_DEBUG=1
export QT_LOGGING_RULES="*.debug=true;qt.qml.connections.warning=false"

if [[ "$*" == *"--clear-cache"* ]]; then
    echo "Clearing QML cache..."
    rm -rf ~/.cache/mocha-dock
fi

echo "Environment configured. Launching Mocha Dock in debug mode..."
mocha-dock --debug "$@"
