# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit flag-o-matic

MY_P="${P/-/_}"
DESCRIPTION="Lists open files for running Unix processes"
HOMEPAGE="https://github.com/lsof-org/lsof"
SRC_URI="https://github.com/lsof-org/lsof/releases/download/${PV}/${P}.tar.gz"

LICENSE="lsof"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~loong ~m68k ~mips ~ppc ~ppc64 ~riscv ~s390 ~sparc ~x86"
IUSE="rpc selinux"

RDEPEND="
	rpc? ( net-libs/libtirpc )
	selinux? ( sys-libs/libselinux )
"
DEPEND="${RDEPEND}"
BDEPEND="
	sys-apps/groff
	rpc? ( virtual/pkgconfig )
"

# Needs fixing first for sandbox
RESTRICT="test"

PATCHES=(
	"${FILESDIR}"/${P}-fix-common-include-strftime.patch
)

src_configure() {
	# TODO: drop after 4.98.0: https://github.com/lsof-org/lsof/commit/4fbe0b78f63ce115f25cf7a49756745e3bf47fea
	export ac_cv_header_selinux_selinux_h=$(usex selinux)

	# TODO: drop after 4.98.0: https://github.com/lsof-org/lsof/commit/22d9cedfca4672601f35f7683907373cd5124121
	[[ ${CHOST} == *-solaris2.11 ]] && append-cppflags -DHAS_PAD_MUTEX

	local myeconfargs=(
		$(use_with rpc libtirpc)
	)

	econf "${myeconfargs[@]}"
}

src_compile() {
	emake DEBUG="" all
}

pkg_postinst() {
	if [[ ${CHOST} == *-solaris* ]] ; then
		einfo "Note: to use lsof on Solaris you need read permissions on"
		einfo "/dev/kmem, i.e. you need to be root, or to be in the group sys"
	fi
}
