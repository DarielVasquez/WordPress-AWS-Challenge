#!/bin/bash

apt-get update
apt-get upgrade -y

apt-get install -y awscli
apt-get install -y docker.io
apt-get install -y docker-compose
aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REPOSITORY_URL}
echo "version: \"3\"

services:
  mysql:
    container_name: mysql
    image: mysql:5.7
    volumes:
      - db_data:/var/lib/mysql
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: password
      MYSQL_DATABASE: wordpress_db
      MYSQL_USER: wordpress_user
      MYSQL_PASSWORD: password
  wordpress:
    container_name: wordpress
    depends_on:
      - mysql
    image: ${ECR_REPOSITORY_URL}:${DOCKER_IMAGE_TAG}
    ports:
      - \"80:80\"
    restart: always

volumes:
  db_data: {}" > docker-compose.yml
docker pull ${ECR_REPOSITORY_URL}:${DOCKER_IMAGE_TAG}
docker-compose up -d

echo Finished executing!