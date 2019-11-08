# add bin from homedir to path
export PATH=$HOME/bin:$PATH

# Ruby
export GEM_HOME=$HOME/.gem
export PATH=$GEM_HOME/bin:$PATH

# Go
export GOROOT=/snap/go/current
export GOPATH=~/go
export PATH=$GOPATH/bin:$GOROOT/bin:$PATH

# most recently build cf should be in path
export PATH=$GOPATH/src/code.cloudfoundry.org/cli/out:$PATH

export PATH=$PATH:$HOME/workspace/capi-workspace/scripts
