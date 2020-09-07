# designed to send rady an SMS when scale up alarm comes up

resource "aws_sns_topic" "scale-up-sms" {
  name = "sms-as-alarm-topic"
}

resource "aws_sns_topic_subscription" "send-sms-autoscaling" {
    topic_arn = "${aws_sns_topic.scale-up-sms.arn}"
    protocol  = "sms"
    endpoint  = "${var.alarms_sms}"
  }

  # cloudwatch alarm for scaling up need, triggers sns topic that triggers sns subscription to send an SMS

  resource "aws_cloudwatch_metric_alarm" "cpu-up-alarm-sms" {
    alarm_name          = "cpu-alarm-to-send-sms-toRady"
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
    alarm_actions   = ["${aws_sns_topic.scale-up-sms.arn}"]
  }

