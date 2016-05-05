bosh_ssh() {
  TARGET=$(bosh target | sed -e 's/Current target is https:\/\/\(.*\):25555.*/\1/')

  if [ -z $TARGET ]; then
    echo "Must first target a BOSH"
    echo "suggestion: bosh target <bosh url>"
    return 1
  else
    echo "BOSH SSH with target: $TARGET"
  fi

  if lpass show $TARGET --field "Private Key" > /dev/null; then
    :
  else
    return 1
  fi

  lpass show $TARGET --field "Private Key" | ssh-add -t 2h -

  bosh ssh \
    --gateway_host $TARGET \
    --gateway_user vcap \
    --strict_host_key_checking false
}
