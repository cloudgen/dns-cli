# folder-backup - Local folder archive backup and restore with narrow sudo deposit

![Version](https://img.shields.io/badge/Version-1.2.1-blue?style=flat-square)
![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)
[![CIAO](https://img.shields.io/badge/Philosophy-CIAO%20(Caution%20%E2%80%A2%20Intentional%20%E2%80%A2%20Anti--fragile%20%E2%80%A2%20Over--engineered)-purple.svg)](https://github.com/cloudgen/ciao)
[![Stars](https://img.shields.io/github/stars/cloudgen/folder-backup?style=flat-square)](https://github.com/cloudgen/folder-backup)

POSIX `/bin/sh` local CLI that archives a folder to gzip tar, deposits it under `/var/backup/folder-backup/` with narrow Type 1 sudo, verifies counts and size, and restores archives with **hard-disk destination as the default SSOT** (reverse of ram-drive-first). Local install only (no online `curl|sh` channel).

## Features

- **Local self-management**: `install`, `uninstall`, `where-is-me`, `version`, `about`, `help`
- **Backup**: `backup <folder>` → stage tar.gz → elevated deposit → verify (entries/files/size)
- **Restore**: `restore <archive|prefix> [dest]` — default dest is hard-disk `${PROJECTS_ROOT}/<project>`
- **Narrow sudoers**: `print-sudoers` emits deposit / verify-list / restore-stage allowlist (admin installs to `/etc/sudoers.d/`)
- **Fail-closed**: missing source, unauthorized deposit, verify mismatch, non-empty restore without `--force`
- **CIAO / CIAO-Lite** defensive design (Protection Zones, `out_*` output SSOT)

## Quick Installation

**Local (recommended):**

```sh
# From this repository checkout
sh src/folder-backup install
# or force refresh after updates
sh src/folder-backup install --force

# Ensure ~/.local/bin is on PATH, then:
folder-backup version
```

**Sudoers (required for non-root deposit / restore of root-owned archives):**

```sh
folder-backup print-sudoers ~/.config/folder-backup/sudoers.fragment
# Admin:
sudo visudo -c -f ~/.config/folder-backup/sudoers.fragment
sudo install -m 0440 ~/.config/folder-backup/sudoers.fragment /etc/sudoers.d/folder-backup
sudo mkdir -p /var/backup/folder-backup
```

This product is **local-only** (no default `SCRIPT_URL` online install channel).

**Source repository:** [cloudgen/folder-backup](https://github.com/cloudgen/folder-backup)  
Config identity: `REPO_USER=cloudgen`, `REPO_NAME=folder-backup` (override with env if needed; does not enable online install while `SCRIPT_URL` is empty).

## Usage

```sh
folder-backup help
folder-backup about
folder-backup --json about

folder-backup backup /path/to/project
folder-backup restore project-name              # → hard-disk PROJECTS_ROOT/project-name
folder-backup restore project-name --disk       # explicit hard-disk
folder-backup restore project-name --ram        # → /dev/shm/project-name
folder-backup restore NAME-YYYYMMDD-N.tar.gz /explicit/dest
folder-backup restore project-name --force      # allow non-empty dest

folder-backup print-sudoers
folder-backup uninstall --force
```

**Environment (selected):**

| Variable | Role |
|----------|------|
| `REPO_USER` | Git host owner (default `cloudgen`) |
| `REPO_NAME` | Git repository name (default `folder-backup`) |
| `SCRIPT_URL` | Online install channel (default **empty** — local only) |
| `BACKUP_ROOT` | Durable root (default `/var/backup`) |
| `BACKUP_NOTATION` | Subdir (default `folder-backup`) |
| `PROJECTS_ROOT` | Hard-disk projects tree for restore default |
| `RAM_ROOT` | RAM projects root (default `/dev/shm`) |
| `RESTORE_HOST_DEFAULT` | `hard-disk` (default) or `ram-drive` |

## Examples

```sh
# Backup the RAM genesis tree
folder-backup backup /dev/shm/genesis-template

# Restore latest genesis-template-* archive to hard-disk projects tree
folder-backup restore genesis-template

# Restore into a temporary path
folder-backup restore genesis-template-20260803-3.tar.gz /tmp/genesis-restore
```

## Platform Compatibility

| Platform | Status |
|----------|--------|
| Linux, `/bin/sh` (dash/bash) | Supported |
| `tar`, `find`, `date` | Required |
| `sudo` + narrow sudoers | Required for non-root deposit/restore of root-owned archives |
| macOS / BSD | Not primary; GNU `stat`/`sed -E` assumptions may differ |

## Related Projects

- [folder-backup](https://github.com/cloudgen/folder-backup) — this product
- [CIAO Defensive Programming](https://github.com/cloudgen/ciao)
- [CIAO-Lite](https://github.com/cloudgen/ciao-lite)
- [selfmanaged](https://github.com/cloudgen/selfmanaged) — bootstrap parent architecture

## Contributing

Keep changes surgical. Honor **CIAO-Lite Protection Zones** in `src/folder-backup`. Product behavior must stay consistent with live `docs/requirements/requirement-*.md`. Run `sh tests/run.sh` before proposing commits.

## License

MIT License — see [`LICENSE.md`](./LICENSE.md).

## Last Update

2026-08-03 — version **1.2.1** (repository identity SSOT `REPO_USER`/`REPO_NAME` for cloudgen/folder-backup).
