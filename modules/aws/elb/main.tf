variable "common_prefix" {}
variable "vpc_id" {}
variable "subnet_public_a_web_id" {}
variable "subnet_public_b_web_id" {}
variable "health_check_path" {}
#variable "ec2_web1_id" {}
#variable "ec2_web2_id" {}

# Security gourp for ALB
resource "aws_security_group" "alb_web" {
  name   = join("-", [var.common_prefix, "sg", "alb_web"])
  vpc_id = var.vpc_id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = join("-", [var.common_prefix, "sg", "alb_web"])
    ManagedBy = "terraform"
  }
}

# ALB
resource "aws_lb" "web" {
  name               = join("-", [var.common_prefix, "alb", "web"])
  internal           = false #false: for public internet / true: for private network
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.alb_web.id
  ]

  subnets = [
    var.subnet_public_a_web_id,
    var.subnet_public_b_web_id,
  ]

  tags = {
    Name      = join("-", [var.common_prefix, "alb", "web"])
    ManagedBy = "terraform"
  }
}

# Target Group of ALB
resource "aws_lb_target_group" "web" {
  name     = join("-", [var.common_prefix, "alb", "tg", "web"])
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path = var.health_check_path
  }

  tags = {
    Name      = join("-", [var.common_prefix, "alb", "tg", "web"])
    ManagedBy = "terraform"
  }
}

#resource "aws_lb_target_group_attachment" "web_a" {
#  target_group_arn = aws_lb_target_group.web.arn
#  target_id        = var.ec2_web1_id
#  port             = 80
#}

#resource "aws_lb_target_group_attachment" "web_b" {
#  target_group_arn = aws_lb_target_group.web.arn
#  target_id        = var.ec2_web2_id
#  port             = 80
#}

# Listener of ALB
resource "aws_lb_listener" "web" {
  load_balancer_arn = aws_lb.web.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

resource "aws_lb_listener_rule" "forward" {
  listener_arn = aws_lb_listener.web.arn
  priority     = 99

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }

  condition {
    field  = "path-pattern"
    values = ["/*"]
  }
}

