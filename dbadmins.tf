resource "aws_iam_group_policy" "my_db_policy" {
  name   = "my_dbadmin_policy"
  group  = aws_iam_group.my_dbadmin.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "rds:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}
resource "aws_iam_group" "my_dbadmin" {
  name = "dbadmins"
  path = "/"
}
resource "aws_iam_group_membership" "database" {
  name = "tf-testing-group-membership"
  users = [
    aws_iam_user.db_user_1.name,
    aws_iam_user.db_user_2.name,
  ]
  group = aws_iam_group.my_dbadmin.name
}

# DB User 1
resource "aws_iam_user" "db_user_1" {
  name          = "db-user-one"
  force_destroy = true
}

resource "aws_iam_access_key" "db_user1_access_key" {
  user = aws_iam_user.db_user_1.name
}
# DB User 2
resource "aws_iam_user" "db_user_2" {
  name          = "db-user-two"
  force_destroy = true
}

resource "aws_iam_access_key" "db_user2_access_key" {
  user = aws_iam_user.db_user_2.name
}
