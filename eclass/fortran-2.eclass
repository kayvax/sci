# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# Author Justin Lecher <jlec@gentoo.org>

# @ECLASS: fortran-2.eclass
# @MAINTAINER:
# sci@gentoo.org
# jlec@gentoo.org
# @BLURB: Packages, which need a frortran compiler should inherit this eclass.
# @DESCRIPTION:
# If you need a fortran compiler, inherit this eclass. This eclass tests for
# working fortran compilers. Optional, check for openmp capability of the
# current fortran compiler through FCOPENMP=1. Only function exported
# is pkg_setup.

# @ECLASS-VARIABLE: FCOPENMP
# @DESCRIPTION:
# If FCOPNMP=1, FC is tested for openmp capabilities
#
# Default is 0

inherit toolchain-funcs

DEPEND="virtual/fortran"
RDEPEND="${DEPEND}"

_have-valid-fortran() {
	local base=${T}/test-tc-fortran
	cat <<-EOF > "${base}.f"
	      end
	EOF
	$(tc-getFC "$@") "${base}.f" -o "${base}" >&/dev/null
	local ret=$?
	rm -f "${base}"*
	return ${ret}
}

# See if the fortran supports OpenMP.
_fortran-has-openmp() {
	local flag
	case "$(tc-getFC)" in
		*gfortran*|pathf*)
			flag=-fopenmp ;;
		ifort)
			flag=-openmp ;;
		*)
			return 0 ;;
	esac
	local base=${T}/test-fc-openmp
	# leave extra leading space to make sure it works on fortran 77 as well
	cat << EOF > "${base}.f"
       call omp_get_num_threads
       end
EOF
	$(tc-getFC "$@") ${flag} "${base}.f" -o "${base}" >&/dev/null
	local ret=$?
	rm -f "${base}"*
	return ${ret}
}

fortran-2_pkg_setup() {
	_have-valid-fortran || \
		die "Please emerge the current gcc with USE=fortran or export FC defining a working fortran compiler"
	if [[ ${FCOPENMP} == 1 ]]; then
		_fortran-has-openmp || \
		die "Please emerge current gcc with USE=openmp or export FC with compiler that supports OpenMP"
	fi
}

EXPORT_FUNCTIONS pkg_setup
