#!/usr/bin/env bash

committer=$(git show HEAD -s --pretty="tformat:%b" | grep Co-authored-by | cut -d: -f2)
if git branch -a --contains=HEAD | grep remotes; then
    # return immediately if the current commit has been pushed remotely
    exit 0
fi
if [ "x$committer" != "x" ]; then
    # extract the name and email of the committer from the signed-of line
    # e.g. "Co-authored-by: Ed King <eking@pivotal.io>"
    GIT_COMMITTER_EMAIL=$(echo $committer | cut -d\< -f2 | cut -d\> -f1)
    GIT_COMMITTER_NAME=$(echo $committer | cut -d\< -f1)
    # remove leading and trailing white spaces
    GIT_COMMITTER_NAME=${GIT_COMMITTER_NAME%% }
    GIT_COMMITTER_NAME=${GIT_COMMITTER_NAME## }
else
    # use the author information
    GIT_COMMITTER_NAME=$(git show HEAD -s --pretty="tformat:%an")
    GIT_COMMITTER_EMAIL=$(git show HEAD -s --pretty="tformat:%ae")
fi
export GIT_COMMITTER_NAME
export GIT_COMMITTER_EMAIL
git commit -n --amend -CHEAD
exit 0
