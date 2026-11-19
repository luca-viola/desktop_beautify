# GNOME settings: window buttons, Compose key, Show Desktop shortcut
# shellcheck shell=bash

# Window controls on the left, with minimize and maximize
gsettings set org.gnome.desktop.wm.preferences button-layout 'close,minimize,maximize:'

# Right Super key as Compose key. Keep the other xkb options, replace any
# existing compose: setting.
xkb=$(gsettings get org.gnome.desktop.input-sources xkb-options \
    | sed -e "s/'compose:[^']*'//g" -e 's/, *,/,/g' -e 's/\[ *, */[/' -e 's/, *\]/]/' -e 's/^@as //')
if [ "${xkb}" = "[]" ]; then
    xkb="['compose:rwin']"
else
    xkb="${xkb%]}, 'compose:rwin']"
fi
gsettings set org.gnome.desktop.input-sources xkb-options "${xkb}"

# Show Desktop on Super+D (the dock launcher in the dock module is best effort)
gsettings set org.gnome.desktop.wm.keybindings show-desktop "['<Super>d']"
