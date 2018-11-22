# gpu-free-gl

## Overview
This project provides build scripts for creating a set of tools and libraries that makes sbsbaker 
run properly on a linux machine without a GPU using no custom sbsbaker executable.
Essentially it builds a small version of xorg and a mesa with a cpu driver and a configuration 
for running xorg in offscreen mode.
It checks out all needed modules from git and builds them for you. It's not completely dependency 
free and it might need some external dependencies to build cleanly, the main focus is on the xorg 
and mesa.

## Libraries
* LLVM: Needed for mesa with high performant CPU support
* Xorg: Xserver needed for sbsbaker to start properly
* mesa: OpenGL libraries

## Building
* Clone the repository and initialize and update submodules

```
git clone git@gitlab.allegorithmic.com:davidallego/gpu-free-gl.git
git submodule init
git submodule update
```

When all the data has been synced, make sure you set up the correct build environment for compatible libraries. 
In centos the setup of choices is devtoolset-7. The project has also been
successfully built using clang.
```
scl enable devtoolset-7 bash
```

Finally, you are ready to run the scripts
```
./build.sh
```

This will take a while since there are quite a lot of libraries to build
In the event something goes wrong, typically because of missing tools and packages, be ready to 
install them. When starting from a minimal centos installation here are some packages needed 
(this is not exhaustive since it's hard to know what is already on the system)
* zlib-devel
* elfutils-devel
* freetype-devel
* fontconfig-devel
* libgcrypt-devel
* libepoxy-devel

## Running
When done running the script you have a set of binaries and libraries in the install directory
Before running substance you need to set up some paths. In the examples below the directory where you cloned the repo into is referred to as <ROOT>
```
export PATH=<ROOT>/install/bin:$PATH
export LD_LIBRARY_PATH=<ROOT>/install/install:$LD_LIBRARY_PATH
```

Next you need to start the xserver
```
cd scripts
./start.sh &
export DISPLAY=:200
```

Finally you are ready to bake maps with sbsrender
If having a linux installation of the substance automation toolkit, go to the root of its installation and run
```
./sbsrender ambient-occlusion-from-mesh samples/Meshes/Grenade_low.FBS --highdef-mesh samples/Meshes/Grenade_high.FBX
```
If you get some nasty warnings about keyboard settings, please set this environment variable to hide them
```
export QT_XKB_CONFIG_ROOT=<ROOT>/install/share/X11/xkb
```
You can also experiment with different drivers for mesa:
```
export GALLIUM_DRIVER=llvmpipe # This is most likely what you want to use
export GALLIUM_DRIVER=swr # This one is supposed to be faster than llvm pipe but it doesn't seem to give correct results
export GALLIUM_DRIVER=softpipe # This is the old mesa driver. It's supposedly very compatible but extremely slow
```

## What if you prefer to install packages rather than build them
If you already have have xorg installed and just want to build the gpu driver, the main concern 
is making sure you have a working software rendering gl driver. The part of the build script that
does this is the following:
```
../../src/mesa/autogen.sh
../../src/mesa/configure --enable-glx=gallium-xlib --disable-dri --disable-egl --disable-gbm --with-gallium-drivers=swrast,swr --with-platforms=x11 --prefix=$(pwd)/../../install
make install
```
Make sure you are careful with the prefix so you don't overwrite your old libraries and use 
LD_LIBRARY_PATH to have these libraries chosen before the out of the box libraries. This process
is also dependent on LLVM so install or build it before building mesa. 

The process is described in detail here:
http://openswr.org/build-linux.html

## Future
This script generates quite a lot of data (lib and bin adds up to ballpark 550MB on my system) 
and any advice to make the build smaller by configuring it better is appreciated.
