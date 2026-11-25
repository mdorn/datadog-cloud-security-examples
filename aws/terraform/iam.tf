data "aws_iam_policy_document" "ec2_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "app" {
  name               = "${local.name_prefix}-app-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json
}

# INTENTIONAL: the web tier can read the sensitive bucket it never uses.
# This is the edge from "compromised public host" to "sensitive data" in the attack path.
data "aws_iam_policy_document" "read_sensitive_bucket" {
  statement {
    sid       = "ListSensitiveBucket"
    actions   = ["s3:ListBucket", "s3:GetBucketLocation"]
    resources = [aws_s3_bucket.sensitive.arn]
  }

  statement {
    sid       = "ReadSensitiveObjects"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.sensitive.arn}/*"]
  }
}

resource "aws_iam_role_policy" "read_sensitive_bucket" {
  name   = "read-sensitive-bucket"
  role   = aws_iam_role.app.id
  policy = data.aws_iam_policy_document.read_sensitive_bucket.json
}

# Shell access through SSM Session Manager instead of SSH.
resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.app.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "app" {
  name = "${local.name_prefix}-app-profile"
  role = aws_iam_role.app.name
}
