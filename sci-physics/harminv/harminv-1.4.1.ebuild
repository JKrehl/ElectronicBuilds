# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit autotools

DESCRIPTION="harmonic inversion algorithm of Mandelshtam: decompose signal into sum of decaying sinusoids"
HOMEPAGE="https://github.com/stevengj/harminv"
SRC_URI="https://github.com/stevengj/harminv/releases/download/v${PV}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~amd64-linux ~x86-linux"
IUSE="hdf5"

RDEPEND="
	virtual/blas
	virtual/lapack
"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	econf \
		--with-blas="$($(tc-getPKG_CONFIG) --libs blas)" \
		--with-lapack="$($(tc-getPKG_CONFIG) --libs lapack)" \
		--enable-shared
}

src_test() {
	emake check
}

src_install() {
	default
}
