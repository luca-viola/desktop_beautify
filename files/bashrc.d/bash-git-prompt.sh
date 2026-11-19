#!/bin/bash
if [ -f "$HOME/.bash-git-prompt/gitprompt.sh" ]; then
    GIT_PROMPT_ONLY_IN_REPO=0
    source "$HOME/.bash-git-prompt/gitprompt.sh"
fi
