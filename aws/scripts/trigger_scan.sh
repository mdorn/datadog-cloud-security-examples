#!/usr/bin/env bash
# Trigger Datadog Agentless on-demand scans for the lab's EC2 instance and S3 bucket,
# instead of waiting for the 12-hour schedule.
# Needs: DD_API_KEY, DD_APP_KEY (app key with security_monitoring_findings_write), DD_SITE (default datadoghq.com)
set -euo pipefail

: "${DD_API_KEY:?set DD_API_KEY}"
: "${DD_APP_KEY:?set DD_APP_KEY}"
DD_SITE="${DD_SITE:-datadoghq.com}"

cd "$(dirname "$0")/../terraform"
INSTANCE_ARN="$(terraform output -raw instance_arn)"
BUCKET_ARN="$(terraform output -raw sensitive_bucket_arn)"

for ARN in "$INSTANCE_ARN" "$BUCKET_ARN"; do
  echo "Requesting on-demand scan for $ARN"
  curl -sS -X POST "https://api.${DD_SITE}/api/v2/agentless_scanning/ondemand/aws" \
    -H "Content-Type: application/json" \
    -H "DD-API-KEY: ${DD_API_KEY}" \
    -H "DD-APPLICATION-KEY: ${DD_APP_KEY}" \
    -d "{\"data\":{\"type\":\"aws_resource\",\"attributes\":{\"arn\":\"${ARN}\"}}}"
  echo
done

echo "Check status: curl -H \"DD-API-KEY: ...\" -H \"DD-APPLICATION-KEY: ...\" https://api.${DD_SITE}/api/v2/agentless_scanning/ondemand/aws"
