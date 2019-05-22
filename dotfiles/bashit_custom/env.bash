# git-duet
export GIT_DUET_GLOBAL=true
export GIT_DUET_CO_AUTHORED_BY=1

# set vim to be the default editor
export GIT_EDITOR=vim
export EDITOR=vim

# set app dir to be /Applications
HOMEBREW_CASK_OPTS='--appdir=/Applications'

# target local bosh lite by default
if [[ -f $HOME/deployments/vbox/creds.yml ]]; then
  export BOSH_ENVIRONMENT=vbox
  export BOSH_CLIENT=admin
  export BOSH_CLIENT_SECRET=$(bosh int ~/deployments/vbox/creds.yml --path /admin_password)
fi

# lpass password via prompt

export LPASS_DISABLE_PINENTRY=1

export DB=postgres

export VAT_HOSTNAMES=(ocean)

contains() {
    local n=$#
    local value=${!n}
    for ((i=1;i < $#;i++)) {
        if [ "${!i}" == "${value}" ]; then
            echo "y"
            return 0
        fi
    }
    echo "n"
    return 1
}

if [ $(contains "${VAT_HOSTNAMES[@]}" "$(hostname)") == "y" ]; then
  export TARGET_V7=true
fi

