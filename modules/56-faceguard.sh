# Face Guard: locks the screen when you walk away (private repo, needs SSH)
# shellcheck shell=bash

# Its install.sh wants a conda env pinned to x86_64/CUDA builds, which can't
# resolve on aarch64. install.sh also accepts any python that has the
# packages, so build a venv with uv from the same pinned pip versions instead.
FACEGUARD="${HOME}/packages/faceguard"
FG_VENV="${HOME}/.local/share/faceguard-venv"
export GIT_SSH_COMMAND="ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new"

if ! git ls-remote git@github.com:luca-viola/faceguard.git HEAD > /dev/null 2>&1; then
    echo "NOTE: can't reach the private faceguard repo over SSH (no GitHub key?), skipping it."
    return 0
fi

# uv builds the venv and fetches a Python if Fedora lacks a suitable one.
# insightface is source-only on PyPI, so it compiles on install.
sudo dnf -y install git uv gcc-c++
clone_or_pull git@github.com:luca-viola/faceguard.git "${FACEGUARD}"

if ! "${FG_VENV}/bin/python" -c 'import insightface, onnxruntime, cv2' 2> /dev/null; then
    # Pip pins from environment.yml, plus numpy (pinned in its conda part).
    # The CUDA build of onnxruntime only exists for x86_64.
    FG_REQS="$(mktemp)"
    {
        sed -nE 's/^ +- numpy=([0-9.]+)=.*/numpy==\1/p' "${FACEGUARD}/environment.yml"
        sed -n '/^ *- pip:/,$p' "${FACEGUARD}/environment.yml" \
            | sed -nE 's/^ +- ([A-Za-z0-9_.-]+==[^ ]+)$/\1/p'
    } > "${FG_REQS}"
    [ "$(uname -m)" = "x86_64" ] || sed -i 's/^onnxruntime-gpu==/onnxruntime==/' "${FG_REQS}"

    # Use the newest Python the pinned packages support: start from Fedora's
    # own and go down (pins often lag behind new Pythons).
    sys_minor=$(python3 -c 'import sys; print(sys.version_info[1])')
    fg_ok=
    for minor in $(seq "${sys_minor}" -1 10); do
        echo "Face Guard: trying Python 3.${minor}"
        rm -rf "${FG_VENV}"
        uv venv --python "3.${minor}" "${FG_VENV}" || continue
        if uv pip install --python "${FG_VENV}/bin/python" -r "${FG_REQS}"; then
            fg_ok=1
            break
        fi
    done
    rm -f "${FG_REQS}"
    if [ -z "${fg_ok}" ]; then
        warn "no Python version could install the Face Guard packages"
        return 1
    fi
fi

# Downloads the buffalo_l model, copies the extension, points it at the venv
if "${FACEGUARD}/install.sh" "${FG_VENV}/bin/python"; then
    enable_extensions faceguard@lviola
else
    warn "Face Guard install failed"
    return 1
fi
