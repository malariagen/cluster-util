#!/bin/bash

# Do a Packer build

TARFILE=malariagen-ldap.tar
IMAGE_NAME=malariagen-ldap
IMAGE_ID=last_malariagen-cas

rm -f ${TARFILE}

packer build -only docker ldap-only.json

# Get the latest base image ID
LAST_IMPORT=`cat ${IMAGE_ID}`

# Import build artifact as Docker image
echo "Importing the newly built image into docker..."
docker import - ${IMAGE_NAME} < ${TARFILE} > ${IMAGE_ID}

# Delete the previous base image
echo "Removing the old base image..."
docker rmi $LAST_IMPORT

# Build a new production Docker image using metadata only Dockerfile
echo "Add in Docker metadata"
docker build -rm -t="mmckeen_net_prod"  dockerfiles/
echo "Final mmckeen_net_prod image built, ready for docker run"

echo "Restarting mmckeen.net through supervisorctl"
supervisorctl restart mmckeen.net


