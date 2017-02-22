# add bin from homedir to path
export PATH=$HOME/bin:$PATH

# Go
export GOROOT=/opt/golang/go1.7.5
export GOPATH=~/go
export PATH=$GOPATH/bin:$PATH

# most recently build cf should be in path
export PATH=$GOPATH/src/code.cloudfoundry.org/cli/out:$PATH
