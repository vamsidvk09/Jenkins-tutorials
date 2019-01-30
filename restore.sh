#!/bin/sh
set -x
set -e

export DATE=${DATE:-`date --date='yesterday' +%Y-%m-%d`}
export ARTIFACTORY_URL=" https://devcloud.swcoe.ge.com/artifactory/OQRWN/com/ge/ss/jenkins/backup/"

# set correct mask
umask 644

#set variables unless set
JENKINS_HOME=${JENKINS_HOME:-'/root/jenkins/data'}

curl -u ${ARTIFACTORY_USER}:${ARTIFACTORY_PASSWORD} ${ARTIFACTORY_URL}jenkins_${DATE}.zip -o jenkins_${DATE}.zip

chmod 755 jenkins_${DATE}.zip
unzip -qo jenkins_${DATE}.zip

rm -f jenkins_${DATE}.zip

cd $DATE
yes | cp -rf * $JENKINS_HOME

chown -R jenkins:jenkins $JENKINS_HOME
