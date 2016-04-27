#!/usr/bin/env bash

set -e

brew_install_or_update() {
  if brew info $1 | grep 'Not installed'; then
    echo Brew installing $1
    brew install $@
  else
    if [[ -z $(brew outdated $1) ]]; then
      echo $1 is up to date
    else
      echo Brew upgrading $1
      brew upgrade $1
    fi
  fi
}

brew_tap_install_or_update() {
  brew tap $1
  brew_install_or_update "${@:2}"
}

clone_into_workspace() {
  DIR="${HOME}/workspace/$(echo $1 | awk -F '/' '{ print $(NF) }')"
  if [[ ! -d $DIR ]]; then
    git clone $1 $DIR
  fi
}

# Install Basic XCode tools if not installed
which ruby 1>/dev/null && which git 1>/dev/null || xcode-select --install

# Install homebrew if not installed
which brew 1>/dev/null || ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

brew update

HOMEBREW_PACKAGES=(
  ack
  awscli
  bash-completion
  bzr
  coreutils
  direnv
  fasd
  fzf
  git
  go
  htop-osx
  jq
  node
  pstree
  python3
  ruby
  s3cmd
  ssh-copy-id
  the_silver_searcher
  tig
  tmux
  tree
  watch
  wget
)

for package in "${HOMEBREW_PACKAGES[@]}"; do
  brew_install_or_update $package
done

brew_install_or_update lastpass-cli --with-pinentry --with-doc
brew_tap_install_or_update neovim/neovim neovim
brew_tap_install_or_update universal-ctags/universal-ctags universal-ctags --HEAD
brew_tap_install_or_update git-duet/tap git-duet

brew tap caskroom/cask
brew tap caskroom/versions

CASK_APPS=(
  google-chrome
  intellij-idea
  iterm2-nightly
  java
  shiftit
  vagrant
  virtualbox
)

for app in "${CASK_APPS[@]}"; do
  brew cask install --appdir=/Applications $app
done

brew cleanup
brew cask cleanup

mkdir -p $HOME/workspace $HOME/go

WORKSPACE_GIT_REPOS=(
  https://github.com/cloudfoundry/bosh-lite
  https://github.com/cloudfoundry/cf-release
  https://github.com/cloudfoundry/claw
  https://github.com/cloudfoundry-incubator/cf-routing-release
  https://github.com/cloudfoundry-incubator/diego-release
  https://github.com/cloudfoundry-incubator/cli-workstation
  https://github.com/cloudfoundry/vcap-test-assets
)

for repo in "${WORKSPACE_GIT_REPOS[@]}"; do
  clone_into_workspace $repo
done

GO_UTILS=(
 github.com/onsi/ginkgo/ginkgo
 github.com/onsi/gomega
 github.com/maxbrunsfeld/counterfeiter
 github.com/FiloSottile/gvt
 github.com/tools/godep
 github.com/jteeuwen/go-bindata/...
 github.com/nicksnyder/go-i18n/goi18n
 github.com/krishicks/i18n4go/i18n4go
)

for gopkg in "${GO_UTILS[@]}"; do
  echo Getting/Updating $gopkg
  GOPATH=$HOME/go go get -u $gopkg
done

if [[ ! -d $HOME/go/src/github.com/cloudfoundry/cli ]]; then
  GOPATH=$HOME/go go get -d github.com/cloudfoundry/cli || true
fi

if [[ ! -d $HOME/.bash_it ]]; then
  git clone https://github.com/Bash-it/bash-it.git $HOME/.bash_it
  $HOME/.bash_it/install.sh
fi

set +e
source $HOME/.bash_profile
bash-it update
set -e

bash-it enable alias general git
bash-it enable completion defaults awscli bash-it brew git ssh tmux vagrant virtualbox
bash-it enable plugin fasd fzf git git-subrepo osx ruby ssh

ln -sf $HOME/workspace/cli-workstation/dotfiles/bashit_custom/* $HOME/.bash_it/custom
ln -sf $HOME/workspace/cli-workstation/dotfiles/vimfiles/vimrc.local $HOME/.vimrc.local
ln -sf $HOME/workspace/cli-workstation/dotfiles/git/gitconfig $HOME/.gitconfig
ln -sf $HOME/workspace/cli-workstation/dotfiles/git/git-authors $HOME/.git-authors

alias vim=nvim
if [[ -d $HOME/.vim ]]; then
  $HOME/.vim/update
else
  git clone https://github.com/luan/vimfiles.git $HOME/.vim
  sudo pip3 install neovim
  $HOME/.vim/install
fi

if bosh version 1>/dev/null 2>/dev/null; then
  gem update bosh_cli
else
  gem install bosh_cli
fi
