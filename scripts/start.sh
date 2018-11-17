export PATH=$(pwd)/../install/bin:$PATH
export LD_LIBRARY_PATH=$(pwd)/../install/lib:$(LD_LIBRARY_PATH)
Xorg -noreset +extension GLX +extension RANDR +extension RENDER -logfile ./10.log -config ./xorg.conf :200
