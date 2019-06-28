#!/usr/bin/env bash

# dynamically determine the path to this package
HERE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" > /dev/null && pwd )"
MASON_NAME=$(basename $(dirname $HERE))
MASON_VERSION=$(basename $HERE)

MASON_LIB_FILE=lib/lib${MASON_NAME}.a

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/google/glog/archive/v${MASON_VERSION}.tar.gz \
        d4e2845562d2ebe4b733c1a528d21184b985129d

    mason_extract_tar_xz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-${MASON_VERSION}
}

function mason_compile {
    ./configure --disable-dependency-tracking \
      --prefix=${MASON_PREFIX} --disable-shared --enable-static

    make install
}

function mason_cflags {
    echo -I${MASON_PREFIX}/include
}

function mason_ldflags {
    :
}

#function mason_static_libs {
#}

function mason_clean {
    make clean
}

mason_run "$@"
