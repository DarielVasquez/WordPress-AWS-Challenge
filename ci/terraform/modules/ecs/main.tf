resource "aws_ecs_cluster" "cluster" {
  name = "${var.name_prefix}-ecs-cluster"
  tags = {
    "Name"        = "${var.name_prefix}-wordpress"
    "DevOps"      = var.devops_tag
    "Project"     = var.project_tag
    "Environment" = var.env_tag
  }
}

resource "aws_ecs_task_definition" "mysql" {
  family                   = "${var.name_prefix}-mysql-task"
  network_mode             = "awsvpc"
  # requires_compatibilities = ["EC2"]
  cpu                      = "512"
  memory                   = "768"
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
        name  = "mysql"
        image = "mysql:5.7"
        portMappings = [{
            containerPort = 3306,
            hostPort      = 3306,
        }]
        environment = [
            { name = "SERVICE_NAME", value = "mysql" },
        ]
        secrets = [
            { name = "MYSQL_ROOT_PASSWORD", valueFrom = "${aws_secretsmanager_secret.mysql_secrets.arn}:MYSQL_ROOT_PASSWORD::"},
            { name = "MYSQL_DATABASE", valueFrom = "${aws_secretsmanager_secret.mysql_secrets.arn}:MYSQL_DATABASE::"},
            { name = "MYSQL_USER", valueFrom = "${aws_secretsmanager_secret.mysql_secrets.arn}:MYSQL_USER::"},
            { name = "MYSQL_PASSWORD", valueFrom = "${aws_secretsmanager_secret.mysql_secrets.arn}:MYSQL_PASSWORD::"},
        ]
        mountPoints = [{
            containerPath = "/var/lib/mysql",
            sourceVolume  = "mysql-data",
        }]
        logConfiguration = {
          logDriver = "awslogs"
          options = {
            "awslogs-group"         = aws_cloudwatch_log_group.cloudwatch_log.name
            "awslogs-region"        = "us-east-1"
            "awslogs-stream-prefix" = "ecs"
          }
        }
        essential = true
    }
  ])

  volume {
    name = "mysql-data"
  }

  tags = {
    "Name"        = "${var.name_prefix}-wordpress"
    "DevOps"      = var.devops_tag
    "Project"     = var.project_tag
    "Environment" = var.env_tag
  }
}

resource "aws_ecs_task_definition" "wordpress" {
  family                   = "${var.name_prefix}-wordpress-task"
  network_mode             = "awsvpc"
  # requires_compatibilities = ["EC2"]
  cpu                      = "512"
  memory                   = "768"
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
        name  = "wordpress"
        image = var.ecs_image
        portMappings = [{
            containerPort = 80,
            hostPort      = 80,
        }]
        environment = [
            { name = "DB_HOST", value = "${aws_service_discovery_service.mysql_service.name}.${aws_service_discovery_private_dns_namespace.namespace.name}" },         
            { name = "SERVICE_NAME", value = "wordpress" },
        ]
        secrets = [
            { name = "MYSQL_DATABASE", valueFrom = "${aws_secretsmanager_secret.mysql_secrets.arn}:MYSQL_DATABASE::"},
            { name = "MYSQL_USER", valueFrom = "${aws_secretsmanager_secret.mysql_secrets.arn}:MYSQL_USER::"},
            { name = "MYSQL_PASSWORD", valueFrom = "${aws_secretsmanager_secret.mysql_secrets.arn}:MYSQL_PASSWORD::"},
        ]
        logConfiguration = {
          logDriver = "awslogs"
          options = {
            "awslogs-group"         = aws_cloudwatch_log_group.cloudwatch_log.name
            "awslogs-region"        = "us-east-1"
            "awslogs-stream-prefix" = "ecs"
          }
        }
        essential = true
    }
  ])

  tags = {
    "Name"        = "${var.name_prefix}-wordpress"
    "DevOps"      = var.devops_tag
    "Project"     = var.project_tag
    "Environment" = var.env_tag
  }
}

resource "aws_ecs_service" "mysql" {
  name            = "${var.name_prefix}-mysql-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.mysql.arn
  # launch_type     = "EC2"
  desired_count   = 1
  force_new_deployment = true

  network_configuration {
    subnets          = [var.public_subnet, var.public_subnet_2]
    security_groups  = [var.security_group]
  }

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.ecs_capacity_provider.name
    weight            = 100
    base              = 1
  }

  service_registries {
    registry_arn = aws_service_discovery_service.mysql_service.arn
  }

  tags = {
    "Name"        = "${var.name_prefix}-wordpress"
    "DevOps"      = var.devops_tag
    "Project"     = var.project_tag
    "Environment" = var.env_tag
  }

  depends_on = [ var.asg ]
}

resource "aws_ecs_service" "wordpress" {
  name            = "${var.name_prefix}-wordpress-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.wordpress.arn
  # launch_type     = "EC2"
  desired_count   = 1
  force_new_deployment = true

  network_configuration {
    subnets          = [var.public_subnet, var.public_subnet_2]
    security_groups  = [var.security_group]
  }

  load_balancer {
    target_group_arn = var.target_group
    container_name   = "wordpress"
    container_port   = 80
  }

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.ecs_capacity_provider.name
    weight            = 100
    base              = 1
  }

  service_registries {
    registry_arn = aws_service_discovery_service.wordpress_service.arn
  }

  tags = {
    "Name"        = "${var.name_prefix}-wordpress"
    "DevOps"      = var.devops_tag
    "Project"     = var.project_tag
    "Environment" = var.env_tag
  }

  depends_on = [ var.asg ]
}

resource "aws_ecs_capacity_provider" "ecs_capacity_provider" {
 name = "${var.name_prefix}-capacity-provider"

 auto_scaling_group_provider {
   auto_scaling_group_arn = var.asg_arn

   managed_scaling {
     maximum_scaling_step_size = 1000
     minimum_scaling_step_size = 1
     status                    = "ENABLED"
     target_capacity           = 1
   }
 }
}

resource "aws_ecs_cluster_capacity_providers" "cluster_capacity_provider" {
 cluster_name = aws_ecs_cluster.cluster.name

 capacity_providers = [aws_ecs_capacity_provider.ecs_capacity_provider.name]

#  default_capacity_provider_strategy {
#    base              = 1
#    weight            = 100
#    capacity_provider = aws_ecs_capacity_provider.ecs_capacity_provider.name
#  }
}

resource "aws_service_discovery_private_dns_namespace" "namespace" {
  name = "${var.name_prefix}-namespace"
  vpc = var.vpc
}

resource "aws_service_discovery_service" "mysql_service" {
  name    = "mysql"
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.namespace.id
    dns_records {
      ttl  = 10
      type = "A"
    }
  }
}

resource "aws_service_discovery_service" "wordpress_service" {
  name    = "wordpress"
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.namespace.id
    dns_records {
      ttl  = 10
      type = "A"
    }
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.name_prefix}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com",
        },
      },
    ],
  })

  tags = {
    "Name"        = "${var.name_prefix}-wordpress"
    "DevOps"      = var.devops_tag
    "Project"     = var.project_tag
    "Environment" = var.env_tag
  } 
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.ecs_task_execution_role.name
}

resource "aws_iam_policy" "ecs_task_secrets_access_policy" {
  name        = "${var.name_prefix}-ecs-task-secrets-access-policy"
  description = "Policy for ECS task to access secrets in Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["secretsmanager:GetSecretValue"],
        Resource = [aws_secretsmanager_secret.mysql_secrets.arn],
      },
    ],
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_secrets_policy_attachment" {
  policy_arn = aws_iam_policy.ecs_task_secrets_access_policy.arn
  role       = aws_iam_role.ecs_task_execution_role.name
}

resource "random_password" "mysql_password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "random_password" "mysql_root_password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "aws_secretsmanager_secret" "mysql_secrets" {
  name = "${var.name_prefix}-mysql-secrets"
  recovery_window_in_days = 0
  tags = {
    "Name"        = "${var.name_prefix}-wordpress"
    "DevOps"      = var.devops_tag
    "Project"     = var.project_tag
    "Environment" = var.env_tag
  } 
}

resource "aws_secretsmanager_secret_version" "mysql_secrets" {
  secret_id     = aws_secretsmanager_secret.mysql_secrets.id
  secret_string = jsonencode({
    "MYSQL_PASSWORD"      : random_password.mysql_password.result,
    "MYSQL_ROOT_PASSWORD" : random_password.mysql_root_password.result
    "MYSQL_DATABASE"      : var.mysql_database
    "MYSQL_USER"          : var.mysql_user
  })
}

resource "aws_cloudwatch_log_group" "cloudwatch_log" {
  name = "${var.name_prefix}-cloudwatch-log"

  tags = {
    "Name"        = "${var.name_prefix}-wordpress"
    "DevOps"      = var.devops_tag
    "Project"     = var.project_tag
    "Environment" = var.env_tag
  } 
}