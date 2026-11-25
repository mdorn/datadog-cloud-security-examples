# Intentional misconfigurations

Every weakness in this lab is on purpose. Each one is marked `# INTENTIONAL:` in code.
"Expected finding" is what Datadog should report; confirm the exact rule names in the
Datadog UI after the first scan and update this table.

## Scenario 01: public EC2 to sensitive S3

| # | Where | Weakness | Expected Datadog finding |
|---|---|---|---|
| 1 | `terraform/network.tf` | SG allows 0.0.0.0/0 on tcp/80 | Misconfiguration: SG open to the internet; host marked publicly accessible |
| 2 | `terraform/network.tf` | Subnet auto-assigns public IPs | Misconfiguration: subnet maps public IPs on launch |
| 3 | `terraform/network.tf` | No VPC flow logs | Misconfiguration: VPC flow logging disabled |
| 4 | `terraform/ec2.tf` | Public IP on an IGW-routed subnet | Feeds "publicly accessible" in the attack path |
| 5 | `terraform/ec2.tf` | IMDSv1 allowed (`http_tokens = "optional"`) | Misconfiguration: EC2 should require IMDSv2 |
| 6 | `terraform/ec2.tf` | Root EBS volume unencrypted | Misconfiguration: EBS volume not encrypted (skipped if account default encryption is on) |
| 7 | `terraform/ec2.tf` + `variables.tf` | Ubuntu 22.04 AMI from 2023 | Host vulnerabilities (kernel, openssl, glibc, sudo...) |
| 8 | `templates/user_data.sh.tftpl` | unattended-upgrades disabled | Keeps #7 from self-healing |
| 9 | `terraform/iam.tf` | Web host role can `s3:GetObject` / `s3:ListBucket` on the sensitive bucket | Edge from host to sensitive data in the attack path |
| 10 | `terraform/s3.tf` | No versioning, no access logging | Misconfiguration: S3 versioning / access logging |
| 11 | `data/customer_records.txt` | 25 synthetic SSNs in S3 | Sensitive Data Scanner: US Social Security Number |
| 12 | `app/Dockerfile` | `python:3.9-buster` base (EOL Debian 10 + Python 3.9) | Container image vulnerabilities (OS packages) |
| 13 | `app/Dockerfile` | Explicit apt installs frozen at buster versions (imagemagick, libxml2, openssl, curl, sudo, git) | Container image vulnerabilities (OS packages) |
| 14 | `app/Dockerfile` | Container runs as root | Container misconfiguration (if the Agent is installed) |
| 15 | `app/requirements.txt` | Flask 1.1.4, Werkzeug 1.0.1, Jinja2 2.11.3, PyYAML 5.3.1 (critical), requests 2.19.1, urllib3 1.23, gunicorn 19.9.0 | Library vulnerabilities (critical and high) |

### The attack path in one line

Internet → public EC2 (#1, #4) with critical vulns (#7, #12, #15) and IMDSv1 (#5) →
instance role credentials (#9) → S3 bucket with SSNs (#11).

## Not done on purpose (safety)

- No SSH, no key pair, no Flask debug mode, no RCE-style endpoints.
- Bucket stays private (public access block on). Exposure is through the role only.
