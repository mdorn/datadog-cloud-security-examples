TF := terraform -chdir=terraform

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
