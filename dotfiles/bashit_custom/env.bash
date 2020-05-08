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

declare -a allowed_versions=("V6" "V7" "V8")

set_cli_version() {
  local myver
	for ver in "${allowed_versions[@]}"; do
		if [[ "$ver" -eq "$1" ]]; then
      myver=$ver
		fi
	done

  if [ -z "$myver" ]; then
		echo "[ $1 ] is not an allowed version"
		exit 1
	fi

	export TARGET_CLI=$1
  export GOFLAGS="--tags=$1"
  export LINT_FLAGS="--build-tags=$1"
}

function set_v6() {
	 set_cli_version "V6"
}

function set_v7() {
	set_cli_version "V7"
}

function set_v8() {
	set_cli_version "V8"
}

set_v7
