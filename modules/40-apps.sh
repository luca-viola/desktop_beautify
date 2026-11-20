# Applications: Chrome, vim, VLC, GIMP, Sublime Text, Spotify (web app), ZapZap, Tweaks, Extensions, Extension Manager, dconf Editor
# shellcheck shell=bash

# dnf5 aborts the whole transaction if any package is missing, so keep the
# apps from third-party repos (set up in the system module) separate
sudo dnf -y install google-chrome-stable \
    || warn "Chrome install failed (check /etc/yum.repos.d/google-chrome.repo)"
sudo dnf -y install sublime-text \
    || warn "Sublime Text install failed (check /etc/yum.repos.d/sublime-text.repo)"

# Spotify: the desktop client is x86_64-only, but the web player works in
# Chrome on both arches (Chrome ships Widevine, which it needs). Add a
# launcher that opens it as a standalone app, unless a Spotify web app made
# by Chrome (e.g. restored by Chrome sync) is already there.
if ! grep -qs '^Name=Spotify$' "${APPS_DIR}"/chrome-*.desktop; then
    cat > "${APPS_DIR}/spotify-web.desktop" << 'EOF'
[Desktop Entry]
Type=Application
Name=Spotify
Comment=Spotify web player in its own window
Icon=spotify-client
Exec=google-chrome --app=https://open.spotify.com/
StartupWMClass=chrome-open.spotify.com__-Default
Categories=Audio;Music;Player;AudioVideo;
EOF
fi

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
