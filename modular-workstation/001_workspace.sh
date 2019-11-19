#!/bin/bash

# Setup Workspace
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

#TODO: Put the CLI repo into the go path?
WORKSPACE_GIT_REPOS=(
  bosh-packages/cf-cli-release
  cloudfoundry/capi-bara-tests
  cloudfoundry/capi-ci
  cloudfoundry/capi-release
  cloudfoundry/capi-workspace
  cloudfoundry/cf-deployment
  cloudfoundry/cf-deployment-concourse-tasks
  cloudfoundry/claw
  cloudfoundry/cli-i18n
  cloudfoundry/cli-pools
  cloudfoundry/cli-private
  cloudfoundry/cli-workstation
  cloudfoundry/cloud_controller_ng
  cloudfoundry/homebrew-tap
  concourse/concourse-bosh-deployment
  pivotal-legacy/pivotal_ide_prefs
)

repo_prefix=git@github.com:

for repo in "${WORKSPACE_GIT_REPOS[@]}"; do
  clone_into_workspace "$repo_prefix""$repo"
done
