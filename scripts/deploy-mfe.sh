#!/bin/bash -xe
mfe_name="$1"

rm -rf dist
rm -rf node_modules
distr_id=$(aws ssm get-parameter --name mfs-cdn-id | jq -r '.Parameter.Value')
distr_url=$(aws cloudfront get-distribution --id "${distr_id}" | jq -r '.Distribution.DomainName')
export CDN_URL="https://${distr_url}"
npm install && npm run build
account_id=$(aws sts get-caller-identity | jq -r '.Account')
aws s3 cp --recursive dist "s3://deployment-${AWS_REGION}-${account_id}/${mfe_name}"