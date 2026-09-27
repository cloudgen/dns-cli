**file**: docs/requirements/requirement-shell-cli-storage.md  
**Status**: Active (Version 1.6.0 – per-login per-process cache folder)  
**Area**: shell  
**Key**: `requirement-shell-cli-storage`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **project Single Source of Truth** for **shell CLI storage** of dns-cli. **Storage** means **two** classes:

| Class | Role | Live path |
|-------|------|-----------|
| **Cache folder** | Volatile scratch / temps / install staging | This host’s chain in §2.2. Volatile leaf `cache-${APP_NAME}-${login}-$$`. Home leaf `cache-${APP_NAME}-$$` |
| **Persistency folder** | This login’s durable app data (not secrets) | `${HOME}/.local/${APP_NAME}` (no login suffix, no `$$`) |

It owns path **shapes**, central resolvers, `app_main` wire, and about diagnostics for **both** classes.

Used for **install staging** (`mktemp` under the **cache** root). **Not** a durable backup deposit. **Not** the application local vault (`requirement-application-local-vault` / `requirement-cloudflare-vault`). **Not** install binary placement (`${HOME}/.local/bin`). **Not** Type 1 host deposit (`/var/dns-cli`).

`${login}` is this login (`id -un`), one path segment. `$$` is **this process id**. **MUST NOT** hardcode an app name, a login name, or a process id in a live path.

The preferred cache is **not** a ram-drive **project** tree (`/dev/shm/${APP_NAME}` or `/dev/shm/${APP_NAME}-${login}`). On Linux it lives under `/dev/shm/cache/`. On Git Bash and Mac the preferred leaf lives under `/tmp/cache/`.

### 1.1 Human-facing

**In one sentence:** dns-cli keeps a **cache folder** for throw-away files (one directory per login and per process) and a **persistency folder** at `~/.local/dns-cli` for this login’s durable app data — that is not the folder that holds API tokens.

| Box | Meaning | Example |
|-----|---------|---------|
| You | Temporary files during install; durable app data for this login | `mktemp` under cache; `${HOME}/.local/${APP_NAME}` |
| Vault | Durable secrets | `requirement-application-local-vault` (`…/.local/vaults/dns-cli/`) |
| Not this | Host backup archive; install bin | No backup verb; `${HOME}/.local/bin` is `USER_BIN` |

| Includes | Excludes |
|----------|----------|
| Isolated **cache folder** + **persistency folder** | Token files; `/var/dns-cli`; `${HOME}/.local/bin` |
| About fields for the cache folder in use, preferred, 1st fallback, 2nd fallback when this host has one, and persistency | A warning because a higher cache folder was not used |

| Surface | What you open | What for |
|---------|---------------|----------|
| `dns-cli about` | Command | **Cache folder used**, **Cache folder (preferred)**, **Cache folder (1st fallback)**, **Cache folder (2nd fallback)** when this host has one, and **Persistence storage** |
| `dns-cli --json about` | Command | `cache_used` · `cache_preferred` · `cache_fallback` · `cache_fallback_2` · `persistence_storage` · `effective_storage` |
| Isolated cache root | Directory | Scratch / `mktemp` |
| Persistency folder | Directory | `${HOME}/.local/${APP_NAME}` |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Ask where cache and persistency live | About names the folder in use and each fallback this host has. A skipped tier prints nothing. Persistency is this login’s durable app data, not the vault. | `dns-cli about` · `dns-cli --json about` |

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Single resolver SSOT

1. **MUST** keep **one** authoritative **cache** resolver: **`util_resolve_storage`**.  
2. New code that needs a product scratch/cache **root** **MUST** call `util_resolve_storage` (or `util_mktemp` / `mktemp` under a path it returned).  
3. Cache resolver **MUST** print the chosen directory path on **stdout** for `$(util_resolve_storage)` capture.  
4. **MUST** keep persistency helpers: **`util_persistent_storage_dir`** (print path), **`util_ensure_persistent_storage`** (mkdir + `out_die` in this shell), and **`util_resolve_persistent_storage`** (ensure then print).  
5. User-visible failure about storage **MUST** use Output SSOT.

### 2.2 Live cache resolve priority

Walk **this host’s** chain in order. First directory that can be created **and** is writable wins. **MUST NOT** replace the chain with one shared `cache-${APP_NAME}` leaf, with `XDG_CACHE_HOME`, or with `STORAGE_DIR`.

Volatile leaf (shared parents `/dev/shm/cache` and `/tmp/cache`): `cache-${APP_NAME}-${login}-$$`.  
Home leaf (already this login): `cache-${APP_NAME}-$$`.

| Host | Preferred | 1st fallback | 2nd fallback |
|------|-----------|--------------|--------------|
| Linux (also Termux, and any host that is not Git Bash and not Mac) | `/dev/shm/cache/cache-${APP_NAME}-${login}-$$` | `/tmp/cache/cache-${APP_NAME}-${login}-$$` | `${HOME}/.cache/cache-${APP_NAME}-$$` |
| Git Bash (`MSYSTEM`, or `uname -s` `MINGW*` / `MSYS*`) | `/tmp/cache/cache-${APP_NAME}-${login}-$$` | `${HOME}/AppData/Local/Temp/cache-${APP_NAME}-$$` | none |
| Mac (`uname -s` `Darwin`) | `/tmp/cache/cache-${APP_NAME}-${login}-$$` | `${HOME}/Library/Caches/cache-${APP_NAME}-$$` | `${HOME}/cache/cache-${APP_NAME}-$$` |

| Order label | Helper |
|-------------|--------|
| Cache folder (preferred) | `util_preferred_cache_dir` |
| Cache folder (1st fallback) | `util_fallback_cache_dir` |
| Cache folder (2nd fallback) | `util_fallback2_cache_dir` (empty on Git Bash) |

On Termux the chosen folder is scratch only (it may be `noexec`). Termux uses the Linux chain. **MUST NOT** `exec` a binary from the cache folder.

**Parent:** for `/dev/shm/cache` and `/tmp/cache` the resolver **MUST** create that parent (prefer mode **1777** when creating it) so each login can add its own leaf. **MUST NOT** `chmod` a parent this login did not create. The **leaf** **MUST** be mode **0700**.

**Create before return:** for the **chosen** leaf, the resolver **MUST** create it, confirm it is writable, then print the path. Failure of **one** tier **MUST NOT** die and **MUST NOT** print an alert, a warning, or an error. Failure of **every** tier for this host **MUST** fail closed. **MUST NOT** return a path without creating it.

**MUST NOT** use `/dev/shm/${APP_NAME}` or `/dev/shm/${APP_NAME}-${login}` as cache — those look like ram-drive **project** folders. The login belongs in the leaf **under** `cache/`.

### 2.3 Isolation

1. Cache leaves **MUST** include **app identity** (`cache-${APP_NAME}`).  
2. Volatile leaves (`/dev/shm/cache` and `/tmp/cache`) **MUST** be `cache-${APP_NAME}-${login}-$$`. Home leaves **MUST** be `cache-${APP_NAME}-$$` (no login segment). Isolation is the login segment plus this process id.  
3. **MUST NOT** use a single shared world-writable directory for all logins or all processes.  
4. Live product **MUST** export `TMPDIR=${EFFECTIVE_STORAGE_DIR}` so `mktemp` inherits the isolated **cache** root.  
5. New scratch files **MUST** be created via **`util_mktemp`** (or `mktemp` under a path `util_resolve_storage` returned).  
6. The **cache directory** name includes `$$`. Scratch **files** inside it **MUST NOT** use a predictable `$$` file name (forbidden: `/tmp/${APP_NAME}.$$`, `${EFFECTIVE_STORAGE_DIR}/${APP_NAME}.$$`).

### 2.3.1 Persistency folder (normative)

1. Persistency **MUST** be **`${HOME}/.local/${APP_NAME}`**. No login suffix. No `$$`. About human label: **Persistence storage**. JSON key: `persistence_storage`. Persistence is **not** a cache tier.  
2. Helper **`util_persistent_storage_dir`** **MUST** print that path. **`util_ensure_persistent_storage`** **MUST** `mkdir -p` it, confirm it is writable, then set `PERSISTENT_STORAGE_DIR` in **this** shell (fail closed with `out_die`). Callers **MUST NOT** wrap that ensure in `$(…)`. **`util_resolve_persistent_storage`** **MAY** print the path after ensure (class B) for tests.  
3. **MUST NOT** use `${HOME}/.local/bin` as persistency (that is `USER_BIN`).  
4. **MUST NOT** use Type 1 `/var/dns-cli` as persistency.  
5. **MUST NOT** use `${HOME}/.local/share/${APP_NAME}` as this product’s persistency shape.  
6. **MUST NOT** use `${HOME}/.local/vaults/dns-cli/` as persistency (that is the vault).  
7. **MUST NOT** store scratch/temps in persistency when a cache root is available.

### 2.4 Wire and diagnostics

| Surface | Requirement |
|---------|-------------|
| `app_main` | Resolve once early: `EFFECTIVE_STORAGE_DIR=$(util_resolve_storage)`; `STORAGE_DIR` is the 1st fallback path; **`util_ensure_persistent_storage`** (not `$(…)` around `out_die`); export both plus `STORAGE_DIR`; **`TMPDIR=${EFFECTIVE_STORAGE_DIR}`** |
| `app_about` JSON | Include `cache_used`, `cache_preferred`, `cache_fallback` (1st), `cache_fallback_2` (2nd, empty string when this host has none), `persistence_storage`, and the live chosen cache root `effective_storage` (same value as `cache_used`). `storage_dir` is the 1st fallback. **MUST NOT** include `CHECKSUM` |
| `app_about` human | **MUST** print **Cache folder used**, **Cache folder (preferred)**, **Cache folder (1st fallback)**, and **Cache folder (2nd fallback)** only when this host has a 2nd fallback, then **Persistence storage**. **MUST NOT** label cache lines **Storage (effective)** or **Storage (fallback)**. **MUST NOT** warn or error when the used directory is a fallback |
| `self-install` / `install` | Stage the ship-unit copy under the isolated **cache** root when using `mktemp` |

Linux `about` lines (`$$` is this process, not a fixed number). **Cache folder used** is the tier that was created. When the preferred tier is the one used, the used line and the preferred line are the same path. When a fallback is used, the used line is that fallback path and the preferred line still shows the preferred path. Neither case prints a warning.

```
[INFO] Cache folder used: /dev/shm/cache/cache-${APP_NAME}-${login}-$$
[INFO] Cache folder (preferred): /dev/shm/cache/cache-${APP_NAME}-${login}-$$
[INFO] Cache folder (1st fallback): /tmp/cache/cache-${APP_NAME}-${login}-$$
[INFO] Cache folder (2nd fallback): ${HOME}/.cache/cache-${APP_NAME}-$$
[INFO] Persistence storage: ${HOME}/.local/${APP_NAME}
```

Git Bash omits the 2nd fallback line. Its 1st fallback is `${HOME}/AppData/Local/Temp/cache-${APP_NAME}-$$`. Mac prints preferred under `/tmp/cache/`, 1st fallback under `${HOME}/Library/Caches/`, and 2nd fallback under `${HOME}/cache/`.

### 2.5 Implementation Notes (this project)

| Item | Live value |
|------|------------|
| **Product / binary** | `dns-cli` |
| **Cache resolver** | `util_resolve_storage` in the ship unit |
| **Linux preferred / 1st / 2nd** | `/dev/shm/cache/cache-${APP_NAME}-${login}-$$` then `/tmp/cache/cache-${APP_NAME}-${login}-$$` then `${HOME}/.cache/cache-${APP_NAME}-$$` |
| **Git Bash** | `/tmp/cache/cache-${APP_NAME}-${login}-$$` then `${HOME}/AppData/Local/Temp/cache-${APP_NAME}-$$` |
| **Mac** | `/tmp/cache/cache-${APP_NAME}-${login}-$$` then `${HOME}/Library/Caches/cache-${APP_NAME}-$$` then `${HOME}/cache/cache-${APP_NAME}-$$` |
| **Persistency folder** | `${HOME}/.local/dns-cli` |
| **Call sites** | `app_main`, `app_about`, install staging |
| **Not used for** | Durable `/var/backup`; **Cloudflare vault** (`…/.local/vaults/dns-cli/`); install bin (`${HOME}/.local/bin`); F5 `/var/dns-cli` |
| **Test-purpose** | `DNS_CLI_CACHE_HOST=linux\|gitbash\|mac` selects the chain. `DNS_CLI_CACHE_SKIP=preferred` skips tier 1 with no message |

### 2.5a Example storage `util_*` (this product)

Class B return-via-stdout. Live code is `src/dns-cli`. Vault files **MUST NOT** use these resolvers.

```sh
util_cache_host_kind() {
    case "${DNS_CLI_CACHE_HOST:-}" in
        linux|gitbash|mac) printf '%s' "${DNS_CLI_CACHE_HOST}"; return 0 ;;
    esac
    if [ -n "${MSYSTEM:-}" ]; then
        printf '%s' "gitbash"
        return 0
    fi
    case "$(uname -s 2>/dev/null)" in
        MINGW*|MSYS*) printf '%s' "gitbash" ;;
        Darwin) printf '%s' "mac" ;;
        *) printf '%s' "linux" ;;
    esac
}

util_cache_login() {
    _clogin="${USERNAME:-unknown}"
    case "${_clogin}" in
        *[!A-Za-z0-9._-]*)
            _clogin=$(printf '%s' "${_clogin}" | tr -c 'A-Za-z0-9._-' '_')
            ;;
    esac
    [ -n "${_clogin}" ] || _clogin="unknown"
    printf '%s' "${_clogin}"
}

util_cache_volatile_leaf() {
    : "${APP_NAME:=dns-cli}"
    printf '%s' "cache-${APP_NAME}-$(util_cache_login)-$$"
}

util_cache_home_leaf() {
    : "${APP_NAME:=dns-cli}"
    printf '%s' "cache-${APP_NAME}-$$"
}

util_preferred_cache_dir() {
    : "${APP_NAME:=dns-cli}"
    : "${HOME:=/tmp}"
    case "$(util_cache_host_kind)" in
        gitbash|mac) printf '%s' "/tmp/cache/$(util_cache_volatile_leaf)" ;;
        *) printf '%s' "/dev/shm/cache/$(util_cache_volatile_leaf)" ;;
    esac
}

util_fallback_cache_dir() {
    : "${APP_NAME:=dns-cli}"
    : "${HOME:=/tmp}"
    case "$(util_cache_host_kind)" in
        gitbash) printf '%s' "${HOME}/AppData/Local/Temp/$(util_cache_home_leaf)" ;;
        mac) printf '%s' "${HOME}/Library/Caches/$(util_cache_home_leaf)" ;;
        *) printf '%s' "/tmp/cache/$(util_cache_volatile_leaf)" ;;
    esac
}

util_fallback2_cache_dir() {
    : "${APP_NAME:=dns-cli}"
    : "${HOME:=/tmp}"
    case "$(util_cache_host_kind)" in
        gitbash) printf '%s' "" ;;
        mac) printf '%s' "${HOME}/cache/$(util_cache_home_leaf)" ;;
        *) printf '%s' "${HOME}/.cache/$(util_cache_home_leaf)" ;;
    esac
}

util_cache_try_dir() {
    _cdir="${1:-}"
    [ -n "${_cdir}" ] || return 1
    _cparent=$(dirname "${_cdir}")
    case "${_cparent}" in
        /dev/shm/cache|/tmp/cache)
            mkdir -m 1777 -p "${_cparent}" 2>/dev/null || mkdir -p "${_cparent}" 2>/dev/null || return 1
            ;;
        *)
            mkdir -p "${_cparent}" 2>/dev/null || return 1
            ;;
    esac
    mkdir -m 0700 -p "${_cdir}" 2>/dev/null || mkdir -p "${_cdir}" 2>/dev/null || return 1
    [ -d "${_cdir}" ] && [ -w "${_cdir}" ] || return 1
    return 0
}

util_persistent_storage_dir() {
    : "${APP_NAME:=dns-cli}"
    : "${HOME:=/tmp}"
    printf '%s' "${HOME}/.local/${APP_NAME}"
}

util_ensure_persistent_storage() {
    : "${APP_NAME:=dns-cli}"
    : "${HOME:=/tmp}"
    _persist=$(util_persistent_storage_dir)
    case "${_persist}" in
        */.local/bin|*/.local/bin/)
            out_die "Persistency folder must not be the install bin directory ${_persist}"
            ;;
    esac
    if ! mkdir -p "${_persist}" 2>/dev/null || [ ! -w "${_persist}" ]; then
        _parent=$(dirname "${_persist}")
        _who=$(id -un 2>/dev/null || echo "this-login")
        out_die "Cannot create persistency folder ${_persist}. This login cannot write ${_parent}. Next: as root, chown ${_who} ${_who} ${_parent}"
    fi
    PERSISTENT_STORAGE_DIR="${_persist}"
    export PERSISTENT_STORAGE_DIR
    unset _persist _parent _who
    return 0
}

util_resolve_persistent_storage() {
    util_ensure_persistent_storage
    echo "${PERSISTENT_STORAGE_DIR}"
    return 0
}

util_resolve_storage() {
    : "${APP_NAME:=dns-cli}"
    : "${HOME:=/tmp}"
    : "${USERNAME:=unknown}"
    _storage_candidate=""
    if [ "${DNS_CLI_CACHE_SKIP:-}" != "preferred" ]; then
        _pref=$(util_preferred_cache_dir)
        if util_cache_try_dir "${_pref}"; then
            _storage_candidate="${_pref}"
        fi
    fi
    if [ -z "${_storage_candidate}" ]; then
        _fb1=$(util_fallback_cache_dir)
        if util_cache_try_dir "${_fb1}"; then
            _storage_candidate="${_fb1}"
        fi
    fi
    if [ -z "${_storage_candidate}" ]; then
        _fb2=$(util_fallback2_cache_dir)
        if [ -n "${_fb2}" ] && util_cache_try_dir "${_fb2}"; then
            _storage_candidate="${_fb2}"
        fi
    fi
    if [ -z "${_storage_candidate}" ]; then
        out_die "Cannot create cache folder"
    fi
    echo "${_storage_candidate}"
    unset _storage_candidate _pref _fb1 _fb2
    return 0
}

util_mktemp() {
    : "${APP_NAME:=dns-cli}"
    : "${EFFECTIVE_STORAGE_DIR:=}"
    _suffix="${1:-tmp}"
    _dollar='$'
    case "${_suffix}" in
        *"${_dollar}${_dollar}"*)
            out_die "util_mktemp: refuse predictable \$\$ name template"
            ;;
    esac
    if [ -z "${EFFECTIVE_STORAGE_DIR}" ]; then
        EFFECTIVE_STORAGE_DIR=$(util_resolve_storage)
        export EFFECTIVE_STORAGE_DIR
    fi
    mktemp "${EFFECTIVE_STORAGE_DIR}/${APP_NAME}.${_suffix}.XXXXXX" \
        || mktemp
}
```

### 2.6 Why This Requirement Exists (CIAO)

- **Caution:** Two logins must not share one scratch directory. Two processes of one login must not share one scratch directory. Do not mix cache with vault or install bin.  
- **Intentional:** Storage = **cache folder** **and** **persistency folder**; about says both.  
- **Anti-fragile:** A missing higher tier still works, and the miss is silent.  
- **Principle 11 – Temps:** Cleanup, not museum copies of staging. The directory name may include `$$`. The file name stays `mktemp`.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- Volatile first, this login’s cache home last for **scratch**.  
- Persistency is `${HOME}/.local/${APP_NAME}`, not under `bin`, vaults, or `/var`.  
- Isolation before convenience.  
- Create fail-closed in the resolver only when every tier failed.  
- Cache path family is distinct from ram-drive **project** folders.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Remove app identity from the cache chain, or drop persistency from this requirement or from `about`.  
2. Replace the fallback chain with a shared world-writable dump, or with one `cache-${APP_NAME}` leaf shared by every login or every process.  
3. Scatter hard-coded `/tmp/dns-cli` (or leftover `/tmp/cli-template`) roots outside the resolver.  
4. Leave the resolver dead with no call sites while claiming storage is product law.  
5. Echo a tier path without creating it.  
6. Treat `/var/backup` or `/var/dns-cli` as a Type 0 persistency path.  
7. Store API tokens or vault files under a cache tier or under persistency.  
8. Use `/dev/shm/${APP_NAME}` or `/dev/shm/${APP_NAME}-${login}` as the preferred cache.  
9. Label about cache lines **Storage (effective)** / **Storage (fallback)**. The labels are **Cache folder used**, **Cache folder (preferred)**, **Cache folder (1st fallback)**, and **Cache folder (2nd fallback)** when this host has one.  
10. Use `${HOME}/.local/bin` or `${HOME}/.local/vaults/dns-cli/` as persistency. Persistency **MUST** be `${HOME}/.local/${APP_NAME}` with no login suffix and no `$$`.  
11. Drop `${login}` or `$$` from a volatile cache leaf, or put the login on a home leaf.  
12. `chmod` the shared `cache` parent when this login did not create it.  
13. Print an alert, warning, or error because a higher cache folder was not used. An error is only when every tier for this host failed.  
14. Use a predictable `$$` scratch **file** name. The cache **directory** itself includes `$$`. Scratch files stay `mktemp` names.  
15. Hardcode an app name, a login name, or a process id in place of `${APP_NAME}`, `${login}`, or `$$`.

**Violating this rule is a critical storage isolation regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | Exactly one authoritative cache resolver creates and returns the cache root |
| AC-2 | Linux preferred leaf is `/dev/shm/cache/cache-${APP_NAME}-${login}-$$` when that directory is usable. Git Bash and Mac preferred leaf is `/tmp/cache/cache-${APP_NAME}-${login}-$$` |
| AC-3 | `app_main` sets `EFFECTIVE_STORAGE_DIR` / `PERSISTENT_STORAGE_DIR` / `TMPDIR` early. Persistency ensure runs in this shell |
| AC-4 | About human prints Cache folder used, preferred, 1st fallback, 2nd fallback when present, and Persistence storage. JSON has `cache_used` / `cache_preferred` / `cache_fallback` / `cache_fallback_2` / `persistence_storage` / `effective_storage` |
| AC-5 | Scratch files use `util_mktemp` / `mktemp` `XXXXXX`. The cache directory name may include `$$`. Scratch file names must not |
| AC-6 | Persistency folder is `${HOME}/.local/${APP_NAME}` and is created before about prints it |
| AC-7 | Storage `util_*` examples on this file (§2.5a) include cache **and** persistency helpers |
| AC-8 | Live cache path is not `/dev/shm/${APP_NAME}` or `/dev/shm/${APP_NAME}-${login}` |
| AC-9 | Skipping a cache tier prints no warning and no error. Git Bash has no 2nd fallback. Mac 2nd fallback is `${HOME}/cache/cache-${APP_NAME}-$$`. Chosen leaf mode is `0700` |

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
| 2026-09-27 | Active 1.6.0 | Per-login per-process leaves. Linux shm → tmp → `${HOME}/.cache`. Git Bash tmp → AppData Local Temp. Mac tmp → Library/Caches → `${HOME}/cache`. Silent tier miss. `about` prints used / preferred / 1st / 2nd. **TP-CLI-06** · **TP-CLI-12** · **TP-CLI-17** |
| 2026-09-23 | Active 1.5.0 | Shared-mount leaves `cache-${APP_NAME}-${USERNAME}`; chmod `1777` only when this login creates the bucket; skipped tier is silent. **TP-CLI-17** |
| 2026-09-17 | Active 1.4.2 | Persistency ensure in this shell; **TP-CLI-26** fail-close parent (no menu after ERROR) |
| 2026-09-17 | Active 1.4.1 | Stage row names **`self-install`** (alias `install`) |
| 2026-08-30 | Active 1.4.0 | Storage = **cache folder** **and** **persistency folder** `${HOME}/.local/dns-cli`; about Cache folder + Persistence storage |

---

## Design-time verification

| TP family / ID | Suite | Status |
|----------------|-------|--------|
| **TP-CLI-06** | `tests/test_cli.sh` | have — about JSON `cache_used` / `cache_preferred` / `cache_fallback` / `cache_fallback_2` / persistency |
| **TP-CLI-12** | `tests/test_cli.sh` | have — Linux, Git Bash, and Mac chains; silent skip; leaf mode `0700`; live dir exists |
| **TP-CLI-17** | `tests/test_cli.sh` | have — persistency folder `${HOME}/.local/dns-cli`; about labels used / preferred / 1st / 2nd |
| **TP-CLI-26** | `tests/test_cli.sh` | have — persistency mkdir fail exits the parent (no version after ERROR) |

**Matrix:** `reviews/requirement-test-matrix.md`  
**Map:** `reviews/test-plan.md`

---

**Last Updated**: 2026-09-27  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
