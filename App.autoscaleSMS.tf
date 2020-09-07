# designed to send rady an SMS when scale up alarm comes up

resource "aws_sns_topic" "app-tier-scale-up-sms" {
  name = "app-tier-sms-au-alarm-topic"
}

resource "aws_sns_topic_subscription" "app-tier-send-sms-autoscaling" {
    topic_arn = "${aws_sns_topic.app-tier-scale-up-sms.arn}"
    protocol  = "sms"
    endpoint  = "${var.alarms_sms}"
  }

  # cloudwatch alarm for scaling up need, triggers sns topic that triggers sns subscription to send an SMS

  resource "aws_cloudwatch_metric_alarm" "app-tier-cpu-up-alarm-sms" {
    alarm_name          = "app-tier-cpu-alarm-to-send-sms-toRady"
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
    alarm_actions   = ["${aws_sns_topic.app-tier-scale-up-sms.arn}"]
  }

