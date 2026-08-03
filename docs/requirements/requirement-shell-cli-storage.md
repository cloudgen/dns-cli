**file**: docs/requirements/requirement-shell-cli-storage.md  
**Status**: Active (Version 1.0.0)  
**Area**: shell  
**Key**: `requirement-shell-cli-storage`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **project Single Source of Truth** for **shell CLI storage resolution** of folder-backup: volatile scratch and app-scoped cache path selection, per-user isolation, central resolver ownership, `app_main` wire, and about diagnostics.

Used heavily for **tar.gz staging** before elevated deposit into `/var/backup/...`.

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Single resolver SSOT

1. **MUST** keep **one** authoritative storage-resolve helper: **`util_resolve_storage`**.  
2. New code that needs a product scratch/cache **root** **MUST** call `util_resolve_storage` (or `mktemp` under a path it returned).  
3. Resolver **MUST** print the chosen directory path on **stdout** for `$(util_resolve_storage)` capture.  
4. User-visible failure about storage **MUST** use Output SSOT.

### 2.2 Live resolve priority

First match that is available and writable:

| Order | Condition | Path shape |
|-------|-----------|------------|
| 1 | `/dev/shm` exists and is writable | `/dev/shm/${APP_NAME}-${USERNAME}` |
| 2 | `/tmp` is writable | `/tmp/${APP_NAME}-${USERNAME}` |
| 3 | Fallback | `STORAGE_DIR` (`${XDG_CACHE_HOME:-${HOME}/.cache}/${APP_NAME}-${USERNAME}`, env-overridable) |

**Create before return:** for the **chosen** tier, the resolver **MUST** `mkdir -p` the root, then print the path. If create fails → **MUST** fail closed. **MUST NOT** return a path without creating it.

### 2.3 Isolation

1. Paths **MUST** include **`${APP_NAME}`** and **`${USERNAME}`**.  
2. **MUST NOT** use a single shared world-writable directory for all users.  
3. Live product **MUST** export `TMPDIR=${EFFECTIVE_STORAGE_DIR}` so `mktemp` inherits the isolated root.

### 2.4 Wire and diagnostics

| Surface | Requirement |
|---------|-------------|
| `app_main` | Resolve once early: `EFFECTIVE_STORAGE_DIR=$(util_resolve_storage)`; export `EFFECTIVE_STORAGE_DIR`, `STORAGE_DIR`, `TMPDIR` |
| `app_about` | Include effective storage fields (human + JSON) |
| Domain `backup` | Stage archives under effective storage; clean up on exit |

### 2.5 Staging rules for backups

1. Create archives in a stage directory under `EFFECTIVE_STORAGE_DIR` (e.g. `.../stage/`).  
2. Use restrictive modes appropriate for user data (prefer not world-readable when content may be sensitive).  
3. **MUST** remove staging artifacts via `trap` on success and failure after deposit attempt completes (or fails closed with path logged).  
4. Durable deposit path `/var/backup/...` is **not** the storage resolver’s job (privilege + domain law).

### 2.6 Implementation Notes (this project)

| Item | Live value |
|------|------------|
| **Product / binary** | `folder-backup` |
| **Resolver** | `util_resolve_storage` in `src/folder-backup` |
| **Call sites** | `app_main`, `app_about`, domain staging |
| **Not used for** | Durable `/var/backup` deposit root |

### 2.7 Why This Requirement Exists (CIAO)

- **Caution:** Multi-user isolation.  
- **Intentional:** One resolver.  
- **Anti-fragile:** Missing `/dev/shm` still works.  
- **Principle 11 – Temps:** Cleanup, not museum copies of staging.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- Volatile first, user cache last for scratch.  
- Isolation before convenience.  
- Create fail-closed in the resolver.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Remove `${APP_NAME}` / `${USERNAME}` isolation.  
2. Replace the fallback chain with a shared world-writable dump.  
3. Scatter hard-coded `/tmp/folder-backup` roots outside the resolver.  
4. Leave the resolver dead with no call sites while claiming storage is product law.  
5. Echo a tier path without creating it.  
6. Stage durable deposits only in world-writable shared paths by design.

**Violating this rule is a critical storage isolation regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | Exactly one authoritative resolver creates and returns the root |
| AC-2 | Priority matches §2.2 |
| AC-3 | `app_main` sets `EFFECTIVE_STORAGE_DIR` / `TMPDIR` early |
| AC-4 | Backup staging uses the resolver root and cleans up |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-project-folder` | Path classes |
| `requirement-domain-folder-backup` | Staging use |
| `requirement-shell-cli-interface` | About fields |
| `docs/requirements/index.md` | Registry |

---

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-03 | Active | Storage resolve for folder-backup staging |

---

**Last Updated**: 2026-08-03  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
