# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit fcaps git-r3

DESCRIPTION="Intel Performance Counter Monitor - A better way to measure CPU utilization"
HOMEPAGE="https://software.intel.com/en-us/articles/intel-performance-counter-monitor-a-better-way-to-measure-cpu-utilization"
EGIT_REPO_URI="https://github.com/opcm/pcm.git"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND=">=sys-devel/gcc-4:*"

DEPEND="${RDEPEND}"

src_configure() {
	sed -i 's/CXXFLAGS += -DPCM_USE_PERF/#CXXFLAGS += -DPCM_USE_PERF/'  Makefile || die
#	cmake-utils_src_configure
}

src_install() {
	exeinto /usr/bin
		newexe pcm.x pcm
		newexe pcm-memory.x pcm-memory
		newexe pcm-msr.x pcm-msr
		newexe pcm-numa.x pcm-numa
		newexe pcm-pcie.x pcm-pcie
		newexe pcm-power.x pcm-power
		newexe pcm-sensor.x pcm-sensor
		newexe pcm-tsx.x pcm-tsx
}

pkg_postinst() {
	fcaps CAP_SYS_RAWIO usr/bin/pcm
	fcaps CAP_SYS_RAWIO usr/bin/pcm-{memory,msr,numa,pcie,power,tsx}
}
