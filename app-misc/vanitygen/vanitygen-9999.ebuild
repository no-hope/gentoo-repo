# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/ansifilter/ansifilter-1.7.ebuild,v 1.3 2013/03/02 19:40:05 hwoarang Exp $

EAPI=7

DESCRIPTION="Standalone command line vanity bitcoin address generator"
HOMEPAGE="https://github.com/samr7/vanitygen"

SRC_URI=""
EGIT_REPO_URI="git://github.com/samr7/vanitygen.git"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 ~arm ~x86"
IUSE="opencl"
inherit db-use eutils git-r3 toolchain-funcs

RDEPEND="
    dev-libs/libpcre
    dev-libs/libgcrypt
"
DEPEND="${RDEPEND}"

S=${WORKDIR}/${PN}-${PV}

pkg_setup() {
	myopts=(
		"CC=$(tc-getCXX)"
		"CFLAGS=${CFLAGS}"
		"LDFLAGS=${LDFLAGS}"
		"DESTDIR=${ED}"
		"PREFIX=${EPREFIX}/usr"
		"doc_dir=${EPREFIX}/usr/share/doc/${PF}/"
	)
}

src_compile() {
	emake -f Makefile "${myopts[@]}" vanitygen keyconv
}

src_install() {
	dobin vanitygen
	dobin keyconv
	dodoc README
}
