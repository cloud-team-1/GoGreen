output "app-tier-security_group" {
  value = aws_security_group.app-tier-sg.id
}

output "app-tier-launch_configuration" {
  value = aws_launch_configuration.app-tier-lc.id
}

output "app-tier-asg_name" {
  value = aws_autoscaling_group.app-tier-asg.id
}

output "app-tier-elb_name" {
  value = aws_lb.app-tier-lb.dns_name
}
