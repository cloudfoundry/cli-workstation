#!/bin/bash

# Installs and configures minikube to run on a Linux workstation
#
# Note that this configures an older Kubernetes version that was in use by
# https://kubernetes.io/docs/tutorials at the time of writing.

KUBE_VERSION=1.15.5
KUBECTL_VERSION=$KUBE_VERSION-00 # The debian packages have this weird decoration
MINIKUBE_VERSION=1.5.2

## Get kubectl
if [[ -z $(which kubectl) ]]; then
	curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
	echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
	sudo apt-get update
	sudo apt-get install -y kubectl=$KUBECTL_VERSION
fi

## Get minikube, which isn't in apt repositories for some reason
## TODO: Make a temp directory for this
if [[ -z $(which minikube) ]]; then
	curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube_$MINIKUBE_VERSION.deb \
	 && sudo dpkg -i minikube_$MINIKUBE_VERSION.deb

	rm minikube_$MINIKUBE_VERSION.deb
fi

## Set default server version to match kubectl version
minikube config set kubernetes-version $KUBE_VERSION

## Get that sweet sweet autocomplete
if grep kubectl "$USER/.bashrc"; then
	source <(kubectl completion bash) # setup autocomplete in bash into the current shell, bash-completion package should be installed first.
	echo "source <(kubectl completion bash)" >> ~/.bashrc # add autocomplete permanently to your bash shell.
	complete -F __start_kubectl k
fi


