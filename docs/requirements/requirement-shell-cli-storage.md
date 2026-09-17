**file**: docs/requirements/requirement-shell-cli-storage.md  
**Status**: Active (Version 1.4.1 – storage = cache folder **and** persistency folder)  
**Area**: shell  
**Key**: `requirement-shell-cli-storage`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **project Single Source of Truth** for **shell CLI storage** of dns-cli. **Storage** means **two** classes:

| Class | Role | Live path |
|-------|------|-----------|
| **Cache folder** | Volatile scratch / temps / install staging | Preferred `/dev/shm/cache/cache-dns-cli`; fallback `${XDG_CACHE_HOME}/cache-dns-cli` |
| **Persistency folder** | This login’s durable app data (not secrets) | `${HOME}/.local/dns-cli` |

It owns path **shapes**, central resolvers, `app_main` wire, and about diagnostics for **both** classes.

Used for **install staging** (`mktemp` under the **cache** root). **Not** a durable backup deposit. **Not** the application local vault (`requirement-application-local-vault` / `requirement-cloudflare-vault`). **Not** install binary placement (`${HOME}/.local/bin`). **Not** Type 1 host deposit (`/var/dns-cli`).

### 1.1 Human-facing

**In one sentence:** dns-cli keeps a **cache folder** for throw-away files and a **persistency folder** at `~/.local/dns-cli` for this login’s durable app data — that is not the folder that holds API tokens.

| Box | Meaning | Example |
|-----|---------|---------|
| You | Temporary files during install; durable app data for this login | `mktemp` under cache; `${HOME}/.local/dns-cli` |
| Vault | Durable secrets | `requirement-application-local-vault` (`…/.local/vaults/dns-cli/`) |
| Not this | Host backup archive; install bin | No backup verb; `${HOME}/.local/bin` is `USER_BIN` |

| Includes | Excludes |
|----------|----------|
| Isolated **cache folder** + **persistency folder** | Token files; `/var/dns-cli`; `${HOME}/.local/bin` |
| About fields for cache preferred/fallback and persistency | `/tmp` as the production vault |

| Surface | What you open | What for |
|---------|---------------|----------|
| `dns-cli about` | Command | **Cache folder (preferred)/(fallback)** and **Persistence storage** |
| `dns-cli --json about` | Command | `cache_preferred` · `cache_fallback` · `persistence_storage` · `effective_storage` |
| Isolated cache root | Directory | Scratch / `mktemp` |
| Persistency folder | Directory | `${HOME}/.local/dns-cli` |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Ask where cache and persistency live | About names both folders. Cache is throw-away. Persistency is this login’s durable app data, not the vault. | `dns-cli about` · `dns-cli --json about` |

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Single resolver SSOT

1. **MUST** keep **one** authoritative **cache** resolver: **`util_resolve_storage`**.  
2. New code that needs a product scratch/cache **root** **MUST** call `util_resolve_storage` (or `mktemp` under a path it returned).  
3. Cache resolver **MUST** print the chosen directory path on **stdout** for `$(util_resolve_storage)` capture.  
4. **MUST** keep persistency helpers: **`util_persistent_storage_dir`** (print path) and **`util_resolve_persistent_storage`** (create-before-return).  
5. User-visible failure about storage **MUST** use Output SSOT.

### 2.2 Live cache resolve priority

First match that is available and writable:

| Order | Condition | Path shape |
|-------|-----------|------------|
| 1 | `/dev/shm` exists and is writable | `/dev/shm/cache/cache-dns-cli` |
| 2 | `/tmp` is writable | `/tmp/cache/cache-dns-cli` |
| 3 | Fallback | `STORAGE_DIR` (`${XDG_CACHE_HOME:-${HOME}/.cache}/cache-dns-cli`, env-overridable) |

Create `/dev/shm/cache` (prefer mode **1777**) so other logins can add sibling `cache-<app>` leaves. If the preferred leaf exists but is **not writable**, fall through.

**Create before return:** for the **chosen** tier, the resolver **MUST** `mkdir -p` the root, then print the path. If create fails → **MUST** fail closed. **MUST NOT** return a path without creating it.

**MUST NOT** use `/dev/shm/dns-cli` or `/dev/shm/dns-cli-${USERNAME}` as cache — those look like ram-drive **project** folders.

### 2.3 Isolation

1. Cache paths **MUST** include **app identity** (`cache-dns-cli` / `${APP_NAME}`). User identity on **fallback** is the home / XDG root.  
2. **MUST NOT** use a single shared world-writable directory for all users.  
3. Live product **MUST** export `TMPDIR=${EFFECTIVE_STORAGE_DIR}` so `mktemp` inherits the isolated **cache** root.

### 2.3.1 Persistency folder (normative)

1. Persistency **MUST** be **`${HOME}/.local/dns-cli`**. About human label: **Persistence storage**. JSON key: `persistence_storage`.  
2. Helper **`util_persistent_storage_dir`** **MUST** print that path. **`util_resolve_persistent_storage`** **MUST** `mkdir -p` it, confirm it is writable, then print it (fail closed).  
3. **MUST NOT** use `${HOME}/.local/bin` as persistency (that is `USER_BIN`).  
4. **MUST NOT** use Type 1 `/var/dns-cli` as persistency.  
5. **MUST NOT** use `${HOME}/.local/share/dns-cli` as this product’s persistency shape.  
6. **MUST NOT** use `${HOME}/.local/vaults/dns-cli/` as persistency (that is the vault).  
7. **MUST NOT** store scratch/temps in persistency when a cache root is available.

### 2.4 Wire and diagnostics

| Surface | Requirement |
|---------|-------------|
| `app_main` | Resolve once early: `EFFECTIVE_STORAGE_DIR=$(util_resolve_storage)`; `PERSISTENT_STORAGE_DIR=$(util_resolve_persistent_storage)`; export both plus `STORAGE_DIR`; **`TMPDIR=${EFFECTIVE_STORAGE_DIR}`** |
| `app_about` JSON | Include `cache_preferred`, `cache_fallback`, `persistence_storage`, and live chosen cache root `effective_storage`; **MUST NOT** include `CHECKSUM` |
| `app_about` human | **Cache folder (preferred):** `/dev/shm/cache/cache-dns-cli` · **Cache folder (fallback):** XDG `cache-dns-cli` · **Persistence storage:** `${HOME}/.local/dns-cli`. **MUST NOT** label cache lines Storage (effective)/(fallback) |
| `self-install` / `install` | Stage the ship-unit copy under the isolated **cache** root when using `mktemp` |

### 2.5 Implementation Notes (this project)

| Item | Live value |
|------|------------|
| **Product / binary** | `dns-cli` |
| **Cache resolver** | `util_resolve_storage` in the ship unit |
| **Preferred cache** | `/dev/shm/cache/cache-dns-cli` |
| **Fallback cache** | `${XDG_CACHE_HOME:-${HOME}/.cache}/cache-dns-cli` |
| **Persistency folder** | `${HOME}/.local/dns-cli` |
| **Call sites** | `app_main`, `app_about`, install staging |
| **Not used for** | Durable `/var/backup`; **Cloudflare vault** (`…/.local/vaults/dns-cli/`); install bin (`${HOME}/.local/bin`); F5 `/var/dns-cli` |

### 2.5a Example storage `util_*` (this product)

Class B return-via-stdout. Live code is `src/dns-cli`. Vault files **MUST NOT** use these resolvers.

```sh
# Isolated cache folder. Preferred /dev/shm/cache/cache-dns-cli.
# Fallback XDG cache-dns-cli. Create chosen leaf before echo. Fail closed.
util_preferred_cache_dir() {
    : "${APP_NAME:=dns-cli}"
    printf '%s' "/dev/shm/cache/cache-${APP_NAME}"
}

util_fallback_cache_dir() {
    : "${APP_NAME:=dns-cli}"
    : "${HOME:=/tmp}"
    : "${XDG_CACHE_HOME:=${HOME}/.cache}"
    printf '%s' "${XDG_CACHE_HOME}/cache-${APP_NAME}"
}

util_persistent_storage_dir() {
    : "${APP_NAME:=dns-cli}"
    : "${HOME:=/tmp}"
    printf '%s' "${HOME}/.local/${APP_NAME}"
}

util_resolve_persistent_storage() {
    : "${APP_NAME:=dns-cli}"
    : "${HOME:=/tmp}"
    _persist=$(util_persistent_storage_dir)
    case "${_persist}" in
        */.local/bin|*/.local/bin/)
            out_die "Persistency folder must not be the install bin directory ${_persist}"
            ;;
    esac
    if ! mkdir -p "${_persist}" 2>/dev/null || [ ! -w "${_persist}" ]; then
        out_die "Cannot create persistency folder ${_persist}"
    fi
    echo "${_persist}"
    unset _persist
    return 0
}

util_resolve_storage() {
    : "${APP_NAME:=dns-cli}"
    : "${HOME:=/tmp}"
    : "${XDG_CACHE_HOME:=${HOME}/.cache}"
    : "${STORAGE_DIR:=${XDG_CACHE_HOME}/cache-${APP_NAME}}"

    _storage_candidate=""
    if [ -d "/dev/shm" ] && [ -w "/dev/shm" ]; then
        mkdir -m 1777 -p /dev/shm/cache 2>/dev/null || mkdir -p /dev/shm/cache 2>/dev/null || true
        _pref="/dev/shm/cache/cache-${APP_NAME}"
        if mkdir -p "${_pref}" 2>/dev/null && [ -w "${_pref}" ]; then
            _storage_candidate="${_pref}"
        fi
    fi
    if [ -z "${_storage_candidate}" ] && [ -w "/tmp" ]; then
        mkdir -m 1777 -p /tmp/cache 2>/dev/null || mkdir -p /tmp/cache 2>/dev/null || true
        _tmpc="/tmp/cache/cache-${APP_NAME}"
        if mkdir -p "${_tmpc}" 2>/dev/null && [ -w "${_tmpc}" ]; then
            _storage_candidate="${_tmpc}"
        fi
    fi
    if [ -z "${_storage_candidate}" ]; then
        _storage_candidate="${STORAGE_DIR}"
        if ! mkdir -p "${_storage_candidate}" 2>/dev/null || [ ! -w "${_storage_candidate}" ]; then
            out_die "Cannot create cache folder ${_storage_candidate}"
        fi
    fi
    echo "${_storage_candidate}"
    unset _storage_candidate _pref _tmpc
    return 0
}

# Best-effort shell name for about. Prefer parent when this process is sh/the app.
util_get_current_shell() {
    local shell="unknown"
    shell=$(ps -p $$ -o comm= 2>/dev/null | tr -d '()' || echo "unknown")
    if [ "$shell" = "${APP_NAME}" ] || [ "$shell" = "sh" ] || \
       [ "$shell" = "dash" ] || [ "$shell" = "ash" ]; then
        local parent_pid
        parent_pid=$(ps -p $$ -o ppid= 2>/dev/null | tr -d ' ')
        if [ -n "$parent_pid" ]; then
            shell=$(ps -p "$parent_pid" -o comm= 2>/dev/null | tr -d '()' || echo "$shell")
        fi
    fi
    printf '%s' "$shell"
}
```

### 2.6 Why This Requirement Exists (CIAO)

- **Caution:** Multi-user isolation; do not mix cache with vault or install bin.  
- **Intentional:** Storage = **cache folder** **and** **persistency folder**; about says both.  
- **Anti-fragile:** Missing `/dev/shm` still works.  
- **Principle 11 – Temps:** Cleanup, not museum copies of staging.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- Volatile first, user cache last for **scratch**.  
- Persistency is `${HOME}/.local/dns-cli`, not under `bin`, vaults, or `/var`.  
- Isolation before convenience.  
- Create fail-closed in the resolver.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Remove app identity from the cache chain, or drop persistency from this requirement or from `about`.  
2. Replace the fallback chain with a shared world-writable dump.  
3. Scatter hard-coded `/tmp/dns-cli` (or leftover `/tmp/cli-template`) roots outside the resolver.  
4. Leave the resolver dead with no call sites while claiming storage is product law.  
5. Echo a tier path without creating it.  
6. Treat `/var/backup` or `/var/dns-cli` as a Type 0 persistency path.  
7. Store API tokens or vault files under a cache tier (`/dev/shm`, `/tmp`, XDG cache) or under persistency.  
8. Use `/dev/shm/dns-cli` or `/dev/shm/dns-cli-${USERNAME}` as the preferred cache. Preferred **MUST** be `/dev/shm/cache/cache-dns-cli`.  
9. Label about cache lines **Storage (effective)** / **Storage (fallback)** instead of **Cache folder (preferred)** / **Cache folder (fallback)**.  
10. Use `${HOME}/.local/bin` or `${HOME}/.local/vaults/dns-cli/` as persistency. Persistency **MUST** be `${HOME}/.local/dns-cli`.

**Violating this rule is a critical storage isolation regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | Exactly one authoritative cache resolver creates and returns the cache root |
| AC-2 | Cache priority matches §2.2 |
| AC-3 | `app_main` sets `EFFECTIVE_STORAGE_DIR` / `PERSISTENT_STORAGE_DIR` / `TMPDIR` early |
| AC-4 | About JSON includes `cache_preferred`, `cache_fallback`, `persistence_storage`, `effective_storage` |
| AC-5 | About human names **Cache folder (preferred)/(fallback)** and **Persistence storage** (persistency folder) |
| AC-6 | Persistency folder is `${HOME}/.local/dns-cli` and is created before about prints it |
| AC-7 | Storage `util_*` examples on this file (§2.5a) include cache **and** persistency helpers |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-project-folder` | Path classes |
| `requirement-shell-cli-interface` | About fields |
| `requirement-shell-local-self-management` | Install staging |
| `requirement-shell-temp-file-system` | Scratch **leaves** under the cache root |
| `requirement-application-local-vault` | Vault path ≠ persistency folder |
| `requirement-cloudflare-vault` | Durable vault ≠ this resolver |
| `docs/requirements/index.md` | Registry |

---

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-03 | Active 1.0.0 | folder-backup staging |
| 2026-08-13 | Active 1.1.0 | cli-template: scratch only |
| 2026-08-18 | Active 1.3.0 | Storage `util_*` examples (§2.5a); AC-5 |
| 2026-08-16 | Active 1.2.0 | Explicit: not the Cloudflare vault; dns-cli identity |
| 2026-09-17 | Active 1.4.1 | Stage row names **`self-install`** (alias `install`) |
| 2026-08-30 | Active 1.4.0 | Storage = **cache folder** **and** **persistency folder** `${HOME}/.local/dns-cli`; about Cache folder + Persistence storage |

---

## Design-time verification

| TP family / ID | Suite | Status |
|----------------|-------|--------|
| **TP-CLI-06** | `tests/test_cli.sh` | have — about JSON storage keys (incl. cache + persistency) |
| **TP-CLI-12** | `tests/test_cli.sh` | have — cache isolation; live cache dir exists |
| **TP-CLI-17** | `tests/test_cli.sh` | have — persistency folder `${HOME}/.local/dns-cli`; about labels |

**Matrix:** `reviews/requirement-test-matrix.md`  
**Map:** `reviews/test-plan.md`

---

**Last Updated**: 2026-08-30  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
