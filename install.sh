# !/bin/bash

# install brew
/bin/zsh -c "$(curl -fsSL https://gitee.com/cunkai/HomebrewCN/raw/master/Homebrew.sh)"

# install sshpass
brew tap esolitos/ipa
brew install esolitos/ipa/sshpass

# install terraform
brew install terraform

# init
terraform init