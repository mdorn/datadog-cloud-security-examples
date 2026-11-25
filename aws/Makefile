TF := terraform -chdir=terraform

# Datadog source code integration: deploy metadata for the commit you are on.
# Commit and push first, or Datadog cannot resolve the SHA.
export TF_VAR_git_commit_sha := $(shell git rev-parse HEAD 2>/dev/null)

.PHONY: init fmt validate plan apply destroy output shell scan data app-local

init:
	$(TF) init

fmt:
	$(TF) fmt -recursive

validate: fmt
	$(TF) validate

plan:
	$(TF) plan

apply:
	$(TF) apply

destroy:
	$(TF) destroy

output:
	$(TF) output

shell:
	eval "$$($(TF) output -raw ssm_command)"

scan:
	./scripts/trigger_scan.sh

data:
	python3 scripts/generate_fake_ssns.py > data/customer_records.txt

app-local:
	docker build -t todo-lab app && docker run --rm -p 8080:5000 todo-lab
