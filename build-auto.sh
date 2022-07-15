#!/bin/bash
set -euo pipefail

function get-package-version {
	OCP_RELEASE="${1}"
	PACKAGE="${2}"
	
	OCP_MAJOR="$(echo "${OCP_RELEASE}" | awk -F. '{print $1"."$2}')"
	RHCOS_VERSION="$(oc adm release info "${OCP_RELEASE}" -o jsonpath='{.displayVersions.machine-os.Version}')"
	
	curl -sk "https://releases-rhcos-art.cloud.privileged.psi.redhat.com/storage/releases/rhcos-${OCP_MAJOR}/${RHCOS_VERSION}/x86_64/commitmeta.json" | jq -r '.["rpmostree.rpmdb.pkglist"]|map(select(.[0]=="'"${PACKAGE}"'"))[0]'
}

function get-rhelver {
        OCP_RELEASE="${1}"

        RHCOS_VERSION="$(oc adm release info "${OCP_RELEASE}" -o jsonpath='{.displayVersions.machine-os.Version}')"

	    RHELVER_FOUND="$(echo "${RHCOS_VERSION}" | awk -F. '{version=gensub("^8([0-9]*)$","8.\\1","g",$2);print version}')"
	    echo -n "${RHELVER_FOUND}"
}

if [[ $# -lt 1 ]] || [[ $# -gt 2 ]]
then
	echo "Usage: ./build-auto.sh <OCP-version> [<image-tag>]"
	exit 1
fi

OCP_VERSION="${1}"

TAG="${2:-stap-image:${OCP_VERSION}}"

echo "Building for OCP version ${OCP_VERSION}"

VERSION=$(get-package-version "${1}" kernel | jq -r '.[2]+"-"+.[3]+"."+.[4]')
echo "Detected kernel version ${VERSION}"

FW=$(get-package-version "${1}" linux-firmware | jq -r '.[2]+"-"+.[3]')
echo "Detected firmware version ${FW}"

RHELVER=$(get-rhelver "${OCP_VERSION}")
echo "Detected RHEL version ${RHELVER}"

echo

./build.sh "${VERSION}" "${FW}" "${RHELVER}" "${TAG}"
