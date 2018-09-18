variable "ENV" {}
variable "AWS_REGION" {}

variable "AWS_BACKUP_REGION" {}

provider "aws" {
  
}

provider "aws" {
alias = "oregon"
region = "us-west-2"
}

provider "aws" {
alias="virginia"
region="us-east-1"
}

variable "AWS_REGION" {
  default = "us-east-1"
}

variable "AWS_BACK_REGION" {
  default = "us-west-1"
}

resource "aws_s3_bucket" "bucket" {
  bucket = "tf-test-bucket-12345-venkat-test"
 provider = "aws.virginia"
 acl    = "private"

  versioning {
    enabled = true
  }
 tags {
    Name        = "Primary"
    Environment = "Dev"
  }
  replication_configuration {
    role = "${aws_iam_role.replication.arn}"

    rules {
      prefix = ""
      status = "Enabled"

      destination {
        bucket        = "${aws_s3_bucket.bucket2.arn}"
        storage_class = "STANDARD"
      }
    }
  }
 
 }

 resource "aws_s3_bucket" "bucket2" {
  bucket = "tf-test-bucket-12345-venkat-test-backup"
 provider = "aws.oregon"
 acl    = "private"

  versioning {
    enabled = true
  }
 tags {
    Name        = "Duplicate"
    Environment = "Dev"
  }
 }


resource "aws_iam_role" "replication" {
  name = "tf-iam-role-replication-12345"

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
  name = "tf-iam-role-policy-replication-12345"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetReplicationConfiguration",
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.bucket.arn}"
      ]
    },
    {
      "Action": [
        "s3:GetObjectVersion",
        "s3:GetObjectVersionAcl"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.bucket.arn}/*"
      ]
    },
    {
      "Action": [
        "s3:ReplicateObject",
        "s3:ReplicateDelete"
      ],
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.bucket2.arn}/*"
    }
  ]
}
POLICY
}

resource "aws_iam_policy_attachment" "replication" {
  name       = "tf-iam-role-attachment-replication-12345"
  roles      = ["${aws_iam_role.replication.name}"]
  policy_arn = "${aws_iam_policy.replication.arn}"
}
