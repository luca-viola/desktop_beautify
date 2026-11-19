#!/bin/bash
# Desktop beautify for Fedora 45 (GNOME 51, Wayland-only, dnf5)
# Run as your normal user from inside a GNOME session (it calls sudo when needed).
set -uo pipefail

if [ "$(id -u)" -eq 0 ]; then
    echo "Run this as your normal user, not root (sudo is used where needed)." >&2
    exit 1
fi

APPS_DIR="${HOME}/.local/share/applications"
mkdir -p "${APPS_DIR}" "${HOME}/.config/autostart" "${HOME}/scripts"

# Append an app to the dock if it's not there yet
pin_app() {
    local current
    current=$(gsettings get org.gnome.shell favorite-apps)
    [[ "${current}" == *"'$1'"* ]] && return
    if [ "${current}" = "@as []" ] || [ "${current}" = "[]" ]; then
        gsettings set org.gnome.shell favorite-apps "['$1']"
    else
        gsettings set org.gnome.shell favorite-apps "${current%]}, '$1']"
    fi
}

# Remove an app from the dock
unpin_app() {
    local current
    current=$(gsettings get org.gnome.shell favorite-apps \
        | sed -e "s/'$1', //" -e "s/, '$1'//" -e "s/'$1'//")
    gsettings set org.gnome.shell favorite-apps "${current}"
}

# Add extensions to enabled-extensions. Unlike `gnome-extensions enable`, this
# works for extensions installed in this same run (on Wayland the Shell can't
# be restarted to pick them up); they load at next login.
enable_extensions() {
    local current uuid
    current=$(gsettings get org.gnome.shell enabled-extensions)
    for uuid in "$@"; do
        [[ "${current}" == *"'${uuid}'"* ]] && continue
        if [ "${current}" = "@as []" ] || [ "${current}" = "[]" ]; then
            current="['${uuid}']"
        else
            current="${current%]}, '${uuid}']"
        fi
    done
    gsettings set org.gnome.shell enabled-extensions "${current}"
    gsettings set org.gnome.shell disable-user-extensions false
}

## Update system
sudo dnf -y upgrade --refresh

## Repositories: RPM Fusion + third-party (Google Chrome)
sudo dnf -y install fedora-workstation-repositories \
    "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
    "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"
# dnf5 syntax (the old --set-enabled flag no longer exists).
# config-manager comes from dnf5-plugins, which may not be installed.
sudo dnf -y install dnf5-plugins
sudo dnf config-manager setopt google-chrome.enabled=1

# Full ffmpeg from RPM Fusion replaces Fedora's ffmpeg-free
sudo dnf -y swap ffmpeg-free ffmpeg --allowerasing

## Replace Files (Nautilus) with Nemo
sudo dnf -y install nemo nemo-fileroller nemo-terminal nemo-preview nemo-image-converter

# Make nemo visible in GNOME. Override the .desktop files in ~/.local instead
# of editing /usr/share, so package updates don't undo it.
for f in nemo.desktop nemo-autostart.desktop nemo-autorun-software.desktop; do
    [ -f "/usr/share/applications/${f}" ] || continue
    sed -e 's/^[^#]*OnlyShowIn=/#&/' -e 's/^[^#]*NoDisplay=true/#&/' \
        "/usr/share/applications/${f}" > "${APPS_DIR}/${f}"
done

# Start nemo-desktop at login (it draws the desktop icons)
cp "${APPS_DIR}/nemo-autostart.desktop" "${HOME}/.config/autostart/"

# Default file manager / archive manager
xdg-mime default nemo.desktop inode/directory application/x-gnome-saved-search
xdg-mime default org.gnome.FileRoller.desktop application/gzip application/x-7z-compressed application/x-7z-compressed-tar application/x-bzip application/x-bzip-compressed-tar application/x-compress application/x-compressed-tar application/x-cpio application/x-gzip application/x-lha application/x-lzip application/x-lzip-compressed-tar application/x-lzma application/x-lzma-compressed-tar application/x-tar application/x-tarz application/x-xar application/x-xz application/x-xz-compressed-tar application/zip application/zstd application/x-zstd-compressed-tar

# "Show in folder" (e.g. Chrome downloads) goes over D-Bus to
# org.freedesktop.FileManager1. Nautilus and Nemo both provide it and Nautilus
# wins, so point it at Nemo with a per-user D-Bus service file.
mkdir -p "${HOME}/.local/share/dbus-1/services"
cat > "${HOME}/.local/share/dbus-1/services/org.freedesktop.FileManager1.service" << 'EOF'
[D-BUS Service]
Name=org.freedesktop.FileManager1
Exec=/usr/bin/nemo --no-default-window
EOF

# Nemo preferences
gsettings set org.nemo.extensions.nemo-terminal default-visible false
gsettings set org.nemo.icon-view default-zoom-level 'standard'
gsettings set org.nemo.preferences show-home-icon-toolbar true
gsettings set org.nemo.preferences show-new-folder-icon-toolbar true
gsettings set org.nemo.preferences show-show-thumbnails-toolbar true
gsettings set org.nemo.desktop show-desktop-icons true
gsettings set org.nemo.desktop volumes-visible true
gsettings set org.nemo.desktop network-icon-visible true

# Window controls on the left, with minimize and maximize
gsettings set org.gnome.desktop.wm.preferences button-layout 'close,minimize,maximize:'

## Applications
# dnf5 aborts the whole transaction if any package is missing, so keep
# Chrome (third-party repo) separate from the Fedora packages
# Google only ships Chrome for x86_64
if [ "$(uname -m)" = "x86_64" ]; then
    sudo dnf -y install google-chrome-stable \
        || echo "WARNING: Chrome install failed (is the google-chrome repo enabled?)"
else
    echo "NOTE: no Chrome build for $(uname -m), skipping it."
fi
sudo dnf -y install \
    vim \
    gnome-tweaks \
    gnome-extensions-app \
    dconf-editor \
    vlc \
    gimp

## GNOME extensions
# sound-output-device-chooser: obsolete, the output chooser is built into Quick Settings
# openweather: no longer packaged; install from extensions.gnome.org if wanted
# system-monitor-applet: now packaged as system-monitor-next
sudo dnf -y install \
    gnome-shell-extension-dash-to-dock \
    gnome-shell-extension-appindicator \
    gnome-shell-extension-system-monitor-applet \
    gnome-shell-extension-drive-menu \
    gnome-shell-extension-apps-menu \
    gnome-shell-extension-places-menu \
    gnome-shell-extension-launch-new-instance \
    gnome-shell-extension-user-theme

enable_extensions \
    dash-to-dock@micxgx.gmail.com \
    apps-menu@gnome-shell-extensions.gcampax.github.com \
    launch-new-instance@gnome-shell-extensions.gcampax.github.com \
    places-menu@gnome-shell-extensions.gcampax.github.com \
    appindicatorsupport@rgcjonas.gmail.com \
    drive-menu@gnome-shell-extensions.gcampax.github.com \
    user-theme@gnome-shell-extensions.gcampax.github.com \
    system-monitor-next@paradoxxx.zero.gmail.com

# Extension preferences. The schemas ship with the extensions, so gsettings sees them right away.
SM=org.gnome.shell.extensions.system-monitor-next-applet
gsettings set ${SM} cpu-graph-width 10
gsettings set ${SM} freq-display true
gsettings set ${SM} freq-graph-width 10
gsettings set ${SM} memory-graph-width 10
gsettings set ${SM} net-graph-width 10
gsettings set ${SM} icon-display false
gsettings set ${SM} freq-show-text true

gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 32
gsettings set org.gnome.shell.extensions.dash-to-dock custom-theme-shrink true

## Dock: pin / unpin applications
# Fedora 41+ uses Ptyxis instead of GNOME Terminal
for app in org.gnome.Settings.desktop nemo.desktop org.gnome.Ptyxis.desktop \
           org.gnome.Calculator.desktop google-chrome.desktop vlc.desktop gimp.desktop; do
    pin_app "${app}"
done
unpin_app org.mozilla.firefox.desktop
unpin_app firefox.desktop
unpin_app org.gnome.Nautilus.desktop

## Personal directories
mkdir -p "${HOME}/.bashrc.d" "${HOME}/work" "${HOME}/packages" \
         "${HOME}/Desktop/work" "${HOME}/Desktop/personal"

## WhiteSur GTK/shell theme + icon theme (cloned into ~/packages)
# Install the build deps ourselves so the installers don't stop to prompt
sudo dnf -y install git sassc glib2-devel libxml2

# Clone, or update an existing clone
clone_or_pull() {
    local url=$1 dir=$2
    if [ -d "${dir}/.git" ]; then
        git -C "${dir}" pull --ff-only
    else
        git clone --depth=1 "${url}" "${dir}"
    fi
}

WHITESUR_GTK="${HOME}/packages/WhiteSur-gtk-theme"
WHITESUR_ICONS="${HOME}/packages/WhiteSur-icon-theme"
clone_or_pull https://github.com/vinceliuice/WhiteSur-gtk-theme.git "${WHITESUR_GTK}"
clone_or_pull https://github.com/vinceliuice/WhiteSur-icon-theme.git "${WHITESUR_ICONS}"

# GTK2/3 + GNOME Shell theme into ~/.themes, dark variants only.
# -l also themes libadwaita (GTK4) apps by writing ~/.config/gtk-4.0.
(cd "${WHITESUR_GTK}" && ./install.sh -c dark -l)
# Icons into ~/.local/share/icons
(cd "${WHITESUR_ICONS}" && ./install.sh)

gsettings set org.gnome.desktop.interface color-scheme prefer-dark
gsettings set org.gnome.desktop.interface gtk-theme 'WhiteSur-Dark-solid'
gsettings set org.gnome.desktop.interface icon-theme 'WhiteSur-dark'
# The shell theme needs the user-theme extension enabled above
gsettings set org.gnome.shell.extensions.user-theme name 'WhiteSur-Dark-solid'

## "Show Desktop"
# GNOME is Wayland-only now: wmctrl can only see XWayland windows, so the
# dock launcher is best effort. Super+D is the reliable native way.
gsettings set org.gnome.desktop.wm.keybindings show-desktop "['<Super>d']"

sudo dnf -y install wmctrl
cat > "${HOME}/scripts/show-desktop" << 'EOF'
#!/bin/bash
# Best effort on Wayland: affects only XWayland windows. Prefer Super+D.
if wmctrl -m | grep -q "showing the desktop.*ON"; then
    wmctrl -k off
else
    wmctrl -k on
fi
EOF
chmod 755 "${HOME}/scripts/show-desktop"

cat > "${APPS_DIR}/show-desktop.desktop" << EOF
[Desktop Entry]
Type=Application
Name=Show Desktop
Icon=user-desktop
Exec=${HOME}/scripts/show-desktop
EOF

current=$(gsettings get org.gnome.shell favorite-apps)
if [[ "${current}" != *"'show-desktop.desktop'"* ]]; then
    gsettings set org.gnome.shell favorite-apps "$(echo "${current}" | sed "s/^\[/['show-desktop.desktop', /")"
fi

## Turn off Nemo's auto-arrange for desktop icons
# On the first run nemo-desktop has never started, so its metadata file
# doesn't exist yet. Start it and wait for the file to appear.
METADATA="${HOME}/.config/nemo/desktop-metadata"
pgrep -x nemo-desktop > /dev/null || (nohup nemo-desktop > /dev/null 2>&1 &)
for _ in $(seq 1 20); do
    [ -f "${METADATA}" ] && break
    sleep 0.5
done
nemo-desktop --quit 2> /dev/null
sleep 1
if [ -f "${METADATA}" ]; then
    sed -i 's/view-auto-layout=true/view-auto-layout=false/g' "${METADATA}"
else
    echo "NOTE: ${METADATA} was not created. Turn off auto-arrange by hand in Nemo."
fi

echo
echo "Done. Log out and back in so the extensions, Nemo desktop and theme load."
gnome-session-quit --logout
