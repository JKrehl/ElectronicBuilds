# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

RESTRICT="test"

inherit eutils multilib pax-utils toolchain-funcs

DESCRIPTION="High-performance programming language for technical computing"
HOMEPAGE="http://julialang.org/"
SRC_URI="
	https://github.com/JuliaLang/${PN}/releases/download/v${PVR/_/-}/${P/_/-}.tar.gz
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~amd64-linux ~x86-linux"
IUSE="system_llvm mkl mkl_fft int64 polly jitevents julia-debug"
REQUIRED_USE="mkl_fft? ( mkl ) int64? ( mkl )"

RDEPEND="
	system_llvm? ( sys-devel/llvm )
	system_llvm? ( sys-devel/clang )
	dev-libs/openspecfun:0=
	virtual/blas
	virtual/lapack
	mkl? ( sci-libs/mkl )
	>=sci-libs/suitesparse-4.1:0=
	sci-libs/arpack:0=
	!mkl_fft? ( >=sci-libs/fftw-3.3:=[threads] )
	>=dev-libs/libpcre2-10.0:0=[jit]
	>=dev-libs/gmp-5.0:0=
	>=dev-libs/mpfr-3.0:0=
	>=dev-libs/libgit2-0.25:0=
	>=net-misc/curl-7.50:0=
	>=net-libs/libssh2-1.7:0=
	>=net-libs/mbedtls-2.2:0=
	dev-python/sphinx[python_targets_python2_7]
	sci-libs/openlibm:0=
"

DEPEND="${RDEPEND}
	dev-vcs/git
	dev-util/patchelf
	virtual/pkgconfig"

src_unpack() {
	if [ "${A}" != "" ]; then
		unpack ${A}
	fi
}

S="${WORKDIR}/${PN}"

src_prepare() {
	default

	sed -i \
		-e "s|/usr/lib|${EPREFIX}/usr/$(get_libdir)|" \
		-e "s|/usr/include|${EPREFIX}/usr/include|" \
		-e "s|LIBDIR = lib|LIBDIR = $(get_libdir)|" \
		Make.inc || die

	sed -i \
		-e "s|,lib)|,$(get_libdir))|g" \
		-e "s|\$(build_prefix)/lib|\$(build_prefix)/$(get_libdir)|" \
		Makefile || die


	sed -i \
		-e "s|\$(build_includedir)/uv-errno.h|\$(LIBUV_INC)/uv-errno.h|" \
		base/Makefile || die

	#sed -i \
	#	-e "s|-rm -rf _build/\* deps/\* docbuild.log UnicodeData.txt|@echo \"Do not clean doc/_build/html. Just use it...\"|" \
		#-e "s|default: html|default: |"\
		#doc/Makefile || die

	sed -i \
		-e "s|ar -rcs|$(tc-getAR) -rcs|" \
		src/Makefile || die

	# disable doc install starting  git fetching
	# sed -i -e 's~install: $(build_depsbindir)/stringreplace $(BUILDROOT)/doc/_build/html/en/index.html~install: $(build_depsbindir)/stringreplace~' Makefile || die
}

src_configure() {
	cat <<-EOF > Make.user
		LD_LIBRARY_PATH=$(get_libdir)
	EOF

	if use system_llvm; then
		echo "USE_SYSTEM_LLVM=1" >> Make.user
	fi

	cat <<-EOF >> Make.user
		USE_SYSTEM_LIBUNWIND=0
		USE_SYSTEM_PCRE=1
		USE_SYSTEM_LIBM=0
		USE_SYSTEM_OPENLIBM=0
		UNTRUSTED_SYSTEM_LIBM=1
		USE_SYSTEM_OPENSPECFUN=1
		USE_SYSTEM_DSFMT=0
		USE_SYSTEM_BLAS=1
		USE_SYSTEM_LAPACK=1
		USE_SYSTEM_FFTW=1
		USE_SYSTEM_GMP=1
		USE_SYSTEM_GRISU=1
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

		USE_LLVM_SHLIB = 0

		SHIPFLAGS = ${CFLAGS}
	EOF

	if tc-is-clang; then
		echo "USECLANG = 1" >> Make.user
	fi

	echo "NO_GIT = 1" >> Make.user

	if use int64; then
		echo "USE_BLAS64 = 1" >> Make.user
		local libblas="$($(tc-getPKG_CONFIG) --libs-only-l blas-int64)"
		local liblapack="$($(tc-getPKG_CONFIG) --libs-only-l lapack-int64)"
	else
		echo "USE_BLAS64 = 0" >> Make.user
		local libblas="$($(tc-getPKG_CONFIG) --libs-only-l blas)"
		local liblapack="$($(tc-getPKG_CONFIG) --libs-only-l lapack)"
	fi

	local libblasname="${libblas%% *}"
	libblasname="lib${libblasname#-l}"
	local liblapackname="${liblapack%% *}"
	liblapackname="lib${liblapackname#-l}"

	echo "LIBBLAS = $libblas" >> Make.user
	echo "LIBBLASNAME = $libblasname" >> Make.user
	echo "LIBLAPACK = $liblapack" >> Make.user
	echo "LIBLAPACKNAME = $liblapackname" >> Make.user

	if use mkl; then
		echo "USE_INTEL_MKL = 1" >> Make.user
	fi

	if use mkl_fft; then
		echo "USE_INTEL_MKL_FFT  = 1" >> Make.user
	fi

	if use polly; then
		echo "USE_POLLY  = 1" >> Make.user
	fi

	if use jitevents; then
		echo "USE_PERF_JITEVENTS = 1" >> Make.user
	fi

	if use julia-debug; then
		echo "BUNDLE_DEBUG_LIBS = 1" >> Make.user
	fi

	emake configure O="${D}" CC="$(tc-getCC)" CXX="$(tc-getCXX)"

}

src_compile() {

	# Julia accesses /proc/self/mem on Linux
	addpredict /proc/self/mem

	if use julia-debug; then
		emake all CC="$(tc-getCC)" CXX="$(tc-getCXX)"
	else
		emake release CC="$(tc-getCC)" CXX="$(tc-getCXX)"
	fi

	pax-mark m $(file usr/bin/julia-* | awk -F : '/ELF/ {print $1}')

	mv "${WORKDIR}/julia/doc/_build" "${WORKDIR}/doc/" || die
}

src_test() {
	emake test O="${D}"
}

src_install() {
	emake install prefix="${EPREFIX}/usr" DESTDIR="${D}" CC="$(tc-getCC)" CXX="$(tc-getCXX)"

	cat > 99julia <<-EOF
		LDPATH=${EROOT%/}/usr/$(get_libdir)/julia
	EOF
	doenvd 99julia

	dodoc README.md

	#mv "${ED}"/usr/etc/julia "${ED}"/etc || die
	#rmdir "${ED}"/usr/etc || die
	#mv "${ED}"/usr/share/doc/julia/html \
	#	"${ED}"/usr/share/doc/${PF} || die
	#rmdir "${ED}"/usr/share/doc/julia || die
	#if [[ $(get_libdir) != lib ]]; then
	#	mkdir -p "${ED}"/usr/$(get_libdir) || die
	#	mv "${ED}"/usr/lib/julia "${ED}"/usr/$(get_libdir)/julia || die
	#fi
}
