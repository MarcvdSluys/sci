# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

# @ECLASS: intel-sdp-r1.eclass
# @MAINTAINER:
# Justin Lecher <jlec@gentoo.org>
# David Seifert <soap@gentoo.org>
# Sci Team <sci@gentoo.org>
# @BLURB: Handling of Intel's Software Development Products package management

if [[ ! ${_INTEL_SDP_R1_ECLASS_} ]]; then

case "${EAPI:-0}" in
	6) ;;
	*) die "EAPI=${EAPI} is not supported" ;;
esac

# @ECLASS-VARIABLE: INTEL_DID
# @DEFAULT_UNSET
# @DESCRIPTION:
# The package download ID from Intel.
# To find out its value, see the links to download in
# https://registrationcenter.intel.com/RegCenter/MyProducts.aspx
#
# e.g. 8365
#
# Must be defined before inheriting the eclass

# @ECLASS-VARIABLE: INTEL_DPN
# @DEFAULT_UNSET
# @DESCRIPTION:
# The package name to download from Intel.
# To find out its value, see the links to download in
# https://registrationcenter.intel.com/RegCenter/MyProducts.aspx
#
# e.g. parallel_studio_xe
#
# Must be defined before inheriting the eclass

# @ECLASS-VARIABLE: INTEL_DPV
# @DEFAULT_UNSET
# @DESCRIPTION:
# The package download version from Intel.
# To find out its value, see the links to download in
# https://registrationcenter.intel.com/RegCenter/MyProducts.aspx
#
# e.g. 2016_update1
#
# Must be defined before inheriting the eclass

# @ECLASS-VARIABLE: INTEL_TARX
# @DESCRIPTION:
# The package extention.
# To find out its value, see the links to download in
# https://registrationcenter.intel.com/RegCenter/MyProducts.aspx
#
# e.g. tar.gz
#
# Must be defined before inheriting the eclass
: ${INTEL_TARX:=tgz}

# @ECLASS-VARIABLE: INTEL_SUBDIR
# @DEFAULT_UNSET
# @DESCRIPTION:
# The package sub-directory where it will end-up in /opt/intel
# To find out its value, you have to do a raw install from the Intel tar ball

# @ECLASS-VARIABLE: INTEL_SKIP_LICENSE
# @DEFAULT_UNSET
# @DESCRIPTION:
# Possibility to skip the mandatory check for licenses. Only set this if there
# is really no fix.

# @ECLASS-VARIABLE: INTEL_RPMS_DIR
# @DESCRIPTION:
# Main subdirectory which contains the rpms to extract.
: ${INTEL_RPMS_DIR:=rpm}

# @ECLASS-VARIABLE: INTEL_X86
# @DESCRIPTION:
# 32bit arch in rpm names
#
# e.g. i486
: ${INTEL_X86:=i486}

# @ECLASS-VARIABLE: INTEL_BIN_RPMS
# @DESCRIPTION:
# Functional name of rpm without any version/arch tag
# Has to be a bash array
#
# e.g. ("icc-l-all-devel")
#
# if the rpm is located in a directory other than INTEL_RPMS_DIR you can
# specify the full path
#
# e.g. CLI_install/rpm/intel-vtune-amplifier-xe-cli
: ${INTEL_BIN_RPMS:=()}

# @ECLASS-VARIABLE: INTEL_AMD64_RPMS
# @DESCRIPTION:
# AMD64 single arch rpms. Same syntax as INTEL_BIN_RPMS
# Has to be a bash array
: ${INTEL_AMD64_RPMS:=()}

# @ECLASS-VARIABLE: INTEL_X86_RPMS
# @DESCRIPTION:
# X86 single arch rpms. Same syntax as INTEL_BIN_RPMS
# Has to be a bash array
: ${INTEL_X86_RPMS:=()}

# @ECLASS-VARIABLE: INTEL_DAT_RPMS
# @DESCRIPTION:
# Functional name of rpm of common data which are arch free
# without any version tag
# Has to be a bash array
#
# e.g. ("openmp-l-all-devel")
#
# if the rpm is located in a directory different to INTEL_RPMS_DIR you can
# specify the full path
#
# e.g. CLI_install/rpm/intel-vtune-amplifier-xe-cli-common
: ${INTEL_DAT_RPMS:=()}

# @ECLASS-VARIABLE: INTEL_SINGLE_ARCH
# @DESCRIPTION:
# Unset, if only the multilib package will be provided by intel
: ${INTEL_SINGLE_ARCH:=true}

MULTILIB_COMPAT=( abi_x86_{32,64} )

inherit check-reqs eutils multilib-build versionator

_INTEL_PV1=$(get_version_component_range 1)
_INTEL_PV2=$(get_version_component_range 2)
_INTEL_PV3=$(get_version_component_range 3)
_INTEL_PV4=$(get_version_component_range 4)
_INTEL_PV=""
[[ -n ${_INTEL_PV4} ]] && _INTEL_PV+="${_INTEL_PV4}-"
[[ -n ${_INTEL_PV1} ]] && _INTEL_PV+="${_INTEL_PV1}"
[[ -n ${_INTEL_PV2} ]] && _INTEL_PV+=".${_INTEL_PV2}"
[[ -n ${_INTEL_PV3} ]] && _INTEL_PV+=".${_INTEL_PV3}"
[[ -n ${_INTEL_PV4} ]] && _INTEL_PV+="-${_INTEL_PV4}"

_INTEL_URI="http://registrationcenter-download.intel.com/akdlm/irc_nas/${INTEL_DID}/${INTEL_DPN}"

if [ ${INTEL_SINGLE_ARCH} == true ]; then
	SRC_URI="
		abi_x86_32? ( ${_INTEL_URI}_${INTEL_DPV}_ia32.${INTEL_TARX} )
		abi_x86_64? ( ${_INTEL_URI}_${INTEL_DPV}_intel64.${INTEL_TARX} )"
else
	SRC_URI="${_INTEL_URI}_${INTEL_DPV}.${INTEL_TARX}"
fi

LICENSE="Intel-SDP"
# Future work, #394411
#SLOT="${_INTEL_PV1}.${_INTEL_PV2}"
SLOT="0"

RESTRICT="mirror"

RDEPEND=""
DEPEND="app-arch/rpm2targz"

_INTEL_SDP_YEAR=${INTEL_DPV}
_INTEL_SDP_YEAR=${_INTEL_SDP_YEAR%_sp*}
_INTEL_SDP_YEAR=${_INTEL_SDP_YEAR%_update*}

# @ECLASS-VARIABLE: INTEL_SDP_DIR
# @DESCRIPTION:
# Full rootless path to installation dir
INTEL_SDP_DIR="opt/intel/${INTEL_SUBDIR}_${_INTEL_SDP_YEAR:-${_INTEL_PV1}}"
[[ -n ${_INTEL_PV3} ]] && INTEL_SDP_DIR+=".${_INTEL_PV3}"
[[ -n ${_INTEL_PV4} ]] && INTEL_SDP_DIR+=".${_INTEL_PV4}"

# @ECLASS-VARIABLE: INTEL_SDP_EDIR
# @DESCRIPTION:
# Full rooted path to installation dir
INTEL_SDP_EDIR="${EROOT%/}/${INTEL_SDP_DIR}"

S="${WORKDIR}"

QA_PREBUILT="${INTEL_SDP_DIR}/*"

# @ECLASS-VARIABLE: INTEL_ARCH
# @DEFAULT_UNSET
# @DESCRIPTION:
# Intels internal names of the arches; will be set at runtime accordingly
#
# e.g. amd64-multilib -> INTEL_ARCH="intel64 ia32"

# @FUNCTION: _isdp_big-warning
# @USAGE: [pre-check | test-failed]
# @INTERNAL
# @DESCRIPTION:
# warn user that we really require a license
_isdp_big-warning() {
	debug-print-function ${FUNCNAME} "${@}"

	case ${1} in
		pre-check )
			echo ""
			ewarn "License file not found!"
			;;

		test-failed )
			echo ""
			ewarn "Function test failed. Most probably due to an invalid license."
			ewarn "This means you already tried to bypass the license check once."
			;;
	esac

	echo ""
	ewarn "Make sure you have received an Intel license."
	ewarn "To receive a non-commercial license, you need to register at:"
	ewarn "https://software.intel.com/en-us/qualify-for-free-software"
	ewarn "Install the license file into ${EPREFIX}/opt/intel/licenses"
	ewarn ""
	ewarn "Beginning with the 2016 suite of tools, license files are keyed"
	ewarn "to the MAC address of the eth0 interface. In order to retrieve"
	ewarn "a personalized license file, follow the instructions at"
	ewarn "https://software.intel.com/en-us/articles/how-do-i-get-my-license-file-for-intel-parallel-studio-xe-2016"

	case ${1} in
		pre-check )
			ewarn "before proceeding with installation of ${P}"
			echo ""
			;;
		* )
			echo ""
			;;
			esac
}

# @FUNCTION: _isdp_version_test
# @INTERNAL
# @DESCRIPTION:
# Testing for valid license by asking for version information of the compiler
_isdp_version_test() {
	debug-print-function ${FUNCNAME} "${@}"

	local comp comp_full arch warn
	case ${PN} in
		ifc )
			debug-print "Testing ifort"
			comp=ifort
			;;
		icc )
			debug-print "Testing icc"
			comp=icc
			;;
		*)
			die "${PN} is not supported for testing"
			;;
	esac

	for arch in ${INTEL_ARCH}; do
		case ${EBUILD_PHASE} in
			install )
				comp_full="${ED}/${INTEL_SDP_DIR}/linux/bin/${arch}/${comp}"
				;;
			postinst )
				comp_full="${INTEL_SDP_EDIR}/linux/bin/${arch}/${comp}"
				;;
			* )
				ewarn "Compile test not supported in ${EBUILD_PHASE}"
				continue
				;;
		esac

		debug-print "LD_LIBRARY_PATH=\"${INTEL_SDP_EDIR}/linux/bin/${arch}/\" \"${comp_full}\" -V"

		LD_LIBRARY_PATH="${INTEL_SDP_EDIR}/linux/bin/${arch}/" "${comp_full}" -V &>/dev/null
		[[ $? -ne 0 ]] && warn=yes
	done
	[[ "${warn}" == "yes" ]] && _isdp_big-warning test-failed
}

# @FUNCTION: _isdp_run-test
# @INTERNAL
# @DESCRIPTION:
# Test if installed compiler is working
_isdp_run-test() {
	debug-print-function ${FUNCNAME} "${@}"

	if [[ -z ${INTEL_SKIP_LICENSE} ]]; then
		case ${PN} in
			ifc | icc )
				_isdp_version_test ;;
			* )
				debug-print "No test available for ${PN}"
				;;
		esac
	fi
}

# @FUNCTION: convert2intel_arch
# @USAGE: <arch>
# @DESCRIPTION:
# Convert between portage arch (e.g. amd64, x86) and intel arch
# nomenclature (e.g. intel64, ia32)
convert2intel_arch() {
	debug-print-function ${FUNCNAME} "${@}"

	case $1 in
		amd64|abi_x86_64|*amd64*)
			echo "intel64"
			;;
		x86|abi_x86_32|*x86*)
			echo "ia32"
			;;
		*)
			die "Abi \'$1\' is unsupported"
			;;
	esac
}

# @FUNCTION: intel-sdp-r1_pkg_pretend
# @DESCRIPTION:
# @CODE
# * Check that the user has a (valid) license file before going on.
# * Check for space requirements being fullfilled
# @CODE
intel-sdp-r1_pkg_pretend() {
	debug-print-function ${FUNCNAME} "${@}"

	local warn=1 dir dirs ret arch a p

	: ${CHECKREQS_DISK_BUILD:=256M}
	check-reqs_pkg_pretend

	if [[ -z ${INTEL_SKIP_LICENSE} ]]; then
		if echo ${INTEL_LICENSE_FILE} | grep -q @; then
			einfo "Looks like you are using following license server:"
			einfo "   ${INTEL_LICENSE_FILE}"
			return 0
		fi

		dirs=(
			"${EPREFIX}/opt/intel/licenses"
			"${INTEL_SDP_EDIR}/licenses"
			"${INTEL_SDP_EDIR}/Licenses"
			)
		for dir in "${dirs[@]}" ; do
			ebegin "Checking for a license in: ${dir}"
			#maybe use nullglob or [[ $(echo ${dir/*lic) != "${dir}/*lic" ]]
			[[ $( ls "${dir}"/*lic 2>/dev/null ) ]]; ret=$?
			eend ${ret}
			if [[ ${ret} == "0" ]]; then
				warn=${ret}
				break
			fi
		done
		if [[ ${warn} == "1" ]]; then
			_isdp_big-warning pre-check
			die "Could not find license file"
		fi
	else
		eqawarn "The ebuild doesn't check for presence of a proper intel license!"
		eqawarn "This shouldn't be done unless there is a very good reason."
	fi
}

# @FUNCTION: intel-sdp-r1_pkg_setup
# @DESCRIPTION:
# Setting up and sorting some internal variables
intel-sdp-r1_pkg_setup() {
	debug-print-function ${FUNCNAME} "${@}"
	local arch a p

	INTEL_ARCH=""

	if use abi_x86_64; then
		arch+=" x86_64"
		INTEL_ARCH+=" intel64"
	fi
	if use abi_x86_32; then
		arch+=" ${INTEL_X86}"
		INTEL_ARCH+=" ia32"
	fi
	INTEL_RPMS=()
	INTEL_RPMS_FULL=()

	for p in "${INTEL_BIN_RPMS[@]}"; do
		for a in ${arch}; do
			if [ ${p} == $(basename ${p}) ]; then
				# check for variables ending in ".rpm"
				# these are excluded from version expansion, due to Intel's
				# idiosyncratic versioning scheme beginning with their 2016
				# suite of tools.
				if [[ "${p}" == *.rpm ]]; then
					INTEL_RPMS+=( intel-${p} )
				else
					INTEL_RPMS+=( intel-${p}-${_INTEL_PV}.${a}.rpm )
				fi
			else
				if [[ "${p}" == *.rpm ]]; then
					INTEL_RPMS_FULL+=( ${p} )
				else
					INTEL_RPMS_FULL+=( ${p}-${_INTEL_PV}.${a}.rpm )
				fi
			fi
		done
	done

	if use amd64; then
		for p in "${INTEL_AMD64_RPMS[@]}"; do
			if [ ${p} == $(basename ${p}) ]; then
				if [[ "${p}" == *.rpm ]]; then
					INTEL_RPMS+=( intel-${p} )
				else
					INTEL_RPMS+=( intel-${p}-${_INTEL_PV}.x86_64.rpm )
				fi
			else
				if [[ "${p}" == *.rpm ]]; then
					INTEL_RPMS_FULL+=( ${p} )
				else
					INTEL_RPMS_FULL+=( ${p}-${_INTEL_PV}.x86_64.rpm )
				fi
			fi
		done
	fi

	for p in "${INTEL_X86_RPMS[@]}"; do
		if [ ${p} == $(basename ${p}) ]; then
			if [[ "${p}" == *.rpm ]]; then
				INTEL_RPMS+=( intel-${p} )
			else
				INTEL_RPMS+=( intel-${p}-${_INTEL_PV}.${INTEL_X86}.rpm )
			fi
		else
			if [[ "${p}" == *.rpm ]]; then
				INTEL_RPMS_FULL+=( ${p} )
			else
				INTEL_RPMS_FULL+=( ${p}-${_INTEL_PV}.${INTEL_X86}.rpm )
			fi
		fi
	done

	for p in "${INTEL_DAT_RPMS[@]}"; do
		if [ ${p} == $(basename ${p}) ]; then
			if [[ "${p}" == *.rpm ]]; then
				INTEL_RPMS+=( intel-${p} )
			else
				INTEL_RPMS+=( intel-${p}-${_INTEL_PV}.noarch.rpm )
			fi
		else
			if [[ "${p}" == *.rpm ]]; then
				INTEL_RPMS_FULL+=( ${p} )
			else
				INTEL_RPMS_FULL+=( ${p}-${_INTEL_PV}.noarch.rpm )
			fi
		fi
	done
}

# @FUNCTION: intel-sdp-r1_src_unpack
# @DESCRIPTION:
# Unpacking necessary rpms from tarball, extract them and rearrange the output.
intel-sdp-r1_src_unpack() {
	local l r subdir rb t list=() debug_list

	for t in ${A}; do
		for r in "${INTEL_RPMS[@]}"; do
			rpmdir=${t%%.*}/${INTEL_RPMS_DIR}
			list+=( ${rpmdir}/${r} )
		done

		for r in "${INTEL_RPMS_FULL[@]}"; do
			list+=( ${t%%.*}/${r} )
		done

		debug_list="$(IFS=$'\n'; echo ${list[@]} )"

		debug-print "Adding to decompression list:"
		debug-print ${debug_list}

		tar xvf "${DISTDIR}"/${t} ${list[@]} &> "${T}"/rpm-extraction.log

		for r in ${list[@]}; do
			rb=$(basename ${r})
			einfo "Unpacking ${rb}"
			rpm2tar -O ${r} | tar xvf - | sed -e \
				"s:^\.:${EROOT#/}:g" > /dev/null; assert "unpacking ${r} failed"
		done
	done
}

# @FUNCTION: intel-sdp-r1_src_install
# @DESCRIPTION:
# Install everything
intel-sdp-r1_src_install() {
	debug-print-function ${FUNCNAME} "${@}"

	# remove uninstall information
	if path_exists opt/intel/"${INTEL_DPN}"*/uninstall; then
		ebegin "Cleaning out uninstall"
		rm -r opt/intel/"${INTEL_DPN}"*/uninstall || die
		eend
	fi

	# handle documentation
	if path_exists "opt/intel/documentation_${_INTEL_SDP_YEAR}"; then
		if path_exists "opt/intel/documentation_${_INTEL_SDP_YEAR}/en/man/common/man1"; then
			doman opt/intel/documentation_"${_INTEL_SDP_YEAR}"/en/man/common/man1/*
			rm -r opt/intel/documentation_"${_INTEL_SDP_YEAR}"/en/man || die
		fi

		if use doc; then
			if ! use linguas_ja; then
				rm -r opt/intel/documentation_"${_INTEL_SDP_YEAR}"/ja || die
			fi
			dodoc -r opt/intel/documentation_"${_INTEL_SDP_YEAR}"/*
		fi

		ebegin "Cleaning out documentation"
		rm -r "opt/intel/documentation_${_INTEL_SDP_YEAR}" || die
		rm "${INTEL_SDP_DIR}"/linux/{documentation,man} || die
		eend
	fi

	# handle examples
	if path_exists "opt/intel/samples_${_INTEL_SDP_YEAR}"; then
		if use examples; then
			if ! use linguas_ja; then
				rm -r opt/intel/samples_"${_INTEL_SDP_YEAR}"/ja || die
			fi
			dodoc -r opt/intel/samples_"${_INTEL_SDP_YEAR}"/*
		fi

		ebegin "Cleaning out examples"
		rm -r "opt/intel/samples_${_INTEL_SDP_YEAR}" || die
		eend
	fi

	# remove eclipse
	rm -rf opt/intel/ide_support_* || die

	ebegin "Tagging ${PN}"
	find opt -name \*sh -type f -exec sed -i \
		-e "s:<.*DIR>:${INTEL_SDP_EDIR}/linux:g" \
		'{}' + || die
	eend

	[[ -d "${ED}" ]] || dodir /
	mv opt "${ED}"/ || die "moving files failed"

	dodir "${INTEL_SDP_DIR}"/licenses /opt/intel/ism/rm
	keepdir "${INTEL_SDP_DIR}"/licenses /opt/intel/ism/rm
}

# @FUNCTION: intel-sdp-r1_pkg_postinst
# @DESCRIPTION:
# Test for all things working
intel-sdp-r1_pkg_postinst() {
	debug-print-function ${FUNCNAME} "${@}"

	_isdp_run-test

	if [[ ${PN} = icc ]] && has_version ">=dev-util/ccache-3.1.9-r2" ; then
		#add ccache links as icc might get installed after ccache
		"${EROOT}"/usr/bin/ccache-config --install-links
	fi

	elog "Beginning with the 2016 suite of Intel tools, Gentoo has removed"
	elog "support for the eclipse plugin. If you require the IDE support,"
	elog "you will have to install the suite on your own, outside portage."
}

# @FUNCTION: intel-sdp-r1_pkg_postrm
# @DESCRIPTION:
# Sanitize cache links
intel-sdp-r1_pkg_postrm() {
	debug-print-function ${FUNCNAME} "${@}"

	if [[ ${PN} = icc ]] && has_version ">=dev-util/ccache-3.1.9-r2" && [[ -z ${REPLACED_BY_VERSION} ]]; then
		# --remove-links would remove all links, --install-links updates them
		"${EROOT}"/usr/bin/ccache-config --install-links
	fi
}

EXPORT_FUNCTIONS pkg_setup src_unpack src_install pkg_postinst pkg_postrm pkg_pretend

_INTEL_SDP_R1_ECLASS_=1
fi