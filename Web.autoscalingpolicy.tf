resource "aws_autoscaling_policy" "web-tier-sp" {
  name                   = "web-tier-cpu-policy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.web-tier-asg.name
  policy_type            = "SimpleScaling"
}

#scale up alarm
resource "aws_cloudwatch_metric_alarm" "cpu-alarm" {
  alarm_name          = "cpu-alarm"
  alarm_description   = "web-tier-scaleup-cpu-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "60"
  dimensions = {
    "AutoScalingGroupName" = "${aws_autoscaling_group.web-tier-asg.name}"
  }
  actions_enabled = true
  alarm_actions   = ["${aws_autoscaling_policy.web-tier-sp.arn}"]
}

#scale down alarm
resource "aws_autoscaling_policy" "web-tier-cpu-policy-scaledown" {
  name                   = "web-tier-cpu-policy-scaledown"
  autoscaling_group_name = "${aws_autoscaling_group.web-tier-asg.name}"
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "-1"
  cooldown               = "300"
  policy_type            = "SimpleScaling"
}
resource "aws_cloudwatch_metric_alarm" "examplweb-tier-cpu-alarm-scaledown" {
  alarm_name          = "web-tier-cpu-alarm-scaledown"
  alarm_description   = "low-cpu-alarm-scaledown"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "50"
  dimensions = {
    "AutoScalingGroupName" = "${aws_autoscaling_group.web-tier-asg.name}"
  }
  actions_enabled = true
  alarm_actions   = ["${aws_autoscaling_policy.web-tier-cpu-policy-scaledown.arn}"]
}