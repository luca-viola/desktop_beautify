# Shared helpers, sourced by fedora45.sh before each module.
# shellcheck shell=bash

APPS_DIR="${HOME}/.local/share/applications"

# Print a warning and fail, so the module is reported as failed
warn() {
    echo "WARNING: $*" >&2
    return 1
}

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

# Put an app first in the dock if it's not there yet
pin_app_first() {
    local current
    current=$(gsettings get org.gnome.shell favorite-apps)
    [[ "${current}" == *"'$1'"* ]] && return
    if [ "${current}" = "@as []" ] || [ "${current}" = "[]" ]; then
        gsettings set org.gnome.shell favorite-apps "['$1']"
    else
        gsettings set org.gnome.shell favorite-apps "['$1', ${current#[}"
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

# Install an extension from extensions.gnome.org, in the version made for the
# running GNOME Shell. For extensions Fedora doesn't package.
install_ego_extension() {
    local uuid=$1 shell url zip rc
    shell=$(gnome-shell --version | sed -nE 's/^GNOME Shell ([0-9]+).*/\1/p')
    url=$(curl -fsSL "https://extensions.gnome.org/extension-info/?uuid=${uuid}&shell_version=${shell}" \
        | sed -nE 's/.*"download_url": *"([^"]+)".*/\1/p') || true
    if [ -z "${url}" ]; then
        warn "${uuid} has no version for GNOME Shell ${shell}, skipping it"
        return 1
    fi
    zip=$(mktemp --suffix=.zip)
    curl -fsSL -o "${zip}" "https://extensions.gnome.org${url}" \
        && gnome-extensions install --force "${zip}"
    rc=$?
    rm -f "${zip}"
    [ "${rc}" -eq 0 ] || warn "${uuid} failed to install"
    return "${rc}"
}

# Clone a git repo, or update an existing clone
clone_or_pull() {
    local url=$1 dir=$2
    if [ -d "${dir}/.git" ]; then
        git -C "${dir}" pull --ff-only
    else
        git clone --depth=1 "${url}" "${dir}"
    fi
}
