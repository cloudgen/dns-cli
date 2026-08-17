**file**: docs/requirements/requirement-dns-approver.md  
**Status**: Active (Version 1.0.0) — `dns-adm` is the approver; rc heal **Implemented**; `interactive` review loop **Gap**  
**Area**: architecture  
**Key**: `requirement-dns-approver`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **Single Source of Truth** for the **dns-cli approver**: identity **`dns-adm`**, the **interactive hook after login**, and **heal** of that hook when the CLI runs interactively as the approver.

**Anyone** may submit (`requirement-dns-actor-table`). Only **`dns-adm`** approves. There is **no** second approver account.

Who-may-submit vs who-may-approve stays on `requirement-dns-actor-table`. This file owns **install / heal** of `.bashrc` and `.profile`. LPU F1–F7 stay on `requirement-least-privilege-user`.

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Approver identity

**APR-M1.** The approver **MUST** be **`dns-adm`**. **MUST NOT** invent `dns-apr` or another leaf.

**APR-M2.** Approval-subject is Cloudflare DNS request JSON (`add` / `update` / `remove` / `mode`). Dest on accept is a vault DNS/mode apply — not `/etc/passwd` or `/etc/sudoers.d`.

### 2.2 Interactive hook after login

**APR-M3.** After a **TTY login** as `dns-adm`, a hook **MUST** run **`sudo -n /usr/local/bin/dns-cli interactive`** once per session. Empty argv of `dns-cli` **MUST** remain help. `scp` / non-TTY **MUST** skip. `sudo -n` fail **MUST** warn and **MUST NOT** block login.

The hook snippet **MUST** match `requirement-dns-actor-table` (begin/end markers, `DNS_CLI_HOOK_RAN` set **before** `sudo -n`, identity `id -un` = `dns-adm`).

### 2.3 Heal when interactive and invoker is the approver

**APR-M4.** When the process is **interactive** (`TTY=1`) **and** `JSON` is not 1 **and** `id -un` equals `dns-adm` (or test override `CF_APPROVER_USER`):

1. **Check** `${HOME}/.bashrc` for `# BEGIN dns-cli login hook` … `# END dns-cli login hook`. If missing, **append** the complete snippet. Create `.bashrc` if absent.  
2. **Check** `${HOME}/.profile`.  
   - **Does not exist:** **create** it with the §2.5 profile body (bash login shells **source** `.bashrc`).  
   - **Exists:** **MUST NOT** overwrite.  
3. **MUST NOT** write another user’s home. **MUST NOT** write if `HOME` is `/tmp` or under `/dev/shm`.  
4. Heal **MUST** be idempotent (one hook block; one profile create).  
5. Heal **MUST NOT** change help/version human output (debug only).

`setup` (when implemented) **MUST** run the same heal on the new `dns-adm` home.

### 2.4 Complete login-hook snippet (`.bashrc`)

Same body as `requirement-dns-actor-table` §2.6. Heal **MUST** use that block verbatim.

### 2.5 Complete `.profile` create sample (only when the file is absent)

```sh
# BEGIN dns-cli profile source-bashrc
# Created so a bash login shell sources interactive rc (hook lives in .bashrc).
if [ -n "${BASH_VERSION:-}" ]; then
    if [ -f "${HOME}/.bashrc" ]; then
        . "${HOME}/.bashrc"
    fi
fi
# END dns-cli profile source-bashrc
```

Session `DNS_CLI_HOOK_RAN` **MUST** prevent a second `interactive` if both login and interactive shells source `.bashrc`.

### 2.6 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **Product** | `dns-cli` |
| **Approver** | `dns-adm` |
| **Review verb** | `interactive` (**Gap** — still unknown on 1.4.x; hook will warn until routed) |
| **Rc heal** | **Implemented** on `src/dns-cli` (`cf_approver_heal_login_rc`) |
| **Test override** | `CF_APPROVER_USER` (default `dns-adm`); `CF_TEST_HEAL_RC=1` skips TTY for suite |
| **Proof** | **TP-CF-APR-01..06** |

### 2.7 Why This Requirement Exists (Direct CIAO Alignment)

- **CIAO Principle 16 – Interactive**: Heal and hook only when interactive; skip scp/JSON.  
- **CIAO Principle 2 – Intentional**: Login shells get `.profile` → `.bashrc` → hook once.  
- **CIAO Principle 10 – Least privilege**: Only the approver’s home is written.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution:** Do not overwrite an existing `.profile`.  
- **Intentional:** Hook in `.bashrc`; missing `.profile` only sources it.  
- **Anti-fragile:** Idempotent markers; `sudo -n` fail does not lock login.  
- **Over-protect:** No heal under `/tmp`; no token in rc.

---

## 4. Protection Rule (Sacred)

**MUST NOT**:

1. Invent a second approver account.  
2. Overwrite an existing `.profile`.  
3. Plant the hook in another user’s rc.  
4. Hijack empty argv as `interactive`.  
5. Put a token in `.bashrc` or `.profile`.

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-APR1 | Interactive + approver → `.bashrc` contains hook markers |
| AC-APR2 | Missing `.profile` is created and sources `.bashrc` |
| AC-APR3 | Existing `.profile` is left unchanged |
| AC-APR4 | Non-approver does not write rc |
| AC-APR5 | `--json` / non-interactive does not heal |
| AC-APR6 | Second heal does not duplicate the hook block |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-dns-actor-table` | Actor table + hook snippet + review loop |
| `requirement-least-privilege-user` | `dns-adm` F1–F7 |
| `requirement-domain-cloudflare-dns` | Named machine |
| `requirement-three-layer-privilege-model` | Type 1 approve after F6 |
| `requirement-shell-interactive-vs-noninteractive` | TTY / `--json` |
| `docs/requirements/index.md` | Registry |

---

## Design-time verification

| TP family / ID | Suite | Status | Note |
|----------------|-------|--------|------|
| **TP-CF-APR-01** | `tests/test_cf_approver.sh` | have | heal writes hook into `.bashrc` |
| **TP-CF-APR-02** | test_cf_approver | have | missing `.profile` created, sources `.bashrc` |
| **TP-CF-APR-03** | test_cf_approver | have | existing `.profile` unchanged |
| **TP-CF-APR-04** | test_cf_approver | have | other user / wrong `CF_APPROVER_USER` does not write |
| **TP-CF-APR-05** | test_cf_approver | have | `--json` does not heal |
| **TP-CF-APR-06** | test_cf_approver | have | second heal idempotent |

**Map:** `reviews/test-plan.md`

---

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-17 | Active 1.0.0 | Approver = `dns-adm`; interactive rc heal; create `.profile` if missing |

---

**Last Updated**: 2026-08-17  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
