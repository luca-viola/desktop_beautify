#!/bin/bash

## Update system
sudo apt -y update 

# Install La Capitaine theme
mkdir -p ${HOME}/.icons
git clone https://github.com/keeferrourke/la-capitaine-icon-theme.git 
mv la-capitaine-icon-theme ${HOME}/.icons/


## Replace Files (Nautilus) with Nemo
# Install nemo & plugins

sudo apt install -y nemo*

# Makes nemo, nemo-autostart and nemo-autorun-software visible in Gnome
sudo sed -i 's/^[^#]*OnlyShowIn=X-Cinnamon;/#&/' /usr/share/applications/nemo-autostart.desktop
sudo sed -i 's/^[^#]*NoDisplay=true/#&/' /usr/share/applications/nemo-autostart.desktop

# Set Nemo as the file manager
mkdir ${HOME}/.config/autostart
cp /usr/share/applications/nemo-autostart.desktop ${HOME}/.config/autostart/
xdg-mime default nemo.desktop inode/directory application/x-gnome-saved-search
gsettings set org.nemo.desktop show-desktop-icons true
xdg-mime default org.gnome.FileRoller.desktop  application/gzip application/x-7z-compressed application/x-7z-compressed-tar application/x-bzip application/x-bzip-compressed-tar application/x-compress application/x-compressed-tar application/x-cpio application/x-gzip application/x-lha application/x-lzip application/x-lzip-compressed-tar application/x-lzma application/x-lzma-compressed-tar application/x-tar application/x-tarz application/x-xar application/x-xz application/x-xz-compressed-tar application/zip

# Set Nemo preferences
gsettings set org.nemo.extensions.nemo-terminal default-visible false
gsettings set org.nemo.icon-view default-zoom-level 'smaller'
gsettings set org.nemo.preferences show-home-icon-toolbar true
gsettings set org.nemo.preferences show-new-folder-icon-toolbar true
gsettings set org.nemo.preferences show-show-thumbnails-toolbar true 
gsettings set org.nemo.desktop show-desktop-icons true
gsettings set org.nemo.desktop volumes-visible true
gsettings set org.nemo.desktop volumes-visible true
gsettings set org.nemo.desktop network-icon-visible true


# Set icon theme
gsettings set org.gnome.desktop.interface icon-theme 'la-capitaine-icon-theme'

# Move window controls to the left, enable minimize and maximize
gsettings set org.gnome.desktop.wm.preferences button-layout 'close,minimize,maximize:'

# install google chrome
sudo apt-get install libxss1 libappindicator1 libindicator7
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install ./google-chrome*.deb

# Install applications
#	google-chrome-stable \
# gnome-shell-extension-dash-to-dock.noarch \
sudo apt -y install vim \
	gnome-tweaks \
	gnome-extensions-app \
	dconf-editor \
        vlc \
	ffmpeg \
	gimp

# Install gnome extensions

#sudo dnf -y install \
#gnome-shell-extension-dash-to-dock.noarch \
#gnome-shell-extension-sound-output-device-chooser.noarch \
#gnome-shell-extension-openweather.noarch \
#gnome-shell-extension-appindicator.noarch \
#gnome-shell-extension-system-monitor-applet.noarch \
#gnome-shell-extension-drive-menu.noarch

# Enable extensions
gnome-extensions enable dash-to-dock@micxgx.gmail.com
gnome-extensions enable apps-menu@gnome-shell-extensions.gcampax.github.com
gnome-extensions enable launch-new-instance@gnome-shell-extensions.gcampax.github.com
gnome-extensions enable places-menu@gnome-shell-extensions.gcampax.github.com
gnome-extensions enable appindicatorsupport@rgcjonas.gmail.com
gnome-extensions enable sound-output-device-chooser@kgshank.net
gnome-extensions enable openweather-extension@jenslody.de
gnome-extensions enable drive-menu@gnome-shell-extensions.gcampax.github.com
gnome-extensions enable system-monitor@paradoxxx.zero.gmail.com

# Set extensions preferences
gsettings set org.gnome.shell.extensions.system-monitor cpu-graph-width 10
gsettings set org.gnome.shell.extensions.system-monitor freq-display true
gsettings set org.gnome.shell.extensions.system-monitor freq-graph-width 10
gsettings set org.gnome.shell.extensions.system-monitor memory-graph-width 10
gsettings set org.gnome.shell.extensions.system-monitor net-graph-width 10
gsettings set org.gnome.shell.extensions.system-monitor icon-display false
gsettings set org.gnome.shell.extensions.system-monitor freq-show-text true

# Pin application to the dock
gsettings set org.gnome.shell favorite-apps "$(gsettings get org.gnome.shell favorite-apps | sed s/.$//), 'org.gnome.Settings.desktop']" 
gsettings set org.gnome.shell favorite-apps "$(gsettings get org.gnome.shell favorite-apps | sed s/.$//), 'nemo.desktop']" 
gsettings set org.gnome.shell favorite-apps "$(gsettings get org.gnome.shell favorite-apps | sed s/.$//), 'org.gnome.Terminal.desktop']" 
gsettings set org.gnome.shell favorite-apps "$(gsettings get org.gnome.shell favorite-apps | sed s/.$//), 'org.gnome.Calculator.desktop']" 
gsettings set org.gnome.shell favorite-apps "$(gsettings get org.gnome.shell favorite-apps | sed s/.$//), 'google-chrome.desktop']" 
gsettings set org.gnome.shell favorite-apps "$(gsettings get org.gnome.shell favorite-apps | sed s/.$//), 'vlc.desktop']" 
gsettings set org.gnome.shell favorite-apps "$(gsettings get org.gnome.shell favorite-apps | sed s/.$//), 'gimp.desktop']" 

# Unpin applications from the dock
favourites=$(gsettings get org.gnome.shell favorite-apps | sed "s/'firefox.desktop',\ //")
favourites=$(echo -n ${favourites} | sed "s/'org.gnome.Nautilus.desktop',\ //")
gsettings set org.gnome.shell favorite-apps "${favourites}" 

# Set dock's icons height and dock's appearance
gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 32
gsettings set org.gnome.shell.extensions.dash-to-dock custom-theme-shrink true

# Set dark theme
gsettings set org.gnome.desktop.interface gtk-theme Adwaita-dark
gsettings set org.gnome.desktop.interface color-scheme prefer-dark

# Set MacOS theme
# https://www.gnome-look.org/p/1241688 
# Download Mc-OS-CTLina-Gnome-Dark-1.3.2.tar.xz from tab "Files"

mkdir -p ${HOME}/.themes
cp Mc-OS* ${HOME}/.themes/
xz -d ${HOME}/.themes/Mc-OS*.tar.xz
tar xvf ${HOME}/.themes/Mc-OS*.tar -C ${HOME}/.themes/ > /dev/null
rm ${HOME}/.themes/Mc-OS*.tar
gsettings set org.gnome.desktop.interface gtk-theme 'Mc-OS-CTLina-Gnome-Dark-1.3.2'

# Personal setting
mkdir -p ${HOME}/.bashrc.d
mkdir -p ${HOME}/work
mkdir -p ${HOME}/packages
mkdir -p ${HOME}/scripts
mkdir -p ${HOME}/Desktop/work
mkdir -p ${HOME}/Desktop/personal

# Add "Show Desktop" to the doc in first position

cat > ${HOME}/scripts/show-desktop << EOF
#!/bin/bash
status="\$(wmctrl -m | grep "showing the desktop" | sed -r 's/(.*)(ON|OFF)/\2/g')"

if [ \$status == "ON" ]; then
    wmctrl -k off
else
    wmctrl -k on
fi
EOF

chmod 755 ${HOME}/scripts/show-desktop

cat > ${HOME}/.local/share/applications/show-desktop.desktop << EOF
[Desktop Entry]
Type=Application
Name=Show Desktop
Icon=desktop
Exec=${HOME}/scripts/show-desktop
EOF

pinned_apps=$(gsettings get org.gnome.shell favorite-apps | sed "s/\[/\['show-desktop.desktop', /")
gsettings set org.gnome.shell favorite-apps "${pinned_apps}"

## Disable Nemo Auto Arrange Icons feature
## change the setting in the metadata file
#nohup nemo-desktop > /dev/null & # Starts nemo to generate desktop metadata
#sed -i 's/view-auto-layout=true/view-auto-layout=false/g' "$HOME/.config/nemo/desktop-metadata"
## quit nemo-desktop
#nemo-desktop --quit
## it should restart itself automatically
#gnome-session-quit
