#!/usr/bin/env bash

# dynamically determine the path to this package
HERE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" > /dev/null && pwd )"
MASON_NAME=$(basename $(dirname $HERE))
MASON_VERSION=$(basename $HERE)
MASON_LIB_FILE=lib/libxml2.a
MASON_PKGCONFIG_FILE=lib/pkgconfig/libxml-2.0.pc

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        ftp://xmlsoft.org/libxml2/libxml2-${MASON_VERSION}.tar.gz \
        b757c8ddd257e575bc7f8d2e278e41605b446505

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-${MASON_VERSION}
}

function mason_compile {
    # note --with-writer for osmium
    export CFLAGS="${CFLAGS} -O3 -DNDEBUG"
    ./configure --prefix=${MASON_PREFIX} \
        --enable-static --disable-shared ${MASON_HOST_ARG} \
        --with-writer \
        --with-xptr \
        --with-xpath \
        --with-xinclude \
        --with-threads \
        --with-tree \
        --with-catalog \
        --without-icu \
        --without-python \
        --without-legacy \
        --without-iconv \
        --without-debug \
        --without-docbook \
        --without-ftp \
        --without-html \
        --without-http \
        --without-lzma
    make install -j${MASON_CONCURRENCY}
}

function mason_cflags {
    echo "-I${MASON_PREFIX}/include/libxml2"
}

function mason_ldflags {
    echo "-L${MASON_PREFIX}/lib -lxml2 -lpthread -lm"
}

function mason_clean {
    make clean
}

mason_run "$@"
