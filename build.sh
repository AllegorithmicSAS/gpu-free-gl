#!/bin/bash
set -e
mkdir -p build
mkdir -p build/llvm
mkdir -p build/mesa
mkdir -p build/glu
mkdir -p build/xorg
mkdir -p build/glproto
mkdir -p build/libexpat

export PREFIX=$(pwd)/install
export PATH=$PATH:$(pwd)/install/bin
export LD_LIBRARY_PATH=$(pwd)/install/lib:$(pwd)/install/lib64${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}
export C_INCLUDE_PATH=$(pwd)/install/include:$(pwd)/install/include/libdrm${C_INCLUDE_PATH:+:$C_INCLUDE_PATH}
export CPLUS_INCLUDE_PATH=$(pwd)/install/include:$(pwd)/install/include/libdrm${CPLUS_INCLUDE_PATH:+:$CPLUS_INCLUDE_PATH}
export PKG_CONFIG_PATH=$(pwd)/install/lib/pkgconfig:$(pwd)/install/share/pkgconfig:$(pwd)/install/lib64/pkgconfig${PKG_CONFIG_PATH:+:$PKG_CONFIG_PATH}

# Build llvm
cd build/llvm
cmake ../../src/llvm -DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=1 -DLLVM_ENABLE_RTTI=1 -DLLVM_TARGETS_TO_BUILD="X86\;AMDGPU"
make install -j2

cd ../libexpat
cmake ../../src/libexpat/expat -DCMAKE_INSTALL_PREFIX=$PREFIX
make install -j2

# Build an initial set of xorg libraries
cd ../xorg
../../src/xorgbuild/build.sh --clone -o mesa/drm

# Build gl proto
cd ../glproto
../../src/glproto/autogen.sh
../../src/glproto/configure --prefix=$PREFIX
make install -j2

# Build the mesa cpu driver
cd ../mesa
../../src/mesa/autogen.sh
../../src/mesa/configure --enable-glx=gallium-xlib --disable-dri --disable-egl --disable-gbm --with-gallium-drivers=swrast,swr --with-platforms=x11 --prefix=$PREFIX
make -j2 install

# Build glu
cd ../glu
../../src/glu/autogen.sh
../../src/glu/configure --prefix=$PREFIX
make install -j2


