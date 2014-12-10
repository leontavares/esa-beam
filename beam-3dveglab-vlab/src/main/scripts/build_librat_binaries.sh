#!/bin/sh
#
# this script builds librat native binaries for win32, win64 and linux64
#

VERSION=1_4_1b
W32NAME=librat_${VERSION}_windows32-`date +%Y%m%d`
W64NAME=librat_${VERSION}_windows64-`date +%Y%m%d`
LINNAME=librat_${VERSION}_linux64-`date +%Y%m%d`

set -e

sudo yum -y install csh
sudo yum -y install gcc
sudo yum -y install mingw32-gcc
sudo yum -y install mingw64-gcc
sudo yum -y install patch
sudo yum -y install elinks

# get official configure
wget http://www2.geog.ucl.ac.uk/~plewis/librat/configure

# get Netcetera patches for cross-compiling win32/win64 binaries under linux
mkdir librat-patches
cd librat-patches
for f in `elinks -dump https://github.com/netceteragroup/esa-beam/tree/master/beam-3dveglab-vlab/src/main/scripts/librat-patches | egrep 'http.*\.patch|http.*librat-testMe.bat'`; do 
  p=`basename $f`
  wget "https://raw.github.com/netceteragroup/esa-beam/master/beam-3dveglab-vlab/src/main/scripts/librat-patches/$p"
done
cd ..

# apply Netcetera windows top level patch, then run configure
patch -b < librat-patches/librat-configure.patch
BPMS=`pwd`/bpms csh -x -f ./configure -mingw32 2>&1 | tee build-win32.log
if test ! -f ./bpms/src/start/ratstart.exe ; then
  echo FAILED && exit -1
fi
mv bpms ${W32NAME}
zip -r ${W32NAME} ${W32NAME}

# problem with getpid() - fix it later
if false; then
BPMS=`pwd`/bpms csh -x -f ./configure -mingw64 2>&1 | tee build-win64.log
if test ! -f ./bpms/src/start/ratstart.exe ; then
  echo FAILED && exit -1
fi
mv bpms ${W64NAME}
zip -r ${W64NAME} ${W64NAME}
fi

# now build for linux
BPMS=`pwd`/bpms csh -x -f ./configure 2>&1 | tee build-linux64.log
if test ! -f ./bpms/src/start/ratstart ; then
  echo FAILED && exit -1
fi
mv bpms ${LINNAME}
tar -cf ${LINNAME}.tar ${LINNAME}
gzip -9 ${LINNAME}.tar
