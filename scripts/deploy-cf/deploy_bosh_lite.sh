#!/bin/bash

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
    git pull
  popd
popd

mkdir -p ~/deployments/vbox

cd ~/deployments/vbox

bosh2 create-env ~/workspace/bosh-deployment/bosh.yml \
  --state ./state.json \
  -o ~/workspace/bosh-deployment/virtualbox/cpi.yml \
  -o ~/workspace/bosh-deployment/virtualbox/outbound-network.yml \
  -o ~/workspace/bosh-deployment/bosh-lite.yml \
  -o ~/workspace/bosh-deployment/bosh-lite-runc.yml \
  -o ~/workspace/bosh-deployment/jumpbox-user.yml \
  --vars-store ./creds.yml \
  -v director_name="Bosh Lite Director" \
  -v internal_ip=$BOSH_ENVIRONMENT \
  -v internal_gw=192.168.50.1 \
  -v internal_cidr=192.168.50.0/24 \
  -v outbound_network_name=NatNetwork

bosh2 \
  --ca-cert <(bosh2 int ~/deployments/vbox/creds.yml --path /director_ssl/ca) \
  alias-env vbox

export BOSH_CLIENT_SECRET=`bosh2 int ~/deployments/vbox/creds.yml --path /admin_password`

# if cf-deployment is not using the latest
bosh2 upload-stemcell https://bosh.io/d/stemcells/bosh-warden-boshlite-ubuntu-trusty-go_agent?v=3363.9
# bosh2 upload-stemcell https://bosh.io/d/stemcells/bosh-warden-boshlite-ubuntu-trusty-go_agent

cd ~/workspace/cf-deployment/

cat << EOF > operations/bosh-lite-internet-required.yml
- type: replace
  path: /vm_extensions/-
  value:
    name:
      internet-required
EOF

bosh2 \
  -n \
  update-cloud-config bosh-lite/cloud-config.yml \
  -o operations/bosh-lite-internet-required.yml

cat << EOF > operations/tcp-routing-bosh-lite.yml
- type: replace
  path: /instance_groups/name=api/jobs/name=routing-api/properties/routing_api/sqldb/host
  value: 10.244.0.10
EOF

cat << EOF > operations/app-memory-override.yml
- type: replace
  path: /instance_groups/name=api/jobs/name=cloud_controller_ng/properties/cc/default_app_memory?
  value: 256
EOF

bosh2 \
  -n \
  -d cf deploy cf-deployment.yml \
  -o operations/bosh-lite.yml \
  -o operations/tcp-routing-gcp.yml \
  -o operations/tcp-routing-bosh-lite.yml \
  -o operations/app-memory-override.yml \
  --vars-store deployment-vars.yml \
  -v system_domain=bosh-lite.com \
  -v uaa_scim_users_admin_password=admin

sudo route add -net 10.244.0.0/16 gw 192.168.50.6
