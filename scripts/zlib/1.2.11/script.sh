#!/usr/bin/env bash

# dynamically determine the path to this package
HERE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" > /dev/null && pwd )"
MASON_NAME=$(basename $(dirname $HERE))
MASON_VERSION=$(basename $HERE)
MASON_LIB_FILE=lib/libz.a
MASON_PKGCONFIG_FILE=lib/pkgconfig/zlib.pc

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/madler/zlib/archive/v1.2.11.tar.gz \
        a4873bac66e65c8066969c4f638bcf6ed780dacb

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/zlib-${MASON_VERSION}
}

function mason_compile {
  export PATH=${MASON_ROOT}/.link/bin:${PATH}
    # Add optimization flags since CFLAGS overrides the default (-g -O2)
    export CFLAGS="${CFLAGS} -O3 -DNDEBUG"
    ./configure \
        --prefix=${MASON_PREFIX} \
        --static

    make install -j${MASON_CONCURRENCY}
}

mason_run "$@"
