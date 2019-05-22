# alias vim=nvim

alias grp="ginkgo -r -nodes=4"
alias fl="fly -t ci login -c https://ci.cli.fun -n main -b"
alias cfbl="cf login -a api.bosh-lite.com --skip-ssl-validation -u admin -p admin"
alias s="git status"
alias gst="git status"
alias gap='git add -p'
alias gd='git diff'
alias gdc='git diff --cached'
alias ll='ls -al'

if [[ ! -z $(which bosh-cli) ]]; then
  alias bosh=bosh-cli
fi

if [[ ! -z $(which lpass) ]]; then
  alias load-key='lpass show "load-key" --notes | bash'
fi

### From bash-it general aliases ###
####################################
if ls --color -d . &> /dev/null
then
  alias ls="ls --color=auto"
elif ls -G -d . &> /dev/null
then
  alias ls='ls -G'        # Compact view, show colors
fi

# colored grep
# Need to check an existing file for a pattern that will be found to ensure
# that the check works when on an OS that supports the color option
if grep --color=auto "a" "${BASH_IT}/"*.md &> /dev/null
then
  alias grep='grep --color=auto'
  export GREP_COLOR='1;33'
fi

alias ..='cd ..'         # Go up one directory
alias ...='cd ../..'     # Go up two directories
alias ....='cd ../../..' # Go up three directories
alias -- -='cd -'        # Go back

alias b='bundle exec'
alias bake='echo "bundling..." && bundle install --quiet && echo "done bundling" && DB=postgres bundle exec rake'
alias slowbake='echo "bundling..." && bundle install --quiet && echo "done bundling" && DB=mysql bundle exec rake'

# Misc aliases
alias cfu="seed_users"

# Remove colors from output
alias nocolor='sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g"'
