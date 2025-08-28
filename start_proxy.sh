# !/bin/bash
sudo echo "starting proxy... ..."
CurDir=$(dirname $0)
cd $CurDir
terraform apply -auto-approve
