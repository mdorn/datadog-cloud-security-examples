output "app_url" {
  description = "Public URL of the to-do app (allow ~5 min after apply for the Docker build)."
  value       = "http://${aws_instance.app.public_ip}"
}

output "instance_id" {
  value = aws_instance.app.id
}

output "instance_arn" {
  description = "Use with scripts/trigger_scan.sh for an on-demand Agentless scan."
  value       = aws_instance.app.arn
}

output "ami_id" {
  value = data.aws_ami.old_ubuntu.id
}

output "ami_name" {
  description = "The old AMI actually picked."
  value       = data.aws_ami.old_ubuntu.name
}

output "sensitive_bucket" {
  value = aws_s3_bucket.sensitive.id
}

output "sensitive_bucket_arn" {
  value = aws_s3_bucket.sensitive.arn
}

output "ssm_command" {
  description = "Open a shell on the instance."
  value       = "aws ssm start-session --region ${var.region} --target ${aws_instance.app.id}"
}
