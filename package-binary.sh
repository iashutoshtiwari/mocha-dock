#!/usr/bin/env bash
set -e

PROJECT_ROOT=$(pwd)
BUILD_DIR="${PROJECT_ROOT}/dist"

echo "Configuring Release Build..."
cmake -B "${BUILD_DIR}" -S "${PROJECT_ROOT}" \
    -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DKDE_INSTALL_LIBDIR=lib

echo "Compiling..."
cmake --build "${BUILD_DIR}"

echo "Generating Binary Tarball via CPack..."
cd "${BUILD_DIR}"
cpack -G TGZ

echo "========================================="
echo "Binary tarball created in the dist directory!"
ls -lh mochadock-*-Linux.tar.gz
