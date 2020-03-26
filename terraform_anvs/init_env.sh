#!/bin/bash
set -eu # fail on errors and undefined variables
scriptDir=$(cd `dirname $0`; pwd)

env=$(basename "${1}")
echo "Initializing ${env}..."
(
  if [[ ! -d "${env}" ]]; then
    echo "No such environment: ${env}"
    exit 1
  fi

  cd "${env}"
  echo "Creating .terraform/modules [fix for external git modules]"
  mkdir -p .terraform/modules
  terraform init -backend=true \
                 -backend-config="../base_s3_backend.tf" \
                 -backend-config="key=pap/${env}/terraform.tfstate"
)
