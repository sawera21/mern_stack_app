 terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region     = "us-east-1"
  access_key = ${{ secrets.ACCESS_KEY_AWS }}
  secret_key = ${{ secrets.SECURITY_KEY_AWS }}
}

variable "azs" {
  type    = set(string)
  default = ["us-east-1a", "us-east-1b"]
}



resource "aws_vpc" "main" {
  cidr_block = "10.100.0.0/16"

  tags = {
    Name = "my-app-vpc"
  }
}

resource "aws_subnet" "public_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.100.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "public_a"
  }
}ility_zone = "us-east-1b"

  tags = {
    Name = "public_b"
  }
}


resource "aws_internet_gateway" "main-igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main-igw.id
  }

  tags = {
    Name = "public_rt"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public_rt.id
}


resource "aws_security_group" "docker_project_lb_sg" {
  name        = "docker-nginx-project-lb-sg"
  description = "allow incoming HTTP traffic only"
  vpc_id      = aws_vpc.main.id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "docker_project_lb" {
  name               = "test-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.docker_project_lb_sg.id}"]
  subnets            = ["${aws_subnet.public_a.id}", "${aws_subnet.public_b.id}"]
  tags = {
    Environment = "dev"
  }
}


resource "aws_lb_target_group" "docker_project_lb_tg" {
  name     = "docker-project-lb-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  health_check {
    protocol = "HTTP"
    port     = 80
  }
}

resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = aws_lb.docker_project_lb.arn
  port              = "80"
  protocol          = "HTTP"


  default_action {
    target_group_arn = aws_lb_target_group.docker_project_lb_tg.arn
    type             = "forward"
  }
}



resource "aws_subnet" "public_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.100.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "public_b"
  }
}


resource "aws_internet_gateway" "main-igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main-igw.id
  }

  tags = {
    Name = "public_rt"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public_rt.id
}


resource "aws_security_group" "docker_project_lb_sg" {
  name        = "docker-nginx-project-lb-sg"
  description = "allow incoming HTTP traffic only"
  vpc_id      = aws_vpc.main.id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "docker_project_lb" {
  name               = "test-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.docker_project_lb_sg.id}"]
  subnets            = ["${aws_subnet.public_a.id}", "${aws_subnet.public_b.id}"]
  tags = {
    Environment = "dev"
  }
}


resource "aws_lb_target_group" "docker_project_lb_tg" {
  name     = "docker-project-lb-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  health_check {
    protocol = "HTTP"
    port     = 80
  }
}

resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = aws_lb.docker_project_lb.arn
  port              = "80"
  protocol          = "HTTP"


  default_action {
    target_group_arn = aws_lb_target_group.docker_project_lb_tg.arn
    type             = "forward"
  }
}




resource "aws_security_group" "docker_project_ec2" {
  name        = "docker-nginx-project-ec2"
  description = "allow incoming HTTP traffic only"
  vpc_id      = aws_vpc.main.id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "url" {
  value = "http://${aws_lb.docker_project_lb.dns_name}/"
}
 
 
 
 
 
 
 
 
 
 
 
 
 
 Create an ECS cluster
resource "aws_ecs_cluster" "cluster" {
  name = "my-ecs-cluster"
}

# Create a task definition for each service
resource "aws_ecs_task_definition" "frontend_task" {
  family                   = "frontend-task"
  execution_role_arn       = aws_iam_role.execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  container_definitions = <<DEFINITION
[
  {
    "name": "frontend-container",
    "image": "your-frontend-image:latest",
    "portMappings": [
      {
        "containerPort": 80,
        "protocol": "tcp"
      }
    ]
  }
]
DEFINITION
}

resource "aws_ecs_task_definition" "backend_task" {
  family                   = "backend-task"
  execution_role_arn       = aws_iam_role.execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  container_definitions = <<DEFINITION
[
  {
    "name": "backend-container",
    "image": "your-backend-image:latest",
    "portMappings": [
      {
        "containerPort": 5000,
        "protocol": "tcp"
      }
    ]
  }
]
DEFINITION
}

resource "aws_ecs_task_definition" "nginx_task" {
  family                   = "nginx-task"
  execution_role_arn       = aws_iam_role.execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  container_definitions = <<DEFINITION
[
  {
    "name": "nginx-container",
    "image": "your-nginx-image:latest",
    "portMappings": [
      {
        "containerPort": 80,
        "protocol": "tcp"
      }
    ]
  }
]
DEFINITION
}

# Create an IAM role for the task execution
resource "aws_iam_role" "execution_role" {
  name = "ecs-task-execution-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

# Create ECS services
resource "aws_ecs_service" "frontend_service" {
  name            = "frontend-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.frontend_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [aws_subnet.public_a.id, aws_subnet.public_b.id]
    security_groups = [aws_security_group.load_balancer_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.arn
    container_name   = "frontend-container"
    container_port   = 80
  }
}

resource "aws_ecs_service" "backend_service" {
  name            = "backend-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.backend_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [aws_subnet.public_a.id, aws_subnet.public_b.id]
    security_groups = [aws_security_group.load_balancer_sg.id]
    assign_public_ip = true
  }
}

resource "aws_ecs_service" "nginx_service" {
  name            = "nginx-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.nginx_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [aws_subnet.public_a.id, aws_subnet.public_b.id]
    security_groups = [aws_security_group.load_balancer_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.arn
    container_name   = "nginx-container"
    container_port   = 80
  }
}

# Output the load balancer DNS name
output "load_balancer_dns_name" {
  value = aws_lb.load_balancer.dns_name
}