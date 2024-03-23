# !/bin/bash

CurDir=$(readlink -f $(dirname $0))
cd $CurDir

if [[ "$OSTYPE" =~ ^darwin ]];then
  # install brew
  /bin/zsh -c "$(curl -fsSL https://gitee.com/cunkai/HomebrewCN/raw/master/Homebrew.sh)"

  # install sshpass
  brew tap esolitos/ipa
  brew install esolitos/ipa/sshpass
  
  # install terraform
  brew install terraform
fi

if [[ "$OSTYPE" =~ ^linux ]];then
  wget -O- -q https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
  sudo apt update
  sudo apt install -y sshpass terraform 
fi

# init
terraform init
