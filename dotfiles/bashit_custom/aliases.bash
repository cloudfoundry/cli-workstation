# alias vim=nvim

alias grp="ginkgo -r -nodes=4"
alias fl="fly -t ci login -c https://wings.concourse.ci -n cf-cli"
alias cfbl="cf login -a api.bosh-lite.com --skip-ssl-validation -u admin -p admin"

if [[ ! -z $(which bosh-cli) ]]; then
  alias bosh=bosh-cli
fi
