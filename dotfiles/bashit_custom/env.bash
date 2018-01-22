# git-duet
export GIT_DUET_GLOBAL=true
export GIT_DUET_ROTATE_AUTHOR=true

# set vim to be the default editor
export EDITOR=vim

# set app dir to be /Applications
HOMEBREW_CASK_OPTS='--appdir=/Applications'

# target local bosh lite by default
if [[ -f $HOME/deployments/vbox/creds.yml ]]; then
  export BOSH_ENVIRONMENT=vbox
  export BOSH_CLIENT=admin
  export BOSH_CLIENT_SECRET=$(bosh int ~/deployments/vbox/creds.yml --path /admin_password)
fi
