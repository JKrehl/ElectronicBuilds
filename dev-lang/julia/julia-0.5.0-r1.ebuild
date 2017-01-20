# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

RESTRICT="test"

inherit elisp-common eutils multilib pax-utils toolchain-funcs

DESCRIPTION="High-performance programming language for technical computing"
HOMEPAGE="http://julialang.org/"
SRC_URI="
	https://github.com/JuliaLang/${PN}/archive/v${PVR}/${P}.tar.gz
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~amd64-linux ~x86-linux"
IUSE="mkl mkl_fft polly int64"
REQUIRED_USE="mkl_fft? ( mkl ) int64? ( mkl )"

RDEPEND="
	>=sys-devel/llvm-3.7:0=
	dev-libs/libuv:0=
	sci-libs/openlibm:0=
	dev-libs/openspecfun:0=
	virtual/blas
	virtual/lapack
	mkl? ( sci-libs/mkl )
	>=sci-libs/suitesparse-4.1:0=
	sci-libs/arpack:0=
	>=sci-libs/fftw-3.3:=
	>=dev-libs/libpcre2-10.0:0=
	>=dev-libs/gmp-5.0:0=
	>=dev-libs/mpfr-3.0:0=
	>=dev-libs/libgit2-0.23:0=
	>=net-misc/curl-7.50:0=
	>=net-libs/libssh2-1.7:0=
	>=net-libs/mbedtls-2.2:0=
	sys-libs/libunwind:=
	dev-python/sphinx[python_targets_python2_7]"

DEPEND="${RDEPEND}
	dev-lang/python:2.7
	sys-devel/gcc[fortran]
	dev-lang/perl
	sys-devel/m4
	dev-util/patchelf
	virtual/pkgconfig"

src_prepare() {
	use polly && tc-check-openmp && eapply "${FILESDIR}/${PN}-${PVR}-polly-openmp.patch"

	eapply_user

	if use int64; then
		local libblas="$($(tc-getPKG_CONFIG) --libs-only-l blas-int64)"
		local liblapack="$($(tc-getPKG_CONFIG) --libs-only-l lapack-int64)"
	else
		local libblas="$($(tc-getPKG_CONFIG) --libs-only-l blas)"
		local liblapack="$($(tc-getPKG_CONFIG) --libs-only-l lapack)"
	fi

	libblas="${libblas%% *}"
	libblas="lib${libblas#-l}"
	liblapack="${liblapack%% *}"
	liblapack="lib${liblapack#-l}"

	sed -i \
		-e "s|\(JULIA_EXECUTABLE = \)\(\$(JULIAHOME)/julia\)|\1 LD_LIBRARY_PATH=\$(build_prefix)/$(get_libdir) \2|" \
		-e "s|LIBDIR = lib|LIBDIR = $(get_libdir)|" \
		-e "s|/usr/lib|${EPREFIX}/usr/$(get_libdir)|" \
		-e "s|/usr/include|${EPREFIX}/usr/include|" \
		-e "s|\$(build_prefix)/lib|\$(build_prefix)/$(get_libdir)|" \
		-e "s|^JULIA_COMMIT = .*|JULIA_COMMIT = v${PV}|" \
		Make.inc || die

	sed -i \
		-e "s|,lib)|,$(get_libdir))|g" \
		-e "s|\$(build_prefix)/lib|\$(build_prefix)/$(get_libdir)|g" \
		Makefile || die

	sed -i \
		-e "s|-rm -rf _build/\*|@echo \"Do not clean doc/_build/html. Just use it...\"|g" \
		doc/Makefile || die

	sed -i \
		-e "s|ar -rcs|$(tc-getAR) -rcs|g" \
		-e "s|-lLLVM-\$(shell \$(LLVM_CONFIG_HOST) --version)|\$(shell \$(LLVM_CONFIG_HOST) --libs)|g" \
		src/Makefile || die
}

#-e "s|-lLLVM-\$(shell $(LLVM_CONFIG_HOST) --version)|\$(shell \$(LLVM_CONFIG_HOST) --libs)|g" \

src_configure() {
	# julia does not play well with the system versions of
	# dsfmt, libuv, pcre2 and utf8proc
	cat <<-EOF > Make.user
		USE_SYSTEM_LLVM=1
		USE_SYSTEM_LIBUNWIND=1
		USE_SYSTEM_PCRE=1
		USE_SYSTEM_LIBM=1
		USE_SYSTEM_OPENLIBM=1
		UNTRUSTED_SYSTEM_LIBM=0
		USE_SYSTEM_OPENSPECFUN=1
		USE_SYSTEM_DSFMT=0
		USE_SYSTEM_BLAS=1
		USE_SYSTEM_LAPACK=1
		USE_SYSTEM_FFTW=1
		USE_SYSTEM_GMP=1
		USE_SYSTEM_MPFR=1
		USE_SYSTEM_ARPACK=1
		USE_SYSTEM_SUITESPARSE=1
		USE_SYSTEM_LIBUV=0
		USE_SYSTEM_UTF8PROC=0
		USE_SYSTEM_MBEDTLS=1
		USE_SYSTEM_LIBSSH2=1
		USE_SYSTEM_CURL=1
		USE_SYSTEM_LIBGIT2=1
		USE_SYSTEM_PATCHELF=1
		VERBOSE=1
	EOF

	if tc-is-clang; then
		echo "USECLANG = 1" >> Make.user
	fi



	#echo "SHIPFLAGS = ${CFLAGS}" >> Make.user
	echo "NO_GIT = 1" >> Make.user

	if use mkl; then
		echo "USE_INTEL_MKL = 1" >> Make.user
		if use int64; then
			echo "USE_BLAS64 = 1" >> Make.user
		else
			echo "USE_BLAS64 = 0" >> Make.user
		fi
	fi

	if use mkl_fft; then
		echo "USE_INTEL_MKL_FFT  = 1" >> Make.user
	fi

	if use polly; then
		echo "USE_POLLY  = 1" >> Make.user
	fi

}

src_compile() {
	addpredict /proc/self/mem

	emake cleanall
	emake julia-release \
		prefix="/usr" DESTDIR="${D}" CC="$(tc-getCC)" CXX="$(tc-getCXX)" || die "make failed"
	pax-mark m $(file usr/bin/julia-* | awk -F : '/ELF/ {print $1}')
	emake
	#use emacs && elisp-compile contrib/julia-mode.el
}

src_test() {
	emake test
}

src_install() {
	emake install \
		prefix="/usr" DESTDIR="${D}" CC="$(tc-getCC)" CXX="$(tc-getCXX)"
	cat > 99julia <<-EOF
		LDPATH=${EROOT%/}/usr/$(get_libdir)/julia
		JULIA_POLLY_ARGS="-polly-parallel -polly-vectorizer=polly"
	EOF
	doenvd 99julia

	dodoc README.md

	mv "${ED}"/usr/etc/julia "${ED}"/etc || die
	rmdir "${ED}"/usr/etc || die
	rmdir "${ED}"/usr/libexec || die
	mv "${ED}"/usr/share/doc/julia/{examples,html} \
		"${ED}"/usr/share/doc/${PN}-${PVR} || die
	rmdir "${ED}"/usr/share/doc/julia || die
	if [[ $(get_libdir) != lib ]]; then
		mkdir -p "${ED}"/usr/$(get_libdir) || die
		mv "${ED}"/usr/lib/julia "${ED}"/usr/$(get_libdir)/julia || die
	fi
}

#pkg_postinst() {
#}

#pkg_postrm() {
#}
