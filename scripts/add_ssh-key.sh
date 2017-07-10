#!/bin/bash

set -e

KEY_EXPIRES_AT=$(date --date=18:00 +%s)
NOW=$(date +%s)
KEY_LIFETIME=$(($KEY_EXPIRES_AT - $NOW))
if [ "$KEY_LIFETIME" -lt "1" ]; then
  KEY_LIFETIME=1h
fi

lpass show github --field='Private Key' | ssh-add -t $KEY_LIFETIME -
