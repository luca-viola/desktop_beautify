# System update and repositories: RPM Fusion, Google Chrome, Sublime Text
# shellcheck shell=bash

sudo dnf -y upgrade --refresh

sudo dnf -y install fedora-workstation-repositories \
    "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
    "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"

# Fedora's google-chrome repo (from fedora-workstation-repositories) hardcodes
# an x86_64 baseurl, so it offers nothing on aarch64. Google ships both arches,
# so write our own repo with $basearch. A same-named file in /etc/yum.repos.d
# overrides the one in /usr/share/dnf5/repos.d.
sudo tee /etc/yum.repos.d/google-chrome.repo > /dev/null << 'EOF'
[google-chrome]
name=google-chrome
baseurl=https://dl.google.com/linux/chrome/rpm/stable/$basearch
skip_if_unavailable=True
gpgcheck=1
gpgkey=https://dl.google.com/linux/linux_signing_key.pub
enabled=1
EOF

# Sublime Text's own repo. Use this instead of the snap: the snap runs on
# bundled Ubuntu libraries that can't find GNOME's settings on Fedora, so it
# ignores the button layout and theme.
sudo tee /etc/yum.repos.d/sublime-text.repo > /dev/null << 'EOF'
[sublime-text]
name=Sublime Text - stable
baseurl=https://download.sublimetext.com/rpm/stable/$basearch
enabled=1
gpgcheck=1
gpgkey=https://download.sublimetext.com/sublimehq-pub.gpg
EOF

# Full ffmpeg from RPM Fusion replaces Fedora's ffmpeg-free
sudo dnf -y swap ffmpeg-free ffmpeg --allowerasing
