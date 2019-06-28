#!/usr/bin/env bash

# dynamically determine the path to this package
HERE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" > /dev/null && pwd )"
MASON_NAME=$(basename $(dirname $HERE))
MASON_VERSION=$(basename $HERE)
MASON_LIB_FILE=lib/libyara.a
MASON_PKGCONFIG_FILE=lib/pkgconfig/yara.pc

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        https://github.com/VirusTotal/yara/archive/v3.7.1.tar.gz \
        48b9e11ac455cc3258e57d197ce9baf870931146

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/${MASON_NAME}-${MASON_VERSION}
}

function mason_compile {
  export LDFLAGS="-L${MASON_ROOT}/.link/lib -lpcre"

  # Use of "inline" requires gnu89 semantics
  export CFLAGS="${CFLAGS} -std=gnu89"
  export CXXFLAGS="-std=c++11"

  export PATH=${MASON_ROOT}/.link/bin:${PATH}

  # this will look for libtoolize and fail, since it's renamed to glibtoolize
  if [ ! -f ${MASON_ROOT}/.link/bin/libtoolize ] ; then
      echo "linking glibtoolize to libtoolize"
      ln -s ${MASON_ROOT}/.link/bin/glibtoolize ${MASON_ROOT}/.link/bin/libtoolize
  fi

  ./bootstrap.sh

  ./configure \
        --prefix=${MASON_PREFIX}

  make install
}

mason_run "$@"
