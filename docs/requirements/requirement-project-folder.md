**file**: docs/requirements/requirement-project-folder.md  
**Status**: Active (Version 2.0.0)  
**Area**: architecture  
**Key**: `requirement-project-folder`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

Define **project folder structure** and path ownership for the cli-template CLI: source layout, install locations, and scratch/cache. This product has **no** durable host backup deposit.

---

## 2. Core Rules (Mandatory)

### 2.1 Workspace source layout (developer tree)

| Path | Role |
|------|------|
| `src/cli-template` | **Ship unit** — single POSIX shell executable source |
| `tests/` | CLI tests when present |
| `docs/requirements/` | Product law (this surface) |
| Product root README / CHANGELOG / LICENSE / SECURITY | Product user docs when specialized |

1. **MUST** keep the installable CLI under **`src/`** (not only repo root).  
2. **MUST** install the binary under a privilege-correct bin path (see §2.2).  
3. **MUST NOT** require online channel files (companion digest) for local install.  
4. **MUST NOT** own `/var/backup` or any durable archive deposit tree.

### 2.2 CLI tool install locations

| Mode | Binary path | Default |
|------|-------------|---------|
| **Per-user (normal)** | `${USER_BIN}/${APP_NAME}` | `${HOME}/.local/bin/cli-template` |
| **Global (root)** | `${GLOBAL_BIN}/${APP_NAME}` | `/usr/local/bin/cli-template` |

Rules:

1. Non-root **install** **MUST** target user bin.  
2. Root **install** **MAY** target global bin.  
3. **Primary product story:** **user bin** (`~/.local/bin`) for Type 0 day-to-day; **global bin** for multi-user hosts.  
4. Uninstall **MUST** remove only the managed binary path for the install mode used.  
5. Managed binary mode **MUST** be **`0755`** after install (see `requirement-shell-local-self-management` §2.3.1).

### 2.3 Scratch / cache (CLI own volatile)

| Purpose | Pattern |
|---------|---------|
| Effective storage root | From `util_resolve_storage` (see `requirement-shell-cli-storage`) |
| Install staging | `mktemp` under the effective storage root |

Rules:

1. Scratch **MUST** be per-user isolated (`APP_NAME` + `USERNAME`).  
2. Temps **MUST** clean up after success/failure of install staging.  
3. Scratch is **not** a durable backup deposit.

### 2.4 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **APP_NAME** | `cli-template` |
| **Ship unit path** | `src/cli-template` |
| **USER_BIN default** | `${HOME}/.local/bin` |
| **GLOBAL_BIN default** | `/usr/local/bin` |
| **Config dir (optional)** | `${HOME}/.config/cli-template/` if needed later |
| **No Type 2 app data tree** | No dedicated system app user for routine ops |
| **No backup deposit** | `/var/backup` is not a product path |

### 2.5 Why This Requirement Exists (CIAO)

- **Principle 1 – Caution**: Separate install paths from scratch.  
- **Principle 11 – Temps**: Staging is cleanup, not museum.  
- **Principle 17 – Defensive storage**: No assumed writable paths without resolve.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution**: Fail loud if install target is not writable.  
- **Intentional**: Path classes are documented and not mixed.  
- **Anti-fragile**: Per-user isolation under multi-user hosts.  
- **Over-protect**: Do not reintroduce `/var/backup` as a product path.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Move the ship unit out of `src/` without updating this requirement and install paths.  
2. Make online channel paths required for install.  
3. Grant the product unrestricted write under `/var` or `/etc`.  
4. Reintroduce a durable backup deposit as if it were still product law.  
5. Rename protected temp isolation away from per-user roots.

**Violating this rule is a critical path/privilege regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | Ship unit lives at `src/cli-template` |
| AC-2 | Default user install path is `~/.local/bin/cli-template` |
| AC-3 | No product law requires `/var/backup` |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-shell-local-self-management` | Place/remove binary |
| `requirement-shell-cli-storage` | Scratch resolve |
| `requirement-shell-cli-interface` | Commands |
| `docs/requirements/index.md` | Registry |

---

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-03 | Active 1.0.0 | folder-backup layout + `/var/backup` deposit |
| 2026-08-13 | Active 2.0.0 | cli-template: retarget; remove deposit |

---

**Last Updated**: 2026-08-13  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
