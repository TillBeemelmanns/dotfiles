# CLAUDE.md

personal dotfiles for linux/macos

## Commands
```bash
./install -v   # apply install.conf.yaml; idempotent, re-run to verify any change
```

## Architecture

- **`install.conf.yaml`** is the only thing that matters, processed top to bottom: `defaults` (relink/create + recursive clean) → `clean` (removes dead symlinks under `~`, `~/.config`, `~/.local/bin`, recursively, but only ones that pointed into this repo) → `shell` (runs `scripts/install-*.sh`, plus a one-off legacy-symlink migration) → `link` (the actual repo-path → `~`-path map, with OS-conditional entries via `if: '[ \`uname\` = Darwin ]'`).
- **Don't glob individual files into a directory that's also directly symlinked elsewhere** — dotbot sees source and destination as the same inode and fails. Link config dirs (`lazygit`, `pip`) wholesale; only split into per-file links (`ghostty`, `claude`) when OS-conditional selection is needed.
- **`scripts/install-<tool>.sh`** (bat, delta, lazygit, turm, yazi) each download a prebuilt binary from GitHub releases into `~/.local/bin`, no-op if the tool is already on `PATH` (never upgrades). Each project names release assets differently (tag with/without `v`, musl vs gnu per arch, OS string casing, version in filename or not) — check the actual current release before copying another script's pattern. `turm` is Linux-only HPC tooling, exits 0 on Darwin.
- **`home/*`** is symlinked into `$HOME` with a `.` prefix via one glob link entry — add new home files there, not as separate explicit links. OS-specific shell behavior goes in `home/zshrc.linux` / `home/zshrc.darwin`, sourced from `home/zshrc` via `uname -s`.

## Adding a new auto-installed tool

1. Check the project's actual GitHub release asset naming (don't assume).
2. Write `scripts/install-<tool>.sh` following an existing script.
3. Add a `shell` entry in `install.conf.yaml`.
4. Run `./install -v` and confirm the binary lands in `~/.local/bin`.
