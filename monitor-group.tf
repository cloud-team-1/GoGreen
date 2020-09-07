
resource "aws_iam_group_policy" "monitor_policy" {
  name  = "monitor"
  group = aws_iam_group.monitor.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "cloudwatch:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_group_membership" "monitor" {
  name = "tf-testing-group-membership"

  users = [
    aws_iam_user.monitor1.name,
    aws_iam_user.monitor2.name,
    aws_iam_user.monitor3.name,
    aws_iam_user.monitor4.name,
  ]

  group = aws_iam_group.monitor.name
}

resource "aws_iam_group" "monitor" {
  name = "test-monitor"
}
# monitor 1

resource "aws_iam_user" "monitor1" {
  name          = "monitor1"
  path          = "/system/"
  force_destroy = true
}

resource "aws_iam_access_key" "monitor1_access_key" {
  user = aws_iam_user.monitor1.name
}

# monitor 2
resource "aws_iam_user" "monitor2" {
  name          = "monitor2"
  path          = "/system/"
  force_destroy = true
}

resource "aws_iam_access_key" "monitor2_access_key" {
  user = aws_iam_user.monitor2.name
}

# monitor 3
resource "aws_iam_user" "monitor3" {
  name          = "monitor3"
  path          = "/system/"
  force_destroy = true
}

resource "aws_iam_access_key" "monitor3_access_key" {
  user = aws_iam_user.monitor3.name
}

# monitor 4
resource "aws_iam_user" "monitor4" {
  name          = "monitor4"
  path          = "/system/"
  force_destroy = true
}

resource "aws_iam_access_key" "monitor4_access_key" {
  user = aws_iam_user.monitor4.name
}


