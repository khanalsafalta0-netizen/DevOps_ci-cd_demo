#!/bin/bash
# Run this after your presentation to avoid leaving AWS resources running.
set -e

AWS_KEY_PAIR_NAME="your-aws-key-pair-name"   # must match what deploy.sh used

cd terraform
terraform destroy -auto-approve -var="key_pair_name=$AWS_KEY_PAIR_NAME"
echo "==> AWS resources destroyed."
