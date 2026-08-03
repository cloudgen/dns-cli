**file**: docs/requirements/requirement-shell-modular-function-design.md  
**Status**: Active (Version 1.0.0)  
**Area**: shell  
**Key**: `requirement-shell-modular-function-design`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **project Single Source of Truth** for **modular function organization** of the folder-backup POSIX shell CLI.

**Core idea:** Modularity is achieved through **clear function boundaries, consistent prefixes, and full CIAO documentation** — **not** by splitting the installable CLI into multiple shipped files.

Ship unit remains a **single executable** at `src/folder-backup`.

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

**All functions MUST use a defined prefix.** Bare names (`main`, `install`, `help`, `backup`) as function names are forbidden.

| Prefix | Category | Purpose | Example functions |
|--------|----------|---------|-------------------|
| `out_` | Output system | All user-facing and machine-readable output | `out_text`, `out_info`, `out_json`, `out_die` |
| `inst_` | Installation lifecycle | Local install/uninstall detect and place/remove | `inst_local_install`, `inst_local_uninstall`, `inst_is_installed` |
| `util_` | General utilities | Path resolve, storage, safe helpers | `util_resolve_storage`, `util_get_install_bin_path` |
| `app_` | Cross-cutting CLI surface | Entry, dispatch, about/help/version/where-is-me | `app_main`, `app_about`, `app_help`, `app_version`, `app_where_is_me` |
| `path_` | Shell PATH & environment | Optional PATH ensure after user install | `path_add_shell` |
| `prompt_` | Interactive prompts | TTY-safe confirmations | `prompt_yes_no` |
| `fb_` | Domain business logic | Folder backup + sudoers fragment | `fb_backup`, `fb_print_sudoers`, `fb_next_archive_name`, `fb_stage_archive` |

**Notes:**

- Domain prefix **`fb_`** is short for **folder-backup** (path-safe, stable).  
- **Do not** put domain ops under `app_*`.  
- **Do not** put generic about/help/main under `fb_*`.  
- Online-only prefixes from parent (`ver_check` remote network path, download install family) **MUST NOT** be reintroduced unless product mode changes.

### 2.3 Function documentation standards

Every non-trivial function **MUST** include a defensive header with:

- One-line purpose  
- **GENERAL PURPOSE** paragraph  
- CIAO principles applied (as relevant)  
- Protection / DO NOT SIMPLIFY note for critical helpers  
- Last reviewed date when modified  

Product-source `ALIGNMENT` / “see” comments **MUST** cite only live `docs/requirements/requirement-*.md` paths registered in `index.md`.

### 2.4 Protection Zones

Critical sections (output SSOT, install place/remove, storage resolve, domain archive naming, sudoers fragment generation, elevated deposit invocation) **MUST** remain CIAO-Lite Protection Zones and **MUST NOT** be simplified away without explicit user redesign order.

### 2.5 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **Ship unit** | `src/folder-backup` |
| **Domain prefix** | `fb_` |
| **Bootstrap inheritance** | Prefix discipline from selfmanaged; domain prefix added |
| **Multi-file authoring** | Optional later only if pack still yields one installable artifact and this requirement is updated |

### 2.6 Why This Requirement Exists (CIAO)

- **Principle 2 – Intentional**: Prefixes encode ownership.  
- **Principle 6 – Single Point of Entry**: `app_main` stays the dispatcher.  
- **Principle 7 – Reusable function protection**: DO NOT MODIFY markers on critical helpers.  
- **Principle 20 – Protect against AI & human modification**: Visible zones.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution:** No bare unscoped helpers.  
- **Intentional:** Domain vs Type 0 separation.  
- **Anti-fragile:** Single file still modular.  
- **Over-protect:** Keep Protection Zones.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Introduce bare function names without an approved prefix.  
2. Merge domain backup logic into `app_*` or `inst_*` without requirement update.  
3. Split into multi-file runtime without a pack story and requirement change.  
4. Strip Protection Zones “for readability.”  
5. Cite templates/skills as product-source behavioral authority.

**Violating this rule is a critical modular design regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | All functions use the prefix table |
| AC-2 | Domain ops live under `fb_*` |
| AC-3 | Single ship unit at `src/folder-backup` |
| AC-4 | Product comments cite live requirements only |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-shell-cli-interface` | Command → handler map |
| `requirement-shell-output-requirements` | Owns `out_*` |
| `requirement-domain-folder-backup` | Owns `fb_*` behavior |
| `docs/requirements/index.md` | Registry |

---

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-03 | Active | Modular prefixes for folder-backup |

---

**Last Updated**: 2026-08-03  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
