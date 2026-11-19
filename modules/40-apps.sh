# Applications: Chrome, vim, VLC, GIMP, Tweaks, Extensions, dconf Editor
# shellcheck shell=bash

# dnf5 aborts the whole transaction if any package is missing, so keep
# Chrome (third-party repo, set up in the system module) separate
sudo dnf -y install google-chrome-stable \
    || warn "Chrome install failed (check /etc/yum.repos.d/google-chrome.repo)"

sudo dnf -y install \
    vim \
    gnome-tweaks \
    gnome-extensions-app \
    dconf-editor \
    vlc \
    gimp
