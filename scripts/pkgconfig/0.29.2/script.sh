#!/usr/bin/env bash

# dynamically determine the path to this package
HERE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" > /dev/null && pwd )"
MASON_NAME=$(basename $(dirname $HERE))
MASON_VERSION=$(basename $HERE)

MASON_LIB_FILE=bin/pkg-config

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://pkgconfig.freedesktop.org/releases/pkg-config-${MASON_VERSION}.tar.gz \
        a82b28f5f4e443c528ee278d8fa8ca673ecfff7a

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/pkg-config-${MASON_VERSION}
}

function mason_compile {
    ./configure --prefix=${MASON_PREFIX} ${MASON_HOST_ARG} \
        --disable-debug \
        --with-internal-glib \
        --disable-dependency-tracking \
        --disable-host-tool \
        --with-pc-path=${MASON_PREFIX}/lib/pkgconfig
    make -j${MASON_CONCURRENCY}
    make install

    # append aclocal dirlist

    F="${MASON_PREFIX}/../../share/aclocal/dirlist"
    echo "${MASON_PREFIX}/share/aclocal/dirlist" >> $F
}

function mason_clean {
    make clean
}

function mason_cflags {
    :
}

function mason_ldflags {
    :
}

function mason_static_libs {
    :
}

mason_run "$@"
