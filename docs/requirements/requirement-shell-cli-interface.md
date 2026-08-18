**file**: docs/requirements/requirement-shell-cli-interface.md  
**Status**: Active (Version 3.5.0)  
**Area**: shell  
**Key**: `requirement-shell-cli-interface`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **project Single Source of Truth** for the **POSIX shell CLI interface** of dns-cli: command surface, privilege typing, global flags, dispatcher behavior, help/about contracts, and mode rules.

**Domain verb catalog, flags, help rows, and about extras** are owned by `requirement-domain-cloudflare-dns.md`. Type 1/2 map and elev tables live in `requirement-three-layer-privilege-model`. This file **lists names + argv grammar only** and **MUST NOT** duplicate full domain or F1–F7 tables. Full lifecycle rules live in `requirement-shell-local-self-management.md`.

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Command surface (portable shape)

Every command **MUST** map to exactly one privilege type. Unclassified commands are incomplete design.

| Category | Privilege | Meaning |
|----------|-----------|---------|
| **Type 0 – CLI lifecycle + diagnostics** | Invoking user | `install`, `uninstall`, `where-is-me`, `version`, `about`, `help`, `ip`, `print-sudoers`, `generate-sudoer-request`, `submit-sudoer-request` |
| **Type 0 – Specify-vault domain** | Invoking user | `vault` / `add` / `update` / `remove` / `status`/`show` **when** `--vault-dir` / `CF_VAULT_DIR` is set — **catalog SSOT:** `requirement-domain-cloudflare-dns` |
| **Type 1 – LPU bootstrap** | Password `sudo` / already-root | `setup`, `remove-lpu` — **SSOT:** `requirement-three-layer-privilege-model` |
| **Type 2 – Default-vault domain** | `dns-adm` | `vault` / `add` / `update` / `remove` / `status`/`show` on the default LPU vault |

### 2.2 Global flags (portable)

| Flag | Env / state | Behavior |
|------|-------------|----------|
| `--quiet`, `-q` | `QUIET=1` | Suppress non-error human output; errors still visible |
| `--json` | `JSON=1` (implies quiet) | Machine-readable structured output |
| `--debug` | `DEBUG=1` | Extra diagnostics on stderr; must not break JSON purity on stdout |
| `--force` | `FORCE=1` / force policy | Skip uninstall confirm or force reinstall only where documented |
| `--global` | `FORCE_GLOBAL=1` | Install to `GLOBAL_BIN` |

Additional flags **MAY** be added only when documented here **or** in the domain SSOT and wired in the dispatcher. Domain flags (`--ip`, `--domain` / `--domain-id`, `--user-id`, `--subdomain`, `--mode`, `--from`, `--ttl`, `--proxied`, `--token-file`) are owned by domain / vault / mode law. `--vault-dir` is owned by `requirement-application-local-vault`. `--mode` and `--from` semantics: `requirement-cloudflare-dns-mode`.

**Sudoer submitter flags (Type 0 generate/submit only):** `--allow-test-local`, `--add`, `--update`. **Forbidden flags (trimmed):** `--disk`, `--ram` (parent backup domain).

### 2.3 Dispatcher and entry rules

1. **Single entry:** `app_main` **MUST** parse global flags and route commands.  
2. **Unknown command:** **MUST** fail loudly with pointer to `help` (via output SSOT).  
3. **Empty argv:** **Type N → help** (`requirement-shell-cli-zero-arguments.md`).  
4. **No raw user I/O:** User-facing messages **MUST** go through `out_*`.  
5. Script end **MUST** call `app_main "$@"` (no basename gate that blocks dispatch).  
6. Trimmed parent verbs (`backup`, `restore`, `print-sudoers-install-script`, `remove-project-sudoers`) **MUST** fail as unknown. `print-sudoers`, `generate-sudoer-request`, and `submit-sudoer-request` **are** in scope.

**CI-M1. Dual mention.** Every routed product verb **MUST** be named in **at least two** Active registered requirements: this file (dispatch / help) **and** a topic-owner. **MUST NOT** leave a verb only here — this file is product-local and is not a portable inventory. The same rule applies to Python (`requirement-python-cli-interface`) and Node (`requirement-nodejs-cli-interface`) products. Topic owners:

| Verb / family | Topic-owner (second mention) |
|---------------|------------------------------|
| `install` / `uninstall` / `where-is-me` / `version` / `about` / `help` | `requirement-shell-local-self-management` (`help` also `requirement-shell-cli-zero-arguments`) |
| `setup` / `remove-lpu` / `print-sudoers` | `requirement-three-layer-privilege-model` (`print-sudoers` also `requirement-sudoer-json-file` §2.0) |
| `generate-sudoer-request` / `submit-sudoer-request` | `requirement-sudoer-json-file` **and** `requirement-three-layer-privilege-model` |
| `vault` + store subcommands (`input` / `set` / `init` / `show` / `clear` / `account`/`zone` / `subdomain`) | `requirement-cloudflare-vault` **and** `requirement-domain-cloudflare-dns` |
| `ip` | `requirement-external-ipv4` **and** `requirement-domain-cloudflare-dns` |
| `add` / `update` / `remove` / `status` / `show` | `requirement-domain-cloudflare-dns` (`add`/`update`/`remove` dest also `requirement-cloudflare-dns-request`) |
| `submit` / `approve` / `reject` / `interactive` | `requirement-dns-actor-table` **and** `requirement-domain-cloudflare-dns` (`interactive` also `requirement-dns-approver`) |

**CI-M1a. Sample invocation.** Every verb (and every `vault` store subcommand) in the table **MUST** have a **complete invocation sample** in its topic-owner REQ: a fenced `sh` block whose command line is `dns-cli` (optional `sudo` / `sudo -n` prefix) plus that verb and operands (copy-pasteable argv). A name in a table, a help string, or `app_help` is **not** the sample. Gap verbs **MUST** still show the intended argv. The domain SSOT **MUST** sample every domain verb it catalogs; store-UX samples live on `requirement-cloudflare-vault`.

### 2.4 Help surface

`help` **MUST** list:

- Usage line  
- Every **routed** Type 0 command with one-line purpose  
- Every **routed** domain verb (domain SSOT owns the rows; do not list unrouted verbs)  
- Global flags  
- Honest note that this product is local-only (no curl\|sh)

In JSON mode, help **MUST NOT** dump long human text; return a short structured success/note object.

`help` **MUST NOT** list backup, restore, or `print-sudoers-install-script` / `remove-project-sudoers`. `help` **MUST** list `setup` / `remove-lpu` / `print-sudoers` / `generate-sudoer-request` / `submit-sudoer-request` **only when** `app_main` routes them.

### 2.5 Implementation Notes (this project)

| Item | Value for dns-cli |
|------|-------------------------|
| **Product / binary name** | `dns-cli` (`APP_NAME`) |
| **Primary executable (target)** | `src/dns-cli` (POSIX `/bin/sh`, single-file ship unit) |
| **Primary executable (live)** | `src/dns-cli` |
| **Dispatcher** | `app_main` |
| **Output SSOT** | `out_text` + wrappers including **`out_die_code`** |
| **Version SSOT** | `VERSION="1.0.0"` until DNS ships; then `1.1.0` |
| **Install paths** | Global: `GLOBAL_BIN` default `/usr/local/bin`; User: `USER_BIN` default `${HOME}/.local/bin` |
| **Primary install story** | User bin: `~/.local/bin/dns-cli` |
| **Online channel env** | **Not product UX** (trimmed) |
| **Type 1 / Type 2 commands** | `setup` / `remove-lpu` (Type 1) **Implemented** 1.5.0; generate/submit JSON sudoer **Implemented** 1.6.0; default-vault domain (Type 2) switch **Implemented** 1.8.2 |
| **Dedicated system user** | `dns-adm` — `requirement-least-privilege-user` |
| **About** | Type 0 fields **plus** domain extras owned by `requirement-domain-cloudflare-dns` (incl. `lpu_present`) |
| **Domain catalog owner** | `requirement-domain-cloudflare-dns` |
| **Domain implementation** | Implemented |

#### Supported commands (normative for this project)

| Command | Type | Handler family | Required behavior |
|---------|------|----------------|-------------------|
| *(no args — empty argv)* | Type 0 | `app_main` → `app_help` | **Type N help** — not install |
| `install` | Type 0 | `inst_local_install` | Copy running ship unit to privilege-correct bin; idempotent unless `--force` |
| `uninstall` | Type 0 | `inst_local_uninstall` | Remove managed binary; confirm unless `--force` |
| `where-is-me` | Type 0 | `app_where_is_me` | Running + install paths + installed flag |
| `version` | Type 0 | `app_version` | Local `VERSION` only; no network |
| `about` | Type 0 | `app_about` | Diagnostics: install presence, paths, user, shell, TTY, storage; **no** channel one-liner; **no** backup/sudoers fields |
| `help` | Type 0 | `app_help` | Full usage in human mode; short JSON note in JSON mode |
| `setup` | Type 1 | `lpu_setup` | Create `dns-adm` + vault dir + F6 dest; auto-queue `login-hook-elev` when sibling exists — **Implemented** |
| `remove-lpu` | Type 1 | `lpu_remove` | F7 teardown — **Implemented** (1.5.0) |
| `print-sudoers` | Type 0 | `lpu_print_sudoers` | **Print the sudoer file** (Table A `sudoers(5)` text) — **Implemented** (1.5.0) |
| `generate-sudoer-request` | Type 0 | `lpu_generate_sudoer_request` | Independent JSON dest; `--kind type-2-switch` (default) or `login-hook-elev` — **Implemented** |
| `submit-sudoer-request` | Type 0 | `lpu_submit_sudoer_request` | Queue **`type-2-switch`** only — **Implemented** |
| `vault` / `ip` / `add` / `update` / `remove` / `status`/`show` | Type 2 default / Type 0 specify (`ip` always Type 0) | `cf_*` | **Owned by** `requirement-domain-cloudflare-dns` — do not duplicate tables here |
| `submit` | Type 0 | Implemented | Inbound **DNS** JSON drop — `requirement-dns-actor-table` (not sudoer submit) |
| `approve` / `reject` / `interactive` | Type 1 | Implemented | Approver path — `requirement-dns-actor-table` |

#### Argv grammar (normative)

1. Global flags **MAY** appear before or after the verb.  
2. Value flags **MUST** consume the next argv token; missing value → fail closed.  
3. Type 0 lifecycle verbs (`install`, `uninstall`, `where-is-me`, `version`, `about`, `help`) **MUST** reject unexpected operands.  
4. `vault` subcommand grammar: `vault set|init|show|clear` or `vault account|zone add|list|modify|remove|default|show [<domain-id>]` or `vault subdomain add|list|modify|remove|mode [<label>]`. `zone` is an alias of `account`.  
5. Domain operands (`--domain` / `--domain-id`, `--subdomain`, `--mode`, `--from`, optional positional host-label) are defined in the domain SSOT / `requirement-cloudflare-dns-mode`.

#### Global flags (normative wiring)

| Flag | Required wiring |
|------|-----------------|
| `--quiet`, `-q` | `QUIET=1` in `app_main` |
| `--json` | `JSON=1` and `QUIET=1` in `app_main` |
| `--debug` | `DEBUG=1` in `app_main` |
| `--force` | `FORCE=1` (and install reinstall policy when applicable) |
| `--global` | `FORCE_GLOBAL=1` |

#### Dispatcher acceptance criteria

1. Unknown token after flag parse → `out_die` / `out_die_code` with pointer to `dns-cli help`.  
2. Zero-arg → help (not install, not DNS).  
3. Command routing table in `app_main` **must** include every **routed** row and **no** trimmed parent verbs.  
4. Help text **must** stay aligned with that table (no listed-but-unrouted domain verbs).

#### Explicitly out of scope

- Online: `version-check`, `self-update`, `self-uninstall`, channel `install` via URL  
- Parent domain: `backup`, `restore` (not Cloudflare verbs)  
- Sudoers-manager extras: `print-sudoers-install-script`, `remove-project-sudoers`  

`print-sudoers`, `setup`, `generate-sudoer-request`, and `submit-sudoer-request` **are** in scope. Do not treat generate/submit as trimmed parent verbs.

### 2.6 Why This Requirement Exists (Direct CIAO Alignment)

- **CIAO Principle 1 – Caution**: Unknown commands fail loud; force gates destructive ops.  
- **CIAO Principle 2 – Intentional**: Every command has one privilege type and one handler family.  
- **CIAO Principle 5 – Single Source of Output**: Central `out_*`.  
- **CIAO Principle 6 – Single Point of Entry**: `app_main` is the dispatcher SSOT.  
- **CIAO Principle 9 – Three Types of Commands**: Type 0 lifecycle + Type 1 setup + Type 2 default-vault.  
- **CIAO Principle 10 – Least-Privilege User**: `dns-adm` owns the default vault; binary lifecycle stays Type 0.  
- **CIAO Principle 16 – Interactive vs Non-Interactive**: No hang in non-interactive mode.  
- **CIAO Principle 4 / 20 – Over-protect**: Protection Rule blocks privilege and UX regressions.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution**: Fail closed on unknown verbs, including trimmed parent verbs.  
- **Intentional**: Privilege column plus a pointer to domain and three-layer SSOTs.  
- **Anti-fragile**: Same dispatcher contract as parent.  
- **Over-protect**: Do not silently restore domain verbs “because the name is cli-template.”

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Add **additional** domain verbs without updating `requirement-domain-cloudflare-dns`, or widen F6 beyond Table A.  
2. Change empty argv from Type N help to install-ensure.  
3. Bypass `out_*` for user-facing messages.  
4. Advertise an online install channel in help/about.  
5. Collapse Type 1/2 into “just run as root.”  
6. Add a routed verb only to this file. Dual mention (CI-M1) is mandatory.  
7. Name a verb on a topic-owner without a complete `dns-cli …` invocation sample (CI-M1a).

**Violating this rule is a critical CLI-surface regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | Help lists install / uninstall / where-is-me / version / about / help plus **routed** domain verbs only |
| AC-2 | Help and about omit backup / restore / print-sudoers-install-script |
| AC-3 | Unknown and trimmed verbs exit non-zero |
| AC-4 | Empty argv is help |
| AC-5 | Every routed verb is named on this file **and** its topic-owner (CI-M1); none exist only here |
| AC-6 | Every verb (and every `vault` store subcommand) has a complete `dns-cli …` invocation sample on its topic-owner (CI-M1a) |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-shell-cli-zero-arguments` | Empty argv |
| `requirement-shell-local-self-management` | install / uninstall / where-is-me |
| `requirement-shell-output-requirements` | `out_*` |
| `requirement-bootstrap-chain` | Trimmed surfaces |
| `requirement-domain-cloudflare-dns` | Domain catalog owner |
| `requirement-cloudflare-dns-mode` | `--mode` / `--from` / `vault subdomain mode` |
| `requirement-cloudflare-dns-request` | Future submit/approve argv; four `action` values |
| `requirement-cloudflare-vault` | Vault flags / `vault` store UX |
| `requirement-least-privilege-user` | `dns-adm` |
| `requirement-three-layer-privilege-model` | Type map + `setup` / `print-sudoers` / generate+submit |
| `requirement-sudoer-json-file` | JSON grant body |
| `docs/requirements/index.md` | Registry |

---

## Design-time verification

| TP family / ID | Suite | Status | Note |
|----------------|-------|--------|------|
| **TP-CLI-01..13** | `tests/test_cli.sh` | have | includes stripped-verb fail-closed |
| **TP-CLI-14** | `tests/test_cli.sh` | have | CI-M1 dual mention — each routed verb in ≥2 REQs |
| **TP-CLI-15** | `tests/test_cli.sh` | have | CI-M1a — each verb has a `dns-cli …` sample on a topic-owner REQ |
| **TP-LC-*** | `tests/test_local_lifecycle.sh` | have | lifecycle |

**Matrix:** `reviews/requirement-test-matrix.md`  
**Map:** `reviews/test-plan.md`

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-03 | Active 1.0.0 | folder-backup Type 0 + domain verbs |
| 2026-08-13 | Active 2.0.0 | cli-template Type 0 only |
| 2026-08-18 | Active 3.5.0 | CI-M1a — topic-owner MUST include a complete `dns-cli …` sample per verb |
| 2026-08-18 | Active 3.4.0 | Dual mention CI-M1 — every verb in ≥2 REQs |
| 2026-08-18 | Active 3.3.0 | `generate-sudoer-request` / `submit-sudoer-request`; `--allow-test-local` / `--add` / `--update` |
| 2026-08-17 | Active 3.2.0 | `vault account\|zone add\|list\|modify\|remove`; `vault subdomain modify` |
| 2026-08-17 | Active 3.1.0 | `--mode` / `--from` / `vault subdomain mode` argv |
| 2026-08-17 | Active 3.0.0 | Type 1 `setup`/`remove-lpu`; Type 2 default-vault; `print-sudoers` in scope |
| 2026-08-16 | Active 2.1.0 | Pointer to domain SSOT; argv grammar; dns-cli identity |

---

**Last Updated**: 2026-08-18  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
