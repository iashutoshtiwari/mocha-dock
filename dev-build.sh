#!/usr/bin/env bash

# Exit on error
set -e

PROJECT_ROOT=$(pwd)
BUILD_DIR="${PROJECT_ROOT}/build"
INSTALL_PREFIX="${PROJECT_ROOT}/local_install"

# Check for ccache to speed up compilation
CMAKE_ARGS=""
if command -v ccache >/dev/null 2>&1; then
    echo "ccache found, enabling compiler cache..."
    CMAKE_ARGS="-DCMAKE_CXX_COMPILER_LAUNCHER=ccache"
fi

echo "Configuring CMake..."
cmake -B "${BUILD_DIR}" -S "${PROJECT_ROOT}" \
    -G Ninja \
    -DCMAKE_BUILD_TYPE=Debug \
    -DCMAKE_INSTALL_PREFIX="${INSTALL_PREFIX}" \
    -DKDE_INSTALL_LIBDIR=lib \
    -DBUILD_TESTING=OFF \
    ${CMAKE_ARGS}

echo "Building and installing to local_install..."
cmake --build "${BUILD_DIR}" --target install

echo "========================================="
echo "Build complete! You can now run the dock without installing it system-wide:"
echo "./run-mocha.sh"
