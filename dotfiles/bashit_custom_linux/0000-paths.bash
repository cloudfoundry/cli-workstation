# add bin from homedir to path
export PATH=$HOME/bin:$PATH

# Ruby
export GEM_HOME=$HOME/.gem
export PATH=$GEM_HOME/bin:$PATH

# Go
export GOROOT=/usr/local/golang/go1.12.1
export GOPATH=~/go
export PATH=$GOPATH/bin:$GOROOT/bin:$PATH

# most recently build cf should be in path
export PATH=$GOPATH/src/code.cloudfoundry.org/cli/out:$PATH
