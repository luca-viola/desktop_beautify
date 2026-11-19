# Shell: eza/bat aliases, fixterm, bash-git-prompt, personal directories
# shellcheck shell=bash

mkdir -p "${HOME}/work" "${HOME}/Desktop/work" "${HOME}/Desktop/personal"

sudo dnf -y install git eza bat

# Snippets go in ~/.bashrc.d, which Fedora's default ~/.bashrc sources
for f in fixterm eza bash-git-prompt.sh; do
    install -m 644 "${ROOT}/files/bashrc.d/${f}" "${HOME}/.bashrc.d/${f}"
done

clone_or_pull https://github.com/magicmonty/bash-git-prompt.git "${HOME}/.bash-git-prompt"

# Custom theme: the Default theme, with 😍 instead of the green ✔ after a
# successful command and 🤌 instead of the red ✘ after a failed one (the exit
# code is still shown). bash-git-prompt picks up ~/.git-prompt-colors.sh by itself.
install -m 644 "${ROOT}/files/git-prompt-colors.sh" "${HOME}/.git-prompt-colors.sh"
