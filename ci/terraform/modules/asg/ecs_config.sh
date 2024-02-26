#!/bin/bash

exec > >(tee -a ${LOG_FILE} )
exec 2> >(tee -a ${LOG_FILE} >&2)

yum update -y
yum install -y ecs-init
echo ECS_CLUSTER=${ECS_CLUSTER}-ecs-cluster >> /etc/ecs/ecs.config
systemctl enable --now --no-block ecs.service
echo Finished executing!