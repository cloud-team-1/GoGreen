#terraform {
#  required_version = ">= 0.12"
#}

resource "aws_lb" "web-tier-lb" {
  name               = "web-tier-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web-tier-sg.id]
  subnets            = "${module.vpc.public-subnet-ids}"


  tags = {
    Environment = "production"
  }
}

resource "aws_lb_listener" "web-lb-listener" {
  load_balancer_arn = aws_lb.web-tier-lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web-tier-tg.arn
  }
}

resource "aws_lb_listener_rule" "host_based_weighted_routing" {
  listener_arn = aws_lb_listener.web-lb-listener.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web-tier-tg.arn
  }
  condition {
    path_pattern {
      values = ["/static/*"]
    }
  }
}

resource "aws_lb_target_group" "web-tier-tg" {
  name     = "web-tier-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${module.vpc.vpc-id}"
  tags = {
    name = "web-tier-tg"
  }

  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 10
    timeout             = 5
    interval            = 10
    path                = "/"
    port                = "traffic-port"
    matcher             = "200-320"
  }
}

resource "aws_autoscaling_attachment" "web-tier-target-attachment" {
  alb_target_group_arn   = "${aws_lb_target_group.web-tier-tg.arn}"
  autoscaling_group_name = "${aws_autoscaling_group.web-tier-asg.id}"
}

resource "aws_autoscaling_group" "web-tier-asg" {
  #availability_zones   = local.availability_zones
  name                 = "web-tier-asg"
  max_size             = var.asg_max
  min_size             = var.asg_min
  desired_capacity     = var.asg_desired
  force_delete         = false
  launch_configuration = aws_launch_configuration.web-tier-lc.name
  #load_balancers       = [aws_lb.web-tier-lb.name]
  target_group_arns   = [aws_lb_target_group.web-tier-tg.arn]
  vpc_zone_identifier = "${module.vpc.public-subnet-ids}"


  tag {
    key                 = "Name"
    value               = "web-tier-asg"
    propagate_at_launch = "true"
  }
}

resource "aws_launch_configuration" "web-tier-lc" {
  name                 = "web-tier-lc"
  image_id             = var.aws_amis
  instance_type        = var.instance_type
  iam_instance_profile = "${aws_iam_instance_profile.s3-profile.id}"
  root_block_device {
    volume_size = "10"
    volume_type = "gp2"
    encrypted   = true
  }

  # Security group
  security_groups = [aws_security_group.web-tier-sg.id]
  user_data       = file("Web.userdata.sh")
  key_name        = var.key_name
}

# Our default security group to access
# the instances over SSH and HTTP
resource "aws_security_group" "web-tier-sg" {
  name        = "web-tier-sg"
  description = "Used in the terraform"
  vpc_id      = "${module.vpc.vpc-id}"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS access from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "web-tier-sg"
  }
}
