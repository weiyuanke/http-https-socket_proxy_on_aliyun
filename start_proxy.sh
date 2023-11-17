# !/bin/bash
CurDir=$(readlink -f $(dirname $0))
cd $CurDir
terraform apply -auto-approve
