# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

PYTHON_COMPAT=( python3_{4,5,6} )

inherit distutils-r1 versionator

DESCRIPTION="a multi-dimensional data analysis toolbox for python"
HOMEPAGE="http://hyperspy.org/"

SRC_URI="https://github.com/hgrecco/${PN}/archive/${PV}.tar.gz"

LICENSE="GPL-2"

SLOT="0"
KEYWORDS="~amd64 ~x86 ~amd64-linux ~x86-linux"
IUSE=""
REQUIRED_USE=""

RDEPEND="
"

DEPEND="${RDEPEND}
		dev-python/setuptools
"


python_prepare_all() {
	distutils-r1_python_prepare_all
}

python_install() {
	distutils-r1_python_install
}

python_install_all() {
	distutils-r1_python_install_all
}
