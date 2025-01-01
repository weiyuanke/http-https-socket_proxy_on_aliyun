# !/bin/bash
CurDir=$(dirname $0)
cd $CurDir
echo "tear down proxy"

if [[ "$OSTYPE" =~ ^darwin ]];then
  IFS=$'\n'
  for svc in `networksetup -listallnetworkservices`; do
      if [[ $svc != *"a network service is disabled"* ]];then
          networksetup -setsocksfirewallproxystate ${svc} off
      fi
  done
  ps ax|grep 'socket_to_http/socks2http'|grep -v grep|awk '{print $1}'|xargs kill
fi

if [[ "$OSTYPE" =~ ^linux ]];then
  gsettings reset org.gnome.system.proxy.http host
  gsettings reset org.gnome.system.proxy.http port
  gsettings reset org.gnome.system.proxy.https host
  gsettings reset org.gnome.system.proxy.https port
  gsettings reset org.gnome.system.proxy.ftp host
  gsettings reset org.gnome.system.proxy.ftp port
  gsettings reset org.gnome.system.proxy.socks host
  gsettings reset org.gnome.system.proxy.socks port
fi

terraform apply -destroy -auto-approve
