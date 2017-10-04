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
    git checkout master
    git pull
  popd
popd

mkdir -p ~/deployments/vbox

cd ~/deployments/vbox

cat << EOF > ~/workspace/bosh-deployment/bosh-lite-more-power.yml
- type: replace
  path: /resource_pools/name=vms/cloud_properties/cpus
  value: 8

- type: replace
  path: /resource_pools/name=vms/cloud_properties/memory
  value: 8192
EOF

bosh create-env ~/workspace/bosh-deployment/bosh.yml \
  --state ./state.json \
  -o ~/workspace/bosh-deployment/virtualbox/cpi.yml \
  -o ~/workspace/bosh-deployment/virtualbox/outbound-network.yml \
  -o ~/workspace/bosh-deployment/bosh-lite.yml \
  -o ~/workspace/bosh-deployment/bosh-lite-runc.yml \
  -o ~/workspace/bosh-deployment/jumpbox-user.yml \
  -o ~/workspace/bosh-deployment/bosh-lite-more-power.yml \
  --vars-store ./creds.yml \
  -v director_name="Bosh Lite Director" \
  -v internal_ip=$BOSH_ENVIRONMENT \
  -v internal_gw=192.168.50.1 \
  -v internal_cidr=192.168.50.0/24 \
  -v outbound_network_name=NatNetwork

bosh \
  --ca-cert <(bosh int ~/deployments/vbox/creds.yml --path /director_ssl/ca) \
  alias-env vbox

export BOSH_CLIENT_SECRET=`bosh int ~/deployments/vbox/creds.yml --path /admin_password`

# if cf-deployment is not using the latest
# bosh upload-stemcell https://bosh.io/d/stemcells/bosh-warden-boshlite-ubuntu-trusty-go_agent?v=3421.9
bosh upload-stemcell https://bosh.io/d/stemcells/bosh-warden-boshlite-ubuntu-trusty-go_agent

cd ~/workspace/cf-deployment/iaas-support/bosh-lite

cat << EOF > bosh-lite-internet-required.yml
- type: replace
  path: /vm_extensions/-
  value:
    name:
      internet-required
EOF

bosh \
  -n \
  update-cloud-config cloud-config.yml \
  -o bosh-lite-internet-required.yml

cd ~/workspace/cf-deployment

cat << EOF > operations/cli-bosh-lite.yml
- type: replace
  path: /instance_groups/name=api/jobs/name=cloud_controller_ng/properties/cc/default_app_memory?
  value: 32
- type: replace
  path: /instance_groups/name=api/jobs/name=cloud_controller_ng/properties/dea_next?
  value:
    staging_memory_limit_mb: 128
    staging_disk_limit_mb: 1024

- type: replace
  path: /instance_groups/name=api/jobs/name=cloud_controller_ng/properties/cc/diego?/temporary_local_tps
  value: true
EOF

bosh \
  -n \
  -d cf deploy cf-deployment.yml \
  -o operations/use-compiled-releases.yml \
  -o operations/bosh-lite.yml \
  -o operations/use-latest-stemcell.yml \
  -o operations/test/add-persistent-isolation-segment-diego-cell.yml \
  -o operations/cli-bosh-lite.yml \
  --vars-store deployment-vars.yml \
  -v system_domain=bosh-lite.com \
  -v cf_admin_password=admin

sudo route add -net 10.244.0.0/16 gw 192.168.50.6

cf api api.bosh-lite.com --skip-ssl-validation
cf auth admin admin
cf enable-feature-flag diego_docker
