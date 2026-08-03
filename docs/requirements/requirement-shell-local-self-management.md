**file**: docs/requirements/requirement-shell-local-self-management.md  
**Status**: Active (Version 1.0.0)  
**Area**: shell  
**Key**: `requirement-shell-local-self-management`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **project Single Source of Truth** for **local self-managed lifecycle** of the folder-backup POSIX shell CLI: **`install`**, **`uninstall`**, and **`where-is-me`**, plus the local diagnostics package contract for **`version`**, **`about`**, and **`help`** (wiring owned with CLI interface).

**Install mode:** **local-only**. Online channel install, remote version-check, self-update, and self-uninstall are **out of scope** (intentionally absent).

---

## 2. Core Rules (Mandatory)

### 2.1 Local lifecycle command pair

| Feature | Command | Meaning |
|---------|---------|---------|
| Local install | **`install`** | Copy **running** ship unit → privilege-correct bin; **no** network |
| Local uninstall | **`uninstall`** | Remove **managed** binary only; confirm / `--force` |
| Local refresh | **`install --force`** | Replace managed binary from **this** running ship unit |
| Where-is-me | **`where-is-me`** | Report running path + managed install path + installed flag |

**Forbidden primary verbs for this product:** `self-install`, `self-uninstall`, `self-update`, `version-check`.

### 2.2 Local diagnostics (required companions)

| Feature | Command | Network |
|---------|---------|---------|
| **Local version** | `version` | **MUST NOT** fetch remote |
| About | `about` | Local diagnostics only; **no** `SCRIPT_URL` install one-liner as product UX |
| Help | `help` | Lists local lifecycle + domain commands |

### 2.3 Local install rules

1. Source **MUST** be the currently executing ship unit when resolvable — **not** a URL.  
2. Target **MUST** be root → `${GLOBAL_BIN}/${APP_NAME}`; non-root → `${USER_BIN}/${APP_NAME}`.  
3. Defaults: `GLOBAL_BIN=/usr/local/bin`; `USER_BIN=${HOME}/.local/bin`.  
4. Create target bin dir when missing; fail loud if not writable.  
5. Atomic: stage → `chmod +x` → `mv` onto final path.  
6. Idempotent: already installed + force off → success no-op.  
7. **MUST NOT** require network for install.

### 2.4 Local uninstall rules

1. User command name **MUST** be **`uninstall`** only.  
2. Target **MUST** be the managed binary only.  
3. Absent → success no-op.  
4. Interactive confirm unless `--force`; non-interactive/json/quiet without force → **fail closed** (`confirm_required`).  
5. **MUST NOT** delete domain data, `/var/backup` archives, home trees, or unrelated binaries.

### 2.5 Where-is-me rules

1. Report absolute running path when resolvable.  
2. Report expected managed install path and whether installed.  
3. Honest degradation when `$0` is not a file path.  
4. JSON at least: `running_path`, `install_path`, `installed`.  
5. Output via `out_*` / `out_json` only.

### 2.6 Config variables (local)

| Variable | Role | Default / note |
|----------|------|----------------|
| `APP_NAME` | Binary basename SSOT | hard-assign `folder-backup` |
| `VERSION` | Local version SSOT | hard-assign `1.0.0` |
| `GLOBAL_BIN` | System-wide bin | `/usr/local/bin` |
| `USER_BIN` | Per-user bin | `${HOME}/.local/bin` |
| `FORCE` | Replace / skip confirm | `0` |
| `SCRIPT_URL` / `REPO_*` / `CHECKSUM` | **Not** install source | Must not appear as required install UX |

### 2.7 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **Product / binary** | `folder-backup` |
| **Ship unit** | `src/folder-backup` |
| **Primary install path story** | `${HOME}/.local/bin/folder-backup` |
| **Handlers** | `inst_local_install`, `inst_local_uninstall`, `app_where_is_me`, `app_version` |
| **Detect** | `inst_is_installed` / privilege-correct path helpers |
| **Online package** | **Absent by design** (bootstrap trim) |

### 2.8 Why This Requirement Exists (CIAO)

- **Principle 9 – Command types**: Type 0 local lifecycle only for place/remove.  
- **Principle 10 – Least privilege**: User bin without root when possible.  
- **Principle 3 – Anti-fragile**: Works offline / air-gapped.  
- **Principle 16 – Interactive**: Uninstall confirm contract.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution**: No network in install path.  
- **Intentional**: Local verbs only (`install`/`uninstall`).  
- **Anti-fragile**: Idempotent place/remove.  
- **Over-protect**: Do not reintroduce online lifecycle under new names.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Replace local `uninstall` with online `self-uninstall` as the primary remove verb.  
2. Require `SCRIPT_URL` for install.  
3. Make empty argv install-ensure while this product remains local-only (Type N owns empty argv).  
4. Delete user data or `/var/backup` content during uninstall.  
5. Fetch remote version inside `version`.

**Violating this rule is a critical install-mode regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | `install` copies ship unit to user or global bin without network |
| AC-2 | `uninstall` removes managed binary only with confirm/`--force` contract |
| AC-3 | `where-is-me` reports paths + installed flag |
| AC-4 | `version` is local-only |
| AC-5 | No Active online self-management requirement required for lifecycle |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-shell-cli-interface` | Command table + flags |
| `requirement-shell-cli-zero-arguments` | Type N empty argv |
| `requirement-project-folder` | Path defaults |
| `requirement-shell-idempotency` | Already installed / uninstalled |
| `requirement-bootstrap-chain` | Why online package is absent |
| `docs/requirements/index.md` | Registry |

---

## Design-time verification

| TP family / ID | Suite | Status |
|----------------|-------|--------|
| **TP-LC-01..08** | `tests/test_local_lifecycle.sh` | have |

**Matrix:** `reviews/requirement-test-matrix.md`  
**Map:** `reviews/test-plan.md`

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-03 | Active | Local-only lifecycle for folder-backup |

---

**Last Updated**: 2026-08-03  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
