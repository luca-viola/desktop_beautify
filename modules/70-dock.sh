# Dock: pinned apps, and a Show Desktop launcher
# shellcheck shell=bash

# Fedora 41+ uses Ptyxis instead of GNOME Terminal. Flatpak apps (ZapZap) are
# named by their app ID.
for app in org.gnome.Settings.desktop nemo.desktop org.gnome.Ptyxis.desktop \
           org.gnome.Calculator.desktop google-chrome.desktop vlc.desktop gimp.desktop \
           com.rtosta.zapzap.desktop; do
    pin_app "${app}"
done
unpin_app org.mozilla.firefox.desktop
unpin_app firefox.desktop
unpin_app org.gnome.Nautilus.desktop

# Show Desktop launcher, first in the dock. GNOME is Wayland-only now: wmctrl
# can only see XWayland windows, so this is best effort. Super+D (set in the
# desktop-settings module) is the reliable native way.
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

pin_app_first show-desktop.desktop
