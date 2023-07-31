##### AZ #####
variable "availability_zones" {
  description = "Availability Zones"
  default     = ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c"]
}

##### AMI ID #####
variable "ami" {
  description = "AMI for EC2 instances"
  default     = "ami-0c9c942bd7bf113a2"
}

##### EC2 Instance #####
resource "aws_instance" "narean_instance" {
  count                  = length(data.terraform_remote_state.vpc.outputs.private_subnets)
  ami                    = var.ami
  instance_type          = "t3.micro"
  subnet_id              = data.terraform_remote_state.vpc.outputs.private_subnets[count.index]
  vpc_security_group_ids = [data.terraform_remote_state.vpc.outputs.aws_security_group]
  user_data = <<-EOF
    #!/bin/bash
    echo "Hello, World" > index.html
    nohup busybox httpd -f -p 80 &
    EOF

  tags = {
    Name = "narean Instance ${count.index + 1}"
  }
}

##### ALB #####
resource "aws_alb" "alb" {
  name               = "narean-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [data.terraform_remote_state.vpc.outputs.aws_security_group]
  subnets            = data.terraform_remote_state.vpc.outputs.public_subnets

  tags = {
    Name = "narean_alb"
  }
}

resource "aws_alb_target_group" "alb_target_group" {
  name        = "narean-alb-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = "/"
    unhealthy_threshold = "2"
  }
}

resource "aws_alb_listener" "user_http" {
  load_balancer_arn = aws_alb.alb.id
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.alb_target_group.id
    type             = "forward"
  }
}

##### VPC data #####
data "terraform_remote_state" "vpc" {
  backend = "local"
  config = {
    path = "../VPC/terraform.tfstate"
  }
}