EAPI="4"

DB_VER="4.8"

inherit db-use eutils versionator toolchain-funcs git-2

MyPV="${PV/_/}"
MyPN="bytecoin"
MyP="${MyPN}-${MyPV}"

DESCRIPTION="Original Bytecoin crypto-currency wallet for automated services"
HOMEPAGE="http://bytecoin.in/"
EGIT_BRANCH="0.8.1"
EGIT_REPO_URI="git://github.com/bryan-mills/bytecoin.git"
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

pkg_setup() {
	local UG='bytecoin'
	enewgroup "${UG}"
	enewuser "${UG}" -1 -1 /var/lib/bytecoin "${UG}"
}

src_prepare() {
	epatch "${FILESDIR}/0.8.0-sys_leveldb.patch"
	rm -r src/leveldb
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

src_test() {
	cd src || die
	emake CC="$(tc-getCC)" CXX="$(tc-getCXX)" -f makefile.unix "${OPTS[@]}" test_bytecoin
	./test_bytecoin || die 'Tests failed'
}

src_install() {
	dobin src/${PN}

	insinto /etc/bytecoin
	newins "${FILESDIR}/bytecoin.conf" bytecoin.conf
	fowners bytecoin:bytecoin /etc/bytecoin/bytecoin.conf
	fperms 600 /etc/bytecoin/bytecoin.conf

	newconfd "${FILESDIR}/bytecoin.confd" ${PN}
	newinitd "${FILESDIR}/bytecoin.initd" ${PN}

	keepdir /var/lib/bytecoin/.bytecoin
	fperms 700 /var/lib/bytecoin
	fowners bytecoin:bytecoin /var/lib/bytecoin/
	fowners bytecoin:bytecoin /var/lib/bytecoin/.bytecoin
	dosym /etc/bytecoin/bytecoin.conf /var/lib/bytecoin/.bytecoin/bytecoin.conf

	dodoc doc/README

	if use examples; then
		docinto examples
		dodoc -r contrib/{bitrpc,pyminer,spendfrom,tidy_datadir.sh,wallettools}
	fi

	if use logrotate; then
		insinto /etc/logrotate.d
		newins "${FILESDIR}/bytecoind.logrotate" bytecoind
	fi
}
