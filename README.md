# cli-template - Type 0 self-managed CLI template (local and global install)

![Version](https://img.shields.io/badge/Version-1.0.0-blue?style=flat-square)
![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)
[![CIAO](https://img.shields.io/badge/Philosophy-CIAO%20(Caution%20%E2%80%A2%20Intentional%20%E2%80%A2%20Anti--fragile%20%E2%80%A2%20Over--engineered)-purple.svg)](https://github.com/cloudgen/ciao)
[![Stars](https://img.shields.io/github/stars/cloudgen/cli-template?style=flat-square)](https://github.com/cloudgen/cli-template)

POSIX `/bin/sh` **Type 0 template** CLI: `install`, `uninstall`, `where-is-me`, `version`, `about`, and `help`. It does **not** manage the operating system (no `setup`, packages, `/etc`, or sudoers emit). This product **is** the Type 0 bootstrap origin (no live parent).

Install **location** is still **both**:
- **local** → `~/.local/bin/cli-template` (normal user)
- **global** → `/usr/local/bin/cli-template` (root / `--global`)

The *channel* is local-only (no online `curl|sh`). Local vs global here means where the binary is placed, not an online vs offline download.

## Features

- **Self-management**: `install`, `uninstall`, `where-is-me`, `version`, `about`, `help` (local **and** global place/remove)
- **Type N empty argv**: no arguments shows help (not install-ensure)
- **Managed binary mode 0755**: global install stays readable and runnable for every user
- **Fail-closed**: unknown commands (including trimmed parent verbs) exit non-zero
- **CIAO / CIAO-Lite** defensive design (Protection Zones, `out_*` output SSOT)

## Quick Installation

**Local (Type 0 day-to-day):**

```sh
# From this repository checkout
sh src/cli-template install
# or force refresh after updates
sh src/cli-template install --force

# Ensure ~/.local/bin is on PATH, then:
cli-template version
```

**Global (multi-user hosts):**

```sh
sudo sh src/cli-template install
# or: cli-template install --global   # needs write access to /usr/local/bin
# Managed binary mode is always 0755 so every user can run the shell ship unit.
```

This product is **local-only** for its install channel (no default `SCRIPT_URL` online install). Global vs local here means install *location*, not an online channel.

**Source repository:** [cloudgen/cli-template](https://github.com/cloudgen/cli-template)  
Config identity: `REPO_USER=cloudgen`, `REPO_NAME=cli-template` (override with env if needed; does not enable online install while `SCRIPT_URL` is empty).

## Usage

```sh
cli-template help
cli-template about
cli-template --json about

cli-template install
cli-template where-is-me
cli-template uninstall --force
```

**Environment (selected):**

| Variable | Role |
|----------|------|
| `REPO_USER` | Git host owner (default `cloudgen`) |
| `REPO_NAME` | Git repository name (default `cli-template`) |
| `SCRIPT_URL` | Online install channel (default **empty** — local only) |
| `USER_BIN` | Per-user install destination (default `~/.local/bin`) |
| `GLOBAL_BIN` | Global install destination (default `/usr/local/bin`) |

## Examples

```sh
# Local install (user bin)
sh src/cli-template install

# Global install (system bin)
sudo sh src/cli-template install

# Diagnostics
cli-template about
cli-template --json version
```

## Platform Compatibility

| Platform | Status |
|----------|--------|
| Linux, `/bin/sh` (dash/bash) | Supported |
| `mktemp`, `date` | Required |
| macOS / BSD | Not primary; GNU `stat`/`sed -E` assumptions may differ |

## Related Projects

- [selfmanaged](https://github.com/cloudgen/selfmanaged) — related Type 0 product (online channel); **not** this product’s origin
- [folder-backup](https://github.com/cloudgen/folder-backup) — related product (backup/restore/sudoers); **not** this product’s origin
- [CIAO Defensive Programming](https://github.com/cloudgen/ciao)
- [CIAO-Lite](https://github.com/cloudgen/ciao-lite)

## Contributing

Keep changes surgical. Honor **CIAO-Lite Protection Zones** in `src/cli-template`. Product behavior must stay consistent with live `docs/requirements/requirement-*.md`. Run `sh tests/run.sh` before proposing commits.

## License

MIT License — see [`LICENSE.md`](./LICENSE.md).

## Last Update

2026-08-13 — version **1.0.0** (Type 0 bootstrap origin; forge **cloudgen/cli-template**; author-email **wongcf22@gmail.com**).
