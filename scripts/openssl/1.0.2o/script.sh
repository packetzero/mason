#!/usr/bin/env bash

# dynamically determine the path to this package
HERE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" > /dev/null && pwd )"
MASON_NAME=$(basename $(dirname $HERE))
MASON_VERSION=$(basename $HERE)

MASON_LIB_FILE=lib/libssl.a
MASON_PKGCONFIG_FILE=lib/pkgconfig/openssl.pc

. ${MASON_DIR}/mason.sh

function mason_load_source {
    mason_download \
        ftp://ftp.openssl.org/source/old/1.0.2/openssl-${MASON_VERSION}.tar.gz \
        fff6a9003598cd3d555ad23bcbc22b739fa48edf

    mason_extract_tar_gz

    export MASON_BUILD_PATH=${MASON_ROOT}/.build/openssl-${MASON_VERSION}
}

function mason_prepare_compile {
    MASON_MAKEDEPEND="gccmakedep"

    if [ ${MASON_PLATFORM} = 'osx' ]; then
        #unset MASON_MAKEDEPEND
        MASON_MAKEDEPEND=""
        MASON_OS_COMPILER="darwin64-x86_64-cc enable-ec_nistp_64_gcc_128"
    elif [ ${MASON_PLATFORM} = 'linux' ]; then
        MASON_OS_COMPILER="linux-x86_64 enable-ec_nistp_64_gcc_128"
    elif [[ ${MASON_PLATFORM} == 'android' ]]; then
        COMMON="-fPIC -ffunction-sections -funwind-tables -fstack-protector-strong -no-canonical-prefixes -fno-integrated-as -O2 -g -DNDEBUG -fomit-frame-pointer -fstrict-aliasing -Wno-invalid-command-line-argument -Wno-unused-command-line-argument -no-canonical-prefixes"
        if [ ${MASON_ANDROID_ABI} = 'arm-v5' ]; then
            MASON_OS_COMPILER="linux-armv4 -march=armv5te -mtune=xscale -msoft-float -fuse-ld=gold $COMMON"
        elif [ ${MASON_ANDROID_ABI} = 'arm-v7' ]; then
            MASON_OS_COMPILER="linux-armv4 -march=armv7-a -mfpu=vfpv3-d16 -mfloat-abi=softfp -Wl,--fix-cortex-a8 -fuse-ld=gold $COMMON"
        elif [ ${MASON_ANDROID_ABI} = 'x86' ]; then
            MASON_OS_COMPILER="linux-elf -march=i686 -msse3 -mfpmath=sse -fuse-ld=gold $COMMON"
        elif [ ${MASON_ANDROID_ABI} = 'mips' ]; then
            MASON_OS_COMPILER="linux-generic32 $COMMON"
        elif [ ${MASON_ANDROID_ABI} = 'arm-v8' ]; then
            MASON_OS_COMPILER="linux-generic64 enable-ec_nistp_64_gcc_128 -fuse-ld=gold $COMMON"
        elif [ ${MASON_ANDROID_ABI} = 'x86-64' ]; then
            MASON_OS_COMPILER="linux-x86_64 enable-ec_nistp_64_gcc_128 -march=x86-64 -msse4.2 -mpopcnt -m64 -mtune=intel -fuse-ld=gold $COMMON"
        elif [ ${MASON_ANDROID_ABI} = 'mips-64' ]; then
            MASON_OS_COMPILER="linux-generic32 $COMMON"
        fi
    fi
}

function mason_compile {
    NO_ASM=

    # Work around a Android 6.0 TEXTREL exception. See https://github.com/mapbox/mapbox-gl-native/issues/2772
    if [[ ${MASON_PLATFORM} == 'android' ]]; then
        if [ ${MASON_ANDROID_ABI} = 'x86' ]; then
            NO_ASM=-no-asm
        fi
    fi

    ./Configure \
        --prefix=${MASON_PREFIX} \
        enable-tlsext \
        ${NO_ASM} \
        -no-dso \
        -no-hw \
        -no-engines \
        -no-comp \
        -no-gmp \
        -no-zlib \
        -no-shared \
        -no-ssl2 \
        -no-ssl3 \
        -no-krb5 \
        -no-camellia \
        -no-capieng \
        -no-cast \
        -no-dtls \
        -no-gost \
        -no-idea \
        -no-jpake \
        -no-md2 \
        -no-mdc2 \
        -no-rc5 \
        -no-rdrand \
        -no-ripemd \
        -no-rsax \
        -no-sctp \
        -no-seed \
        -no-sha0 \
        -no-whirlpool \
        -fPIC \
        -DOPENSSL_PIC \
        -DOPENSSL_NO_COMP \
        -DOPENSSL_NO_HEARTBEATS \
        --openssldir=${MASON_PREFIX}/etc/openssl \
        ${MASON_OS_COMPILER}

    if [ "${MASON_MAKEDEPEND}" == "" ] ; then
      make depend
    else
      make depend MAKEDEPPROG=${MASON_MAKEDEPEND}
    fi

    make

    # ensure that pkgconfig is available to install_sw
    export PATH=${MASON_ROOT}/.link/bin:$PATH
    PKG_CONFIG_PATH+=${MASON_PREFIX}/lib/pkgconfig
    export PKG_CONFIG_PATH

    # https://github.com/openssl/openssl/issues/57
    make install_sw
}

function mason_clean {
    make clean
}

mason_run "$@"
