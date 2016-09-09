# Go
export GOPATH=~/go
export PATH=$GOPATH/bin:$PATH

# most recently build cf should be in path
export WORKSPACE=$GOPATH/src/code.cloudfoundry.org/cli
export PATH=$WORKSPACE/out:$PATH

# add bin from homedir to path
export PATH=$HOME/bin:$PATH
