# !/bin/bash
CurDir=$(readlink -f $(dirname $0))
cd $CurDir
echo "tear down proxy"
IFS=$'\n'
for svc in `networksetup -listallnetworkservices`; do
    if [[ $svc != *"a network service is disabled"* ]];then
        networksetup -setsocksfirewallproxystate ${svc} off
    fi
done
ps ax|grep 'socket_to_http/socks2http'|grep -v grep|awk '{print $1}'|xargs kill
terraform apply -destroy -auto-approve
