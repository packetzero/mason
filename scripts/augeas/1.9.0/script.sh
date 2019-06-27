#!/usr/bin/env bash

MASON_NAME=augeas
MASON_VERSION=1.9.0
MASON_HEADER_ONLY=false
MASON_LIB_FILE=lib/libaugeas.a

. ${MASON_DIR}/mason.sh

function mason_load_source {
  pushd ${MASON_ROOT}/.build

  rm -rf ${MASON_NAME}-${MASON_VERSION}
  git clone https://github.com/hercules-team/augeas.git ${MASON_NAME}-${MASON_VERSION}
  pushd ${MASON_NAME}-${MASON_VERSION} && \
    git checkout 3775c2bf53fef5f694fcf25308cee1dfe00600c4 && popd

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-${MASON_VERSION}
}

function mason_compile {
  export PATH="${MASON_ROOT}/.link/bin:${PATH}"
  export ACLOCAL_PATH="${MASON_ROOT}/.link/share/aclocal"
  export PKG_CONFIG_PATH="${MASON_ROOT}/.link/lib/pkgconfig"

  echo "==running autogen:"
  ./autogen.sh --without-selinux --prefix="${MASON_PREFIX}"

  echo "==configure:"
  ./configure --without-selinux --prefix="${MASON_PREFIX}" \
    --disable-dependency-tracking --enable-shared=no \
  && pushd gnulib/lib && make && popd \
  && pushd src \
  && make datadir.h \
  && make install-libLTLIBRARIES \
  && make install-data-am \
  && popd \
  && make install-data-am
}

function mason_cflags {
    echo "-I${MASON_PREFIX}/include"
    P=`uname -s`
    if [ "$P" == "Darwin" ] ; then
      echo "-I/usr/include/libxml2"
    fi
}

function mason_ldflags {
    :
}

mason_run "$@"
