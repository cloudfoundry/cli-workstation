#!/usr/bin/env bash

set -e

if [[ $1 == "--skip-cask" ]]; then
  SKIP_CASK=1
fi

brew_install() {
  if brew info $1 | grep 'Not installed'; then
    echo Brew installing $1
    brew install $@
  else
    echo $1 installed
  fi
}

brew_tap_install() {
  brew tap $1
  brew_install "${@:2}"
}

clone_into_go_path() {
  DIR="${HOME}/go/src/${1}"
  if [[ ! -d $DIR ]]; then
    git clone "https://${1}" $DIR
  fi
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

echo "Updating Homebrew"
brew update

HOMEBREW_PACKAGES=(
  ack
  awscli
  bash-completion
  bzr
  coreutils
  diff-so-fancy
  direnv
  fasd
  fzf
  git
  git-hooks
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
  brew_install $package
done

brew_install lastpass-cli --with-pinentry --with-doc
brew_tap_install neovim/neovim neovim
brew_tap_install universal-ctags/universal-ctags universal-ctags --HEAD
brew_tap_install git-duet/tap git-duet

brew tap caskroom/cask
brew tap caskroom/versions

CASK_APPS=(
  charles
  dash
  google-chrome
  intellij-idea
  iterm2-nightly
  java
  shiftit
  the-unarchiver
  vagrant
  virtualbox
  time-out
)

if [[ $SKIP_CASK != 1 ]]; then
  for app in "${CASK_APPS[@]}"; do
    brew cask install --appdir=/Applications $app
  done
fi

if [[ ! -z $(brew outdated) ]]; then
  brew upgrade
fi

brew cleanup
brew cask cleanup

mkdir -p $HOME/go $HOME/workspace

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
)

for gopkg in "${GO_UTILS[@]}"; do
  echo Getting/Updating $gopkg
  GOPATH=$HOME/go go get -u $gopkg
done

if [[ ! -x $HOME/bin/fly ]]; then
  mkdir -p $HOME/bin
  curl "https://ci.concourse.ci/api/v1/cli?arch=amd64&platform=darwin" > $HOME/bin/fly
  chmod 755 $HOME/bin/fly
fi

GO_REPOS=(
  code.cloudfoundry.org/cli
  github.com/cloudfoundry/cf-acceptance-tests
)

for repo in "${GO_REPOS[@]}"; do
  clone_into_go_path $repo
done

WORKSPACE_GIT_REPOS=(
  https://github.com/cloudfoundry-incubator/cf-routing-release
  https://github.com/cloudfoundry-incubator/cli-workstation
  https://github.com/cloudfoundry-incubator/diego-enabler
  https://github.com/cloudfoundry-incubator/diego-release
  https://github.com/cloudfoundry/bosh-lite
  https://github.com/cloudfoundry/cf-release
  https://github.com/cloudfoundry/claw
  https://github.com/cloudfoundry/homebrew-tap
)

for repo in "${WORKSPACE_GIT_REPOS[@]}"; do
  clone_into_workspace $repo
done

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
bash-it enable plugin fasd fzf git git-subrepo osx ruby ssh history

ln -sf $HOME/workspace/cli-workstation/dotfiles/bashit_custom/* $HOME/.bash_it/custom
ln -sf $HOME/workspace/cli-workstation/dotfiles/bashit_custom_osx/* $HOME/.bash_it/custom
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

ln -sf $HOME/workspace/cli-workstation/dotfiles/tmux/tmux.conf $HOME/.tmux.conf
if [[ ! -d ~/.tmux/plugins/tpm ]]; then
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

sudo ln -sf $HOME/workspace/cli-workstation/scripts/vagrant/suspend_all.sh /usr/local/bin/logout.sh
sudo defaults write com.apple.loginwindow LogoutHook /usr/local/bin/logout.sh

if bosh version 1>/dev/null 2>/dev/null; then
  gem update bosh_cli
else
  gem install bosh_cli
fi

