#!/usr/bin/env bash

# dynamically determine the path to this package
HERE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" > /dev/null && pwd )"
MASON_NAME=$(basename $(dirname $HERE))
MASON_VERSION=$(basename $HERE)

MASON_LIB_FILE=lib/${MASON_NAME}.a

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
      https://distfiles.macports.org/file/file-${MASON_VERSION}.tar.gz \
      689ac18c373f4179b8e37f46c979107f90492366

    mason_extract_tar_xz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/file-${MASON_VERSION}
}

function mason_compile {
    ./configure --disable-dependency-tracking \
      --prefix=${MASON_PREFIX} \
      --enable-fsect-man5 --disable-silent-rules \
      --disable-shared --enable-static

    make install

    # copy over defs
    mkdir -p ${MASON_PREFIX}/share/misc/magic
    cp -r ${MASON_BUILD_PATH}/magic/Magdir/* ${MASON_PREFIX}/share/misc/magic/

    # only want lib, not file util
    rm -f ${MASON_PREFIX}/bin/file
    rm -f ${MASON_PREFIX}/man1/file.1
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
