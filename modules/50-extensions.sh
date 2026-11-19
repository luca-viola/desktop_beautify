# GNOME Shell extensions (Snappo and Face Guard have their own modules)
# shellcheck shell=bash

# From Fedora where packaged (system-monitor-applet is system-monitor-next)
sudo dnf -y install \
    gnome-shell-extension-dash-to-dock \
    gnome-shell-extension-launch-new-instance \
    gnome-shell-extension-appindicator \
    gnome-shell-extension-apps-menu \
    gnome-shell-extension-background-logo \
    gnome-shell-extension-blur-my-shell \
    gnome-shell-extension-drive-menu \
    gnome-shell-extension-places-menu \
    gnome-shell-extension-system-monitor-applet \
    gnome-shell-extension-user-theme

# Not packaged in Fedora: from extensions.gnome.org.
# Tweaks & Extensions in System Menu needs gnome-tweaks and
# gnome-extensions-app (apps module).
EGO_EXTENSIONS=(
    Bluetooth-Battery-Meter@maniacx.github.com
    burn-my-windows@schneegans.github.com
    desktop-cube@schneegans.github.com
    dhruva@narkagni
    tweaks-system-menu@extensions.gnome-shell.fifi.org
    undecorate@sun.wxg@gmail.com
    weatheroclock@CleoMenezesJr.github.io
)
for uuid in "${EGO_EXTENSIONS[@]}"; do
    install_ego_extension "${uuid}"
done

# Turn them on. blur-my-shell and dhruva are installed but left off.
enable_extensions \
    dash-to-dock@micxgx.gmail.com \
    launch-new-instance@gnome-shell-extensions.gcampax.github.com \
    appindicatorsupport@rgcjonas.gmail.com \
    apps-menu@gnome-shell-extensions.gcampax.github.com \
    background-logo@fedorahosted.org \
    drive-menu@gnome-shell-extensions.gcampax.github.com \
    places-menu@gnome-shell-extensions.gcampax.github.com \
    system-monitor-next@paradoxxx.zero.gmail.com \
    user-theme@gnome-shell-extensions.gcampax.github.com \
    Bluetooth-Battery-Meter@maniacx.github.com \
    burn-my-windows@schneegans.github.com \
    desktop-cube@schneegans.github.com \
    tweaks-system-menu@extensions.gnome-shell.fifi.org \
    undecorate@sun.wxg@gmail.com \
    weatheroclock@CleoMenezesJr.github.io

# Extension preferences. The schemas ship with the extensions, so gsettings
# sees them right away.
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
