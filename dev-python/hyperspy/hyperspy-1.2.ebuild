# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

PYTHON_COMPAT=( python3_{4,5,6} )

inherit distutils-r1 versionator

DESCRIPTION="a multi-dimensional data analysis toolbox for python"
HOMEPAGE="http://hyperspy.org/"

SRC_URI="https://github.com/${PN}/${PN}/archive/v${PV}.tar.gz"

LICENSE="GPL-2"

SLOT="0"
KEYWORDS="~amd64 ~x86 ~amd64-linux ~x86-linux"
IUSE=""
REQUIRED_USE=""

RDEPEND="
	>=dev-python/numpy-1.10
	>=sci-libs/scipy-0.15
	>=dev-python/matplotlib-1.2
	>=dev-python/h5py-2.6.0
	sci-libs/scikits_image
	dev-python/ipython
	dev-python/natsort
	>=dev-python/traits-4.5.0
	>=dev-python/traitsui-4.5.0
	dev-python/requests
	>=dev-python/tqdm-0.4.9
	dev-python/ipyparallel
	dev-python/python-dateutil
	dev-python/nose
	>=dev-python/dask-0.13.0
"

DEPEND="${RDEPEND}"

python_prepare_all() {
	distutils-r1_python_prepare_all
}

python_install() {
	distutils-r1_python_install
}

python_install_all() {
	distutils-r1_python_install_all
}
