.PHONY: init plan apply destroy

init:
\t./scripts/bootstrap.sh \$(ENV)

plan:
\t./scripts/deploy.sh \$(ENV)

apply:
\t./scripts/deploy.sh \$(ENV)

destroy:
\tcd \$(ENV) && terraform destroy -auto-approve
