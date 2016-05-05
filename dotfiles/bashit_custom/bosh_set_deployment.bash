bosh_set_deployment() {
  bosh download manifest $1 /tmp/$1.yml
  if [ $? != 0 ]; then
    return
  fi
  bosh deployment /tmp/$1.yml
}
