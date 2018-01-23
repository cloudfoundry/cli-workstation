#!/usr/bin/env bash

set -e

GO_VERSION="1.9.2" # Don't forget to date dotfiles/bashit_custom_linux/paths.bash

# Add any required repositories
if [[ -z $(which vim) ]]; then sudo add-apt-repository -y ppa:neovim-ppa/stable; fi
if [[ -z $(which fasd) ]]; then sudo add-apt-repository -y ppa:aacebedo/fasd; fi
if [[ -z $(which git) ]]; then sudo add-apt-repository -y ppa:git-core/ppa; fi
if [[ -z $(which tilix) ]]; then sudo add-apt-repository -y ppa:webupd8team/terminix; fi

if [[ -z $(which virtualbox) ]]; then
  wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -
  wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add -
  sudo add-apt-repository "deb http://download.virtualbox.org/virtualbox/debian $(lsb_release -cs) contrib"
fi


# Update/Upgrade to the latest
sudo apt update
sudo apt dist-upgrade -y

# Install system dependancies
sudo apt install -y bash-completion chromium-browser curl htop openssh-server software-properties-common tilix tree

# Install development dependancies
sudo apt install -y awscli bzr direnv exuberant-ctags git jq neovim nodejs npm python3-pip ruby silversearcher-ag tig tmux virtualbox-5.1

# Cleanup cache
sudo apt -y autoremove
sudo apt autoclean

# Sets tilix as the default terminal
sudo update-alternatives --set x-terminal-emulator /usr/bin/tilix

# Install fly
if [[ ! -x $HOME/bin/fly ]]; then
  mkdir -p $HOME/bin
  curl "https://ci.concourse.ci/api/v1/cli?arch=amd64&platform=linux" > $HOME/bin/fly
  chmod 755 $HOME/bin/fly
fi

# Install diff-so-fancy for better diffing
if [[ -z $(which diff-so-fancy) ]]; then
  sudo npm install -g diff-so-fancy
else
  sudo npm upgrade -g diff-so-fancy
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
  https://github.com/cloudfoundry/cli-workstation
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
bash-it enable completion defaults awscli bash-it brew git ssh tmux virtualbox
bash-it enable plugin fasd fzf git git-subrepo osx ruby ssh history

# Link Dotfiles
ln -sf $HOME/workspace/cli-workstation/dotfiles/bashit_custom/* $HOME/.bash_it/custom
ln -sf $HOME/workspace/cli-workstation/dotfiles/bashit_custom_linux/* $HOME/.bash_it/custom
ln -sf $HOME/workspace/cli-workstation/dotfiles/vimfiles/vimrc.local $HOME/.vimrc.local
ln -sf $HOME/workspace/cli-workstation/dotfiles/vimfiles/vimrc.local.plugins $HOME/.vimrc.local.plugins
ln -sf $HOME/workspace/cli-workstation/dotfiles/git/gitconfig $HOME/.gitconfig_include
ln -sf $HOME/workspace/cli-workstation/dotfiles/git/git-authors $HOME/.git-authors

# Setup gitconfig
if [[ -L $HOME/.gitconfig ]]; then
  rm $HOME/.gitconfig
  printf "[include]\n\tpath = $HOME/.gitconfig_include" > $HOME/.gitconfig
elif [[ ! -f $HOME/.gitconfig ]]; then
  printf "[include]\n\tpath = $HOME/.gitconfig_include" > $HOME/.gitconfig
fi

# Disable gnome keyring
if [[ ! -f $HOME/.config/autostart/gnome-keyring-secrets.desktop ]]; then
  mkdir -p $HOME/.config/autostart

  cp /etc/xdg/autostart/gnome-keyring* $HOME/.config/autostart

  find $HOME/.config/autostart -name "*gnome-keyring*" | \
    xargs sed -i "$ a\X-GNOME-Autostart-enabled=false"
fi

# Install go if it's not installed
if [[ -z $(which go) || $(go version) != *$GO_VERSION* ]]; then
  sudo mkdir -p /usr/local/golang
  sudo chown -R pivotal:pivotal /usr/local/golang
  mkdir -p $HOME/go/src
  rm -rf $HOME/go/pkg/*
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

sudo ln -fs ${GOPATH}/src/code.cloudfoundry.org/cli/ci/installers/completion/cf /usr/share/bash-completion/completions

# Install common utilities
GO_UTILS=(
  github.com/onsi/ginkgo/ginkgo
  github.com/onsi/gomega
  github.com/maxbrunsfeld/counterfeiter
  github.com/FiloSottile/gvt
  github.com/tools/godep
  github.com/jteeuwen/go-bindata/...
  github.com/XenoPhex/i18n4go/i18n4go
  github.com/alecthomas/gometalinter
  github.com/git-duet/git-duet/...
  github.com/cloudfoundry/bosh-cli
)

echo Running $(go version)
for gopkg in "${GO_UTILS[@]}"; do
  echo Getting/Updating $gopkg
  GOPATH=$HOME/go go get -u $gopkg
done

CLI_TEAM_REPOS=(
  "${GOPATH}"/src/code.cloudfoundry.org/cli
  "${GOPATH}"/src/github.com/cloudfoundry-incubator/cli-plugin-repo
  "${HOME}"/workspace/claw
  "${HOME}"/workspace/cli-workstation
  "${HOME}"/workspace/cli-private
)

# install git-hooks
sudo curl -o /usr/local/bin/git-hooks https://raw.githubusercontent.com/icefox/git-hooks/master/git-hooks
sudo chmod +x /usr/local/bin/git-hooks
for repo in "${CLI_TEAM_REPOS[@]}"; do
  if [ -d $repo ]; then
    pushd $repo
      git-hooks --uninstall || true
    popd
  fi
done

# install bosh
gem uninstall bosh_cli
sudo rm -f /usr/local/bin/bosh-cli
sudo curl https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-2.0.48-linux-amd64 -o /usr/local/bin/bosh-cli
sudo chmod 0755 /usr/local/bin/bosh-cli
sudo ln -sf /usr/local/bin/bosh-cli /usr/local/bin/bosh

# create symlink for bosh-cli
pushd $HOME/go/bin
  ln -sf bosh-cli bosh
popd

# Install Luan's Vim config
if [[ -d $HOME/.vim ]]; then
  pip3 install --upgrade neovim
  $HOME/.vim/update
else
  pip3 install neovim
  git clone https://github.com/luan/vimfiles.git $HOME/.vim
  $HOME/.vim/install
fi

# Install Luan's Tmux config
if [[ ! -d $HOME/.tmux ]]; then
  git clone https://github.com/luan/tmuxfiles.git $HOME/.tmux
  $HOME/.tmux/install
fi

# install lastpass-cli from source (the Ubuntu package is broken)
if [[ ! -d ~/workspace/lastpass-cli ]]; then
  pushd ~/workspace
    git clone https://github.com/lastpass/lastpass-cli.git
  popd
fi

pushd ~/workspace/lastpass-cli
  sudo apt install -y openssl libcurl4-openssl-dev libxml2 libssl-dev libxml2-dev pinentry-curses xclip cmake build-essential pkg-config
  git pull
  cmake .
  make
  sudo make install
popd

# install fasd from source (does not exist in ubuntu ppa)
if [[ ! -d ~/workspace/fasd ]]; then
  pushd ~/workspace
    git clone https://github.com/clvv/fasd
  popd
fi

pushd ~/workspace/fasd
  git pull
  make
  sudo make install
popd
