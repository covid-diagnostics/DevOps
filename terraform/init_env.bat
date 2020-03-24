@echo on

set env=%1
echo Initializing %env%...

if not exist %env% (
  echo No such environment: %env%
  exit /b 1
)

pushd .

cd %env%
echo Creating .terraform/modules [fix for external git modules]
mkdir ".terraform/modules"
terraform init -backend=true ^
               -backend-config="..\base_s3_backend.tf" ^
               -backend-config="key=pap/%env%/terraform.tfstate"

popd
