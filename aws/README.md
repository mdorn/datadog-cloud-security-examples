# dd-attack-path-lab

A deliberately insecure AWS lab that lights up an **attack path** in Datadog Cloud Security:
a public EC2 instance running a vulnerable Docker app, whose role can read an S3 bucket
full of synthetic SSNs.

> **Sandbox AWS accounts only.** Everything here is vulnerable on purpose.
> Run `make destroy` when you're done.

## Prerequisites

- Terraform >= 1.5, AWS CLI v2 + Session Manager plugin, credentials for a sandbox account
- Datadog: AWS integration with Cloud Security on, plus Agentless Scanning with
  Sensitive Data Scanner for cloud storage in the lab's region (see `CLAUDE.md`)

## Quickstart

```bash
cp terraform/terraform.tfvars.example terraform/terraform.tfvars   # edit owner, region, profile
make init
make plan
make apply            # ~5 min until the app answers on app_url
make output           # app_url, instance ARN, bucket name
make scan             # optional: on-demand Agentless scan (DD_API_KEY, DD_APP_KEY, DD_SITE)
```

Then in Datadog: **Security > Cloud Security** for misconfigurations, vulnerabilities and
the attack path; **Sensitive Data Scanner > Findings** for the SSN match in S3.

## Teardown

```bash
make destroy
```

See [`docs/misconfigurations.md`](docs/misconfigurations.md) for what is broken and why,
and [`docs/roadmap.md`](docs/roadmap.md) for what's next.
