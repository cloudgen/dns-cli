**file**: docs/requirements/requirement-shell-interactive-vs-noninteractive.md  
**Status**: Active (Version 1.3.1)  
**Area**: shell  
**Key**: `requirement-shell-interactive-vs-noninteractive`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **project Single Source of Truth** for how dns-cli behaves in **interactive** (human + TTY) versus **non-interactive** (automation, CI/CD, pipes, `--json` / often `--quiet`) environments.

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Definitions

| Mode | Definition |
|------|------------|
| **Interactive** | Human + usable TTY; confirmations allowed when not overridden by machine flags |
| **Non-interactive** | No human available: CI, scripts, pipes, `--json` (and often `--quiet`). **Must never hang** waiting for input |

### 2.2 Detection (mode SSOT)

| Signal | Variable / check | Meaning |
|--------|------------------|---------|
| TTY | `TTY=1` when stdin and stdout are terminals | Interactive UX possible |
| Quiet | `QUIET=1` | Suppress non-essential human chatter |
| JSON | `JSON=1` (implies quiet) | Machine output; no human hang |
| Debug | `DEBUG=1` | Extra stderr diagnostics |
| Force | `FORCE=1` | Skip confirms / force reinstall where documented |

Rules:

1. Prompt decisions **MUST** use shared `prompt_*` helpers — not ad-hoc `read` in domain logic.  
2. After flags are parsed in `app_main`, subsequent code **MUST** see updated mode globals.  
3. Do **not** invent a second parallel mode system per command.  
4. Interactive capability **MUST** be measured in the **main process, outside functions**: after flags, `TTY=0` then `[ -t 0 ] && [ -t 1 ] && TTY=1` (or a direct setter that assigns `TTY`).  
5. `prompt_ask` / `prompt_yes_no` / `prompt_secret` and vault confirm gates **MUST consume `TTY`**. Live `[ -t 0 ]` / `[ -t 1 ]` as a **policy gate inside those helpers** is forbidden.  
6. A login-hook snippet that runs in the **user’s shell** (not the CLI process) **MAY** probe `[ -t` there — that is hook identity, not CLI `TTY` SSOT.  
7. `about` **MUST** report `TTY`, not a live `[ -t` retest.

### 2.3 Behavioral matrix (this product)

| Action | Interactive | Non-interactive |
|--------|-------------|-----------------|
| `uninstall` | Confirm unless `--force` | **Fail closed** without `--force` (`confirm_required`) |
| `install` | May inform; no required confirm for first install | Proceed without hang |
| `vault input` (and bare `vault`) | Full TTY wizard (domain-id then fields; Enter keeps current; token via `prompt_secret`) | Fail `confirm_required` |
| `vault set` / `init` / `account modify` / `zone modify` | `prompt_*` / `prompt_secret` **only empty fields** after vault+flags+env | Fail `vault_incomplete` unless flags/env complete remaining fields |
| `vault account remove` / `vault zone remove` / `vault clear` | Confirm unless `--force` | Fail `confirm_required` unless `--force` |
| `vault subdomain remove` last label | Fail `subdomain_required` / `vault_incomplete` | Same |
| `remove-lpu` | Confirm unless `--force` | Fail `confirm_required` unless `--force` |
| `setup` | Password `sudo` is approval; no extra confirm required | Fail closed if sudo/root unavailable |
| `add`/`update`/`remove`/`status` with incomplete vault | Collect **empty** fields then continue | `vault_incomplete` |
| Missing required operand | Clear error | Clear error; non-zero exit |

### 2.4 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **Product** | `dns-cli` |
| **No curl\|sh auto-install path** | Local-only; non-interactive does not mean Type O install-ensure |
| **Prompt helpers** | `prompt_yes_no` / `prompt_ask` / `prompt_secret` consume `TTY` — **Implemented** on `src/dns-cli` 1.4.1 |

### 2.5 Why This Requirement Exists (CIAO)

- **Principle 16 – Interactive vs Non-Interactive**  
- **Principle 1 – Caution**: Never hang automation  
- **Principle 14 – Traceability**: Errors visible under quiet/json contracts

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution:** Fail closed on destructive ops without force in non-interactive.  
- **Intentional:** One mode SSOT.  
- **Anti-fragile:** CI-safe.  
- **Over-protect:** No bare `read` in domain paths.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Hang on stdin in non-interactive/json modes.  
2. Auto-yes destructive uninstall without `--force` in non-interactive mode.  
3. Scatter unguarded `read` calls outside `prompt_*`.  
4. Treat non-interactive as license to skip required validation.  
5. Retest `[ -t 0 ]` / `[ -t 1 ]` inside `prompt_*` or vault confirm gates instead of consuming `TTY`.

**Violating this rule is a critical interaction-mode regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | Non-interactive uninstall without force fails closed |
| AC-2 | JSON mode never prompts |
| AC-3 | Lifecycle commands never hang waiting for optional confirm by default |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-shell-cli-interface` | Flags |
| `requirement-shell-local-self-management` | Uninstall confirm |
| `requirement-shell-output-requirements` | Quiet/json emission |
| `requirement-cloudflare-vault` | Collect / clear / last-label |
| `requirement-domain-cloudflare-dns` | First-run DNS with incomplete vault |
| `docs/requirements/index.md` | Registry |

---

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-18 | Active 1.3.1 | `TTY` measured in `app_main`; `prompt_*` consume `TTY` |
| 2026-08-03 | Active | Interactive vs non-interactive for folder-backup |
| 2026-08-17 | Active 1.3.0 | `account`/`zone` modify collect; `zone remove` confirm |
| 2026-08-17 | Active 1.2.0 | account remove / remove-lpu / setup rows |
| 2026-08-16 | Active 1.1.0 | Vault collect / clear / DNS incomplete-vault matrix |

---

**Last Updated**: 2026-08-18  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
