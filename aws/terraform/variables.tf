variable "region" {
  description = "AWS region. Must be a region where Datadog Agentless Scanning is deployed."
  type        = string
  default     = "us-east-2"
}

variable "aws_profile" {
  description = "AWS CLI profile for the sandbox account. null uses the default credential chain."
  type        = string
  default     = null
}

variable "owner" {
  description = "Owner tag (your email or handle)."
  type        = string
}

variable "name_prefix" {
  description = "Prefix for resource names. A random suffix is appended."
  type        = string
  default     = "ddlab"
}

variable "instance_type" {
  description = "EC2 instance type. t3.micro is enough for the app; use t3.small if the Agent is installed."
  type        = string
  default     = "t3.micro"
}

variable "ami_name_pattern" {
  description = "Name filter for an OLD Canonical Ubuntu AMI. The most recent match is used."
  type        = string
  # INTENTIONAL: 2023 build of Ubuntu 22.04 -> host vulnerability findings (kernel, openssl, glibc...)
  default = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-2023*"
}

variable "ingress_cidrs" {
  description = "CIDRs allowed to reach the app on port 80. Must include 0.0.0.0/0 for Datadog to call the host publicly accessible."
  type        = list(string)
  # INTENTIONAL: open to the world -> "publicly accessible" + SG misconfiguration
  default = ["0.0.0.0/0"]
}

variable "vpc_cidr" {
  description = "CIDR for the lab VPC."
  type        = string
  default     = "10.42.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR for the public subnet."
  type        = string
  default     = "10.42.1.0/24"
}

# ---------------------------------------------------------------------------
# Optional Datadog Agent on the instance
# ---------------------------------------------------------------------------

variable "install_datadog_agent" {
  description = "Install the Datadog Agent on the EC2 instance (SBOM + CSM Threats)."
  type        = bool
  default     = false
}

variable "datadog_api_key" {
  description = "Datadog API key. Required only when install_datadog_agent = true."
  type        = string
  default     = ""
  sensitive   = true
}

variable "datadog_site" {
  description = "Datadog site, e.g. datadoghq.com, us3.datadoghq.com, datadoghq.eu."
  type        = string
  default     = "datadoghq.com"
}
