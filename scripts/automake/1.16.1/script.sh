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
        0d7bdd17fcaabe72a59fafa1ce036af5d2e8daf4

    mason_extract_tar_xz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-${MASON_VERSION}
}

function mason_compile {
  export PATH="${MASON_ROOT}/.link/bin:${PATH}"
  export PERL=/usr/bin/perl

    ./configure --prefix=${MASON_PREFIX}

    make install

    # Our aclocal must go first. See:
    # https://github.com/Homebrew/homebrew/issues/10618
    F="${MASON_PREFIX}/share/aclocal/dirlist"
    echo "${MASON_ROOT}/.link/share/aclocal" > $F
    echo "/usr/share/aclocal" >> $F
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
