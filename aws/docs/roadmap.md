# Roadmap

Ideas for the next iterations. Pick one, build it, then move it to "Done".

## Next

- [ ] **ECR delivery**: push the image to ECR instead of shipping it in user data
      (adds registry image scanning and removes the 16 KB user data limit).
- [ ] **Over-privileged role**: swap the scoped S3 read for `AmazonS3ReadOnlyAccess` or
      an `iam:PassRole` + `ec2:RunInstances` combo to show privilege escalation paths.
- [ ] **Leaked secret on the host**: a fake AWS access key in an env file (secret scanning).
- [ ] **RDS with PII**: publicly reachable RDS snapshot or instance with synthetic data.
- [ ] **Lambda path**: public Function URL + vulnerable dependency + role to the bucket.
- [ ] **EKS / Kubernetes**: privileged pod with a hostPath mount and a public LoadBalancer.
- [ ] **IaC scanning**: point Datadog IaC Security at this repo so the same issues show
      up shift-left on pull requests.
- [ ] **Runtime story**: with the Agent on, run a safe simulation (for example
      `curl http://169.254.169.254/latest/meta-data/iam/security-credentials/` from the
      container via SSM) to fire a CSM Threats signal tied to the attack path.

## Done

- [x] Scenario 01: public EC2 + vulnerable container + role to S3 with SSNs (2026-11-24)
