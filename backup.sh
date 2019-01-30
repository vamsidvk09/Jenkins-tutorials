#!/bin/sh

export DATE=`date +%Y-%m-%d`
export filesToKeep=30
export ARTIFACTORY_URL="https://devcloud.swcoe.ge.com/artifactory/OQRWN/com/ge/ss/jenkins/backup/"

#set variables unless set
JENKINS_HOME=${JENKINS_HOME:-'/root/jenkins/data'}

# Create a directory for the job definitions
mkdir -p $DATE/jobs

# Copy global configuration files into the workspace
cp $JENKINS_HOME/*.xml $DATE/

# Copy keys and secrets into the workspace
cp $JENKINS_HOME/identity.key.enc $DATE/
cp $JENKINS_HOME/secret.key $DATE/
cp $JENKINS_HOME/secret.key.not-so-secret $DATE/
cp -r $JENKINS_HOME/secrets $DATE/

# Copy user configuration files into the workspace
cp -r $JENKINS_HOME/users $DATE/

# Copy custom Pipeline workflow libraries
cp -r $JENKINS_HOME/workflow-libs $DATE

# Copy job definitions into the workspace
rsync -am --include='config.xml' --include='*/' --prune-empty-dirs --exclude='*' --exclude='.git/' --exclude='node_modules/' --exclude='bower/' $JENKINS_HOME/jobs/ $DATE/jobs/

# Create an archive from all copied files
zip -r jenkins_${DATE}.zip $DATE/

# Remove the directory so only the tar.gz gets copied to server
rm -rf $DATE

curl -u ${ARTIFACTORY_USER}:${ARTIFACTORY_PASSWORD} -X PUT ${ARTIFACTORY_URL} -T jenkins_${DATE}.zip

rm -rf jenkins_${DATE}.zip

# Delete older than 30 days
files=`curl --silent -u ${ARTIFACTORY_USER}:${ARTIFACTORY_PASSWORD} "${ARTIFACTORY_URL}" | grep -o ">jenkins_[0-9\-]*.zip</a>" | grep -o "jenkins_[0-9\-]*.zip"`
echo $files


rmFiles=($files)
echo $filesToKeep

filesKept=0
for ((i=${#rmFiles[@]}-1; i>=0; i--)); do
    if (($filesKept >= $filesToKeep)); then
        echo "Deleting ${rmFiles[$i]}"
        curl --silent -u ${ARTIFACTORY_USER}:${ARTIFACTORY_PASSWORD} -X DELETE ${ARTIFACTORY_URL}${files[$i]}
    else
        echo "Keeping ${rmFiles[$i]}"
        filesKept=$((filesKept+1))
    fi
done
