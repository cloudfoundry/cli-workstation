#!/usr/bin/env bash

set -e

#sudo add-apt-repository -y ppa:neovim-ppa/unstable

sudo apt-get update
sudo apt-get install -y git ruby tmux silversearcher-ag bash-completion tree awscli tig direnv htop openssh-server bzr jq nodejs lastpass-cli software-properties-common neovim exuberant-ctags chromium-browser

sudo apt-get upgrade -y

sudo apt-get clean
