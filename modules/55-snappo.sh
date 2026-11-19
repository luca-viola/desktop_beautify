# Snappo: screenshot extension with OCR and barcode reading
# shellcheck shell=bash

# tesseract and zbar are only needed for OCR; make builds the extension
sudo dnf -y install git make tesseract zbar
SNAPPO="${HOME}/packages/snappo"
clone_or_pull https://github.com/luca-viola/snappo.git "${SNAPPO}"
make -C "${SNAPPO}/gnome-wayland" install
enable_extensions snappo@lviola
