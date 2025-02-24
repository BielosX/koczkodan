export AWS_REGION := "eu-west-1"
export AWS_PAGER := ""

[working-directory: 'infra']
tf-fmt:
    tofu fmt -recursive .

[working-directory: 'payments']
deploy-payments:
    #!/bin/bash -xe
    rm -rf dist
    rm -rf node_modules
    npm install && npm run build
    account_id=$(aws sts get-caller-identity | jq -r '.Account')
    aws s3 cp --recursive dist "s3://deployment-${AWS_REGION}-${account_id}/payments"

[working-directory: 'user-profile']
deploy-user-profile: deploy-payments
    #!/bin/bash -xe
    rm -rf dist
    rm -rf node_modules
    distr_id=$(aws ssm get-parameter --name mfs-cdn-id | jq -r '.Parameter.Value')
    distr_url=$(aws cloudfront get-distribution --id "${distr_id}" | jq -r '.Distribution.DomainName')
    export PAYMENTS_URL="https://${distr_url}/payments"
    npm install && npm run build
    account_id=$(aws sts get-caller-identity | jq -r '.Account')
    aws s3 cp --recursive dist "s3://deployment-${AWS_REGION}-${account_id}/user-profile"

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
