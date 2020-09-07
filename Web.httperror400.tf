# this creates an SNS topic that would send an email to the var.**email.com when the cloudwatch alarm triggers

resource "aws_sns_topic" "error-400-alarm" {
  name            = "alarms-topic"
  delivery_policy = <<EOF

{
  "http": {
    "defaultHealthyRetryPolicy": {
      "minDelayTarget": 20,
      "maxDelayTarget": 20,
      "numRetries": 3,
      "numMaxDelayRetries": 0,
      "numNoDelayRetries": 0,
      "numMinDelayRetries": 0,
      "backoffFunction": "linear"
    },
    "disableSubscriptionOverrides": false,
    "defaultThrottlePolicy": {
      "maxReceivesPerSecond": 1
    }
  }
}
EOF

  #provisioner "local-exec" {
  # command = "aws sns subscribe --topic-arn ${self.arn} --protocol email --notification-endpoint ${var.alarms_email}"
  #}
}

# metric name could be found into the namaspace section on terraform cloudwatch docs.
# period is in second; threshhold is th enumber of occurancies; not clear what is the elvaluation period. 

resource "aws_cloudwatch_metric_alarm" "error-400-alarm" {
  alarm_name          = "error-400-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "HTTPCode_ELB_400_Count"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Sum"
  threshold           = "100"
  alarm_description   = "This metric monitors http errors 400"
  alarm_actions       = ["${aws_sns_topic.error-400-alarm.arn}"]

  # next connects the alarm to the resource, my load balancer. 
  dimensions = {
    LoadBalancer = "${aws_lb.web-tier-lb.arn_suffix}"
  }
}

# create a subscription to the sns topic, email is not supported on terraform, must use sms

resource "aws_sns_topic_subscription" "admin-sms-error" {
  topic_arn = "${aws_sns_topic.error-400-alarm.arn}"
  protocol  = "sms"
  endpoint  = "${var.alarms_sms}"
}