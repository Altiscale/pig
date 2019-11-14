#!/bin/sh -ex

# find this script and establish base directory
SCRIPT_DIR="$( dirname "${BASH_SOURCE[0]}" )"
cd "$SCRIPT_DIR" &> /dev/null
MY_DIR="$(pwd)"
echo "[INFO] Executing in ${MY_DIR}"

cd ${MY_DIR}/pig

ant -Dforrest.home=/opt/apache-forrest -Dant.home=/opt/apache-ant/ -Dversion=${ARTIFACT_VERSION} -Dhadoopversion=23 clean jar
pushd contrib/piggybank/java
ant -Dhadoopversion=23
popd
ant -Dforrest.home=/opt/apache-forrest -Dant.home=/opt/apache-ant/ -Dversion=${ARTIFACT_VERSION} -Dhadoopversion=23 tar

exit 0