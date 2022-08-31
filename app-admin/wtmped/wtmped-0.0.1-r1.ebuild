EAPI=8

S="${WORKDIR}/${PN}-${PV}/wtmp_editor"

DESCRIPTION="Simple wtmp file editor written in C"
HOMEPAGE="https://github.com/no-hope/wtmped"

RESTRICT="nomirror"
SRC_URI="https://github.com/no-hope/wtmped/archive/v${PV}.tar.gz -> ${PN}-${PV}.tar.gz"

LICENSE="GPL-3"
SLOT="2"
KEYWORDS="x86 amd64"

src_install() {
	dobin ${PN} || die
}
