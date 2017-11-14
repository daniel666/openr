#!/bin/bash -e

#
# Copyright (c) 2014-present, Facebook, Inc.
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

set -ex

BUILD_DIR="$(readlink -f "$(dirname "$0")")"
export DESTDIR=""
mkdir -p "$BUILD_DIR/deps"
cd "$BUILD_DIR/deps"

install_zstd() {
  pushd .
  if [[ ! -e "zstd" ]]; then
    git clone https://github.com/facebook/zstd
  fi
  cd zstd
  make
  make install
  ldconfig
  popd
}

install_mstch() {
  pushd .
  if [[ ! -e "mstch" ]]; then
    git clone https://github.com/no1msd/mstch
  fi
  cd mstch
  cmake -DBUILD_SHARED_LIBS=ON -DCMAKE_CXX_FLAGS="-fPIC" .
  make
  make install
  ldconfig
  popd
}

install_wangle() {
  pushd .
  if [[ ! -e "wangle" ]]; then
    git clone https://github.com/facebook/wangle
  fi
  cd wangle/wangle
  git checkout v2017.10.23.00
  cmake \
    -DFOLLY_INCLUDE_DIR=$DESTDIR/usr/local/include \
    -DFOLLY_LIBRARY=$DESTDIR/usr/local/lib \
    -DBUILD_TESTS=OFF .
  make
  make install
  ldconfig
  popd
}

install_libzmq() {
  pushd .
  if [[ ! -e "libzmq" ]]; then
    git clone https://github.com/zeromq/libzmq
  fi
  cd libzmq
  git checkout v4.2.2
  ./autogen.sh
  ./configure
  make
  make install
  ldconfig
  popd
}

install_libsodium() {
  pushd .
  if [[ ! -e "libsodium" ]]; then
    git clone https://github.com/jedisct1/libsodium --branch stable
  fi
  cd libsodium
  ./configure
  make
  make install
  ldconfig
  popd
}

install_folly() {
  pushd .
  if [[ ! -e "folly" ]]; then
    git clone https://github.com/facebook/folly
  fi
  cd folly/folly
  git checkout v2017.10.23.00
  autoreconf -ivf
  ./configure LIBS="-lpthread"
  make
  make install
  ldconfig
  popd
}

install_fbthrift() {
  pushd .
  #if [[ ! -z "$PYTHONPATH" ]]; then
  #  export PYTHONPATH=""
  #fi
  #export PYTHONPATH="$DESTDIR/usr/local/lib/python2.7/dist-packages:$BUILD_DIR/deps/fbthrift/thrift/compiler/py/usr/local/lib/python2.7/dist-packages:$PYTHONPATH"
  if [[ ! -e "fbthrift" ]]; then
    git clone https://github.com/facebook/fbthrift
  fi
  cd fbthrift/build
  git checkout v2017.10.23.00
  cmake -DBUILD_SHARED_LIBS=ON ..
  make
  make install
  ldconfig
  cd ../thrift/lib/py
  python setup.py install
  popd
}

install_fbzmq() {
  pushd .
  if [[ ! -e "fbzmq" ]]; then
    git clone https://github.com/facebook/fbzmq.git
  fi
  cd fbzmq/fbzmq/build
  git checkout v2017.10.23.00
  cmake \
    -DCMAKE_CXX_FLAGS="-Wno-sign-compare -Wno-unused-parameter" \
    -DBUILD_SHARED_LIBS=OFF \
    -DCMAKE_EXE_LINKER_FLAGS="-static" \
    -DCMAKE_FIND_LIBRARY_SUFFIXES=".a" \
    -DBUILD_TESTS=OFF \
    ..
  make
  make install
  ldconfig
  cd ../py
  python setup.py install
  popd
}

install_glog() {
  pushd .
  if [[ ! -e "glog" ]]; then
    git clone https://github.com/google/glog
  fi
  cd glog
  git checkout v0.3.5
  set -eu && autoreconf -i
  ./configure
  make
  make install
  ldconfig
  popd
}

install_gflags() {
  pushd .
  if [[ ! -e "gflags" ]]; then
    git clone https://github.com/gflags/gflags
  fi
  cd gflags
  git checkout v2.2.0
  if [[ ! -e "mybuild" ]]; then
    mkdir mybuild
  fi
  cd mybuild
  cmake -DBUILD_SHARED_LIBS=ON ..
  make
  make install
  ldconfig
  popd
}

install_gtest() {
  pushd .
  if [[ ! -e "googletest" ]]; then
    git clone https://github.com/google/googletest
  fi
  cd googletest
  git checkout release-1.8.0
  cd googletest
  cmake .
  make
  make install
  ldconfig
  cd ../googlemock
  cmake .
  make
  make install
  ldconfig
  popd
}

install_libnl() {
  pushd .
  if [[ ! -e "libnl" ]]; then
    git clone https://github.com/thom311/libnl
    cd libnl
    git checkout libnl3_2_25
    git apply ../../fix-route-obj-attr-list.patch
    cd ..
  fi
  cd libnl
  ./autogen.sh
  ./configure
  make
  make install
  ldconfig
  popd
}

install_openr() {
  pushd .
  cd "$BUILD_DIR"
  cmake \
    -DBUILD_SHARED_LIBS=OFF \
    -DBUILD_TESTS=ON \
    -DADD_ROOT_TESTS=ON \
    -DCMAKE_CXX_FLAGS="-Wno-unused-parameter" \
    ../openr/
  make
  make install
  chmod +x "/usr/local/sbin/run_openr.sh"
  cd "$BUILD_DIR/../openr/py"
  pip install cffi
  pip install future
  python setup.py build
  sudo python setup.py install
  cd "$BUILD_DIR"
  make test
  popd
}

#
# Install required tools and libraries via package managers
#

apt-get install libdouble-conversion-dev \
  libssl-dev \
  cmake \
  make \
  zip \
  git \
  autoconf \
  autoconf-archive \
  automake \
  libtool \
  g++ \
  libboost-all-dev \
  libevent-dev \
  flex \
  bison \
  liblz4-dev \
  liblzma-dev \
  scons \
  libkrb5-dev \
  libsnappy-dev \
  libsasl2-dev \
  libnuma-dev \
  pkg-config \
  zlib1g-dev \
  binutils-dev \
  libjemalloc-dev \
  libiberty-dev \
  python-setuptools \
  python3-setuptools \
  python-pip

#
# install other dependencies from source
#

install_glog
install_gflags
install_gtest
install_mstch
install_zstd
install_folly
install_wangle
install_libsodium
install_libzmq
install_libnl
install_fbthrift
install_fbzmq
install_openr

echo "OpenR built and installed successfully"
exit 0
