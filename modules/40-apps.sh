# Applications: Chrome, vim, VLC, GIMP, Sublime Text, ZapZap, Tweaks, Extensions, Extension Manager, dconf Editor
# shellcheck shell=bash

# dnf5 aborts the whole transaction if any package is missing, so keep the
# apps from third-party repos (set up in the system module) separate
sudo dnf -y install google-chrome-stable \
    || warn "Chrome install failed (check /etc/yum.repos.d/google-chrome.repo)"
sudo dnf -y install sublime-text \
    || warn "Sublime Text install failed (check /etc/yum.repos.d/sublime-text.repo)"

sudo dnf -y install \
    vim \
    gnome-tweaks \
    gnome-extensions-app \
    dconf-editor \
    vlc \
    gimp

# Only on Flathub: Extension Manager (by Matthew Jakeman) and ZapZap
# (WhatsApp). Fedora's Flathub remote can be disabled or filtered on a fresh
# install, so make sure it's added, enabled and unfiltered first.
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
sudo flatpak remote-modify --enable --no-filter flathub
sudo flatpak install -y --noninteractive flathub \
    com.mattjakeman.ExtensionManager \
    com.rtosta.zapzap
