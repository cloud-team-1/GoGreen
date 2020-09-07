resource "aws_iam_role" "replication" {
  name = "s3-bucket-replication-${local.destination_bucket_name}"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "replication" {
  name = "s3-bucket-replication-${local.destination_bucket_name}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
            "s3:ListBucket",
            "s3:GetReplicationConfiguration",
            "s3:GetObjectVersionForReplication",
            "s3:GetObjectVersionAcl"        
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::${local.bucket_name}"
      ]
    },
    {
      "Action": [
        "s3:GetObjectVersion",
        "s3:GetObjectVersionAcl",
        "s3:GetObjectVersionTagging"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::${local.bucket_name}/*"
      ]
    },
    {
      "Action": [
        "s3:ReplicateObject",
        "s3:ReplicateDelete",
        "s3:ReplicateTags"
      ],
      "Effect": "Allow",
      
      "Resource": "arn:aws:s3:::${local.destination_bucket_name}/*"
    },
    {
      "Action": [
         "kms:*"
      ],
      "Effect": "Allow",
      
      "Resource": "*"
      }
  ]
}
POLICY
}

resource "aws_iam_policy_attachment" "replication" {
  name       = "s3-bucket-replication-${local.destination_bucket_name}"
  roles      = [aws_iam_role.replication.name]
  policy_arn = aws_iam_policy.replication.arn
}
