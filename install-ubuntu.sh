#!/usr/bin/env bash
set -e

GO_VERSION="1.12.13"
BOSH_VERSION="6.1.1"             # SMT - was version 5.4.0
NODE_VERSION="10"                # SMT - was version 8
GOLANGCI_LINT_VERSION="v1.16.0"  # SMT - subsequent versions bring in new linters that we're not ready for
GODEP_VERSION="v0.5.4"

report() {
  echo
  echo "++ $1"
  echo
}

# Update / Upgrade apt packages
report "Updating apt packages"
sudo apt update
report "Upgrading Linux distribution"
sudo apt dist-upgrade -y

# Install system dependencies
report "Installing system dependencies"
sudo apt install -y \
  bash-completion \
  curl \
  fasd \
  gnome-tweak-tool \
  htop \
  openssh-server \
  shellcheck \
  snapd \
  software-properties-common \
  tilix \
  tree


# Add required repositories
#
# Humans need NeoVim
if [[ -z $(which nvim) ]]; then sudo add-apt-repository -y ppa:neovim-ppa/stable; fi

# NeoVim needs yarn
if [[ -z $(which yarn) ]]; then
  report "Setting up binary distribution of yarn for apt installation"
  curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
fi

# NeoVim needs node
if [[ -z $(which node) ]]; then
  report "Setting up binary distribution of NodeJS for apt installation"
  # From https://github.com/nodesource/distributions#installation-instructions
  curl -sL https://deb.nodesource.com/setup_$NODE_VERSION.x | sudo bash - # For Ubuntu LTS
  # From https://node.melroy.org/
  # curl -sL https://node.melroy.org/deb/setup_$NODE_VERSION.x | sudo bash - # For Mint 19.2
fi


# Install development dependencies
report "Installing development dependencies"
sudo apt install -y \
  awscli \
  direnv \
  exuberant-ctags \
  git \
  jq \
  neovim \
  net-tools \
  nodejs \
  python3-pip \
  python3-setuptools \
  ruby2.5 \
  ruby-dev \
  silversearcher-ag \
  tig \
  tmux \
  yarn                 # Required for neovim

# Install silly messaging utilities
report "Installing silly messaging utilities"
sudo apt install -y \
  cowsay \
  figlet

# Clean up apt cache
report "Cleaning up apt cache"
sudo apt autoremove -y
sudo apt autoclean


if [[ -z $(which goland) ]]; then
  report "Installing GoLand"
  sudo snap install goland --classic
else
  report "Updating Goland"
  sudo snap refresh goland
fi


## SMT - why do we want a floppy drive?
# function install_fd() {
#
#   FD_VERSION="7.3.0"
#   FD_FILENAME="fd-musl_${FD_VERSION}_amd64.deb"
#   FD_URL="https://github.com/sharkdp/fd/releases/download/v${FD_VERSION}/${FD_FILENAME}"
#
#   echo "Installing fd version $FD_VERSION"
#
#   pushd "$(mktemp -d)"
#     wget "$FD_URL"
#     sudo dpkg -i "$FD_FILENAME"
#   popd
# }
#
# $(fd -h | grep 'fd 7.3.0') || install_fd


## SMT - why do we want to control the drivers in our software setup script?
# Install system drivers
# sudo ubuntu-drivers autoinstall


# Set tilix as the default terminal
report "Setting 'tilix' as the default terminal"
sudo update-alternatives --set x-terminal-emulator /usr/bin/tilix.wrapper


# Install fly
if [[ ! -x $HOME/bin/fly ]]; then
  report "Installing fly"
  mkdir -p $HOME/bin
  curl "https://ci.cli.fun/api/v1/cli?arch=amd64&platform=linux" > $HOME/bin/fly
  chmod 755 $HOME/bin/fly
else
  report "Skipping installation of fly: already present"
fi


# Install diff-so-fancy for better diffing in git
if [[ -z $(which diff-so-fancy) ]]; then
  report "Installing diff-so-fancy for better git diffs"
  sudo npm install -g diff-so-fancy
else
  report "Updating diff-so-fancy for better git diffs"
  sudo npm upgrade -g diff-so-fancy
fi


# Install lastpass-cli from source (the Ubuntu package is broken)
report "Installing lastpass-cli from source"
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


# SMT TODO: handle git ssh somehow
# Setup Workspace
report "Cloning repos into workspace"
mkdir -p $HOME/workspace

clone_into_workspace() {
  repo="$1"
  shift 1

  DIR="${HOME}/workspace/$(echo "$repo" | awk -F '/' '{ print $(NF) }')"
  if [[ ! -d $DIR ]]; then
    git clone --recurse-submodules "$repo" "$DIR" "$@"
  else
    cd "$DIR"
    git init
  fi
}

SSH_REPO_SCHEME=git@github.com

WORKSPACE_GIT_REPOS=(
  $SSH_REPO_SCHEME:bosh-packages/cf-cli-release
  $SSH_REPO_SCHEME:cloudfoundry/cf-deployment
  $SSH_REPO_SCHEME:cloudfoundry/claw
  $SSH_REPO_SCHEME:cloudfoundry/cli-i18n
  $SSH_REPO_SCHEME:cloudfoundry/cli-pools
  $SSH_REPO_SCHEME:cloudfoundry/cli-private
  $SSH_REPO_SCHEME:cloudfoundry/cli-workstation
  $SSH_REPO_SCHEME:cloudfoundry/homebrew-tap
  $SSH_REPO_SCHEME:concourse/concourse-bosh-deployment
  $SSH_REPO_SCHEME:pivotal-legacy/pivotal_ide_prefs
)

for repo in "${WORKSPACE_GIT_REPOS[@]}"; do
  clone_into_workspace "$repo"
done


# Install fancier fonts with glyphs
if [[ ! -d $HOME/.local/share/fonts/NerdFonts ]]; then
  installDateTime=$(date '+%Y%m%d-%H%M%S')
  report "Installing NerdFonts -- See /tmp/nerdFontsInstallReport1-$installDateTime for details"
  clone_into_workspace https://github.com/ryanoasis/nerd-fonts --depth 1
  pushd "$HOME/workspace/nerd-fonts"
    # This is a lengthy process that the rest of the script doesn't rely on, so run in background
    ./install.sh 2>&1 > /tmp/nerdFontsInstallReport1-$installDateTime.txt &
  popd
else
  report "Skipping installation of existing NerdFonts"
fi


# After cloning the pivotal_ide_prefs repository
# Change the keymap for GoLand to "Mac OS X 10.5"
sed -i 's/Pivotal Goland/Mac OS X 10.5+/' ~/workspace/pivotal_ide_prefs/pref_sources/Goland/options/keymap.xml

pushd "$HOME/workspace/pivotal_ide_prefs"
 cli/bin/ide_prefs install --ide=goland --user-prefs-location="$HOME/.GoLand2019.1/config/"
popd


# install cli tab completion
report "Installing cli tab completion"
sudo ln -sf ${GOPATH}/src/code.cloudfoundry.org/cli/ci/installers/completion/cf /usr/share/bash-completion/completions


# Install/Upgrade BashIT
report "Installing or upgrading BashIT"
if [[ ! -d $HOME/.bash_it ]]; then
  git clone https://github.com/Bash-it/bash-it.git $HOME/.bash_it
  $HOME/.bash_it/install.sh --silent
fi

# These are pulled directly from our current (2019/02/28) ~/.bashrc
# This is because ~/.bashrc's are difficult to source from a script
# https://askubuntu.com/a/77053
# Also, it is currently unknown why sourcing bash_it.sh requires set +e.
export BASH_IT="$HOME/.bash_it"
export BASH_IT_THEME="$HOME/workspace/cli-workstation/dotfiles/bashit_custom_themes/cli.theme.bash"

set +e
source "$BASH_IT"/bash_it.sh
bash-it update
set -e

# Configure BashIT
report "Configuring BashIT"
bash-it disable alias general git
bash-it enable completion defaults awscli bash-it brew git ssh tmux virtualbox
bash-it enable plugin fasd fzf git git-subrepo ssh history


# Link Dotfiles
report "Creating dotfile symlinks"
ln -sf $HOME/workspace/cli-workstation/dotfiles/bashit_custom/* $HOME/.bash_it/custom
ln -sf $HOME/workspace/cli-workstation/dotfiles/bashit_custom_themes/* $HOME/.bash_it/custom/themes
ln -sf $HOME/workspace/cli-workstation/dotfiles/bashit_custom_linux/* $HOME/.bash_it/custom
ln -sf $HOME/workspace/cli-workstation/dotfiles/git/gitconfig $HOME/.gitconfig_include
ln -sf $HOME/workspace/cli-workstation/dotfiles/git/git-authors $HOME/.git-authors

ln -sf $HOME/workspace/cli-workstation/scripts/ui-scale $HOME/bin/
ln -sf $HOME/workspace/cli-workstation/scripts/ui-display $HOME/bin/


# Setup gitconfig
report "Configuring $HOME/.gitconfig"
if [[ -L $HOME/.gitconfig ]]; then
  rm $HOME/.gitconfig
  printf "[include]\n\tpath = $HOME/.gitconfig_include" > $HOME/.gitconfig
elif [[ ! -f $HOME/.gitconfig ]]; then
  printf "[include]\n\tpath = $HOME/.gitconfig_include" > $HOME/.gitconfig
fi


## SMT - Why disable gnome keyring?
# # Disable gnome keyring
# if [[ ! -f $HOME/.config/autostart/gnome-keyring-secrets.desktop ]]; then
#   mkdir -p $HOME/.config/autostart
#
#   cp /etc/xdg/autostart/gnome-keyring* $HOME/.config/autostart
#
#   find $HOME/.config/autostart -name "*gnome-keyring*" | \
#     xargs sed -i "$ a\X-GNOME-Autostart-enabled=false"
# fi

# Install go if it's not installed or the wrong version
if [[ -z $(which go) || $(go version) != *$GO_VERSION* ]]; then
  report "Installing go version [ $GO_VERSION ]"
  sudo snap install go --classic --channel=1.12/stable
else
  report "Skipping installation of existing go version [ $GO_VERSION ]"
fi


# Install common go utilities
GO_UTILS=(
  github.com/onsi/ginkgo/ginkgo
  github.com/onsi/gomega
  github.com/maxbrunsfeld/counterfeiter
  github.com/tools/godep
  github.com/shuLhan/go-bindata/...
  github.com/XenoPhex/i18n4go/i18n4go
  github.com/git-duet/git-duet/...
  github.com/cloudfoundry/bosh-bootloader/bbl
)

report "Getting or updating common Go utilities"
for gopkg in "${GO_UTILS[@]}"; do
  echo Updating $gopkg
  GOPATH=$HOME/go go get -u $gopkg
done


# Clone Go repos into the GOPATH
clone_into_go_path() {
  DIR="${HOME}/go/src/${1}"
  if [[ ! -d $DIR ]]; then
    mkdir -p $(dirname $DIR)
    git clone "https://${1}" $DIR
    ## SMT - The symlinks have caused problems in the past.  Can we drop them?
    # ln -s $DIR $HOME/workspace/$(basename $DIR)
  fi
}

GO_REPOS=(
  github.com/cloudfoundry/cf-acceptance-tests
  github.com/golangci/golangci-lint
)

for repo in "${GO_REPOS[@]}"; do
  clone_into_go_path $repo
done

cd $GOPATH/src/github.com/golangci/golangci-lint
git checkout $GOLANGCI_LINT_VERSION
cd $GOPATH/src
GOPATH=$HOME/go go get github.com/golangci/golangci-lint/cmd/golangci-lint

# Clone CLI Repo
if [[ ! -d "${GOPATH}/src/code.cloudfoundry.org/cli" ]]; then
  mkdir -p "${GOPATH}/src/code.cloudfoundry.org"
  cd "${GOPATH}/src/code.cloudfoundry.org"
  git clone "$SSH_REPO_SCHEME:cloudfoundry/cli"
fi

# Clone cli-plugin-repo
if [[ ! -d "${GOPATH}/src/code.cloudfoundry.org/cli-plugin-repo" ]]; then
  cd "${GOPATH}/src/code.cloudfoundry.org"
  git clone "$SSH_REPO_SCHEME:cloudfoundry/cli-plugin-repo"
fi

# Install bosh
if [[ -z $(which bosh) || $(bosh --version | cut -d'-' -f 1 | cut -d' ' -f 2) != $BOSH_VERSION ]]; then
  report "Installing bosh version [ $BOSH_VERSION ]"
  sudo rm -f /usr/local/bin/bosh-cli $HOME/go/bin/bosh*
  sudo curl https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-$BOSH_VERSION-linux-amd64 -o /usr/local/bin/bosh-cli
  sudo chmod 0755 /usr/local/bin/bosh-cli
  sudo ln -sf /usr/local/bin/bosh-cli /usr/local/bin/bosh
else
  report "Skipping installation of existing bosh version [ $BOSH_VERSION ]"
fi


# Install RipGrep
if [[ -z $(which rg) ]]; then
  report "Installing RipGrep"
  sudo snap install ripgrep --classic
else
  report "Updating RipGrep"
  sudo snap refresh ripgrep
fi

# Install NeoVim and Luan's NeoVim config
if [[ ! -d $HOME/.config/nvim ]]; then
  report "Installing NeoVim"
  if [[ -L $HOME/.config/nvim ]]; then
    rm $HOME/.config/nvim
  fi

  pip3 install wheel
  pip3 install neovim

  report "Installing Luan's NeoVim config"
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
  report "Upgrading NeoVim"
  pip3 install --upgrade neovim
fi

report "Installing / upgrading and configuring yamllint for NeoVim"
pip3 install --upgrade yamllint
mkdir -p $HOME/.config/yamllint
ln -sf $HOME/workspace/cli-workstation/dotfiles/yamllint.config $HOME/.config/yamllint/config

# Install Luan's Tmux config
if [[ ! -d $HOME/.tmux ]]; then
  report "Installing Luan's Tmux config"
  git clone https://github.com/luan/tmuxfiles.git $HOME/.tmux
  $HOME/.tmux/install

  ln -sf $HOME/workspace/cli-workstation/dotfiles/tmux/tmux.conf.local $HOME/.tmux.conf.local
  cat  <<EOT >> $HOME/.tmux.conf

# load user config
source-file $HOME/.tmux.conf.local
EOT
else
  report "Skipping installation of existing Luan's Tmux config"
fi


# Install credhub cli
report "Installing latest Credhub CLI"
credhub_url="$(curl https://api.github.com/repos/cloudfoundry-incubator/credhub-cli/releases | jq '.[0].assets | map(select(.name | contains("linux"))) | .[0].browser_download_url' -r)"
curl -Lo /tmp/credhub.tgz "$credhub_url"
tar xzvf /tmp/credhub.tgz -C $HOME/bin
chmod 755 $HOME/bin/credhub


# Install dep
report "Installing dep version [ $GODEP_VERSION ]"
curl -Lo $HOME/bin/dep "https://github.com/golang/dep/releases/download/$GODEP_VERSION/dep-linux-amd64"
chmod 755 $HOME/bin/dep


# Make bash auto-complete case-insensitive
if [ ! -f ~/.inputrc ]; then
  report "Making bash auto-complete case-insensitive"
  echo '$include /etc/inputrc' > ~/.inputrc
  echo 'set completion-ignore-case On' >> ~/.inputrc
fi


# increase key repeat rate
if [[ -n "$DISPLAY" ]] ; then
  report "Increasing key repeat rate"
  xset r rate 250 35
fi


if [[ -z $(which zoom) ]]; then
  report "NOT installing zoom because it has to be done manually once this script ends"
  report "go to zoom.com and download and install the hotness yerself"
  report "https://support.zoom.us/hc/en-us/articles/204206269-Installing-Zoom-on-Linux"
fi

figlet -t -k -c -f /usr/share/figlet/script.flf "You have achieved pure workstation happiness!"
