echo "start configuring proxy"
./socket_to_http/socks2http -http 8080 -socks 9002 &
sleep 20
rm -f ${HOME}/.ssh/known_hosts;
HTTP_PROXY=http://127.0.0.1:8080 HTTPS_PROXY=http://127.0.0.1:8080 open -n /System/Applications/Utilities/Terminal.app
IFS=$'\n'
for svc in `networksetup -listallnetworkservices`; do
    if [[ $svc != *"a network service is disabled"* ]];then
        networksetup -setsocksfirewallproxy ${svc} 127.0.0.1 9002
    fi
done
sshpass -p Admin123 ssh -o StrictHostKeyChecking=no -vvv -D 9002 root@${PubIP} vmstat 1