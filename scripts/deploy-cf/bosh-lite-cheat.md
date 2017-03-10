# New bosh-lite cheat sheet

## log in to bosh

```sh
export BOSH_ENVIRONMENT=vbox
export BOSH_CLIENT=admin
export BOSH_CLIENT_SECRET=$(bosh2 int ~/deployments/vbox/creds.yml --path /admin_password)
```

## ssh to bosh

```sh
bosh2 int ~/deployments/vbox/creds.yml --path /jumpbox_ssh/private_key > private_key

chmod 0600 private_key

ssh -i private_key jumpbox@192.168.50.6
```
