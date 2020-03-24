EAPI=6

DB_VER="4.8"

inherit db-use eutils versionator toolchain-funcs git-r3

MyPV="${PV/_/}"
MyPN="bytecoin"
MyP="${MyPN}-${MyPV}"

DESCRIPTION="Original Bytecoin crypto-currency wallet for automated services"
HOMEPAGE="http://bytecoin.in/"
#EGIT_BRANCH="0.8.1"
EGIT_REPO_URI="git://github.com/FeatherCoin/FeatherCoin.git"
SRC_URI=""

LICENSE="MIT ISC GPL-2"
SLOT="0"
KEYWORDS="amd64 ~arm ~x86"
IUSE="examples ipv6 logrotate upnp"

RDEPEND="
	>=dev-libs/boost-1.41.0[threads(+)]
	dev-libs/openssl:0[-bindist]
	logrotate? (
		app-admin/logrotate
	)
	upnp? (
		net-libs/miniupnpc
	)
	sys-libs/db:$(db_ver_to_slot "${DB_VER}")[cxx]
	=dev-libs/leveldb-1.9.0*
"
DEPEND="${RDEPEND}
	>=app-shells/bash-4.1
"

S="${WORKDIR}/${MyP}"
UG='feathercoin'

pkg_setup() {
	enewgroup "${UG}"
	enewuser "${UG}" -1 -1 /var/lib/${UG} "${UG}"
}

src_prepare() {
	use ipv6 || epatch "${FILESDIR}/fix_ipv4.diff"
}

src_compile() {
	OPTS=()

	OPTS+=("DEBUGFLAGS=")
	OPTS+=("CXXFLAGS=${CXXFLAGS}")
	OPTS+=("LDFLAGS=${LDFLAGS}")

	OPTS+=("BDB_INCLUDE_PATH=$(db_includedir "${DB_VER}")")
	OPTS+=("BDB_LIB_SUFFIX=-${DB_VER}")

	if use upnp; then
		OPTS+=(USE_UPNP=1)
	else
		OPTS+=(USE_UPNP=)
	fi
	use ipv6 || OPTS+=("USE_IPV6=-")

	OPTS+=("USE_SYSTEM_LEVELDB=1")

	cd src || die
	emake CC="$(tc-getCC)" CXX="$(tc-getCXX)" -f makefile.unix "${OPTS[@]}" ${PN}
}

src_install() {
	dobin src/${PN}

	insinto /etc/${UG}
	newins "${FILESDIR}/conf" ${UG}.conf
	fowners ${UG}:${UG} /etc/${UG}/${UG}.conf
	fperms 600 /etc/${UG}/${UG}.conf

	newconfd "${FILESDIR}/confd" ${PN}
	newinitd "${FILESDIR}/initd" ${PN}

	keepdir /var/lib/${UG}/.${UG}
	fperms 700 /var/lib/${UG}
	fowners ${UG}:${UG} /var/lib/${UG}/
	fowners ${UG}:${UG} /var/lib/${UG}/.${UG}
	dosym /etc/${UG}/${UG}.conf /var/lib/${UG}/.${UG}/${UG}.conf

	dodoc doc/README

	if use examples; then
		docinto examples
		dodoc -r contrib/{bitrpc,pyminer,spendfrom,tidy_datadir.sh,wallettools}
	fi

	if use logrotate; then
		insinto /etc/logrotate.d
		newins "${FILESDIR}/logrotate" ${PN}
	fi
}
