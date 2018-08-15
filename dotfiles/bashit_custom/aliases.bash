# alias vim=nvim

alias grp="ginkgo -r -nodes=4"
alias fl="fly -t ci login -c https://wings.pivotal.io -n cf-cli -b"
alias cfbl="cf login -a api.bosh-lite.com --skip-ssl-validation -u admin -p admin"

if [[ ! -z $(which bosh-cli) ]]; then
  alias bosh=bosh-cli
fi
