**file**: docs/requirements/requirement-shell-modular-function-design.md  
**Status**: Active (Version 2.3.0)  
**Area**: shell  
**Key**: `requirement-shell-modular-function-design`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **project Single Source of Truth** for **modular function organization** of the dns-cli POSIX shell CLI.

**Core idea:** Modularity is achieved through **clear function boundaries, consistent prefixes, and full CIAO documentation** — **not** by splitting the installable CLI into multiple shipped files.

Ship unit remains a **single executable** at `src/dns-cli`.

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Overall architecture

| Rule | Meaning |
|------|---------|
| **Single executable** | One primary script file for the installable CLI |
| **Logical modules** | Functions grouped by **strict prefixes** |
| **Documented units** | Public helpers carry defensive headers and safe defaults |
| **Requirements extract policy** | Durable rules live in `requirement-*.md`; code comments encode intent and Protection Zones |

### 2.2 Official function prefix table

**All functions MUST use a defined prefix.** Bare names (`main`, `install`, `help`) as function names are forbidden.

| Prefix | Category | Purpose | Example functions |
|--------|----------|---------|-------------------|
| `out_` | Output system | All user-facing and machine-readable output | `out_text`, `out_info`, `out_json`, `out_die` |
| `inst_` | Installation lifecycle | Local install/uninstall detect and place/remove | `inst_local_install`, `inst_local_uninstall`, `inst_is_installed` |
| `util_` | General utilities | Path resolve, storage, CIAO pre-change `.bak` helper | `util_resolve_storage`, `util_resolve_running_path`, `util_get_install_bin_path`, `util_get_current_shell`, `util_json_escape`, `util_backup` — **examples:** §2.2a |
| `app_` | Cross-cutting CLI surface | Entry, dispatch, about/help/version/where-is-me | `app_main`, `app_about`, `app_help`, `app_version`, `app_where_is_me` |
| `path_` | Shell PATH & environment | Optional PATH ensure after user install | `path_add_shell` |
| `prompt_` | Interactive prompts | TTY-safe confirmations and secrets | `prompt_yes_no`, `prompt_secret` |
| `cf_` | Cloudflare domain | Vault, DNS, IP lookup, API, JSON extract | `cf_vault_*`, `cf_dns_*`, `cf_ip_*`, `cf_api_*`, `cf_json_*` |
| `lpu_` | LPU / privilege | `setup`, `remove-lpu`, `print-sudoers`, generate/submit sudoer JSON | `lpu_setup`, `lpu_remove`, `lpu_print_sudoers`, `lpu_generate_sudoer_request`, `lpu_submit_sudoer_request` |

**Notes:**

- Domain prefix **`cf_`** is required for Cloudflare ops. LPU prefix **`lpu_`** is required for `setup` / `remove-lpu` / `print-sudoers` / generate+submit. Do not invent `hm_*` / `fb_*`.  
- **Do not** put generic about/help/main under a domain prefix.  
- Parent `fb_*` **MUST NOT** be reintroduced.  
- Online-only prefixes from grandparent (`ver_check` remote network path, download install family) **MUST NOT** be reintroduced unless product mode changes.  
- `util_backup` is the CIAO pre-change sibling `.bak` helper — **not** a folder-archive backup verb.

### 2.2a `util_*` example ownership (this product)

A name in §2.2 is **not** the example. Every **shipped** `util_*` **MUST** have a fenced `sh` example on its topic-owner REQ. Live code remains `src/dns-cli`.

| Function | Topic-owner REQ | Shipped |
|----------|-----------------|---------|
| `util_json_escape` | `requirement-shell-output-requirements` §2.2a | yes |
| `util_resolve_running_path` | `requirement-shell-local-self-management` §2.7a | yes |
| `util_get_install_bin_path` | `requirement-shell-local-self-management` §2.7a | yes |
| `util_resolve_storage` | `requirement-shell-cli-storage` §2.5a | yes |
| `util_get_current_shell` | `requirement-shell-cli-storage` §2.5a | yes |
| `util_backup` | **this file** §2.2b (no `requirement-*-backup-strategy` on this product) | yes |
| `util_sha256_file` | **`LM-ONLINE-INSTALL`** only | **no** — local-only; do not specialize |
| `util_fetch_remote_version` | **`LM-ONLINE-INSTALL`** only | **no** — local-only; do not specialize |

### 2.2b Example `util_backup` (this product)

Vault / secret files **MUST NOT** call this helper (`requirement-cloudflare-vault`).

```sh
# Dated sibling backup before mutate. Name: <target>.YYYYMMDD-N.bak
# MUST NOT use on vault/secret files. Refuse /, $HOME, empty.
util_backup() {
    : "${APP_NAME:=dns-cli}"
    : "${HOME:=/tmp}"
    : "${JSON:=0}"
    : "${QUIET:=0}"

    local target="${1-}"
    local reason="${2:-pre-change}"

    if [ -z "$target" ] || [ "$target" = "/" ] || [ "$target" = "${HOME}" ]; then
        out_warn "Refusing to backup dangerous path: $target"
        return 1
    fi

    local timestamp counter backup_path
    timestamp=$(date +%Y%m%d)
    counter=1
    backup_path="${target}.${timestamp}-${counter}.bak"
    while [ -e "$backup_path" ]; do
        counter=$((counter + 1))
        backup_path="${target}.${timestamp}-${counter}.bak"
    done

    if [ -d "$target" ]; then
        cp -a "$target" "$backup_path" 2>/dev/null && \
            out_info "Backup created: $backup_path (reason: $reason)" || \
            out_warn "Failed to create backup of directory $target"
    elif [ -f "$target" ]; then
        cp "$target" "$backup_path" 2>/dev/null && \
            out_info "Backup created: $backup_path (reason: $reason)" || \
            out_warn "Failed to create backup of file $target"
    fi
}
```

### 2.3 Function documentation standards

Every non-trivial function **MUST** include a defensive header with:

- One-line purpose  
- **GENERAL PURPOSE** paragraph  
- CIAO principles applied (as relevant)  
- Protection / DO NOT SIMPLIFY note for critical helpers  
- Last reviewed date when modified  

Product-source `ALIGNMENT` / “see” comments **MUST** cite only live `docs/requirements/requirement-*.md` paths registered in `index.md`.

### 2.4 Protection Zones

Critical sections (output SSOT, install place/remove, storage resolve) **MUST** remain CIAO-Lite Protection Zones and **MUST NOT** be simplified away without explicit user redesign order.

### 2.5 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **Ship unit (target)** | `src/dns-cli` |
| **Domain prefix** | **`cf_`** — Implemented for v1 vault/DNS |
| **LPU prefix** | **`lpu_`** — Implemented (`lpu_setup`, `lpu_remove`, `lpu_print_sudoers`, `lpu_generate_sudoer_request`, `lpu_submit_sudoer_request`) |
| **New prompt** | `prompt_secret` (no echo) — Implemented |
| **Bootstrap role** | Hop 1; inherit Type 0 prefixes; add `cf_` + `lpu_` |
| **Multi-file authoring** | Optional later only if pack still yields one installable artifact and this requirement is updated |

### 2.6 Why This Requirement Exists (CIAO)

- **Principle 2 – Intentional**: Prefixes encode ownership.  
- **Principle 6 – Single Point of Entry**: `app_main` stays the dispatcher.  
- **Principle 7 – Reusable function protection**: DO NOT MODIFY markers on critical helpers.  
- **Principle 20 – Protect against AI & human modification**: Visible zones.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- Single file; logical modules via prefixes.  
- Domain prefix is `cf_` only.  
- Keep `out_*` intact.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Reintroduce `fb_*` or parent sudoers/backup helpers.  
2. Flatten prefixes into bare `main` / `install` function names.  
3. Strip Protection Zones from `out_*` or install helpers.  
4. Cite templates or skills as product-source authority.
5. Leave a shipped `util_*` as a table name only — topic-owner **MUST** hold the fenced example (§2.2a).
6. Specialize `util_sha256_file` / `util_fetch_remote_version` into this product (online-only).

**Violating this rule is a critical modular-design regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | Ship unit is a single file at `src/dns-cli` after retarget |
| AC-2 | No `fb_` functions exist |
| AC-3 | Dispatcher is `app_main` |
| AC-4 | Every shipped `util_*` has a fenced `sh` example on its topic-owner (§2.2a) |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-shell-cli-interface` | Dispatch |
| `requirement-shell-output-requirements` | `out_*` + `util_json_escape` |
| `requirement-shell-local-self-management` | `inst_*` + path `util_*` |
| `requirement-shell-cli-storage` | `util_resolve_storage` + `util_get_current_shell` |
| `requirement-domain-cloudflare-dns` | `cf_dns_*` / `cf_ip_*` |
| `requirement-cloudflare-vault` | `cf_vault_*` |
| `requirement-least-privilege-user` | `lpu_*` |
| `docs/requirements/index.md` | Registry |

---

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-03 | Active 1.0.0 | folder-backup prefixes including `fb_*` |
| 2026-08-13 | Active 2.0.0 | cli-template: no domain prefix |
| 2026-08-18 | Active 2.3.0 | `util_*` example ownership; `util_backup` sample; AC-4 |
| 2026-08-17 | Active 2.2.0 | Add `lpu_` for setup/remove-lpu/print-sudoers |
| 2026-08-16 | Active 2.1.0 | Add `cf_` + `prompt_secret`; dns-cli ship unit |

---

**Last Updated**: 2026-08-18  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
