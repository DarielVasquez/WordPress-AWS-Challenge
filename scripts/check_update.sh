#!/bin/bash

source variables.sh

DOCKER_CONTAINER_NAME="wordpress"

sudo docker pull ${ECR_REPOSITORY_URL}:${DOCKER_IMAGE_TAG}
# sudo docker stop ${DOCKER_CONTAINER_NAME}
# sudo docker rm -f ${DOCKER_CONTAINER_NAME}
sudo docker-compose down

# sudo docker run -d --name ${DOCKER_CONTAINER_NAME} -p 80:80 ${ECR_REPOSITORY_URL}:${DOCKER_IMAGE_TAG}
sudo docker-compose up -d

# GITLAB_API_URL="https://gitlab.com/api/v4"
# GITLAB_PROJECT_ID="53531030"
# GITLAB_JOB_NAME="build"

# # Check if the CI/CD pipeline has succeeded
# PIPELINE_STATUS=$(curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" "$GITLAB_API_URL/projects/$GITLAB_PROJECT_ID/pipelines?ref=main" | jq -r '.[0].status')

# if [ "$PIPELINE_STATUS" == "success" ]; then
#   # Set the image name and tag
#   IMAGE_NAME="darielv/wordpress"
#   IMAGE_TAG="latest"

#   # Pull the latest Docker image
#   docker pull ${IMAGE_NAME}:${IMAGE_TAG}

#   # Stop and remove the existing container (if any)
#   docker stop wordpress
#   docker rm wordpress

#   # Run a new container with the updated image
#   docker run -d --name wordpress -p 80:80 ${IMAGE_NAME}:${IMAGE_TAG}
# else
#   echo "CI/CD pipeline has not succeeded. Skipping deployment."
# fi