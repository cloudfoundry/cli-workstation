#!/bin/bash -eux

pushd /tmp
  mkdir -p bosh-lite-deployment

  # assumes a bosh-lite has already been spun up
  bosh target 192.168.50.4

  # upload stemcell
  bosh upload stemcell \
    https://bosh.io/d/stemcells/bosh-warden-boshlite-ubuntu-trusty-go_agent \
    --skip-if-exists

  # upload garden runc release
  bosh upload release \
    https://bosh.io/d/github.com/cloudfoundry/garden-runc-release \
    --skip-if-exists

  # upload cflinuxfs2
  bosh upload release \
    https://bosh.io/d/github.com/cloudfoundry/cflinuxfs2-rootfs-release \
    --skip-if-exists

  # create, upload & deploy cf-release
  pushd $HOME/workspace/cf-release
    git checkout master
    git pull -r
    CF_VERSION=$(git tag | cut -d v -f 2 | sort -g | tail -n 1)
    git checkout v$CF_VERSION
    scripts/update
    bosh upload release releases/cf/cf-$CF_VERSION.yml --skip-if-exists

    scripts/generate-bosh-lite-dev-manifest \
      ~/workspace/diego-release/manifest-generation/stubs-for-cf-release/enable_diego_windows_in_cc.yml
    bosh -n deploy
  popd

  # create, upload & deploy diego-release
  pushd $HOME/workspace/diego-release
    git checkout master
    git pull -r
    DIEGO_VERSION=$(git tag | cut -d v -f 2 | sort -g | tail -n 1)
    git checkout v$DIEGO_VERSION
    scripts/update
    bosh upload release releases/diego/diego-$DIEGO_VERSION.yml --skip-if-exists

    scripts/generate-bosh-lite-manifests
    bosh deployment bosh-lite/deployments/diego.yml
    bosh -n deploy
  popd

  # create, upload & deploy routing-release
  pushd $HOME/workspace/cf-routing-release
    git checkout master
    git pull -r
    routing_version=$(git tag | sort -k 2 -n -t . | tail -n 1)
    git checkout $routing_version
    scripts/update
    bosh -n upload release releases/routing-${routing_version}.yml --skip-if-exists
    scripts/generate-bosh-lite-manifest
		bosh -n deploy
  popd

	# redeploy cf to use diego and the routing release
	cat << EOF > property-overrides.yml
properties:
  cc:
    default_to_diego_backend: true
  routing_api:
    enabled: true
EOF

	pushd $HOME/cf-release
		scripts/generate-bosh-lite-dev-manifest $HOME/workspace/property-overrides.yml
		bosh -n deploy
  popd

  # adds the route for the bosh-lite
  $HOME/workspace/bosh-lite/bin/add-route
popd

bosh -n cleanup --all
