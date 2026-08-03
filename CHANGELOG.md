# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [1.2.0] - 2026-08-03

### Added

- `restore <archive|prefix> [dest]` with count verification after extract.
- Default restore destination host is **hard-disk** (`PROJECTS_ROOT/<project>`) — reverse of ram-drive-first; override with `--ram`, `--disk`, or an explicit path.
- Sudoers fragment lines for restore: allowlisted `cp` from deposit into per-user stage (Type 0 `tar -xzf` after).
- Domain surface and ops requirement coverage for restore; suite cases TP-FOLDER-BACKUP-11..13.
- Product harness skill `SK-FOLDER-ARCHIVE-BACKUP` and related sudoers create skill.

### Changed

- Backup flow reports source/archive file and member counts; deposit size verification.
- `print-sudoers` includes `tar -tzf` list allowlist and restore stage fetch.
- Version SSOT **1.2.0** on ship unit.

## [1.1.0] - 2026-08-03

### Added

- Post-deposit verification (stage counts + deposit size; optional elevated `tar -tzf` re-list).
- `print-sudoers` allowlist for deposit listing.

### Fixed

- Fail-closed deposit path retained when sudoers missing.

## [1.0.0] - 2026-08-03

### Added

- Initial specialized product **folder-backup**: local install/uninstall, backup with elevated deposit, print-sudoers, isolated test suite.
