**file**: docs/requirements/requirement-shell-cli-storage.md  
**Status**: Active (Version 1.2.0)  
**Area**: shell  
**Key**: `requirement-shell-cli-storage`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **project Single Source of Truth** for **shell CLI storage resolution** of dns-cli: volatile scratch and app-scoped cache path selection, per-user isolation, central resolver ownership, `app_main` wire, and about diagnostics.

Used for **install staging** (`mktemp` under the isolated root). Not a durable backup deposit. **Not** the application local vault (`requirement-application-local-vault` / `requirement-cloudflare-vault`).

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
| `install` | Stage the ship-unit copy under the isolated root when using `mktemp` |

### 2.5 Implementation Notes (this project)

| Item | Live value |
|------|------------|
| **Product / binary** | `dns-cli` |
| **Resolver** | `util_resolve_storage` in the ship unit |
| **Call sites** | `app_main`, `app_about`, install staging |
| **Not used for** | Durable `/var/backup`; **Cloudflare vault** (separate law) |

### 2.6 Why This Requirement Exists (CIAO)

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
3. Scatter hard-coded `/tmp/dns-cli` (or leftover `/tmp/cli-template`) roots outside the resolver.  
4. Leave the resolver dead with no call sites while claiming storage is product law.  
5. Echo a tier path without creating it.  
6. Treat `/var/backup` as a product storage path.  
7. Store API tokens or vault files under a scratch tier (`/dev/shm`, `/tmp`, XDG cache).

**Violating this rule is a critical storage isolation regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | Exactly one authoritative resolver creates and returns the root |
| AC-2 | Priority matches §2.2 |
| AC-3 | `app_main` sets `EFFECTIVE_STORAGE_DIR` / `TMPDIR` early |
| AC-4 | About JSON includes `effective_storage` |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-project-folder` | Path classes |
| `requirement-shell-cli-interface` | About fields |
| `requirement-shell-local-self-management` | Install staging |
| `requirement-cloudflare-vault` | Durable vault ≠ this resolver |
| `docs/requirements/index.md` | Registry |

---

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-03 | Active 1.0.0 | folder-backup staging |
| 2026-08-13 | Active 1.1.0 | cli-template: scratch only |
| 2026-08-16 | Active 1.2.0 | Explicit: not the Cloudflare vault; dns-cli identity |

---

**Last Updated**: 2026-08-16  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
