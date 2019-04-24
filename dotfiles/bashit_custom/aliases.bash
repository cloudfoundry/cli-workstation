# alias vim=nvim

alias grp="ginkgo -r -nodes=4"
alias fl="fly -t ci login -c https://ci.cli.fun -n main -b"
alias cfbl="cf login -a api.bosh-lite.com --skip-ssl-validation -u admin -p admin"
alias s="git status"
alias gst="git status"
alias gap='git add -p'

if [[ ! -z $(which bosh-cli) ]]; then
  alias bosh=bosh-cli
fi


if [[ ! -z $(which lpass) ]]; then
  alias load-key='lpass show "load-key" --notes | bash'
fi
