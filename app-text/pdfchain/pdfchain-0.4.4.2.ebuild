# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

DESCRIPTION="a frontend for pdftk"
HOMEPAGE="http://pdfchain.sourceforge.net/"

SRC_URI="https://sourceforge.net/projects/pdfchain/files/${P}/${P}.tar.gz"

LICENSE="GPL-3"

SLOT="0"
KEYWORDS="~amd64 ~x86 ~amd64-linux ~x86-linux"
IUSE=""
REQUIRED_USE=""

RDEPEND="
    >=dev-cpp/gtkmm-3
    >=app-text/pdftk-1.45
    "

DEPEND="${RDEPEND}"
