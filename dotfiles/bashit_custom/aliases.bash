# alias vim=nvim

alias grp="ginkgo -r -nodes=4"
alias fl="fly -t ci login -c https://p-concourse.wings.cf-app.com -n system-team-cli-cf-cli-619e"
alias cfbl="cf login -a api.bosh-lite.com --skip-ssl-validation -u admin -p admin"

if [[ ! -z $(which bosh-cli) ]]; then
  alias bosh2=bosh-cli
fi
