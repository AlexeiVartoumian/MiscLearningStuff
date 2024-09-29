provider "aws" {
  region = var.aws_region
}

# Variables
variable "aws_region" {
  default = "eu-west-2"
}

variable "vpc_id" {
  description = "VPC ID where the ECS task will run"
  default     = "vpc-0b17276edbeed6724"
}

variable "subnet_ids" {
  description = "List of subnet IDs where the ECS task can be run"
  type        = list(string)
  default     = ["subnet-05806a01860749cc7"]
}

variable "s3_bucket" {
  description = "S3 bucket containing Ansible playbooks"
}

variable "s3_key" {
  description = "S3 key for the Ansible playbook zip file"
}

variable "http_proxy" {
  default = ""
}

variable "https_proxy" {
  default = ""
}

# Data sources for existing VPC and subnet
data "aws_vpc" "existing" {
  id = var.vpc_id
}

data "aws_subnet" "existing" {
  id = var.subnet_ids[0]
}

# IAM Role for ECS Task
resource "aws_iam_role" "ecs_task_role" {
  name = "ecs_ansible_task_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy for ECS Task Role
resource "aws_iam_role_policy" "ecs_task_policy" {
  name = "ecs_ansible_task_policy"
  role = aws_iam_role.ecs_task_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.s3_bucket}",
          "arn:aws:s3:::${var.s3_bucket}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeVpcs",
          "ec2:CreateVpc",
          "ec2:CreateSubnet",
          "ec2:CreateSecurityGroup",
          "ec2:CreateInternetGateway",
          "ec2:AttachInternetGateway",
          "ec2:RunInstances",
          "ec2:CreateKeyPair"
        ]
        Resource = "*"
      }
    ]
  })
}

# ECS Task Execution Role
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs_ansible_task_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

# Attach the AmazonECSTaskExecutionRolePolicy to the execution role
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECS Cluster
resource "aws_ecs_cluster" "ansible_cluster" {
  name = "ansible-cluster"
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "ansible_task" {
  name              = "/ecs/ansible-task"
  retention_in_days = 7
}

resource "aws_ecs_task_definition" "ansible_task" {
  family                   = "ansible-proxy-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "ansible-container"
      image     = "ansible/ansible-runner"
      essential = true
      command   = [
        "sh", 
        "-c", 
        "export HTTP_PROXY=$HTTP_PROXY HTTPS_PROXY=$HTTPS_PROXY NO_PROXY=$NO_PROXY && \
         pip install --proxy $HTTP_PROXY awscli && \
         aws --endpoint-url https://s3.$AWS_DEFAULT_REGION.amazonaws.com s3 cp s3://${var.s3_bucket}/${var.s3_key} . && \
         unzip ${var.s3_key} && \
         cd playbook && \
         ansible-galaxy collection install -r requirements.yml && \
         ansible-playbook $PLAYBOOK_NAME"
      ]
      environment = [
        { name = "S3_BUCKET", value = var.s3_bucket },
        { name = "S3_KEY", value = var.s3_key },
        { name = "HTTP_PROXY", value = var.http_proxy },
        { name = "HTTPS_PROXY", value = var.https_proxy },
        { name = "NO_PROXY", value = "169.254.169.254,169.254.170.2,/var/run/docker.sock" },
        { name = "AWS_DEFAULT_REGION", value = var.aws_region },
        { name = "PLAYBOOK_NAME", value = "main.yml" }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ansible_task.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}
resource "aws_lambda_function" "ecs_task_trigger" {
  filename      = "lambda_function.zip"
  function_name = "ecs-ansible-task-trigger"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"

  environment {
    variables = {
      ECS_CLUSTER_NAME    = aws_ecs_cluster.ansible_cluster.name
      ECS_TASK_DEFINITION = aws_ecs_task_definition.ansible_task.arn
      SUBNET_ID           = var.subnet_ids[0]
      SECURITY_GROUP_ID   = aws_security_group.ecs_tasks.id
    }
  }
}

resource "aws_iam_role" "lambda_exec" {
  name = "lambda_ecs_task_trigger"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_exec_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_run_task_policy" {
  name = "lambda_run_ecs_task"
  role = aws_iam_role.lambda_exec.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecs:RunTask",
          "iam:PassRole"
        ]
        Resource = "*"
      }
    ]
  })
}
# Security Group for ECS Tasks
resource "aws_security_group" "ecs_tasks" {
  name        = "ansible-ecs-tasks-sg"
  description = "Allow outbound traffic for ECS tasks"
  vpc_id      = data.aws_vpc.existing.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ECS Service
resource "aws_ecs_service" "ansible_service" {
  name            = "ansible-service"
  cluster         = aws_ecs_cluster.ansible_cluster.id
  task_definition = aws_ecs_task_definition.ansible_task.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = true
  }
}

# Outputs
output "cluster_name" {
  value = aws_ecs_cluster.ansible_cluster.name
}

output "task_definition_arn" {
  value = aws_ecs_task_definition.ansible_task.arn
}

output "security_group_id" {
  value = aws_security_group.ecs_tasks.id
}