#!/usr/bin/env bash

# dynamically determine the path to this package
HERE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" > /dev/null && pwd )"
MASON_NAME=$(basename $(dirname $HERE))
MASON_VERSION=$(basename $HERE)

MASON_LIB_FILE=bin/${MASON_NAME}

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://ftp.gnu.org/gnu/${MASON_NAME}/${MASON_NAME}-${MASON_VERSION}.tar.gz \
        2d93fd4de1d3d648b615ee5c9f381ceea8aef2e7

    mason_extract_tar_xz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-${MASON_VERSION}
}

function mason_compile {
    ./configure --disable-dependency-tracking \
      --prefix=${MASON_PREFIX}

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
