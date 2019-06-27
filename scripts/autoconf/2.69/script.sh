#!/usr/bin/env bash

# dynamically determine the path to this package
HERE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" > /dev/null && pwd )"

# dynamically take name of package from directory
MASON_NAME=$(basename $(dirname $HERE))
# dynamically take the version of the package from directory
MASON_VERSION=$(basename $HERE)
MASON_LIB_FILE=bin/${MASON_NAME}

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://ftp.gnu.org/gnu/${MASON_NAME}/${MASON_NAME}-${MASON_VERSION}.tar.gz \
        1c7a3adc3ce8b71b471ad705098f483b99b056a1

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-${MASON_VERSION}
}

function mason_compile {
  export PERL=/usr/bin/perl

  sed 's/libtoolize/glibtoolize/g' bin/autoreconf.in
  sed 's/libtoolize/glibtoolize/g' man/autoreconf.1

    ./configure \
        --prefix=${MASON_PREFIX}
        #\
        #--with-lispdir=${ELISP}

    make -j${MASON_CONCURRENCY}
    make install

    rm -f info/standards.info
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
