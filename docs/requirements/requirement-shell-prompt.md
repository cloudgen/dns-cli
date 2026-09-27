**file**: docs/requirements/requirement-shell-prompt.md
**Status**: Active (Version 1.2.0) — current-shell `prompt_ask`; answer is `PROMPT_ASK_VALUE`
**Area**: shell
**Key**: `requirement-shell-prompt`
**id**: RQ-SHELL-PROMPT
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **project Single Source of Truth** for **how** dns-cli writes `prompt_*` helpers: yes/no confirm and value ask.

**Mode policy** (when a human may be prompted, how `TTY` is measured) stays in `requirement-shell-interactive-vs-noninteractive`. This file owns helper **bodies**, contracts, and worked samples. Dest **approval question** (one-off yes/no) stays dest law; dest **MUST** use this `prompt_yes_no`.

### 1.1 Human-facing

**In one sentence:** Yes/no and ask helpers read TTY in this shell. The typed answer is `PROMPT_ASK_VALUE`. They do not re-test the terminal themselves.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | Answer a confirm | `dns-cli uninstall` |
| The other role | Non-interactive must not hang on a prompt | `--json` / no TTY |
| Not this file | When prompting is allowed | `requirement-shell-interactive-vs-noninteractive` |

| Includes | Excludes |
|----------|----------|
| Complete `prompt_yes_no` / `prompt_ask` bodies that consume TTY | Ad-hoc `read`; `--force` auto-approve; a second confirm family; a four-way dest menu |

| Surface | What you open | What for |
|---------|---------------|----------|
| `src/dns-cli` | ship unit | `prompt_*` |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Confirm uninstall | Type yes. Enter is no. There is no skip or quit. | `dns-cli uninstall` |
| Dest review one file | Type yes to accept or no to reject. Enter is no. | (login as `dns-adm`; `dns-cli interactive`) |

---

## Design-time verification

| Gate | Artifact | Phase |
|------|----------|-------|
| Current-shell `prompt_ask` / `prompt_secret`; no `$()` of those helpers | **TP-CLI-25** · **TP-CLI-27**; dest **TP-CF-ACTOR-04** | Proof |

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Ownership

| Helper | Role | Return |
|--------|------|--------|
| `prompt_yes_no` | Destructive / optional confirm | Exit **0** yes, **1** no/cancel |
| `prompt_ask` | Value with default | Assign **`PROMPT_ASK_VALUE`** in this shell |
| `prompt_secret` | Secret, no echo | Assign **`PROMPT_ASK_VALUE`** in this shell (empty when refused) |

1. Domain and lifecycle **MUST NOT** call raw `read` for user-visible confirms.  
2. Prompt **question text** **MUST** go through `out_msg_n` / `out_*` — never raw product `printf` for the question.  
3. `prompt_ask` / `prompt_secret` **MUST** assign the answer to **`PROMPT_ASK_VALUE`**. Stdout is **not** the return. Callers **MUST** copy that global after a current-shell call.  
4. Callers **MUST NOT** wrap `prompt_ask`, `prompt_secret`, `prompt_yes_no`, or any other function whose body contains `read`, in `$()` or backticks.  
5. Printing the question on stderr, or reading `/dev/tty`, **MUST NOT** be used to keep `$()`.  
6. `prompt_yes_no` returns an exit status (`if prompt_yes_no; then`). It does **not** use `PROMPT_ASK_VALUE`.  
7. A function whose body `read`s a person (`prompt_*` and the numbered-menu loops) **MUST** carry the do-not-capture-read WARNING in its comment block, before `Last updated:`.

### 2.2 Consume mode SSOT (no-retest)

Helpers **MUST** read `TTY`, `JSON`, `QUIET`, and optional `INTERACTIVE`. They **MUST NOT** use live `[ -t 0 ]` / `[ -t 1 ]` as the interactive-policy gate.

| Condition | `prompt_yes_no` | `prompt_ask` |
|-----------|-----------------|--------------|
| `JSON=1` or `QUIET=1` | return 1 (no) | print default; return 0 |
| `TTY` is not `1` and `INTERACTIVE` is not `1` | return 1 | print default; return 0 |
| else | ask; `read` | ask; `read`; print answer or default |

`read` **MAY** use `/dev/tty` when that node opens, because `TTY` can be 1 while stdin is not the terminal. That read target is the input device. It is **not** permission to capture the helper. Fallback: stdin. Direct `if prompt_yes_no; then` **MAY** `read` from stdin when `TTY=1`.

Human UI uses `out_info` / `out_msg_n` on the normal output path. **MUST NOT** print the answer (or the secret) on stdout for a caller to capture.

Measuring `[ -t` remains **outside functions** (interactive REQ).

### 2.3 Sufficient samples (normative shape)

These samples **are** the helper contract.

```sh
prompt_yes_no() {
    : "${JSON:=0}"
    : "${QUIET:=0}"
    : "${TTY:=0}"
    local message="${1-}"
    if [ "${JSON}" -eq 1 ] || [ "${QUIET}" -eq 1 ]; then
        return 1
    fi
    if [ "${TTY}" -ne 1 ]; then
        return 1
    fi
    out_msg_n "${message} (y/N)? "
    local answer=""
    read -r answer || true
    case "${answer}" in
        [Yy]*|[Yy][Ee][Ss]*) return 0 ;;
        *) return 1 ;;
    esac
}
```

```sh
# WARNING — do-not-capture-read (PP-A-22 / T1-PROMPT-CAPTURE)
# MUST NOT capture this function. This body contains read.
# Call in the current shell. The answer is PROMPT_ASK_VALUE.
prompt_ask() {
    : "${JSON:=0}"
    : "${QUIET:=0}"
    : "${TTY:=0}"
    : "${INTERACTIVE:=0}"
    : "${PROMPT_ASK_VALUE:=}"
    local message="${1-}"
    local default="${2-}"
    local current="${3-}"
    PROMPT_ASK_VALUE="${default}"
    if [ "${JSON}" -eq 1 ] || [ "${QUIET}" -eq 1 ]; then
        return 0
    fi
    if [ "${TTY}" -ne 1 ] && [ "${INTERACTIVE}" -ne 1 ]; then
        return 0
    fi
    if [ -n "${current}" ]; then
        out_info "Current: ${current}"
    fi
    if [ -n "${default}" ]; then
        out_info "Default: ${default}"
    fi
    out_msg_n "${message}: "
    local answer=""
    if [ -c /dev/tty ] && ( : </dev/tty ) 2>/dev/null; then
        read -r answer </dev/tty || true
    else
        read -r answer || true
    fi
    if [ -n "${answer}" ]; then
        PROMPT_ASK_VALUE="${answer}"
    fi
    return 0
}

prompt_ask "Zone ID" ""
_zone="${PROMPT_ASK_VALUE}"
```

### 2.4 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **Product** | `dns-cli` |
| **Ship unit** | `src/dns-cli` |
| **Live confirm** | `uninstall` / `remove-lpu` / vault delete use `prompt_yes_no` unless `--force` — **Implemented** |
| **Live ask** | vault collect uses `prompt_ask` — **Implemented** |
| **Dest review** | `interactive` uses one `prompt_yes_no` after fence — **Implemented** |

```sh
dns-cli uninstall
```

```sh
dns-cli interactive
```

### 2.5 Why This Requirement Exists (Direct CIAO Alignment)

- **CIAO Principle 16**: Helpers consume `TTY`; they do not re-test.  
- **CIAO Principle 5**: One confirm family.  
- **CIAO Principle 2**: Dest question is one-off yes/no.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution**: Non-TTY returns no / default.  
- **Intentional**: Bodies here; mode policy on the interactive REQ.  
- **Anti-fragile**: `--json` cannot hang.  
- **Over-protect**: No skip/quit/maybe on dest confirm.

---

## 4. Protection Rule (Sacred)

**Future AI assistants or maintainers MUST NOT**:

1. Re-test `[ -t` inside `prompt_*` as the policy gate.  
2. Add a second confirm family or a four-way dest menu.  
3. Use raw `read` for user-visible confirms.  
4. Treat `--force` as auto-approve on dest `interactive`.  
5. Return `prompt_ask` / `prompt_secret` on stdout, or wrap them in `$()` / backticks.  
6. Treat stderr UI or `read </dev/tty` as permission to capture a function that contains `read`.

**Violating any of these is a critical regression.**

---

## 5. Related artifacts (versioned surface only)

| Artifact | Role |
|----------|------|
| `docs/requirements/index.md` | Registry SSOT |
| `docs/requirements/requirement-shell-interactive-vs-noninteractive.md` | Mode / TTY measure |
| `docs/requirements/requirement-dns-actor-table.md` | Dest one-off yes/no |
| `./src/dns-cli` | `prompt_yes_no` / `prompt_ask` / `prompt_secret` |

## 6. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-20 | Active 1.0.0 | `prompt_yes_no` / `prompt_ask` bodies |
| 2026-09-23 | Active 1.2.0 | Current-shell call; `PROMPT_ASK_VALUE`; **TP-CLI-25** · **TP-CLI-27** |
| 2026-09-17 | Active 1.1.0 | Captured `prompt_ask`: UI on stderr; `read` `/dev/tty`; **TP-CLI-25** (superseded call shape) |

**Last Updated**: 2026-09-23  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
