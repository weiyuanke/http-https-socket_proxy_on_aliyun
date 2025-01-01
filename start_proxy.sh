# !/bin/bash
CurDir=$(dirname $0)
cd $CurDir
terraform apply -auto-approve
