#!/bin/bash

if [ ! -x configure ]
then
  echo "Run this script from the GMP base directory"
  exit 1
fi

export NDK="${HOME}/work/android-ndk-r6b"
if [ ! -d ${NDK} ]
then
  echo "Please download and install the NDK, then update the path in this script."
  echo "  http://developer.android.com/sdk/ndk/index.html"
  exit 1
fi

# Extract an android-5 toolchain if needed
export TARGET="android-5"
export TOOLCHAIN="/tmp/${TARGET}"
if [ ! -d ${TOOLCHAIN} ]
then
  ${NDK}/build/tools/make-standalone-toolchain.sh --platform=${TARGET} --install-dir=${TOOLCHAIN}
fi

export PATH=${TOOLCHAIN}/bin:$PATH
export LDFLAGS='-Wl,--fix-cortex-a8'
export LIBGMP_LDFLAGS='-avoid-version'
export LIBGMPXX_LDFLAGS='-avoid-version'

################################################################################################################

# armeabi-v7a with neon (unsupported target: will cause crashes on many phones, but works well on the Nexus One)
#export CFLAGS="-O2 -pedantic -fomit-frame-pointer -march=armv7-a -mfloat-abi=softfp -mfpu=neon -ftree-vectorize"

# armeabi-v7a
export CFLAGS="-O2 -pedantic -fomit-frame-pointer -march=armv7-a -mfloat-abi=softfp"
./configure --prefix=/usr --disable-static --build=i686-pc-linux-gnu --host=arm-linux-androideabi
make
make install DESTDIR=$PWD/armeabi-v7a
cd armeabi-v7a && mv usr/lib/libgmp.so usr/include/gmp.h . && rm -rf usr && cd ..
make distclean

# armeabi
export CFLAGS="-O2 -pedantic -fomit-frame-pointer"
./configure --prefix=/usr --disable-static --build=i686-pc-linux-gnu --host=arm-linux-androideabi
make
make install DESTDIR=$PWD/armeabi
cd armeabi && mv usr/lib/libgmp.so usr/include/gmp.h . && rm -rf usr && cd ..
make distclean
