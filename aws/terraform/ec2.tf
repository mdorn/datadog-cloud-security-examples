# INTENTIONAL: an old (deprecated) Canonical Ubuntu AMI -> host vulnerability findings
data "aws_ami" "old_ubuntu" {
  most_recent        = true
  owners             = ["099720109477"] # Canonical
  include_deprecated = true

  filter {
    name   = "name"
    values = [var.ami_name_pattern]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

locals {
  app_dir = "${path.module}/../app"

  # Every file under app/ is shipped inside user data (see CLAUDE.md "How the app gets onto the instance").
  app_files = {
    for f in fileset(local.app_dir, "**") :
    f => filebase64("${local.app_dir}/${f}")
    if !strcontains(f, "__pycache__") && !endswith(f, ".pyc")
  }

  user_data = templatefile("${path.module}/templates/user_data.sh.tftpl", {
    app_files             = local.app_files
    install_datadog_agent = var.install_datadog_agent
    datadog_api_key       = var.datadog_api_key
    datadog_site          = var.datadog_site
    git_repository_url    = var.git_repository_url
    git_commit_sha        = var.git_commit_sha
  })
}

check "git_commit_sha_set" {
  assert {
    condition     = var.git_commit_sha != ""
    error_message = "git_commit_sha is empty, so Datadog source code integration will not link traces or vulns to code. Use `make plan`/`make apply`, or export TF_VAR_git_commit_sha=$(git rev-parse HEAD)."
  }
}

resource "aws_instance" "app" {
  ami                    = data.aws_ami.old_ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.web.id]
  iam_instance_profile   = aws_iam_instance_profile.app.name

  # INTENTIONAL: public IP on an internet-routed subnet -> "publicly accessible"
  associate_public_ip_address = true

  # Gzipped (cloud-init unpacks it) to stay well under the 16 KB EC2 user data limit.
  user_data_base64            = base64gzip(local.user_data)
  user_data_replace_on_change = true

  # INTENTIONAL: IMDSv1 allowed (tokens optional) -> CSPM "EC2 should use IMDSv2"
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "optional"
    http_put_response_hop_limit = 2 # lets containers reach IMDS too
  }

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
    # INTENTIONAL: unencrypted root volume -> CSPM "EBS volume not encrypted"
    # (no effect if the account enforces EBS encryption by default)
    encrypted             = false
    delete_on_termination = true
  }

  # INTENTIONAL: no detailed monitoring, no termination protection (lab hygiene, not a demo point)
  monitoring = false

  tags = { Name = "${local.name_prefix}-todo-app" }

  lifecycle {
    precondition {
      condition     = !var.install_datadog_agent || length(var.datadog_api_key) > 0
      error_message = "install_datadog_agent = true needs datadog_api_key."
    }
    precondition {
      # EC2 counts the decoded (gzipped) bytes: base64 length * 3/4.
      condition     = length(base64gzip(local.user_data)) * 3 / 4 < 16000
      error_message = "Gzipped user data is over the 16 KB EC2 limit. Move app delivery to S3 or ECR."
    }
  }
}
