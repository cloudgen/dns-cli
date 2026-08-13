# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [1.0.0] - 2026-08-13

### Added

- **cli-template** as a Type 0 template bootstrap origin (no live parent).
- Type 0 local self-managed CLI: `install`, `uninstall`, `where-is-me`, `version`, `about`, `help`.
- Empty argv **Type N** help (local-only; no curl|sh).
- Suite **TP-CLI-01..13** and **TP-LC-01..10**.
- Law: class software-dev + bootstrap-chain (this product is hop 0) + Type 0 shell family.

### Removed (not this origin’s surfaces)

- Domain verbs: `backup`, `restore`
- Sudoers-file verbs: `print-sudoers`, `print-sudoers-install-script`, `remove-project-sudoers`
- Durable `/var/backup` deposit, retention, restore dest whitelist
- `requirement-domain-folder-backup`, `requirement-folder-archive-backup*`, `requirement-three-layer-privilege-model`
- Product incidents INC-20260811-001 (sudoers grantee) and INC-20260812-001 (restore dest) — remain on sibling **folder-backup**
- Domain suite **TP-FOLDER-BACKUP-***

### Changed

- Identity SSOT: `APP_NAME=cli-template`, `REPO_NAME=cli-template`, `VERSION=1.0.0` (working names `hostmanaged` / `climanaged` dropped so this is not read as host-OS setup)
- Live parent hops **retired** — this product is hop 0; **selfmanaged** and **folder-backup** are not origins
- Ship unit path: `src/cli-template`
- About: Type 0 diagnostics only (no backup/sudoers fields)
- **No domain SSOT** and **no `setup` verb** — Type 0 template only (`version`, `install`, `about`, `help`)
- Install **locations unchanged**: local `${USER_BIN}` **and** global `${GLOBAL_BIN}` (`install --global` / root). “Local-only” still means **no online channel**, not “user-bin only.”
- Forge identity: repository-user **cloudgen**, author-email **wongcf22@gmail.com**, project-repository **cloudgen/cli-template**, product version **1.0.0**
