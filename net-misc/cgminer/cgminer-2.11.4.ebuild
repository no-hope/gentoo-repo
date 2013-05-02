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
SLOT="2"
KEYWORDS="x86 amd64"

IUSE="+adl altivec bitforce +cpumining examples hardened icarus modminer ncurses +opencl padlock scrypt sse2 sse2_4way sse4 +udev ztex"
REQUIRED_USE="
	|| ( bitforce cpumining icarus modminer opencl ztex )
	adl? ( opencl )
	altivec? ( cpumining ppc ppc64 )
	opencl? ( ncurses )
	padlock? ( cpumining || ( amd64 x86 ) )
	scrypt? ( opencl )
	sse2? ( cpumining || ( amd64 x86 ) )
	sse4? ( cpumining amd64 )
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
	sse2? (
		>=dev-lang/yasm-1.0.1
	)
	sse4? (
		>=dev-lang/yasm-1.0.1
	)
"

src_prepare() {
	sed -i 's/\(^\#define WANT_.*\(SSE\|PADLOCK\|ALTIVEC\)\)/\/\/ \1/' miner.h || die
	ln -s /usr/include/ADL/* ADL_SDK/

	# trying to fix x86_32
	if use x86; then
		sed -i 's/global $@CalcSha256_x86@12/global CalcSha256_x86/' x86_32/sha256_xmm.asm || die
		sed -i 's/@CalcSha256_x86@12:/CalcSha256_x86:/' x86_32/sha256_xmm.asm || die
		sed -i 's/_sha256_consts_m128i/sha256_consts_m128i/g' x86_32/sha256_xmm.asm || die
	fi
	eautoreconf
}

src_configure() {


	local CFLAGS="${CFLAGS}"
	if ! use altivec; then
		sed -i 's/-faltivec//g' configure
	else
		CFLAGS="${CFLAGS} -DWANT_ALTIVEC=1"
	fi
	use padlock && CFLAGS="${CFLAGS} -DWANT_VIA_PADLOCK=1"
	if use sse2; then
		if use amd64; then
			CFLAGS="${CFLAGS} -DWANT_X8664_SSE2=1"
		else
			CFLAGS="${CFLAGS} -DWANT_X8632_SSE2=1"
		fi
	fi
	use sse2_4way && CFLAGS="${CFLAGS} -DWANT_SSE2_4WAY=1"
	use sse4 && CFLAGS="${CFLAGS} -DWANT_X8664_SSE4=1"
	use hardened && CFLAGS="${CFLAGS} -nopie"
	#use cpumining && CFLAGS="${CFLAGS} WANT_CPUMINE=1"

	CFLAGS="${CFLAGS}" \
	econf \
		$(use_enable adl) \
		$(use_enable bitforce) \
		$(use_enable cpumining) \
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
	dodoc AUTHORS NEWS README API-README
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
