# Copyright 1999-2020 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="A SIP003 plugin based on v2ray."
HOMEPAGE="https://github.com/shadowsocks/v2ray-plugin"
SRC_URI="
    amd64?	( https://github.com/shadowsocks/v2ray-plugin/releases/download/v${PV}/v2ray-plugin-linux-amd64-v${PV}.tar.gz -> ${P}-amd64.tar.gz )
    x86?	( https://github.com/shadowsocks/v2ray-plugin/releases/download/v${PV}/v2ray-plugin-linux-386-v${PV}.tar.gz -> ${P}-x86.tar.gz )
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"
S=${WORKDIR}

src_install() {
    mv v2ray-plugin_* ${PN} || die
    dobin ${PN} || die
}
