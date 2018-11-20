export ROOT=`readlink -e ../install/`

export PATH=$ROOT/bin:$PATH
export LD_LIBRARY_PATH=$ROOT/lib:$LD_LIBRARY_PATH
export LIBGL_DRIVERS_PATH=$ROOT/lib/dri
export PKG_CONFIG_PATH=$ROOT/install/lib/pkgconfig:$ROOT/share/pkgconfig
export XKB_BASE=$ROOT/share/X11/xkb
export XKB_CONFIG_ROOT=$ROOT/share/X11/xkb
Xorg -noreset +extension GLX +extension RANDR +extension RENDER -logfile ./10.log -logverbose 6 -xkbdir $XKB_BASE -config ./xorg.conf -modulepath $ROOT/lib/xorg/modules :200
