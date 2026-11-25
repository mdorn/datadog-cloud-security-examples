terraform {
  required_version = ">= 1.10.0" # S3 native state locking (use_lockfile)

  # Remote state in S3 so Datadog can ingest it (Terraform state ingestion).
  # Backend blocks cannot use variables; edit here if the bucket or key changes.
  # Credentials come from AWS_PROFILE / the default chain, not var.aws_profile.
  backend "s3" {
    bucket       = "tfstate-mdorn"
    key          = "datadog-cloud-security-examples/terraform.tfstate"
    region       = "us-east-2"
    encrypt      = true
    use_lockfile = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.60"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}
