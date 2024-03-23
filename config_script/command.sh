echo "start configuring proxy"
rm -f ${HOME}/.ssh/known_hosts;

if [[ "$OSTYPE" =~ ^darwin ]];then
  ./socket_to_http/socks2http -http 8080 -socks 9002 &
  sleep 20
  HTTP_PROXY=http://127.0.0.1:8080 HTTPS_PROXY=http://127.0.0.1:8080 open -n /Applications/Utilities/Terminal.app
  IFS=$'\n'
  for svc in `networksetup -listallnetworkservices`; do
      if [[ $svc != *"a network service is disabled"* ]];then
          networksetup -setsocksfirewallproxy ${svc} 127.0.0.1 9002
      fi
  done
fi

if [[ "$OSTYPE" =~ ^linux ]];then
  gsettings set org.gnome.system.proxy.socks host '127.0.0.1'
  gsettings set org.gnome.system.proxy.socks port 9002
fi

sshpass -p Admin123 ssh -o StrictHostKeyChecking=no -D 9002 root@${PubIP} iftop -t -n
