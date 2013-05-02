# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/cgminer/cgminer-2.7.4.ebuild,v 1.2 2012/12/03 02:27:14 ssuominen Exp $

EAPI="5"

inherit versionator autotools

MY_PV="$(replace_version_separator 3 -)"
S="${WORKDIR}/${PN}-${PV}"

DESCRIPTION="Bitcoin CPU/GPU/FPGA miner in C"
HOMEPAGE="https://bitcointalk.org/index.php?topic=28402.0"

RESTRICT="nomirror"
SRC_URI="https://github.com/ckolivas/cgminer/archive/v${PV}.tar.gz -> cgminer-${PV}.tar.gz"

LICENSE="GPL-3"
SLOT="3"
KEYWORDS="x86 amd64"

IUSE="+adl bitforce examples hardened icarus modminer ncurses +opencl scrypt +udev ztex"
REQUIRED_USE="
	|| ( bitforce icarus modminer opencl ztex )
	adl? ( opencl )
	opencl? ( ncurses )
	scrypt? ( opencl )
"

DEPEND="
	net-misc/curl
	ncurses? (
		sys-libs/ncurses
	)
	dev-libs/jansson
	opencl? (
		virtual/opencl
	)
	udev? (
		virtual/udev
	)
	ztex? (
		virtual/libusb:1
	)
"
RDEPEND="${DEPEND}"
DEPEND="${DEPEND}
	virtual/pkgconfig
	sys-apps/sed
	adl? (
		x11-libs/amd-adl-sdk
	)
"

src_prepare() {
	ln -s /usr/include/ADL/* ADL_SDK/
	eautoreconf
}

src_configure() {
	local CFLAGS="${CFLAGS}"
	use hardened && CFLAGS="${CFLAGS} -nopie"

	CFLAGS="${CFLAGS}" \
	econf \
		$(use_enable adl) \
		$(use_enable bitforce) \
		$(use_enable icarus) \
		$(use_enable modminer) \
		$(use_with ncurses curses) \
		$(use_enable opencl) \
		$(use_enable scrypt) \
		$(use_with udev libudev) \
		$(use_enable ztex)
	# sanitize directories
	sed -i 's~^\(\#define CGMINER_PREFIX \).*$~\1"'"${EPREFIX}/usr/lib/cgminer-${PV}"'"~' config.h
}

src_install() {
	mv cgminer cgminer-${PV}
	dobin cgminer-${PV}
	dodoc AUTHORS NEWS LICENSE COPYING README API-README ASIC-README FPGA-README GPU-README SCRYPT-README
	if use scrypt; then
		dodoc SCRYPT-README
	fi
	if use icarus || use bitforce; then
		dodoc FPGA-README
	fi
	if use modminer; then
		insinto /usr/lib/cgminer-${PV}/modminer
		doins bitstreams/*.ncd
		dodoc bitstreams/COPYING_fpgaminer
	fi
	if use opencl; then
		insinto /usr/lib/cgminer-${PV}
		doins *.cl
	fi
	if use ztex; then
		insinto /usr/lib/cgminer-${PV}/ztex
		doins bitstreams/*.bit
		dodoc bitstreams/COPYING_ztex
	fi
	if use examples; then
		docinto examples
		dodoc api-example.php miner.php API.java api-example.c
	fi
}
