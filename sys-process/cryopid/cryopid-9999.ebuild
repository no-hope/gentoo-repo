# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=7

inherit eutils linux-info git-r3

DESCRIPTION="Process freezing utility"
HOMEPAGE="http://cryopid.berlios.de"
EGIT_REPO_URI="git://github.com/maaziz/cryopid.git"
SRC_URI=""

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
	dev-libs/dietlibc
	sys-libs/zlib[static-libs]
"
RDEPEND="${DEPEND}"

S=${WORKDIR}/${P}/src

pkg_setup() {
	linux_config_src_exists
	get_version
}

src_compile() {
	cd src
	emake CC="$(tc-getCC)" CFLAGS="${CFLAGS} -I\"${KV_DIR}/include\" -Iarch -I.. -Wl,-t" -j1
}
