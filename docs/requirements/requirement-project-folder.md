**file**: docs/requirements/requirement-project-folder.md  
**Status**: Active (Version 1.0.0)  
**Area**: architecture  
**Key**: `requirement-project-folder`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

Define **project folder structure** and path ownership for the folder-backup CLI: source layout, install locations, staging/scratch, and the privileged durable backup deposit root.

**Critical distinction:** CLI tool own paths vs target folders being archived vs host durable backup deposit.

---

## 2. Core Rules (Mandatory)

### 2.1 Workspace source layout (developer tree)

| Path | Role |
|------|------|
| `src/folder-backup` | **Ship unit** — single POSIX shell executable source |
| `tests/` | CLI tests when present |
| `docs/requirements/` | Product law (this surface) |
| Product root README / CHANGELOG / LICENSE / SECURITY | Product user docs when specialized |

1. **MUST** keep the installable CLI under **`src/`** (not only repo root).  
2. **MUST** install the binary under a privilege-correct bin path (see §2.2).  
3. **MUST NOT** require online channel files (companion digest) for local install.

### 2.2 CLI tool install locations (Type 1a / 1b)

| Mode | Binary path | Default |
|------|-------------|---------|
| **Per-user (normal)** | `${USER_BIN}/${APP_NAME}` | `${HOME}/.local/bin/folder-backup` |
| **Global (root)** | `${GLOBAL_BIN}/${APP_NAME}` | `/usr/local/bin/folder-backup` |

Rules:

1. Non-root **install** **MUST** target user bin.  
2. Root **install** **MAY** target global bin.  
3. **Primary product story** for this project: **user bin** (`~/.local/bin`).  
4. Uninstall **MUST** remove only the managed binary path for the install mode used.

### 2.3 Scratch / cache (CLI own volatile)

| Purpose | Pattern |
|---------|---------|
| Effective storage root | From `util_resolve_storage` (see `requirement-shell-cli-storage`) |
| Archive staging | `${EFFECTIVE_STORAGE_DIR}/stage/` (or `mktemp` under that root) |
| Sudoers fragment draft | User-writable path under config or storage (never auto-write `/etc/sudoers.d`) |

Rules:

1. Scratch **MUST** be per-user isolated (`APP_NAME` + `USERNAME`).  
2. Temps **MUST** clean up (`trap`) after success/failure of a backup run.  
3. Staging archives are **EPHEMERAL** until successfully deposited; do not leave world-writable archives.

### 2.4 Durable host backup deposit (not CLI config)

| Item | Value |
|------|--------|
| **Backup root** | `/var/backup` |
| **Backup notation directory** | `/var/backup/${BACKUP_NOTATION}/` |
| **Default notation** | `folder-backup` (same as `APP_NAME` unless overridden by env/config) |
| **Archive basename pattern** | `${SOURCE_FOLDER_NAME}-YYYYMMDD-N.tar.gz` |

Rules:

1. Writing into `/var/backup/...` **MUST** use the **narrow elevated path** defined in privilege + domain law — not unrestricted root shell.  
2. Normal users **MUST NOT** be granted write to all of `/var` — only the allowlisted deposit.  
3. Archive **creation** (tar gzip) **MUST** run as the invoking user into staging; only the **deposit copy** is elevated.

### 2.5 Target folders being backed up

1. Source folder is a **user-supplied path** (domain operand), not an app system-user tree.  
2. The tool **MUST** validate the source is a readable directory before archiving.  
3. The tool **MUST NOT** follow uncontrolled recursion into dangerous system roots without explicit user path input and validation.

### 2.6 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **APP_NAME** | `folder-backup` |
| **Ship unit path** | `src/folder-backup` |
| **USER_BIN default** | `${HOME}/.local/bin` |
| **GLOBAL_BIN default** | `/usr/local/bin` |
| **BACKUP_ROOT** | `/var/backup` |
| **BACKUP_NOTATION default** | `folder-backup` |
| **Config dir (optional)** | `${HOME}/.config/folder-backup/` for generated sudoers drafts |
| **No Type 2 app data tree** | No dedicated system app user for routine ops |

### 2.7 Why This Requirement Exists (CIAO)

- **Principle 1 – Caution**: Separate staging, install, and privileged deposit.  
- **Principle 10 – Least privilege**: User creates archive; elevation only for deposit.  
- **Principle 11 – Temps**: Staging is cleanup, not museum.  
- **Principle 17 – Defensive storage**: No assumed writable paths without resolve.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution**: Fail loud if deposit root or staging is not usable under policy.  
- **Intentional**: Path classes are documented and not mixed.  
- **Anti-fragile**: Per-user isolation under multi-user hosts.  
- **Over-protect**: Do not “simplify” by writing archives straight into `/var/backup` as a normal user or by running the whole CLI as root.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Move the ship unit out of `src/` without updating this requirement and install paths.  
2. Make online channel paths required for install.  
3. Grant the product unrestricted write under `/var` or `/etc`.  
4. Collapse staging and durable deposit into one world-writable directory.  
5. Rename protected temp isolation away from per-user roots.

**Violating this rule is a critical path/privilege regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | Ship unit lives at `src/folder-backup` |
| AC-2 | Default user install path is `~/.local/bin/folder-backup` |
| AC-3 | Durable deposit is under `/var/backup/${BACKUP_NOTATION}/` |
| AC-4 | Archive naming pattern documented and owned with domain law |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-shell-local-self-management` | Place/remove binary |
| `requirement-shell-cli-storage` | Scratch resolve |
| `requirement-domain-folder-backup` | Archive + deposit behavior |
| `requirement-three-layer-privilege-model` | Elevation boundary |
| `docs/requirements/index.md` | Registry |

---

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-03 | Active | Specialized project folder law for folder-backup |

---

**Last Updated**: 2026-08-03  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
