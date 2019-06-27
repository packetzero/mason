#!/usr/bin/env bash

# dynamically determine the path to this package
HERE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" > /dev/null && pwd )"

# dynamically take name of package from directory
MASON_NAME=$(basename $(dirname $HERE))
# dynamically take the version of the package from directory
MASON_VERSION=$(basename $HERE)
MASON_LIB_FILE=bin/g${MASON_NAME}

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://ftp.gnu.org/gnu/${MASON_NAME}/${MASON_NAME}-${MASON_VERSION}.tar.xz \
        8782cd4a728ee4fe6e3962accae2bc2a3c228bd1

    mason_extract_tar_xz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-${MASON_VERSION}
}

#In order to prevent conflicts with Apple's own libtool we have prepended a "g"
#so, you have instead: glibtool and glibtoolize.

function mason_compile {
  export PATH="${MASON_ROOT}/.link/bin:${PATH}"
  export SED=sed

    ./configure --disable-dependency-tracking \
        --prefix=${MASON_PREFIX} \
        --program-prefix=g --enable-ltdl-install

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
