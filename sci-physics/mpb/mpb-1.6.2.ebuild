# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit autotools

DESCRIPTION="MIT Photonic-Bands: computation of photonic band structures in periodic media "
HOMEPAGE="https://github.com/stevengj/mpb"
SRC_URI="https://github.com/stevengj/mpb/releases/download/v${PV}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~amd64-linux ~x86-linux"
IUSE="hdf5"

RDEPEND="
	sci-libs/fftw:3.0=
	sci-libs/gsl:=
	sci-physics/harminv
	>=sci-libs/libctl-4
	hdf5? ( sci-libs/hdf5:= )
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
		$(use_with hdf5) \
		--enable-shared
}

src_test() {
	emake check
}

src_install() {
	default
}
