#!/bin/bash

su - pivotal -c "bash -l -c \"vagrant global-status | grep virtualbox | cut -d' ' -f1 | xargs -n1 vagrant suspend\""
