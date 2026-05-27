#!/usr/bin/env bash
set -e

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NPROC="${NPROC:-$(nproc)}"

cd "$ROOT_DIR"

echo "Configuring and building Components/DBoW2 ..."
cmake -S Components/DBoW2 -B Components/DBoW2/build -DCMAKE_BUILD_TYPE=Release
cmake --build Components/DBoW2/build -j"$NPROC"

echo "Configuring and building Components/g2o ..."
cmake -S Components/g2o -B Components/g2o/build -DCMAKE_BUILD_TYPE=Release
cmake --build Components/g2o/build -j"$NPROC"

echo "Configuring and building Components/Sophus ..."
cmake -S Components/Sophus -B Components/Sophus/build -DCMAKE_BUILD_TYPE=Release
cmake --build Components/Sophus/build -j"$NPROC"

if [ ! -f Thirdparty/Pangolin/CMakeLists.txt ]; then
    echo "Pangolin submodule is missing. Run:"
    echo "  git submodule update --init --recursive Thirdparty/Pangolin"
    exit 1
fi

echo "Configuring, building and installing Thirdparty/Pangolin v0.6 ..."
cmake -S Thirdparty/Pangolin -B Thirdparty/Pangolin-build \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="$ROOT_DIR/Thirdparty/Pangolin-install" \
    -DBUILD_TESTS=OFF \
    -DBUILD_TOOLS=OFF \
    -DBUILD_EXAMPLES=OFF
cmake --build Thirdparty/Pangolin-build -j"$NPROC"
cmake --install Thirdparty/Pangolin-build

echo "Uncompress vocabulary ..."
if [ ! -f Vocabulary/ORBvoc.txt ]; then
    tar -xf Vocabulary/ORBvoc.txt.tar.gz -C Vocabulary
fi

echo "Configuring and building ORB_SLAM3 ..."
cmake -S . -B build \
    -DCMAKE_BUILD_TYPE=Release \
    -DPangolin_DIR="$ROOT_DIR/Thirdparty/Pangolin-install/lib/cmake/Pangolin"
cmake --build build -j"$NPROC"
