provider "aws" {
  region  = var.region
  profile = var.aws_profile

  default_tags {
    tags = {
      Project     = "dd-attack-path-lab"
      Scenario    = "01-public-ec2-to-sensitive-s3"
      Owner       = var.owner
      Environment = "sandbox"
      ManagedBy   = "terraform"
      # Datadog unified tags so findings group nicely
      env     = "attack-path-lab"
      service = "todo-app"
    }
  }
}

resource "random_id" "suffix" {
  byte_length = 3
}

locals {
  name_prefix = "${var.name_prefix}-${random_id.suffix.hex}"
}
