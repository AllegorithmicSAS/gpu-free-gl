#!/bin/bash
set -e
mkdir -p build
mkdir -p build/llvm
mkdir -p build/mesa
mkdir -p build/glu
mkdir -p build/xorg
mkdir -p build/glproto


export PREFIX=$(pwd)/install
export PATH=$PATH:$(pwd)/install/bin
export LD_LIBRARY_PATH=$(pwd)/install/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}
export C_INCLUDE_PATH=$(pwd)/install/include:$(pwd)/install/include/libdrm${C_INCLUDE_PATH:+:$C_INCLUDE_PATH}
export CPLUS_INCLUDE_PATH=$(pwd)/install/include:$(pwd)/install/include/libdrm${CPLUS_INCLUDE_PATH:+:$CPLUS_INCLUDE_PATH}
export PKG_CONFIG_PATH=$(pwd)/install/lib/pkgconfig:$(pwd)/install/share/pkgconfig${PKG_CONFIG_PATH:+:$PKG_CONFIG_PATH}
export ACLOCAL="aclocal -I $(pwd)/install/share/aclocal"

# Build llvm
cd build/llvm
cmake ../../src/llvm -DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=1 -DLLVM_ENABLE_RTTI=1 -DLLVM_TARGETS_TO_BUILD="X86\;AMDGPU"
make install -j2

# Build an initial set of xorg libraries
cd ../xorg
../../src/xorgbuild/build.sh --clone -o util/macros
../../src/xorgbuild/build.sh --clone -o font/util
../../src/xorgbuild/build.sh --clone -o lib/libxtrans
../../src/xorgbuild/build.sh --clone -o xcb/proto
../../src/xorgbuild/build.sh --clone -o proto/xorgproto
../../src/xorgbuild/build.sh --clone -o lib/libXau
../../src/xorgbuild/build.sh --clone -o xcb/pthread-stubs
../../src/xorgbuild/build.sh --clone -o xcb/libxcb
../../src/xorgbuild/build.sh --clone -o xcb/util-keysyms
../../src/xorgbuild/build.sh --clone -o lib/libX11
../../src/xorgbuild/build.sh --clone -o lib/libXext
../../src/xorgbuild/build.sh --clone -o lib/libXfixes
../../src/xorgbuild/build.sh --clone -o lib/libXdamage
../../src/xorgbuild/build.sh --clone -o lib/libxshmfence
../../src/xorgbuild/build.sh --clone -o lib/libXrender
../../src/xorgbuild/build.sh --clone -o lib/libXrandr
../../src/xorgbuild/build.sh --clone -o pixman
../../src/xorgbuild/build.sh --clone -o lib/libpciaccess
../../src/xorgbuild/build.sh --clone -o lib/libxkbfile
../../src/xorgbuild/build.sh --clone -o lib/libfontenc
../../src/xorgbuild/build.sh --clone -o lib/libXfont
../../src/xorgbuild/build.sh --clone -o mesa/drm
../../src/xorgbuild/build.sh --clone -o mesa/mesa

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

# Build more xorg libraries
cd ../xorg
../../src/xorgbuild/build.sh --clone -o app/xkbcomp
../../src/xorgbuild/build.sh --clone -o font/util
../../src/xorgbuild/build.sh --clone --confflags "--disable-dri --disable-dri2 --disable-dri3 --disable-glamor --with-xkb-bin-directory=\"\"" -o xserver
../../src/xorgbuild/build.sh --clone -o driver/xf86-video-dummy
../../src/xorgbuild/build.sh --clone -o lib/libxkbfile
../../src/xorgbuild/build.sh --clone -o driver/xf86-input-void
../../src/xorgbuild/build.sh --clone -o driver/xf86-input-keyboard
../../src/xorgbuild/build.sh --clone -o xkeyboard-config
../../src/xorgbuild/build.sh --clone -o xcb/xcb-proto
../../src/xorgbuild/build.sh --clone -o lib/libXi
