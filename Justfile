export AWS_REGION := "eu-west-1"
export AWS_PAGER := ""

[working-directory: 'infra']
tf-fmt:
    tofu fmt -recursive .

[working-directory: 'payments']
deploy-payments:
    ../scripts/deploy-mfe.sh "payments"

[working-directory: 'user-profile']
deploy-user-profile: deploy-payments
    ../scripts/deploy-mfe.sh "user-profile"

[working-directory: 'payments']
payments-local:
    #!/bin/bash -xe
    rm -rf dist
    rm -rf @mf-types
    rm -rf node_modules
    npm install && npm run dev


[working-directory: 'user-profile']
user-profile-local:
    #!/bin/bash -xe
    rm -rf dist
    rm -rf @mf-types
    rm -rf node_modules
    npm install && npm run dev

deploy-mfs: deploy-payments deploy-user-profile

[working-directory: 'infra']
tf-deploy:
    tofu init && tofu apply -auto-approve

[working-directory: 'infra']
tf-destroy:
    tofu destroy -auto-approve
