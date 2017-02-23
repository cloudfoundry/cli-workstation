#!/usr/bin/env bash

set -e

GO_VERSION="1.7.5"

# Add any required repositories
sudo add-apt-repository -y ppa:neovim-ppa/unstable
sudo add-apt-repository -y ppa:webupd8team/atom
sudo add-apt-repository -y ppa:aacebedo/fasd


# Update/Upgrade to the latest
sudo apt update
sudo apt upgrade -y

# Install system dependancies
sudo apt install -y bash-completion chromium-browser curl fasd htop openssh-server software-properties-common tree ubuntu-gnome-desktop

# Install development dependancies
sudo apt install -y atom awscli bzr direnv exuberant-ctags git jq lastpass-cli neovim nodejs npm python3-pip ruby silversearcher-ag tig tmux virtualbox-qt

# Cleanup cache
sudo apt -y autoremove
sudo apt autoclean

# Install fly
if [[ ! -x $HOME/bin/fly ]]; then
  mkdir -p $HOME/bin
  curl "https://ci.concourse.ci/api/v1/cli?arch=amd64&platform=linux" > $HOME/bin/fly
  chmod 755 $HOME/bin/fly
fi

# Install Vagrant since System version is Repo version is too old
if [[ -z $(which vagrant) ]]; then
  pushd /tmp
  wget https://releases.hashicorp.com/vagrant/1.9.1/vagrant_1.9.1_x86_64.deb
  sudo dpkg --install vagrant_1.9.1_x86_64.deb
  rm vagrant_1.9.1_x86_64.deb
  popd
fi

# Setup Workspace
mkdir -p $HOME/workspace

clone_into_workspace() {
  DIR="${HOME}/workspace/$(echo $1 | awk -F '/' '{ print $(NF) }')"
  if [[ ! -d $DIR ]]; then
    git clone $1 $DIR
  fi
}

WORKSPACE_GIT_REPOS=(
  https://github.com/cloudfoundry-incubator/cf-routing-release
  https://github.com/cloudfoundry-incubator/cli-workstation
  https://github.com/cloudfoundry-incubator/diego-release
  https://github.com/cloudfoundry/bosh-lite
  https://github.com/cloudfoundry/cf-release
  https://github.com/cloudfoundry/claw
  https://github.com/cloudfoundry/homebrew-tap
)

for repo in "${WORKSPACE_GIT_REPOS[@]}"; do
  clone_into_workspace $repo
done

# Install/Upgrade BashIT
if [[ ! -d $HOME/.bash_it ]]; then
  git clone https://github.com/Bash-it/bash-it.git $HOME/.bash_it
  $HOME/.bash_it/install.sh
fi

set +e
source $HOME/.bashrc
bash-it update
set -e

# Configure BashIT
bash-it enable alias general git
bash-it enable completion defaults awscli bash-it brew git ssh tmux vagrant virtualbox
bash-it enable plugin fasd fzf git git-subrepo osx ruby ssh history

# Link Dotfiles
ln -sf $HOME/workspace/cli-workstation/dotfiles/bashit_custom/* $HOME/.bash_it/custom
ln -sf $HOME/workspace/cli-workstation/dotfiles/bashit_custom_linux/* $HOME/.bash_it/custom
ln -sf $HOME/workspace/cli-workstation/dotfiles/vimfiles/vimrc.local $HOME/.vimrc.local
ln -sf $HOME/workspace/cli-workstation/dotfiles/git/gitconfig $HOME/.gitconfig
ln -sf $HOME/workspace/cli-workstation/dotfiles/git/git-authors $HOME/.git-authors

ln -sf $HOME/workspace/cli-workstation/dotfiles/tmux/tmux.conf $HOME/.tmux.conf
if [[ ! -d ~/.tmux/plugins/tpm ]]; then
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# Install diff-so-fancy for better diffing
sudo npm install -g diff-so-fancy

# Install go if it's not installed
if [[ -z $(which go) ]]; then
  sudo mkdir -p /usr/local/golang
  sudo chown pivotal:pivotal /usr/local/golang
  mkdir -p $HOME/go/src
  curl -L "https://storage.googleapis.com/golang/go${GO_VERSION}.linux-amd64.tar.gz" > /tmp/go.tgz
  tar -C /usr/local/golang -xzf /tmp/go.tgz
  mv /usr/local/golang/go /usr/local/golang/go$GO_VERSION
  export GOROOT=/usr/local/golang/go$GO_VERSION
  export GOPATH=$HOME/go
  export PATH=$GOPATH/bin:$GOROOT/bin:$PATH
  rm /tmp/go.tgz
fi

# Clone Go repos into the correct gopath
clone_into_go_path() {
  DIR="${HOME}/go/src/${1}"
  if [[ ! -d $DIR ]]; then
    mkdir -p $(dirname $DIR)
    git clone "https://${1}" $DIR
    ln -s $DIR $HOME/workspace/$(basename $DIR)
  fi
}

GO_REPOS=(
  github.com/cloudfoundry/cf-acceptance-tests
  github.com/cloudfoundry-incubator/cli-plugin-repo
  github.com/cloudfoundry-incubator/diego-enabler
)

for repo in "${GO_REPOS[@]}"; do
  clone_into_go_path $repo
done

# Clone CLI Repo
if [[ ! -d "${GOPATH}/src/code.cloudfoundry.org/cli" ]]; then
  mkdir -p "${GOPATH}/src/code.cloudfoundry.org"
  cd "${GOPATH}/src/code.cloudfoundry.org"
  git clone "https://github.com/cloudfoundry/cli"
fi

# Install common utilities
GO_UTILS=(
  github.com/onsi/ginkgo/ginkgo
  github.com/onsi/gomega
  github.com/maxbrunsfeld/counterfeiter
  github.com/FiloSottile/gvt
  github.com/tools/godep
  github.com/jteeuwen/go-bindata/...
  github.com/nicksnyder/go-i18n/goi18n
  github.com/krishicks/i18n4go/i18n4go
  github.com/alecthomas/gometalinter
  github.com/git-duet/git-duet/...
)

for gopkg in "${GO_UTILS[@]}"; do
  echo Getting/Updating $gopkg
  GOPATH=$HOME/go go get -u $gopkg
done

# install bosh
if [[ -z $(which bosh) ]]; then
  sudo gem install --no-document bosh_cli
fi

# install bundler
if [[ -z $(which bundler) ]]; then
  sudo gem install --no-document bundler
fi

sudo gem update --no-document bosh_cli bundler

# Install Luan's Vim config
if [[ -d $HOME/.vim ]]; then
  pip3 install --upgrade neovim
  $HOME/.vim/update
else
  pip3 install neovim
  git clone https://github.com/luan/vimfiles.git $HOME/.vim
  $HOME/.vim/install
fi
