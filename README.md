# desktop_beautify

Scripts to set up a saner GNOME desktop on Fedora 45 (GNOME 51, Wayland, dnf5),
on x86_64 and aarch64 (Asahi).

## Usage

Clone the repo and run the script as your normal user, from inside a GNOME
session. It asks for your sudo password once.

```sh
./fedora45.sh                  # run every module, then log out
./fedora45.sh nemo shell       # run only these modules
./fedora45.sh --list           # list the modules
```

Every module can be run again safely. A partial run doesn't log you out, but
extensions and themes only load at your next login.

If a module fails, the others still run. At the end the script names the
modules that failed, so you can fix the cause and re-run just those.

## Modules

| Module | What it does |
| --- | --- |
| `system` | Updates the system, adds RPM Fusion and the Google Chrome and Sublime Text repos, swaps in full ffmpeg |
| `nemo` | Replaces Files (Nautilus) with Nemo, which also draws the desktop icons: on every monitor, auto-arrange off |
| `desktop-settings` | Window buttons on the left, right Super as Compose key, Super+D shows the desktop |
| `apps` | Chrome, Sublime Text, vim, VLC, GIMP, GNOME Tweaks, Extensions, dconf Editor; from Flathub: Extension Manager, ZapZap |
| `kubernetes` | kubectl from the upstream repo, aliased to kubecolor |
| `extensions` | GNOME Shell extensions, from Fedora where packaged, otherwise from extensions.gnome.org |
| `snappo` | [Snappo](https://github.com/luca-viola/snappo), a screenshot extension with OCR |
| `faceguard` | Face Guard, which locks the screen when you walk away. Private repo: needs a GitHub SSH key, otherwise it's skipped |
| `theme` | WhiteSur GTK, shell and icon themes, dark |
| `dock` | Pinned apps (including ZapZap), and a Show Desktop launcher |
| `shell` | eza/bat aliases, `fixterm`, bash-git-prompt, personal directories |

## Layout

```
fedora45.sh          entry point: picks and runs the modules
lib/common.sh        helpers shared by the modules
modules/NN-name.sh   one module per file; the number sets the order
files/               dotfiles installed as-is (~/.bashrc.d snippets, prompt theme)
```

To add a module, create `modules/NN-name.sh`. Its first line is a comment that
describes it, shown by `--list`. Write commands that are allowed to fail as
`cmd || true`, or inside an `if`, so they aren't reported as failures; use
`warn "message"` for a failure worth reporting.
