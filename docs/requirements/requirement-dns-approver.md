**file**: docs/requirements/requirement-dns-approver.md  
**Status**: Active (Version 1.6.0) — interactive records original owner then dest-writes `submit_by`  
**Area**: architecture  
**Key**: `requirement-dns-approver`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **Single Source of Truth** for the **dns-cli approver**: identity **`dns-adm`**, the **interactive hook after login**, and **heal** of that hook when the CLI runs interactively as the approver.

**Anyone** may submit (`requirement-dns-actor-table`). Only **`dns-adm`** approves. There is **no** second approver account.

Who-may-submit vs who-may-approve stays on `requirement-dns-actor-table`. This file owns **install / heal** of `.bashrc` and `.profile`. LPU F1–F7 stay on `requirement-least-privilege-user`.

### 1.1 Human-facing

**In one sentence:** When **`dns-adm`** logs in at a keyboard, `.bashrc` starts **one** review. That review **first** takes ownership of waiting files as `dns-adm`, then asks **yes** (approve) or **no** (reject) for each file.

| Box | Meaning | Example |
|-----|---------|---------|
| Approver login | Hook runs once per session | `# BEGIN dns-cli login hook` |
| This file | Heal `.bashrc` / missing `.profile` | Happens on interactive CLI as `dns-adm` |
| Not this | Who may submit | `requirement-dns-actor-table` |

| Includes | Excludes |
|----------|----------|
| Hook snippet + heal | Second approver account |
| Skip scp / no TTY | Hijacking empty `dns-cli` as review |

| Surface | What you open | What for |
|---------|---------------|----------|
| `/home/dns-adm/.bashrc` | File | Hook |
| `sudo -n /usr/local/bin/dns-cli interactive` | Command | Review |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Log in as `dns-adm` | Review starts if inbound has files | (login) |

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Approver identity

**APR-M1.** The approver **MUST** be **`dns-adm`**. **MUST NOT** invent `dns-apr` or another leaf.

**APR-M2.** Approval-subject is Cloudflare DNS request JSON (`add` / `update` / `remove` / `mode`). Dest on accept is a vault DNS/mode apply — not `/etc/passwd` or `/etc/sudoers.d`.

### 2.2 Interactive hook after login

**APR-M3.** After a **TTY login** as `dns-adm`, a hook **MUST** run **`sudo -n /usr/local/bin/dns-cli interactive`** once per session. Empty argv of `dns-cli` **MUST** remain help. `scp` / non-TTY **MUST** skip. `sudo -n` fail **MUST** warn and **MUST NOT** block login. **At the beginning** of `interactive`, dest **MUST** read original file-ownership, take ownership of inbound JSON as **`dns-adm`**, review JSON format, and if the JSON is correct add `submit_by` (human: submit by) set to that original owner, then review. Dest **MUST** handle **fencing first** (this file-based JSON system **MUST** include incorrect JSON format). Dest **MUST NOT** treat dest-written `submit_by` as unknown. If a fence matches: display it in human-facing words and **MUST NOT** ask yes/no for that file. If no fence matched: one **approval question** (term `approval-question`): **yes** = approve, **no** = reject. **MUST NOT** offer skip / quit. Queue move assumes that previous ownership change (`requirement-dns-actor-table` ACT-M4 / ACT-M6).

The hook’s `sudo -n` needs a live grant **`login-hook-elev`** (`dns-adm ALL=(root) NOPASSWD: /usr/local/bin/dns-cli interactive`). That JSON is **not** the Type 0 current-user grant. Type 1 `setup` **MUST** queue it when sibling `sudoer-cli` + `sudoer-adm` exist (`requirement-sudoer-json-file`). Rc heal **MUST NOT** be treated as that grant.

The hook snippet **MUST** match `requirement-dns-actor-table` (begin/end markers, `DNS_CLI_HOOK_RAN` set **before** `sudo -n`, identity `id -un` = `dns-adm`).

### 2.2a Sample invocations (CI-M1a)

```sh
dns-cli interactive
sudo -n /usr/local/bin/dns-cli interactive
```

`interactive` is Type 1 as `dns-adm`. Empty argv remains help. The review loop is **Implemented** on 1.9.0; rc heal is Implemented.

### 2.3 Heal when interactive and invoker is the approver

**APR-M4.** When the process is **interactive** (`TTY=1`) **and** `JSON` is not 1 **and** `id -un` equals `dns-adm` (or test override `CF_APPROVER_USER`):

1. **Check** `${HOME}/.bashrc` for `# BEGIN dns-cli login hook` … `# END dns-cli login hook`. If missing, **append** the complete snippet. Create `.bashrc` if absent.  
2. **Check** `${HOME}/.profile`.  
   - **Does not exist:** **create** it with the §2.5 profile body (bash login shells **source** `.bashrc`).  
   - **Exists:** **MUST NOT** overwrite.  
3. **MUST NOT** write another user’s home. **MUST NOT** write if `HOME` is `/tmp` or under `/dev/shm`.  
4. Heal **MUST** be idempotent (one hook block; one profile create).  
5. Heal **MUST NOT** change help/version human output (debug only).  
6. After every create or modify of `.bashrc` / `.profile`, dest **MUST** align **shell-rc file ownership** to the **corresponding user** (`dns-adm` for that home). Writer euid **MUST NOT** remain the owner. Same for `setup` heal of the new home.

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
| **Review verb** | `interactive` (**Implemented** 1.9.4 — fence first, then yes/no) |
| **Rc heal** | **Implemented** on `src/dns-cli` (`cf_approver_heal_login_rc`); `setup` also heals the new home (`lpu_heal_home_rc`) |
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
6. Leave `.bashrc` / `.profile` owned by root (or the writer) after heal.

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
| AC-APR7 | After rc create/modify, owner is the corresponding user (shell-rc-file-ownership) |

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
| **TP-CF-APR-07** | test_cf_approver | have | heal calls `util_align_rc_owner` (corresponding user) |

**Map:** `reviews/test-plan.md`

---

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-19 | Active 1.6.0 | APR-M3 interactive records original file-ownership, then dest-writes `submit_by` if format is clear |
| 2026-08-19 | Active 1.5.0 | APR-M4 rc heal aligns ownership to corresponding user (shell-rc-file-ownership) |
| 2026-08-19 | Active 1.4.0 | Fence first; human-facing match; then one-off yes/no (approval-system) |
| 2026-08-19 | Active 1.3.0 | Approval question is one-off yes/no (yes=approve, no=reject); term `approval-question` |
| 2026-08-19 | Active 1.2.0 | Login-hook `interactive` takes inbound file-ownership as `dns-adm` **at the beginning** |
| 2026-08-17 | Active 1.0.0 | Approver = `dns-adm`; interactive rc heal; create `.profile` if missing |

---

**Last Updated**: 2026-08-19  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
