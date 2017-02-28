#!/bin/sh

set -e

export BOSH_CLIENT=admin
export BOSH_ENVIRONMENT=192.168.50.6

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

bosh2 --ca-cert <(bosh2 int ~/deployments/vbox/creds.yml --path /director_ssl/ca) alias-env vbox

export BOSH_CLIENT_SECRET=`bosh2 int ~/deployments/vbox/creds.yml --path /admin_password`

bosh2 upload-stemcell https://bosh.io/d/stemcells/bosh-warden-boshlite-ubuntu-trusty-go_agent

bosh2 update-cloud-config ~/workspace/cf-deployment/bosh-lite/cloud-config.yml

bosh2 -d cf deploy cf-deployment.yml -o operations/bosh-lite.yml --vars-store deployment-vars.yml -v system_domain=bosh-lite.com
