**file**: docs/requirements/requirement-shell-interactive-vs-noninteractive.md  
**Status**: Active (Version 1.0.0)  
**Area**: shell  
**Key**: `requirement-shell-interactive-vs-noninteractive`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **project Single Source of Truth** for how cli-template behaves in **interactive** (human + TTY) versus **non-interactive** (automation, CI/CD, pipes, `--json` / often `--quiet`) environments.

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

### 2.3 Behavioral matrix (this product)

| Action | Interactive | Non-interactive |
|--------|-------------|-----------------|
| `uninstall` | Confirm unless `--force` | **Fail closed** without `--force` (`confirm_required`) |
| `install` | May inform; no required confirm for first install | Proceed without hang |
| Missing required operand | Clear error | Clear error; non-zero exit |

### 2.4 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **Product** | `cli-template` |
| **No curl\|sh auto-install path** | Local-only; non-interactive does not mean Type O install-ensure |
| **Prompt helper** | `prompt_yes_no` for uninstall (and any future destructive confirm) |

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
| `docs/requirements/index.md` | Registry |

---

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-03 | Active | Interactive vs non-interactive for folder-backup |

---

**Last Updated**: 2026-08-03  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
