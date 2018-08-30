#!/bin/bash

if [[ $1 == "clean" ]]; then
  echo "removing old bosh lite"
  rm -rf $HOME/deployments/vbox
  vboxmanage list vms | awk '{print $1}' | tr -d '"'| grep -e ^sc- -e ^vm- | xargs -r -n 1 vboxmanage unregistervm --delete
fi # deletion can be a bit flaky, error handle after

set -e

export BOSH_CLIENT=admin
export BOSH_ENVIRONMENT=192.168.50.6

pushd ~/workspace
  if [ ! -d bosh-deployment ]; then
    git clone https://github.com/cloudfoundry/bosh-deployment.git
  fi
  pushd bosh-deployment
    git pull
  popd

  if [ ! -d cf-deployment ]; then
    git clone https://github.com/cloudfoundry/cf-deployment.git
  fi
  pushd cf-deployment
    git checkout master
    git pull
  popd
popd

CLI_OPS_DIR=~/workspace/cli-workstation/scripts/deploy-cf/operations
CLI_VARS_DIR=~/workspace/cli-lite-vars
BOSH_DEPLOYMENT=~/workspace/bosh-deployment
CF_DEPLOYMENT=~/workspace/cf-deployment
BOSH_RUNTIME_DIR=~/deployments/vbox

mkdir -p $CLI_VARS_DIR
mkdir -p $BOSH_RUNTIME_DIR

cd $BOSH_RUNTIME_DIR

bosh -n create-env --recreate $BOSH_DEPLOYMENT/bosh.yml \
  --state ./state.json \
  -o $BOSH_DEPLOYMENT/virtualbox/cpi.yml \
  -o $BOSH_DEPLOYMENT/virtualbox/outbound-network.yml \
  -o $BOSH_DEPLOYMENT/bosh-lite.yml \
  -o $BOSH_DEPLOYMENT/bosh-lite-runc.yml \
  -o $BOSH_DEPLOYMENT/jumpbox-user.yml \
  -o $CLI_OPS_DIR/bosh-lite-more-power.yml \
  --vars-store $CLI_VARS_DIR/creds.yml \
  -v director_name="Bosh Lite Director" \
  -v internal_ip=$BOSH_ENVIRONMENT \
  -v internal_gw=192.168.50.1 \
  -v internal_cidr=192.168.50.0/24 \
  -v outbound_network_name=NatNetwork

bosh \
  --ca-cert <(bosh int $CLI_VARS_DIR/creds.yml --path /director_ssl/ca) \
  alias-env vbox

export BOSH_CLIENT_SECRET=`bosh int $CLI_VARS_DIR/creds.yml --path /admin_password`

bosh -e vbox -n update-runtime-config $BOSH_DEPLOYMENT/runtime-configs/dns.yml --vars-store=$CLI_VARS_DIR/runtime-config-vars.yml --name=dns

CFD_STEMCELL_VERSION="$(bosh int $CF_DEPLOYMENT/cf-deployment.yml --path /stemcells/alias=default/version)"
bosh upload-stemcell https://bosh.io/d/stemcells/bosh-warden-boshlite-ubuntu-trusty-go_agent?v=$CFD_STEMCELL_VERSION

cd $CF_DEPLOYMENT/iaas-support/bosh-lite

bosh \
  -n \
  update-cloud-config cloud-config.yml \
  -o $CLI_OPS_DIR/cloud-config-internet-required.yml

cd $CF_DEPLOYMENT

bosh \
  -n \
  -d cf deploy cf-deployment.yml \
  -o operations/use-compiled-releases.yml \
  -o operations/bosh-lite.yml \
  -o operations/test/add-persistent-isolation-segment-diego-cell.yml \
  -o operations/experimental/fast-deploy-with-downtime-and-danger.yml \
  -o $CLI_OPS_DIR/cli-bosh-lite.yml \
  -o $CLI_OPS_DIR/cli-bosh-lite-uaa-client-credentials.yml \
  -o $CLI_OPS_DIR/disable-rep-kernel-params.yml \
  -o $CLI_OPS_DIR/add-oidc-provider.yml \
  --vars-store $CLI_VARS_DIR/deployment-vars.yml \
  -v system_domain=bosh-lite.com \
  -v cf_admin_password=admin

BOSH_LITE_NETWORK=10.244.0.0
BOSH_LITE_NETMASK=255.255.0.0

# Set up virtualbox IP as the gateway to our CF
if ! route | egrep -q "$BOSH_LITE_NETWORK\\s+$BOSH_ENVIRONMENT\\s+$BOSH_LITE_NETMASK\\s"; then
  sudo route add -net $BOSH_LITE_NETWORK netmask $BOSH_LITE_NETMASK gw $BOSH_ENVIRONMENT
fi

cf api api.bosh-lite.com --skip-ssl-validation
cf auth admin admin
cf enable-feature-flag diego_docker
