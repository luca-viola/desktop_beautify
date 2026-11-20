# Fonts: JetBrains Mono Nerd Font (the icons in the eza aliases need a Nerd Font)
# shellcheck shell=bash

# Not packaged in Fedora (only plain JetBrains Mono is), so install the latest
# release from GitHub for this user. A version file means re-runs only
# download when there's a new release.
FONT_DIR="${HOME}/.local/share/fonts/JetBrainsMonoNerdFont"
FONT_VERSION_FILE="${FONT_DIR}/.version"

sudo dnf -y install fontconfig xz

latest=$(curl -fsSL https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest \
    | sed -nE 's/.*"tag_name": *"([^"]+)".*/\1/p') || true
installed=$(cat "${FONT_VERSION_FILE}" 2> /dev/null || true)

if [ -n "${installed}" ] && { [ -z "${latest}" ] || [ "${installed}" = "${latest}" ]; }; then
    echo "JetBrains Mono Nerd Font ${installed} is already installed."
else
    # Without a version from the API, fall back to GitHub's "latest" link
    if [ -n "${latest}" ]; then
        url="https://github.com/ryanoasis/nerd-fonts/releases/download/${latest}/JetBrainsMono.tar.xz"
    else
        url="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz"
    fi
    archive=$(mktemp --suffix=.tar.xz)
    if curl -fsSL -o "${archive}" "${url}"; then
        rm -rf "${FONT_DIR}"
        mkdir -p "${FONT_DIR}"
        tar -xJf "${archive}" -C "${FONT_DIR}" --wildcards '*.ttf'
        echo "${latest:-unknown}" > "${FONT_VERSION_FILE}"
        echo "Installed JetBrains Mono Nerd Font ${latest}."
    else
        warn "couldn't download the JetBrains Mono Nerd Font"
    fi
    rm -f "${archive}"
fi

# Rebuild the font cache every run (not only after a download), so fonts added
# or changed by hand in ~/.local/share/fonts show up too
fc-cache -f
