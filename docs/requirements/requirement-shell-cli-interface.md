**file**: docs/requirements/requirement-shell-cli-interface.md  
**Status**: Active (Version 1.0.0)  
**Area**: shell  
**Key**: `requirement-shell-cli-interface`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **project Single Source of Truth** for the **POSIX shell CLI interface** of folder-backup: command surface, privilege typing, global flags, dispatcher behavior, help/about contracts, and mode rules.

It defines a **Type 0–centric local self-managed shell CLI** plus **domain backup** commands and a **narrow elevated deposit** path. Full domain semantics live in `requirement-domain-folder-backup.md`. Full elevation/sudoers rules live in `requirement-three-layer-privilege-model.md`.

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Command surface (portable shape)

Every command **MUST** map to exactly one privilege type. Unclassified commands are incomplete design.

| Category | Privilege | Meaning |
|----------|-----------|---------|
| **Type 0 – CLI lifecycle + diagnostics** | Invoking user | `install`, `uninstall`, `where-is-me`, `version`, `about`, `help` |
| **Type 0 – Domain (user work)** | Invoking user | Archive create, naming, staging, sudoers fragment **print** |
| **Type 1 – Narrow elevated deposit** | Controlled sudo (allowlisted only) | Copy staged archive into `/var/backup/...` only |
| **Type 2 – Dedicated system user app ops** | Dedicated app user | **Not in scope** for this product |

### 2.2 Global flags (portable)

| Flag | Env / state | Behavior |
|------|-------------|----------|
| `--quiet`, `-q` | `QUIET=1` | Suppress non-error human output; errors still visible |
| `--json` | `JSON=1` (implies quiet) | Machine-readable structured output |
| `--debug` | `DEBUG=1` | Extra diagnostics on stderr; must not break JSON purity on stdout |
| `--force` | `FORCE=1` / force policy | Skip safe confirms or force reinstall only where documented |

Additional flags **MAY** be added only when documented here (or a superseding requirement) and wired in the dispatcher.

### 2.3 Dispatcher and entry rules

1. **Single entry:** `app_main` **MUST** parse global flags and route commands.  
2. **Unknown command:** **MUST** fail loudly with pointer to `help` (via output SSOT).  
3. **Empty argv:** **Type N → help** (`requirement-shell-cli-zero-arguments.md`).  
4. **No raw user I/O:** User-facing messages **MUST** go through `out_*`.  
5. Script end **MUST** call `app_main "$@"` (no basename gate that blocks dispatch).

### 2.4 Help surface

`help` **MUST** list:

- Usage line  
- Every supported command with one-line purpose  
- Privilege category (Type 0 vs elevated deposit)  
- Global flags  
- Honest note that deposit requires admin-installed sudoers fragment  

In JSON mode, help **MUST NOT** dump long human text; return a short structured success/note object.

### 2.5 Implementation Notes (this project)

| Item | Value for folder-backup |
|------|-------------------------|
| **Product / binary name** | `folder-backup` (`APP_NAME`) |
| **Primary executable** | `src/folder-backup` (POSIX `/bin/sh`, single-file ship unit) |
| **Dispatcher** | `app_main` |
| **Output SSOT** | `out_text` + wrappers (`out_info`, `out_success`, `out_warn`, `out_error`, `out_die`, `out_plain`, `out_json`, …) |
| **Version SSOT** | `VERSION="1.0.0"` hard-assign in ship unit |
| **Install paths** | Global: `GLOBAL_BIN` default `/usr/local/bin`; User: `USER_BIN` default `${HOME}/.local/bin` |
| **Primary install story** | User bin: `~/.local/bin/folder-backup` |
| **Online channel env** | **Not product UX** (trimmed) |
| **Type 2 commands** | None |
| **Dedicated system user** | Not required |

#### Supported commands (normative for this project)

| Command | Type | Handler family | Required behavior |
|---------|------|----------------|-------------------|
| *(no args — empty argv)* | Type 0 | `app_main` → `app_help` | **Type N help** — not install |
| `install` | Type 0 | `inst_local_install` | Copy running ship unit to privilege-correct bin; idempotent unless `--force` |
| `uninstall` | Type 0 | `inst_local_uninstall` | Remove managed binary; confirm unless `--force` |
| `where-is-me` | Type 0 | `app_where_is_me` | Running + install paths + installed flag |
| `version` | Type 0 | `app_version` | Local `VERSION` only; no network |
| `about` | Type 0 | `app_about` | Diagnostics: install presence, paths, user, shell, TTY, storage, backup defaults; **no** channel one-liner |
| `help` | Type 0 | `app_help` | Full usage in human mode; short JSON note in JSON mode |
| `backup` | Type 0 (+ Type 1 deposit step) | `fb_backup` (domain) | Tar gzip source folder; stage; elevated copy into `/var/backup/${BACKUP_NOTATION}/` |
| `print-sudoers` | Type 0 | `fb_print_sudoers` (domain) | Emit sudoers fragment for admin to install under `/etc/sudoers.d/` — **does not** write `/etc` itself |

#### Global flags (normative wiring)

| Flag | Required wiring |
|------|-----------------|
| `--quiet`, `-q` | `QUIET=1` in `app_main` |
| `--json` | `JSON=1` and `QUIET=1` in `app_main` |
| `--debug` | `DEBUG=1` in `app_main` |
| `--force` | `FORCE=1` (and install reinstall policy when applicable) |

#### Dispatcher acceptance criteria

1. Unknown token after flag parse → `out_die` with pointer to `folder-backup help`.  
2. Zero-arg → help (not install, not backup).  
3. Command routing table in `app_main` **must** include every row above.  
4. Help text **must** stay aligned with that table.  
5. Domain catalog detail (operands, archive naming, error codes) is owned by `requirement-domain-folder-backup.md` — this file owns the **listed verbs** and routing.

#### Explicitly out of scope

- Online: `version-check`, `self-update`, `self-uninstall`, channel `install` via URL  
- Type 1 host bootstrap beyond **narrow deposit** and **sudoers fragment generation**  
- Type 2 app runtime under a dedicated system user  

### 2.6 Why This Requirement Exists (Direct CIAO Alignment)

- **CIAO Principle 1 – Caution**: Unknown commands fail loud; force gates destructive ops.  
- **CIAO Principle 2 – Intentional**: Every command has one privilege type and one handler family.  
- **CIAO Principle 5 – Single Source of Output**: Central `out_*`.  
- **CIAO Principle 6 – Single Point of Entry**: `app_main` is the dispatcher SSOT.  
- **CIAO Principle 9 – Three Types of Commands**: Type 0 lifecycle/domain; Type 1 narrow deposit only.  
- **CIAO Principle 10 – Least-Privilege User**: No invented system-user requirement for binary lifecycle.  
- **CIAO Principle 16 – Interactive vs Non-Interactive**: No hang in non-interactive mode.  
- **CIAO Principle 4 / 20 – Over-protect**: Protection Rule blocks privilege and UX regressions.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution:** Fail loud on bad input; never silent wrong privilege context.  
- **Intentional:** Command table + help + dispatcher stay synchronized.  
- **Anti-fragile:** Works under TTY, quiet, JSON, offline local install.  
- **Over-protect:** Do not collapse Type 0/1, reintroduce online verbs, or raw output for user messages.  
- **SSOT:** `APP_NAME` / `VERSION` / flags at config defaults; output via `out_*`; dispatch via `app_main`.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Add online lifecycle commands without an explicit product-mode change and registry update.  
2. Change empty argv away from Type N help while install mode remains local-only.  
3. List commands in help that are not routed (or route commands not listed).  
4. Bypass `out_*` for product user messages.  
5. Run the entire CLI as root by default instead of narrow deposit elevation.  
6. Put full domain archive semantics only here and omit the domain SSOT.

**Violating this rule is a critical CLI interface regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | All commands in the table are routed and listed in help |
| AC-2 | Global flags wire QUIET/JSON/DEBUG/FORCE as specified |
| AC-3 | Empty argv is help (Type N) |
| AC-4 | No online self-management verbs on the surface |
| AC-5 | Domain verbs point to domain requirement for deep semantics |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-shell-cli-zero-arguments` | Empty argv Type N |
| `requirement-shell-local-self-management` | install/uninstall/where-is-me |
| `requirement-shell-output-requirements` | `out_*` catalog |
| `requirement-domain-folder-backup` | Domain four pillars |
| `requirement-three-layer-privilege-model` | Elevation model |
| `docs/requirements/index.md` | Registry |

---

## Design-time verification

| TP family / ID | Suite | Status |
|----------------|-------|--------|
| **TP-CLI-01..12** | `tests/test_cli.sh` | have |

**Matrix:** `reviews/requirement-test-matrix.md`  
**Map:** `reviews/test-plan.md`

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-03 | Active | CLI surface for local-only folder-backup + domain backup |

---

**Last Updated**: 2026-08-03  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
