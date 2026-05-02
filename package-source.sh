#!/usr/bin/env bash
set -e

PROJECT_ROOT=$(pwd)
BUILD_DIR="${PROJECT_ROOT}/build"

echo "Generating Source Tarball via CPack..."
cmake -B "${BUILD_DIR}" -S "${PROJECT_ROOT}"

cd "${BUILD_DIR}"
cpack -G TGZ --config CPackSourceConfig.cmake

echo "========================================="
echo "Source tarball created in the build directory!"
ls -lh mochadock-*-Source.tar.gz
