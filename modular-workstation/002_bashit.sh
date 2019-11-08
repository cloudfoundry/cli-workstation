#!/bin/bash

# These are pulled directly from our current (2019/02/28) ~/.bashrc
# This is because ~/.bashrc's are difficult to source from a script
# https://askubuntu.com/a/77053
# Also, it is currently unknown why sourcing bash_it.sh requires set +e.
export BASH_IT="$HOME/.bash_it"
export BASH_IT_THEME="$HOME/workspace/cli-workstation/dotfiles/bashit_custom_themes/cli.theme.bash"

set +e
source "$BASH_IT"/bash_it.sh
bash-it update
set -e

# Configure BashIT
bash-it disable alias general git
bash-it enable completion defaults awscli bash-it brew git ssh tmux virtualbox
bash-it enable plugin fasd fzf git git-subrepo ssh history

