#!/usr/bin/env bash

# dynamically determine the path to this package
HERE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" > /dev/null && pwd )"
MASON_NAME=$(basename $(dirname $HERE))
MASON_VERSION=$(basename $HERE)
MASON_LIB_FILE=lib/libpcre.a
MASON_PKGCONFIG_FILE=lib/pkgconfig/libpcre.pc

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://ftp.pcre.org/pub/pcre/pcre-8.40.tar.gz \
        ce004b67f2a589d7381b2d8ab5619e8a4e99a71b

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/pcre-${MASON_VERSION}
}

function mason_compile {

  #./autogen.sh
  ./configure \
      --disable-dependency-tracking \
        --prefix=${MASON_PREFIX} \
        --enable-static --disable-shared \
        --enable-jit \
        --enable-utf8 --enable-pcre8 \
        --enable-pcre16 --enable-pcre32 \
        --enable-unicode-properties \
        --enable-pcregrep-libz --enable-pcregrep-libbz2
  make

  # ensure pkg-config available
  PATH=${MASON_ROOT}/.link/bin:$PATH

  make install
}

mason_run "$@"
