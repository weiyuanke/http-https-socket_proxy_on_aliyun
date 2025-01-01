# !/bin/bash

set -e
set -o pipefail

CurDir=$(dirname $0)
cd $CurDir

if [[ "$OSTYPE" =~ ^darwin ]];then
  # install brew
  if ! command -v brew &> /dev/null
  then
    echo "brew未安装，正在尝试安装..."
    /bin/zsh -c "$(curl -fsSL https://gitee.com/cunkai/HomebrewCN/raw/master/Homebrew.sh)"
  fi

  # install sshpass
  if ! command -v sshpass &> /dev/null
  then
    echo "安装sshpass"
    brew tap esolitos/ipa
    brew install esolitos/ipa/sshpass
  fi
  
  # install terraform
  if ! command -v terraform &> /dev/null
  then
    echo "brew install terraform"
    brew install terraform
  fi
fi

if [[ "$OSTYPE" =~ ^linux ]];then
  wget -O- -q https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
  sudo apt update
  sudo apt install -y sshpass terraform 
fi

# init
echo "terraform init"
terraform init
