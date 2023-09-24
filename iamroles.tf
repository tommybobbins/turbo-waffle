##aws_iam_instance_profile.ec2_access_role.name
##A managed resource "aws_iam_role" "ec2_access_role" has not been declared in the root module.
resource "aws_iam_instance_profile" "ec2_access_role" {
  name = "ec2_profile"
  role = aws_iam_role.ec2_instance_role.name
}

resource "aws_iam_role" "ec2_instance_role" {
  assume_role_policy = data.aws_iam_policy_document.ec2_instance_assume_role_policy.json
  name               = "${var.project_name}-EC2InstanceRole"
}



#// Allow EC2 instance to register as ECS cluster member, fetch ECR images, write logs to CloudWatch
data "aws_iam_policy_document" "ec2_instance_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "s3_write_only" {
  statement {
    effect    = "Allow"
    actions   = ["s3:PutObject","s3:PutObjectAcl"]
    resources = ["${aws_s3_bucket.turbo-waffle.arn}/*"]
  }
  statement {
    effect    = "Allow"
#    actions   = ["s3:GetAccessPoint"]
    actions   = ["s3:GetAccessPoint","s3:ListBucket"]
    resources = [aws_s3_bucket.turbo-waffle.arn]
  }
}

resource "aws_iam_policy" "s3_write_only" {
  name        = "${var.project_name}-policy"
  description = "S3 Write Only"
  policy      = data.aws_iam_policy_document.s3_write_only.json
}

resource "aws_iam_role_policy_attachment" "ssm_core_role" {
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

#resource "aws_iam_role_policy_attachment" "s3_rw_role" {
#  role       = aws_iam_role.ec2_instance_role.name
#  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
#}

resource "aws_iam_role_policy_attachment" "s3_wo_role" {
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = aws_iam_policy.s3_write_only.arn
}
