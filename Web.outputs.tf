output "web-tier-security_group" {
  value = aws_security_group.web-tier-sg.id
}

output "web-tier-launch_configuration" {
  value = aws_launch_configuration.web-tier-lc.id
}

output "web-tier-asg_name" {
  value = aws_autoscaling_group.web-tier-asg.id
}

output "web-tier-elb_name" {
  value = aws_lb.web-tier-lb.dns_name
}
