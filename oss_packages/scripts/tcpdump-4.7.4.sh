#! /bin/sh

SCRIPTSDIR=$(dirname $0)
HELPERSDIR="${SCRIPTSDIR}/helpers"
TOPDIR=$(realpath ${SCRIPTSDIR}/../..)

. ${TOPDIR}/scripts/common_settings.sh
. ${HELPERSDIR}/functions.sh

PKG_DIR="tcpdump-4.7.4"
PKG_ARCHIVE_FILE="${PKG_DIR}.tar.gz"
PKG_CHECKSUM="58af728de36f499341918fc4b8e827c3"

PKG_ARCHIVE="${DOWNLOADS_DIR}/${PKG_ARCHIVE_FILE}"
PKG_SRC_DIR="${SOURCES_DIR}/${PKG_DIR}"
PKG_BUILD_DIR="${BUILD_DIR}/${PKG_DIR}"
PKG_INSTALL_DIR="${PKG_BUILD_DIR}/install"

configure()
{
    cd "${PKG_BUILD_DIR}"
    export ac_cv_linux_vers=2
    export td_cv_buggygetaddrinfo=no
    export ac_cv_func_strlcpy=no
    export CROSS_COMPILE="${M3_CROSS_COMPILE}"
    export CFLAGS="${M3_CFLAGS}  -L${STAGING_LIB} -I${STAGING_INCLUDE}"
    export LDFLAGS="${M3_LDFLAGS}  -L${STAGING_LIB}"
    ./configure --target=${M3_TARGET} --host=${M3_TARGET} --enable-ipv6  --disable-smb --without-crypto --prefix=""
}

compile()
{
    copy_overlay
    cd "${PKG_BUILD_DIR}"
    export CROSS_COMPILE="${M3_CROSS_COMPILE}"
    make ${M3_MAKEFLAGS} || exit_failure "failed to build ${PKG_DIR}"
    make DESTDIR="${PKG_INSTALL_DIR}" install
}

install_staging()
{
    cd "${PKG_BUILD_DIR}"
    make -i DESTDIR="${STAGING_DIR}" install || exit_failure "failed to install ${PKG_DIR}"
}

. ${HELPERSDIR}/call_functions.sh