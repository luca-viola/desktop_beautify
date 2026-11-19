#!/bin/bash
# Desktop beautify for Fedora 45 (GNOME 51, Wayland-only, dnf5)
# Run as your normal user from inside a GNOME session (it calls sudo when needed).
#
#   ./fedora45.sh                 run every module, then log out
#   ./fedora45.sh nemo shell      run only these modules, in their usual order
#   ./fedora45.sh --list          list the modules
#
# Each module is a file in modules/; its number sets the order. Modules run in
# their own subshell, so one that fails doesn't stop the others.
set -uo pipefail

ROOT="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
export ROOT

# Module name: modules/45-kubernetes.sh -> kubernetes
module_name() {
    local base
    base=$(basename "$1" .sh)
    echo "${base#*-}"
}

# One-line description: the module's first comment line
module_description() {
    sed -n '1s/^# *//p' "$1"
}

MODULES=("${ROOT}"/modules/[0-9]*.sh)

if [ "${1:-}" = "--list" ] || [ "${1:-}" = "-l" ]; then
    for m in "${MODULES[@]}"; do
        printf '  %-18s %s\n' "$(module_name "${m}")" "$(module_description "${m}")"
    done
    exit 0
fi
if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
    sed -n '2,10s/^# \{0,1\}//p' "${BASH_SOURCE[0]}"
    exit 0
fi

if [ "$(id -u)" -eq 0 ]; then
    echo "Run this as your normal user, not root (sudo is used where needed)." >&2
    exit 1
fi

# Pick the modules to run: all of them, or the ones named on the command line
SELECTED=()
if [ $# -eq 0 ]; then
    SELECTED=("${MODULES[@]}")
else
    for name in "$@"; do
        found=
        for m in "${MODULES[@]}"; do
            [ "$(module_name "${m}")" = "${name}" ] && found=${m}
        done
        [ -n "${found}" ] || { echo "Unknown module: ${name} (see --list)" >&2; exit 1; }
    done
    # Keep the usual order whatever order they were named in
    for m in "${MODULES[@]}"; do
        for name in "$@"; do
            [ "$(module_name "${m}")" = "${name}" ] && SELECTED+=("${m}")
        done
    done
fi

# shellcheck source=lib/common.sh
source "${ROOT}/lib/common.sh"

mkdir -p "${APPS_DIR}" "${HOME}/.config/autostart" "${HOME}/scripts" \
         "${HOME}/.bashrc.d" "${HOME}/packages"

# Ask for the sudo password once, up front
sudo -v || exit 1

FAILED=()
for m in "${SELECTED[@]}"; do
    name=$(module_name "${m}")
    echo
    echo "==> ${name}: $(module_description "${m}")"
    # Report every command that fails (not just the module's last one) and
    # keep going; the module counts as failed if any did. Commands in an
    # if/while test or before || and && don't count, so expected failures
    # are written that way. (The subshell must not sit before || itself:
    # bash turns ERR traps off in that position.)
    # shellcheck disable=SC1090
    (
        set -E
        failed=0
        trap 'rc=$?; failed=1; echo "  ! ${name}: exit ${rc} from: ${BASH_COMMAND}  (${BASH_SOURCE[0]##*/}:${LINENO})" >&2' ERR
        source "${m}"
        exit "${failed}"
    )
    [ $? -eq 0 ] || FAILED+=("${name}")
done

echo
if [ ${#FAILED[@]} -gt 0 ]; then
    echo "Finished, but these modules reported a failure: ${FAILED[*]}"
    echo "Fix the cause and re-run just those: ./fedora45.sh ${FAILED[*]}"
else
    echo "Finished: $(for m in "${SELECTED[@]}"; do printf '%s ' "$(module_name "${m}")"; done)"
fi

# A full run changes extensions, theme and the Nemo desktop, which only load
# at login. A partial run leaves logging out to you.
if [ $# -eq 0 ]; then
    echo "Log out and back in so the extensions, Nemo desktop and theme load."
    gnome-session-quit --logout
fi
