#scale up alarm

resource "aws_autoscaling_policy" "app-tier-sp" {
  name                   = "app-tier-cpu-policy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.app-tier-asg.name
  policy_type            = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "app-tier-cpu-alarm" {
  alarm_name          = "app-tier-cpu-alarm"
  alarm_description   = "app-tier-scaleup-cpu-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "75"
  dimensions = {
    "AutoScalingGroupName" = "${aws_autoscaling_group.app-tier-asg.name}"
  }
  actions_enabled = true
  alarm_actions   = ["${aws_autoscaling_policy.app-tier-sp.arn}"]
}

#scale down alarm
resource "aws_autoscaling_policy" "app-tier-cpu-policy-scaledown" {
  name                   = "app-tier-cpu-policy-scaledown"
  autoscaling_group_name = "${aws_autoscaling_group.app-tier-asg.name}"
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "-1"
  cooldown               = "300"
  policy_type            = "SimpleScaling"
}
resource "aws_cloudwatch_metric_alarm" "app-tier-cpu-alarm-scaledown" {
  alarm_name          = "app-tier-cpu-alarm-scaledown"
  alarm_description   = "app-tier-low-cpu-alarm-scaledown"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "30"
  dimensions = {
    "AutoScalingGroupName" = "${aws_autoscaling_group.app-tier-asg.name}"
  }
  actions_enabled = true
  alarm_actions   = ["${aws_autoscaling_policy.app-tier-cpu-policy-scaledown.arn}"]
}

# scale up, low memory alarm

resource "aws_autoscaling_policy" "app-tier-memory-sp" {
  name                   = "app-tier-memory-policy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.app-tier-asg.name
  policy_type            = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "app-tier-memory-alarm" {
  alarm_name          = "app-tier-memory-alarm"
  alarm_description   = "app-tier-scaleup-memory-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "mem_used_percent"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"
  dimensions = {
    "AutoScalingGroupName" = "${aws_autoscaling_group.app-tier-asg.name}"
  }
  actions_enabled = true
  alarm_actions   = ["${aws_autoscaling_policy.app-tier-memory-sp.arn}"]
}