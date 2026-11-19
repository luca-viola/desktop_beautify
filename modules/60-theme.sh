# WhiteSur GTK/shell theme and icon theme, dark (cloned into ~/packages)
# shellcheck shell=bash

# Install the build deps ourselves so the installers don't stop to prompt
sudo dnf -y install git sassc glib2-devel libxml2

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
# The shell theme needs the user-theme extension (extensions module)
gsettings set org.gnome.shell.extensions.user-theme name 'WhiteSur-Dark-solid'
