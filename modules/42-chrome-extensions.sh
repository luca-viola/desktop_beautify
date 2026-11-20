# Chrome extensions from your own repos: Teams Transcript Exporter, MP4 Capture Debugger
# shellcheck shell=bash

# They aren't on the Chrome Web Store, and official Chrome dropped
# --load-extension in version 137. Linux Chrome still installs "external
# extensions": a JSON file in /usr/share/google-chrome/extensions/, named
# after the extension ID, pointing at a packed .crx. Chrome picks them up at
# its next start (and asks once whether to enable them), and updates one when
# its manifest version goes up.
#
# Each entry: name|git URL|folder inside the repo holding manifest.json
CHROME_EXTENSIONS=(
    "teams-transcript-exporter|git@macminim4.local:admin/teams-transcript-exporter.git|."
    "media_debug|git@macminim4.local:admin/media_debug.git|extension"
)
EXT_HOME="${HOME}/.local/share/chrome-extensions"
EXT_SYSTEM_DIR=/usr/share/google-chrome/extensions

if ! command -v google-chrome > /dev/null; then
    warn "Chrome isn't installed (apps module), skipping its extensions"
    return 1
fi

# Extension ID: SHA-256 of the public key, first 32 hex digits mapped to a-p
extension_id() {
    openssl pkey -in "$1" -pubout -outform DER | sha256sum | cut -c1-32 | tr '0-9a-f' 'a-p'
}

export GIT_SSH_COMMAND="ssh -o BatchMode=yes -o ConnectTimeout=10 -o StrictHostKeyChecking=accept-new"
mkdir -p "${EXT_HOME}/keys" "${EXT_HOME}/crx"
sudo mkdir -p "${EXT_SYSTEM_DIR}"
sudo dnf -y install git openssl

for entry in "${CHROME_EXTENSIONS[@]}"; do
    IFS='|' read -r name url subdir <<< "${entry}"
    repo="${HOME}/packages/${name}"
    key="${EXT_HOME}/keys/${name}.pem"
    crx="${EXT_HOME}/crx/${name}.crx"

    if ! git ls-remote "${url}" HEAD > /dev/null 2>&1; then
        echo "NOTE: can't reach ${url} (not on the home network, or no SSH key?), skipping ${name}."
        continue
    fi
    clone_or_pull "${url}" "${repo}" || { warn "${name}: clone/update failed"; continue; }

    # Pack a clean copy (no .git) of the extension folder. The key is made
    # once and reused, so the extension ID stays the same across re-runs.
    src=$(mktemp -d)
    cp -r "${repo}/${subdir}/." "${src}/"
    rm -rf "${src}/.git"
    [ -f "${key}" ] || openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:2048 -out "${key}"
    chmod 600 "${key}"
    profile=$(mktemp -d)
    google-chrome --headless=new --no-message-box --user-data-dir="${profile}" \
        --pack-extension="${src}" --pack-extension-key="${key}" > /dev/null 2>&1 || true
    rm -rf "${profile}"
    if [ ! -f "${src}.crx" ]; then
        rm -rf "${src}"
        warn "${name}: Chrome couldn't pack the extension"
        continue
    fi
    mv "${src}.crx" "${crx}"
    version=$(python3 -c 'import json, sys; print(json.load(open(sys.argv[1]))["version"])' "${src}/manifest.json")
    rm -rf "${src}"

    id=$(extension_id "${key}")
    sudo tee "${EXT_SYSTEM_DIR}/${id}.json" > /dev/null << EOF
{
  "external_crx": "${crx}",
  "external_version": "${version}"
}
EOF
    echo "${name}: version ${version}, extension ID ${id}"
done
unset GIT_SSH_COMMAND

echo "Restart Chrome; it asks once whether to enable each new extension."
