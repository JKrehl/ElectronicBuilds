# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit multilib

DESCRIPTION="Intel's implementation of the OpenCL standard"
HOMEPAGE="http://software.intel.com/en-us/articles/opencl-sdk/"
SRC_URI="http://registrationcenter-download.intel.com/akdlm/irc_nas/vcp/11060/intel_sdk_for_opencl_2016_ubuntu_6.3.0.1904_x64.tgz"

LICENSE="Intel-SDP"
SLOT="0"
IUSE=""
KEYWORDS="-*"
RESTRICT="mirror"

RDEPEND="app-eselect/eselect-opencl
	sys-process/numactl
	"
DEPEND=""

S=${WORKDIR}/intel_sdk_for_opencl_2016_ubuntu_6.3.0.1904_x64/

src_configure() {
	cp "${FILESDIR}"/silent.cfg "${S}" || die
	sed -i -e "s|\${D}|${D}|g" silent.cfg || die
}

src_compile() {
	sh "${S}"install.sh --user-mode -s "${S}"silent.cfg -t "${T}" -D "${T}" || die
}

src_install() {
	insinto /etc/OpenCL/vendors/
	doins "${WORKDIR}/${INTEL_CL}"/etc/intel64.icd

	insinto /"${INTEL_CL}"/lib64
	insopts -m 755
	doins "${WORKDIR}/${INTEL_CL}"/lib64/*

	insinto /"${INTEL_CL}"/bin
	doins "${WORKDIR}"/"${INTEL_CL}"/bin/*

	# TODO put this somewhere
	# doins ${INTEL_CL}/eclipse-plug-in/OpenCL_SDK_0.1.0.jar

	dodir "${INTEL_VENDOR_DIR}"
	dosym "/opt/intel/opencl-1.2-${PV}/lib64/libOpenCL.so"     "${INTEL_VENDOR_DIR}/libOpenCL.so"
	dosym "/opt/intel/opencl-1.2-${PV}/lib64/libOpenCL.so.1"   "${INTEL_VENDOR_DIR}/libOpenCL.so.1"
	dosym "/opt/intel/opencl-1.2-${PV}/lib64/libOpenCL.so.1.2" "${INTEL_VENDOR_DIR}/libOpenCL.so.1.2"
}

pkg_postinst() {
	eselect opencl set --use-old intel
}
