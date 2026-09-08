**file**: docs/requirements/requirement-login-interactive-hook.md  
**Status**: Active (Version 1.0.0) — independent login-hook plant; `/usr/local/bin/${APP_NAME}-hook` soft link  
**Area**: architecture  
**Key**: `requirement-login-interactive-hook`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **Single Source of Truth** for the **login-interactive review hook**: the marker-guarded `.bashrc` snippet, create-if-absent `.profile`, **heal** of that plant on the **`dns-adm`** account, and the **login-hook-symlink** **`/usr/local/bin/${APP_NAME}-hook`** (this product: `/usr/local/bin/dns-cli-hook`).

It does **not** own dest who (`requirement-dns-actor-table`), dest yes/no, dest fence meaning, or the `login-hook-elev` JSON body (`requirement-sudoer-json-file`). Approver identity **`dns-adm`** stays on `requirement-dns-approver`.

The `-hook` name is a **shared convention**: similar dest CLIs plant `/usr/local/bin/{{appname}}-hook` so a host admin **MAY** retarget the soft link at another similar program without rewriting `dns-adm` rc.

### 1.1 Human-facing

**In one sentence:** When **`dns-adm`** logs in at a keyboard, `.bashrc` starts **one** review through the **soft link** **`/usr/local/bin/dns-cli-hook`**; heal of that account rewrites an **old** `dns-cli interactive` line to that `-hook` name.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | `dns-adm` at a TTY | `ssh dns-adm@host` |
| Similar app | May sit behind the same `-hook` name | Host admin retargets `dns-cli-hook` |
| Not this file | Who dest-approves, or dest yes/no | `requirement-dns-actor-table` |

| Includes | Excludes |
|----------|----------|
| Soft link `/usr/local/bin/${APP_NAME}-hook`; heal of `dns-adm` rc; old-hook rewrite | Second approver account; dest fence catalog |
| Skip scp / no TTY; `sudo -n` fail warns | Hijacking empty `dns-cli` as review |

| Surface | What you open | What for |
|---------|---------------|----------|
| `/usr/local/bin/dns-cli-hook` | Soft link | Stable hook identity |
| `dns-adm` `.bashrc` | File | Marker-guarded snippet |
| `sudo -n /usr/local/bin/dns-cli-hook interactive` | Command | Start review once |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| First-time host prepare | `setup` creates the `-hook` name when missing | `sudo dns-cli setup` |
| Log in as `dns-adm` | Hook runs if guards pass | (login) |
| Old hook still in `.bashrc` | Heal rewrites it to `dns-cli-hook` | `dns-cli` (interactive as `dns-adm`) |

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 When this file applies

**HOOK-M1.** This product **claims** login-time review. After a **TTY login** as **`dns-adm`**, a hook **MUST** run **`sudo -n /usr/local/bin/dns-cli-hook interactive`** **once** per session. Empty argv of `dns-cli` **MUST** remain help. `scp` / `SSH_ORIGINAL_COMMAND` / non-TTY **MUST** skip. `sudo -n` fail **MUST** warn on stderr and **MUST NOT** block login (`exit` from the login shell is forbidden). Dest review after launch is `requirement-dns-actor-table` ACT-M4.

### 2.2 Login-hook-symlink (`/usr/local/bin/{{appname}}-hook`)

**HOOK-M2.** The login-hook identity **MUST** be the **soft link** **`/usr/local/bin/${APP_NAME}-hook`** (this product: **`/usr/local/bin/dns-cli-hook`**). `.bashrc` and `login-hook-elev` **MUST** both call that name. They **MUST NOT** call `/usr/local/bin/${APP_NAME} interactive` as the live hook identity.

**Why a separate name.** Similar dest CLIs (this product and peers such as `sudoer-cli`) **MUST** use the same `/usr/local/bin/{{appname}}-hook` convention so:

1. A host admin **MAY** retarget the soft link at **another similar program** without rewriting `dns-adm` `.bashrc`.  
2. This product **MUST NOT** overwrite an existing hook name (it may already point at another similar app).  
3. Heal of the **`dns-adm`** account can detect an **old** hook and update it to the new `-hook` name (HOOK-M5).

**HOOK-M3.** Type 1 `setup`, when the global binary `/usr/local/bin/dns-cli` exists, **MUST** create `/usr/local/bin/dns-cli-hook` → `/usr/local/bin/dns-cli` **if that name is absent**. **MUST NOT** overwrite an existing `dns-cli-hook`. `CF_TEST_LPU=1` **MUST NOT** create the live symlink. Type 2 switch grants stay `/usr/local/bin/dns-cli`. `remove-lpu` **MUST NOT** unlink the global hook name. Grant JSON path is `requirement-sudoer-json-file`.

### 2.3 Heal when interactive and invoker is `dns-adm`

**HOOK-M4.** When the process is **interactive** (`TTY=1`) **and** `JSON` is not 1 **and** `id -un` equals `dns-adm` (or test override `CF_APPROVER_USER`):

1. **Check** the **`dns-adm`** account home `${HOME}/.bashrc` for `# BEGIN dns-cli login hook` … `# END dns-cli login hook`. If missing, **append** the complete snippet in §2.5 (uses `/usr/local/bin/dns-cli-hook`). Create `.bashrc` if absent. **MUST NOT** duplicate the block.  
2. **HOOK-M5. Old-hook rewrite (sacred).** If the block is present and still runs `sudo -n /usr/local/bin/dns-cli interactive` (the **old** hook), **rewrite** that line to `sudo -n /usr/local/bin/dns-cli-hook interactive`. Already on the `-hook` name → no-op. Type 1 `setup` **MUST** run the same check on the `dns-adm` home.  
3. **Check** `${HOME}/.profile`.  
   - **Does not exist:** **create** it with the §2.6 profile body (bash login shells **source** `.bashrc`).  
   - **Exists:** **MUST NOT** overwrite.  
4. **MUST NOT** write another user’s home. **MUST NOT** write if `HOME` is `/tmp` or under `/dev/shm`.  
5. Heal **MUST** be idempotent (one hook block; one profile create; one old-path rewrite).  
6. Heal **MUST NOT** change help/version human output (debug only).  
7. After every create or modify of `.bashrc` / `.profile`, dest **MUST** align **shell-rc file ownership** to the **corresponding user** (`dns-adm` for that home). Writer euid **MUST NOT** remain the owner. Same for `setup` heal of the new home.

`setup` **MUST** run the same heal on the new `dns-adm` home. Rc heal **MUST NOT** be treated as the `login-hook-elev` grant.

### 2.4 Sample invocations (CI-M1a)

```sh
dns-cli interactive
sudo -n /usr/local/bin/dns-cli-hook interactive
sudo dns-cli setup
```

`interactive` is Type 1 as `dns-adm`. Empty argv remains help. The hook **starts** review; dest yes/no stays on `requirement-dns-actor-table`.

### 2.5 Complete login-hook snippet (`.bashrc`) (normative sample)

Markers: `# BEGIN dns-cli login hook` … `# END dns-cli login hook`. Session guard **MUST** be set **before** `sudo -n`.

```sh
# BEGIN dns-cli login hook
if [ -z "${DNS_CLI_HOOK_RAN:-}" ] \
    && [ -n "${PS1:-}" ] \
    && [ -t 0 ] && [ -t 1 ] \
    && case "$-" in *i*) true ;; *) false ;; esac \
    && [ "$(id -un)" = "dns-adm" ] \
    && [ -z "${SSH_ORIGINAL_COMMAND:-}" ]; then
    DNS_CLI_HOOK_RAN=1
    export DNS_CLI_HOOK_RAN
    if ! sudo -n /usr/local/bin/dns-cli-hook interactive; then
        printf '%s\n' "dns-cli: login review hook skipped (sudo -n failed)" >&2
    fi
fi
# END dns-cli login hook
```

F7 **MUST** strip this block from whichever rc files contain it. Peer dest who files **MUST** use this block verbatim.

### 2.6 Complete `.profile` create sample (only when the file is absent)

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

### 2.7 What this file does not own

| Topic | Owner |
|-------|--------|
| Approver identity `dns-adm` | `requirement-dns-approver` |
| Dest who / keep-latest / take-ownership / fence / YAML / yes/no | `requirement-dns-actor-table` |
| `login-hook-elev` JSON body + queue | `requirement-sudoer-json-file` |
| LPU F1–F7 create | `requirement-least-privilege-user` (L-M15 **points** here) |
| Table A ELEV-CF-02 grant line | `requirement-three-layer-privilege-model` |

### 2.8 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **Product** | `dns-cli` (`APP_NAME`) |
| **Approver account** | `dns-adm` |
| **Review verb** | `interactive` |
| **Hook name** | `/usr/local/bin/${APP_NAME}-hook` → `/usr/local/bin/dns-cli-hook` |
| **Old hook** | `sudo -n /usr/local/bin/dns-cli interactive` |
| **New hook** | `sudo -n /usr/local/bin/dns-cli-hook interactive` |
| **Hook variable** | `DNS_CLI_HOOK_RAN` |
| **Rc heal** | **Implemented** on `src/dns-cli` (`cf_approver_heal_login_rc` / `cf_approver_apply_hook_to_bashrc`); `setup` also heals the new home (`lpu_heal_home_rc`) and ensures the symlink (`lpu_ensure_login_hook_symlink`) |
| **Test override** | `CF_APPROVER_USER` (default `dns-adm`); `CF_TEST_HEAL_RC=1` skips TTY for suite; `CF_TEST_LPU=1` skips live `/usr/local/bin` |
| **Proof** | **TP-CF-APR-01..08** · **TP-LPU-08** |

### 2.9 Why This Requirement Exists (Direct CIAO Alignment)

- **CIAO Principle 16 – Interactive**: Heal and hook only when interactive; skip scp/JSON.  
- **CIAO Principle 2 – Intentional**: The `-hook` name is explicit; empty argv stays help.  
- **CIAO Principle 5 – SSOT**: One file owns plant + symlink; dest review stays on the actor table.  
- **CIAO Principle 10 – Least privilege**: Only the `dns-adm` home is written.  
- **CIAO Principle 3 – Anti-fragile**: Old hook on `dns-adm` is rewritten; a retargeted name is not overwritten.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution:** Do not overwrite an existing `.profile` or an existing `-hook` name.  
- **Intentional:** Soft link `/usr/local/bin/{{appname}}-hook` so similar apps can utilize the hook.  
- **Anti-fragile:** Idempotent markers; `sudo -n` fail does not lock login; old path is healed.  
- **Over-protect:** No heal under `/tmp`; no token in rc; test-mode does not write live `/usr/local/bin`.

---

## 4. Protection Rule (Sacred)

**MUST NOT**:

1. Fold this plant back into `requirement-dns-approver` as the only login-hook law.  
2. Hijack empty argv as `interactive`.  
3. Overwrite an existing `.profile`.  
4. Plant the hook in another user’s rc.  
5. Hang `scp` / CI (`sudo` without `-n`, or `exit` on `sudo -n` fail).  
6. Put a token in `.bashrc` or `.profile`.  
7. Leave `.bashrc` / `.profile` owned by root (or the writer) after heal.  
8. Leave an old `sudo -n /usr/local/bin/dns-cli interactive` line in the `dns-adm` `.bashrc` after heal.  
9. Overwrite an existing `/usr/local/bin/dns-cli-hook`, or create that live symlink from `CF_TEST_LPU=1`.  
10. Treat rc heal as the `login-hook-elev` grant.  
11. Unlink the global `-hook` name from `remove-lpu`.

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-HOOK1 | Interactive + `dns-adm` → `.bashrc` contains hook markers and `/usr/local/bin/dns-cli-hook` |
| AC-HOOK2 | Missing `.profile` is created and sources `.bashrc` |
| AC-HOOK3 | Existing `.profile` is left unchanged |
| AC-HOOK4 | Non-approver does not write rc |
| AC-HOOK5 | `--json` / non-interactive does not heal |
| AC-HOOK6 | Second heal does not duplicate the hook block |
| AC-HOOK7 | After rc create/modify, owner is the corresponding user (`dns-adm`) |
| AC-HOOK8 | Heal of the `dns-adm` account rewrites old `/usr/local/bin/dns-cli` hook line to `/usr/local/bin/dns-cli-hook` |
| AC-HOOK9 | Setup creates `dns-cli-hook` only when missing; test-mode does not write live `/usr/local/bin` |
| AC-HOOK10 | Host admin MAY retarget an existing `dns-cli-hook`; this product MUST NOT overwrite it |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-dns-approver` | Approver identity `dns-adm` |
| `requirement-dns-actor-table` | Dest who + dest review loop after launch |
| `requirement-least-privilege-user` | `dns-adm` F1–F7; L-M15 points here |
| `requirement-sudoer-json-file` | `login-hook-elev` JSON `commands[].path` |
| `requirement-three-layer-privilege-model` | ELEV-CF-02 grant line |
| `requirement-shell-cli-interface` | Dual mention of `interactive` |
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
| **TP-CF-APR-08** | test_cf_approver | have | heal rewrites old `/usr/local/bin/dns-cli` hook path to `dns-cli-hook` |
| **TP-LPU-08** | `tests/test_cf_lpu.sh` | have | L-M15 login-hook-symlink helper; test-mode skips live `/usr/local/bin` |

**Map:** `reviews/test-plan.md`

---

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-09-08 | Active 1.0.0 | Independent login-hook REQ. Soft link `/usr/local/bin/${APP_NAME}-hook` so similar apps can utilize the hook. Heal of `dns-adm` rewrites old `dns-cli interactive` to `dns-cli-hook`. Split from `requirement-dns-approver`. |

---

**Last Updated**: 2026-09-08  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
