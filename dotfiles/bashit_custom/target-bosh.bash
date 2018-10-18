#!/usr/bin/env bash

target_bosh() {
  # tput setaf 1 = red
  # tput setaf 2 = green
  # tput setaf 9 = reset color

  pool_dir=~/workspace/cli-pools/bosh-lites/claimed

  pushd ${pool_dir} >/dev/null
    git pull
  popd >/dev/null

  if [ -z "$1" ]; then
    echo "$(tput setaf 1)Usage: target_bosh <environment>. Valid environments are:$(tput setaf 9)"
    ls ${pool_dir}
  else
    env_file=${pool_dir}/${1}

    if [ -f "$env_file" ]; then
      source "$env_file"
      echo "$(tput setaf 2)Success!$(tput setaf 9)"
      env_ssh_key_path="$HOME/workspace/cli-pools/${1}/bosh.pem"

      if [ ! -f "$env_ssh_key_path" ]; then
        echo "$BOSH_GW_PRIVATE_KEY_CONTENTS" > "$env_ssh_key_path"
        chmod 0600 "$env_ssh_key_path"
      fi

      export BOSH_GW_PRIVATE_KEY="$env_ssh_key_path"
    else
      echo "$(tput setaf 1)Environment '${1}' does not exist. Valid environments are:$(tput setaf 9)"
      ls ${pool_dir}
    fi
  fi
}

export -f target_bosh
