#!/usr/bin/env bash
set -e

GO_VERSION="1.12.1" # Don't forget to date dotfiles/bashit_custom_linux/paths.bash

# Add any required repositories
if [[ -z $(which vim) ]]; then sudo add-apt-repository -y ppa:neovim-ppa/stable; fi
if [[ -z $(which git) ]]; then sudo add-apt-repository -y ppa:git-core/ppa; fi

if [[ -z $(which virtualbox) ]]; then
  wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -
  wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add -
  sudo add-apt-repository "deb http://download.virtualbox.org/virtualbox/debian $(lsb_release -cs) contrib"
fi

if [[ -z $(which goland) ]]; then
  curl -s https://s3.eu-central-1.amazonaws.com/jetbrains-ppa/0xA6E8698A.pub.asc | sudo apt-key add -
  echo "deb http://jetbrains-ppa.s3-website.eu-central-1.amazonaws.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/jetbrains-ppa.list
fi

if [[ -z $(which google-chrome) ]]; then
  curl -s https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
  echo "deb http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list
fi

# Update/Upgrade to the latest
sudo apt update
sudo apt dist-upgrade -y

# Install system dependancies
sudo apt install -y bash-completion google-chrome-stable curl fasd gnome-tweak-tool htop openssh-server software-properties-common tilix tree

# Install system drivers
sudo ubuntu-drivers autoinstall

# Install development dependancies
sudo apt install -y awscli bzr direnv exuberant-ctags git goland \
  jq neovim net-tools nodejs python3-pip \
  ruby2.5 ruby-dev silversearcher-ag tig tmux virtualbox-5.2

gem i bundler -v 1.17.3 #Cloud controller does not work with 2.x version of bundler

# Cleanup cache
sudo apt -y autoremove
sudo apt autoclean

# Sets tilix as the default terminal
sudo update-alternatives --set x-terminal-emulator /usr/bin/tilix.wrapper

# Install fly
if [[ ! -x $HOME/bin/fly ]]; then
  mkdir -p $HOME/bin
  curl "https://ci.cli.fun/api/v1/cli?arch=amd64&platform=linux" > $HOME/bin/fly
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
  else
    cd $DIR
    git init
  fi
}

WORKSPACE_GIT_REPOS=(
  https://github.com/bosh-packages/cf-cli-release
  https://github.com/cloudfoundry/cf-deployment
  https://github.com/cloudfoundry/claw
  https://github.com/cloudfoundry/cli-i18n
  https://github.com/cloudfoundry/cli-workstation
  https://github.com/cloudfoundry/capi-workspace
  https://github.com/cloudfoundry/cloud_controller_ng
  https://github.com/cloudfoundry/homebrew-tap
  https://github.com/concourse/concourse-bosh-deployment
)

for repo in "${WORKSPACE_GIT_REPOS[@]}"; do
  clone_into_workspace $repo
done

# install cli tab completion
sudo ln -sf ${GOPATH}/src/code.cloudfoundry.org/cli/ci/installers/completion/cf /usr/share/bash-completion/completions

# Install/Upgrade BashIT
if [[ ! -d $HOME/.bash_it ]]; then
  git clone https://github.com/Bash-it/bash-it.git $HOME/.bash_it
  $HOME/.bash_it/install.sh --silent
fi

# These are pulled directly from our current (2019/02/28) ~/.bashrc
# This is because ~/.bashrc's are difficult to source from a script
# https://askubuntu.com/a/77053
# Also, it is currently unknown why sourcing bash_it.sh requires set +e.
export BASH_IT="/home/pivotal/.bash_it"
export BASH_IT_THEME="$HOME/workspace/cli-workstation/dotfiles/bashit_custom_themes/cli.theme.bash"

set +e
source "$BASH_IT"/bash_it.sh
bash-it update
set -e


# Configure BashIT
bash-it enable alias general git
bash-it enable completion defaults awscli bash-it brew git ssh tmux virtualbox
bash-it enable plugin fasd fzf git git-subrepo ssh history

# Link Dotfiles
ln -sf $HOME/workspace/cli-workstation/dotfiles/bashit_custom/* $HOME/.bash_it/custom
ln -sf $HOME/workspace/cli-workstation/dotfiles/bashit_custom_themes/* $HOME/.bash_it/custom/themes
ln -sf $HOME/workspace/cli-workstation/dotfiles/bashit_custom_linux/* $HOME/.bash_it/custom
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

# Install common utilities
GO_UTILS=(
  github.com/onsi/ginkgo/ginkgo
  github.com/onsi/gomega
  github.com/maxbrunsfeld/counterfeiter
  github.com/FiloSottile/gvt
  github.com/tools/godep
  github.com/shuLhan/go-bindata/...
  github.com/XenoPhex/i18n4go/i18n4go
  github.com/alecthomas/gometalinter
  github.com/git-duet/git-duet/...
  github.com/cloudfoundry/bosh-bootloader/bbl
  github.com/golangci/golangci-lint/cmd/golangci-lint
)

echo Running $(go version)
for gopkg in "${GO_UTILS[@]}"; do
  echo Getting/Updating $gopkg
  GOPATH=$HOME/go go get -u $gopkg
done

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



# install bosh
echo "installing latest bosh"
sudo rm -f /usr/local/bin/bosh-cli $HOME/go/bin/bosh*
sudo curl https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-5.4.0-linux-amd64 -o /usr/local/bin/bosh-cli
sudo chmod 0755 /usr/local/bin/bosh-cli
sudo ln -sf /usr/local/bin/bosh-cli /usr/local/bin/bosh

# Install RipGrep
pushd /tmp
  curl -s https://api.github.com/repos/BurntSushi/ripgrep/releases/latest > git_ripgrep.json
  RG_VERSION=$(jq '.["tag_name"]' git_ripgrep.json | tr -d \")
  cat git_ripgrep.json \
    | grep "browser_download_url.*deb" \
    | cut -d : -f 2,3 \
    | tr -d \" \
    | wget -qi -
  sudo dpkg -i ripgrep_${RG_VERSION}_amd64.deb

  rm git_ripgrep.json
  rm ripgrep_${RG_VERSION}_amd64.deb
popd


# Install Luan's NeoVim config
if [[ ! -d $HOME/.config/nvim ]]; then
  if [[ -L $HOME/.config/nvim ]]; then
    rm $HOME/.config/nvim
  fi

  pip3 install neovim
  git clone https://github.com/luan/nvim $HOME/.config/nvim

  mkdir -p $HOME/.config/nvim/user
  ln -sf $HOME/workspace/cli-workstation/dotfiles/vimfiles/after.vim $HOME/.config/nvim/user/after.vim
  ln -sf $HOME/workspace/cli-workstation/dotfiles/vimfiles/before.vim $HOME/.config/nvim/user/before.vim
  ln -sf $HOME/workspace/cli-workstation/dotfiles/vimfiles/plug.vim $HOME/.config/nvim/user/plug.vim

  git clone --depth 1 https://github.com/ryanoasis/nerd-fonts $HOME/.config/nerd-fonts
  pushd $HOME/.config/nerd-fonts
    ./install.sh DejaVuSansMono
  popd
else
  pip3 install --upgrade neovim
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

# install dep
curl -L "https://github.com/golang/dep/releases/download/v0.5.0/dep-linux-amd64" > $HOME/bin/dep
chmod 755 $HOME/bin/dep

# Bash auto-complete case-insensitive
if [ ! -a ~/.inputrc ]; then echo '$include /etc/inputrc' > ~/.inputrc; fi
echo 'set completion-ignore-case On' >> ~/.inputrc
