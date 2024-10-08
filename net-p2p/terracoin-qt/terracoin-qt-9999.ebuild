EAPI=8

DB_VER="4.8"

LANGS="ca_ES cs da de en es es_CL et eu_ES fa fa_IR fi fr_CA fr_FR he hr hu it lt nb nl pl pt_BR ro_RO ru sk sr sv tr uk zh_CN zh_TW"
inherit db-use qmake-utils git-r3

DESCRIPTION="An end-user Qt4 GUI for the Bytecoin crypto-currency"
HOMEPAGE="http://bytecoin.in/"

SRC_URI=""
EGIT_REPO_URI="git://github.com/terracoin/terracoin.git"
EGIT_BRANCH="master"
LICENSE="MIT ISC GPL-3 LGPL-2.1 public-domain"
SLOT="0"
KEYWORDS="amd64 ~arm ~x86"
IUSE="$IUSE 1stclassmsg dbus +qrcode upnp"

RDEPEND="
	>=dev-libs/boost-1.41.0[threads(+)]
	dev-libs/openssl:0[-bindist]
	qrcode? (
		media-gfx/qrencode
	)
	upnp? (
		net-libs/miniupnpc
	)
	sys-libs/db:$(db_ver_to_slot "${DB_VER}")[cxx]
	dev-qt/qtgui:5
	dbus? (
		dev-qt/qtdbus:5
	)
"
DEPEND="${RDEPEND}
	>=app-shells/bash-4.1
"

DOCS="doc/README"

#S="${WORKDIR}/bitcoin-bitcoind-stable"

#src_prepare() {
#	cd src || die

#	local filt= yeslang= nolang=

#	for lan in $LANGS; do
#		if [ ! -e qt/locale/bytecoin_$lan.ts ]; then
#			ewarn "Language '$lan' no longer supported. Ebuild needs update."
#		fi
#	done

#	for ts in $(ls qt/locale/*.ts)
#	do
#		x="${ts/*bytecoin_/}"
#		x="${x/.ts/}"
#		if ! use "linguas_$x"; then
#			nolang="$nolang $x"
#			rm "$ts"
#			filt="$filt\\|$x"
#		else
#			yeslang="$yeslang $x"
#		fi
#	done
#	filt="bytecoin_\\(${filt:2}\\)\\.qm"
#	sed "/${filt}/d" -i 'qt/bitcoin.qrc'
#	einfo "Languages -- Enabled:$yeslang -- Disabled:$nolang"
#}

src_configure() {
	OPTS=()

	use dbus && OPTS+=("USE_DBUS=1")
	if use upnp; then
		OPTS+=("USE_UPNP=1")
	else
		OPTS+=("USE_UPNP=-")
	fi
	use qrcode && OPTS+=("USE_QRCODE=1")
	use 1stclassmsg && OPTS+=("FIRST_CLASS_MESSAGING=1")

	OPTS+=("BDB_INCLUDE_PATH=$(db_includedir "${DB_VER}")")
	OPTS+=("BDB_LIB_SUFFIX=-${DB_VER}")

	echo "${OPTS[@]}"

	eqmake5 "${PN}.pro" "${OPTS[@]}"
}

src_compile() {
	# Workaround for bug #440034
	share/genbuild.sh build/build.h
	emake
}

src_test() {
	cd src || die
	emake -f makefile.unix "${OPTS[@]}" test_bitcoin
	./test_bitcoin || die 'Tests failed'
}

src_install() {
	qt5-build_src_install
	ls -la ${S}/bitcoin-qt
	mv ${S}/bitcoin-qt ${S}/${PN}
	ls -la ${S}/${PN}
	dobin ${PN}
	insinto /usr/share/pixmaps
	newins "share/pixmaps/bitcoin.ico" "${PN}.ico"
	make_desktop_entry ${PN} "Terracoin-Qt" "/usr/share/pixmaps/${PN}.ico" "Network;P2P"
}
