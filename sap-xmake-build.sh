#!/bin/bash -l

# find this script and establish base directory
SCRIPT_DIR="$( dirname "${BASH_SOURCE[0]}" )"
cd "$SCRIPT_DIR" &> /dev/null
MY_DIR="$(pwd)"
echo "[INFO] Executing in ${MY_DIR}"

# PATH does not contain ant in this login shell
export M2_HOME=/opt/mvn3
export JAVA_HOME=/opt/sapjvm_7
export FORREST_HOME=/opt/apache-forrest
export PATH=$M2_HOME/bin:$JAVA_HOME/bin:/opt/apache-ant/bin:$PATH


#------------------------------------------------------------------------------
#
#  ***** compile and package pig *****
#
#------------------------------------------------------------------------------

PIG_VERSION="${PIG_VERSION:-0.16.0}"
export ARTIFACT_VERSION="$PIG_VERSION"

ant -Dforrest.home=/opt/apache-forrest -Dant.home=/opt/apache-ant/ -Dversion=${ARTIFACT_VERSION} -Dhadoopversion=23 clean jar
pushd contrib/piggybank/java
ant -Dhadoopversion=23
popd
ant -Dforrest.home=/opt/apache-forrest -Dant.home=/opt/apache-ant/ -Dversion=${ARTIFACT_VERSION} -Dhadoopversion=23 tar

#------------------------------------------------------------------------------
#
#  ***** setup the environment generating RPM via fpm *****
#
#------------------------------------------------------------------------------

ALTISCALE_RELEASE="${ALTISCALE_RELEASE:-5.0.0}"
DATE_STRING=`date +%Y%m%d%H%M%S`
GIT_REPO="https://github.com/Altiscale/pig"

INSTALL_DIR="$MY_DIR/pigrpmbuild"
mkdir --mode=0755 -p ${INSTALL_DIR}

export RPM_NAME=`echo alti-pig-${ARTIFACT_VERSION}`
export RPM_DESCRIPTION="Apache Pig ${ARTIFACT_VERSION}\n\n${DESCRIPTION}"
export RPM_DIR="${RPM_DIR:-"${INSTALL_DIR}/pig-artifact/"}"
mkdir --mode=0755 -p ${RPM_DIR}

echo "Packaging pig rpm with name ${RPM_NAME} with version ${ARTIFACT_VERSION}-${DATE_STRING}"

export RPM_BUILD_DIR="${INSTALL_DIR}/opt/pig-${PIG_VERSION}"
mkdir --mode=0755 -p ${RPM_BUILD_DIR}
mkdir --mode=0755 -p ${INSTALL_DIR}/etc/pig
cd ${RPM_BUILD_DIR}
mkdir --mode=0755 lib

cd ${RPM_DIR}

fpm --verbose \
--maintainer ops@verticloud.com \
--vendor Altiscale \
--provides ${RPM_NAME} \
--description "${DESCRIPTION}" \
--replaces alti-pig_${ARTIFACT_VERSION} \
--replaces vcc-pig \
--url "${GITREPO}" \
--license "Apache License v2" \
--epoch 1 \
-s dir \
-t rpm \
-n ${RPM_NAME} \
-v ${ALTISCALE_RELEASE} \
--iteration ${DATE_STRING} \
--rpm-user root \
--rpm-group root \
-C ${INSTALL_DIR} \
opt etc

exit 0