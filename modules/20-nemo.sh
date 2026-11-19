# Replace Files (Nautilus) with Nemo, which also draws the desktop icons
# shellcheck shell=bash

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

# Turn off auto-arrange for desktop icons. On the first run nemo-desktop has
# never started, so its metadata file doesn't exist yet: start it and wait for
# the file to appear.
METADATA="${HOME}/.config/nemo/desktop-metadata"
pgrep -x nemo-desktop > /dev/null || (nohup nemo-desktop > /dev/null 2>&1 &)
for _ in $(seq 1 20); do
    [ -f "${METADATA}" ] && break
    sleep 0.5
done
nemo-desktop --quit 2> /dev/null || true
sleep 1
if [ -f "${METADATA}" ]; then
    sed -i 's/view-auto-layout=true/view-auto-layout=false/g' "${METADATA}"
else
    echo "NOTE: ${METADATA} was not created. Turn off auto-arrange by hand in Nemo."
fi
