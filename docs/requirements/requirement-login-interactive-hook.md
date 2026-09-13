**file**: docs/requirements/requirement-login-interactive-hook.md  
**Status**: Active (Version 1.2.0) — doorbell `/usr/local/bin/dns-review-hooks`; heal rewrites old `dns-cli`, `dns-cli-hook`, and `login-review-hook`  
**Area**: architecture  
**Key**: `requirement-login-interactive-hook`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **Single Source of Truth** for the **login-interactive review hook**: the marker-guarded `.bashrc` snippet, create-if-absent `.profile`, **heal** of that plant on the **`dns-adm`** account, and this product’s doorbell **`/usr/local/bin/dns-review-hooks`**.

It does **not** own dest who (`requirement-dns-actor-table`), dest yes/no, dest fence meaning, or the `login-hook-elev` JSON body (`requirement-sudoer-json-file`). Approver identity **`dns-adm`** stays on `requirement-dns-approver`.

This product **MUST** plant `/usr/local/bin/dns-review-hooks` (symlink to `/usr/local/bin/dns-cli` when missing). It **MUST NOT** plant leftover `dns-cli-hook`. It **MUST NOT** plant sibling `login-review-hook` in `dns-adm` rc (that name is sudoer-cli’s doorbell). If `dns-review-hooks` already exists, **MUST NOT** overwrite it. **MUST NOT** overwrite sibling `login-review-hook`.

### 1.1 Human-facing

**In one sentence:** When **`dns-adm`** logs in at a keyboard, `.bashrc` starts **one** review through **`/usr/local/bin/dns-review-hooks`**; heal rewrites old `dns-cli interactive`, `dns-cli-hook`, and `login-review-hook` lines to that name.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | `dns-adm` at a TTY | `ssh dns-adm@host` |
| Similar app | Sibling doorbell is a different name | sudoer-cli uses `login-review-hook` |
| Not this file | Who dest-approves, or dest yes/no | `requirement-dns-actor-table` |

| Includes | Excludes |
|----------|----------|
| Soft link `/usr/local/bin/dns-review-hooks`; heal of `dns-adm` rc; old-hook rewrite | Second approver account; dest fence catalog; planting `dns-cli-hook` or sibling `login-review-hook` |
| Skip scp / no TTY; `sudo -n` fail warns | Hijacking empty `dns-cli` as review |

| Surface | What you open | What for |
|---------|---------------|----------|
| `/usr/local/bin/dns-review-hooks` | Soft link | This product’s doorbell |
| `dns-adm` `.bashrc` | File | Marker-guarded snippet |
| `sudo -n /usr/local/bin/dns-review-hooks interactive` | Command | Start review once |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| First-time host prepare | `setup` creates `dns-review-hooks` when missing | `sudo dns-cli setup` |
| Log in as `dns-adm` | Hook runs if guards pass | (login) |
| Old hook still in `.bashrc` | Heal rewrites `dns-cli` / `dns-cli-hook` / `login-review-hook` to `dns-review-hooks` | `dns-cli` (interactive as `dns-adm`) |

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 When this file applies

**HOOK-M1.** This product **claims** login-time review. After a **TTY login** as **`dns-adm`**, a hook **MUST** run **`sudo -n /usr/local/bin/dns-review-hooks interactive`** **once** per session. Empty argv of `dns-cli` **MUST** remain help. `scp` / `SSH_ORIGINAL_COMMAND` / non-TTY **MUST** skip. `sudo -n` fail **MUST** warn on stderr and **MUST NOT** block login (`exit` from the login shell is forbidden). The snippet **MUST** redirect that `sudo -n` stderr (`2>/dev/null`) so sudo’s `a password is required` does **not** look like a password prompt, then print a human next step: dest-approve **`login-hook-elev`** via sibling `sudoer-cli interactive` as `sudoer-adm`. Dest review after launch is `requirement-dns-actor-table` ACT-M4.

This product’s F6 (`%sudo ALL=(dns-adm) NOPASSWD: /usr/local/bin/dns-cli`) is **not** that grant. Sibling `sudoer-cli` F6 grants `sudoer-adm ALL=(root) NOPASSWD: …-hook` because that product dest-writes `/etc/sudoers.d`. This product **MUST NOT** dest-write `/etc/sudoers.d` and **MUST NOT** copy whole-CLI-as-root onto F6. The live hook grant stays sibling dest `/etc/sudoers.d/dns-cli-dns-adm` after `login-hook-elev` approve.

### 2.2 Login-hook-symlink (`/usr/local/bin/dns-review-hooks`)

**HOOK-M2.** The login-hook identity **MUST** be the **soft link** **`/usr/local/bin/dns-review-hooks`**. `.bashrc` and `login-hook-elev` **MUST** both call that name. They **MUST NOT** call `/usr/local/bin/${APP_NAME} interactive` as the live hook identity. They **MUST NOT** plant leftover `/usr/local/bin/${APP_NAME}-hook`. They **MUST NOT** plant sibling `/usr/local/bin/login-review-hook` in `dns-adm` rc.

**Why a separate name.** `dns-adm` login **MUST** start **this** product’s review, not sibling `sudoer-cli`. Sibling doorbell `login-review-hook` may already point at `sudoer-cli`. This product therefore uses **`dns-review-hooks`**.

1. A host admin **MAY** retarget `dns-review-hooks` without rewriting `dns-adm` `.bashrc`.  
2. This product **MUST NOT** overwrite an existing `dns-review-hooks`. **MUST NOT** overwrite sibling `login-review-hook`.  
3. Heal of the **`dns-adm`** account can detect an **old** product-binary, `dns-cli-hook`, or `login-review-hook` line and update it to `dns-review-hooks` (HOOK-M5).

**HOOK-M3.** Type 1 `setup`, when the global binary `/usr/local/bin/dns-cli` exists, **MUST** create `/usr/local/bin/dns-review-hooks` → `/usr/local/bin/dns-cli` **if that name is absent**. **MUST NOT** overwrite an existing `dns-review-hooks`. **MUST NOT** reverse-symlink `dns-cli` onto the doorbell. **MUST NOT** create or retarget sibling `login-review-hook`. `CF_TEST_LPU=1` **MUST NOT** create the live symlink. Type 2 switch grants stay `/usr/local/bin/dns-cli`. `remove-lpu` **MUST NOT** unlink the global hook name. Grant JSON path is `requirement-sudoer-json-file`.

### 2.3 Heal when interactive and invoker is `dns-adm`

**HOOK-M4.** When the process is **interactive** (`TTY=1`) **and** `JSON` is not 1 **and** `id -un` equals `dns-adm` (or test override `CF_APPROVER_USER`):

1. **Check** the **`dns-adm`** account home `${HOME}/.bashrc` for `# BEGIN dns-cli login hook` … `# END dns-cli login hook`. If missing, **append** the complete snippet in §2.5 (uses `/usr/local/bin/dns-review-hooks`). Create `.bashrc` if absent. **MUST NOT** duplicate the block.  
2. **HOOK-M5. Old-hook rewrite (sacred).** If the block is present and still runs `sudo -n /usr/local/bin/dns-cli interactive` (old product-binary), `sudo -n /usr/local/bin/dns-cli-hook interactive` (old per-app doorbell), **or** `sudo -n /usr/local/bin/login-review-hook interactive` (sibling doorbell), **rewrite** that line to `sudo -n /usr/local/bin/dns-review-hooks interactive 2>/dev/null`. If the line already uses `dns-review-hooks` but lacks `2>/dev/null` or the skip next-step, **rewrite** those. Already complete → no-op. Type 1 `setup` **MUST** run the same check on the `dns-adm` home.

**HOOK-M6. Type 1 `interactive` reviews `dns-adm` rc (sibling-aligned).** When euid is 0, dest `interactive` **MUST** review the dedicated approver home (not the invoker’s `HOME`): ensure the login-hook-symlink, then run the same heal as HOOK-M4/M5 on that home. `CF_TEST_LPU=1` **MUST NOT** write the live `dns-adm` home. Non-root `interactive` **MUST NOT** inspect another user’s rc. Invocation: `sudo dns-cli interactive`. Peer: sibling `sudoer-cli` `lpu_review_old_login_hook`.  
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
sudo dns-cli interactive
sudo -n /usr/local/bin/dns-review-hooks interactive
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
    if ! sudo -n /usr/local/bin/dns-review-hooks interactive 2>/dev/null; then
        printf '%s\n' "dns-cli: login review hook skipped (sudo -n failed). Next: as sudoer-adm, sudo sudoer-cli interactive to approve login-hook-elev." >&2
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
| **Hook name** | `/usr/local/bin/dns-review-hooks` (pinned plant path for future `dns-adm` `.bashrc`; create symlink when missing; do not overwrite) |
| **Old hooks** | `dns-cli interactive` · `dns-cli-hook` · sibling `login-review-hook` |
| **New hook** | `sudo -n /usr/local/bin/dns-review-hooks interactive` |
| **Hook variable** | `DNS_CLI_HOOK_RAN` |
| **Rc heal** | **Implemented** on `src/dns-cli` (`cf_approver_heal_login_rc` / `cf_approver_apply_hook_to_bashrc`); `setup` also heals the new home (`lpu_heal_home_rc`) and ensures the symlink (`lpu_ensure_login_hook_symlink`) |
| **Test override** | `CF_APPROVER_USER` (default `dns-adm`); `CF_TEST_HEAL_RC=1` skips TTY for suite; `CF_TEST_LPU=1` skips live `/usr/local/bin` |
| **Proof** | **TP-CF-APR-01..09** · **TP-LPU-08** |

### 2.9 Why This Requirement Exists (Direct CIAO Alignment)

- **CIAO Principle 16 – Interactive**: Heal and hook only when interactive; skip scp/JSON.  
- **CIAO Principle 2 – Intentional**: The common doorbell is explicit; empty argv stays help.  
- **CIAO Principle 5 – SSOT**: One file owns plant + symlink; dest review stays on the actor table.  
- **CIAO Principle 10 – Least privilege**: Only the `dns-adm` home is written.  
- **CIAO Principle 3 – Anti-fragile**: Old hook on `dns-adm` is rewritten; a retargeted name is not overwritten.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution:** Do not overwrite an existing `.profile` or an existing `-hook` name.  
- **Intentional:** Soft link `/usr/local/bin/dns-review-hooks` so `dns-adm` login starts this product’s review.  
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
8. Leave an old `dns-cli interactive`, `dns-cli-hook`, or sibling `login-review-hook` line in the `dns-adm` `.bashrc` after heal or Type 1 `interactive`.  
8a. Let sudo’s `a password is required` be the only skip text (hide it; print the `login-hook-elev` next step).  
8b. Skip Type 1 `interactive` review of `dns-adm` rc when euid is 0.  
9. Overwrite an existing `/usr/local/bin/dns-review-hooks`, reverse-symlink `dns-cli` onto the doorbell, or create that live symlink from `CF_TEST_LPU=1`.  
9a. Plant leftover `/usr/local/bin/dns-cli-hook` or sibling `/usr/local/bin/login-review-hook` as this product’s live doorbell.  
10. Treat rc heal as the `login-hook-elev` grant.  
11. Unlink the global doorbell from `remove-lpu`.

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-HOOK1 | Interactive + `dns-adm` → `.bashrc` contains hook markers and `/usr/local/bin/dns-review-hooks` |
| AC-HOOK2 | Missing `.profile` is created and sources `.bashrc` |
| AC-HOOK3 | Existing `.profile` is left unchanged |
| AC-HOOK4 | Non-approver does not write rc |
| AC-HOOK5 | `--json` / non-interactive does not heal |
| AC-HOOK6 | Second heal does not duplicate the hook block |
| AC-HOOK7 | After rc create/modify, owner is the corresponding user (`dns-adm`) |
| AC-HOOK8 | Heal of the `dns-adm` account rewrites old `dns-cli`, `dns-cli-hook`, and `login-review-hook` lines to `/usr/local/bin/dns-review-hooks` |
| AC-HOOK9 | Setup creates `dns-review-hooks` only when missing; test-mode does not write live `/usr/local/bin` |
| AC-HOOK10 | Host admin MAY retarget an existing `dns-review-hooks`; this product MUST NOT overwrite it |
| AC-HOOK11 | Snippet `sudo -n` redirects stderr; skip names `login-hook-elev` next via `sudoer-cli interactive` |
| AC-HOOK12 | Type 1 `interactive` (euid 0) calls `lpu_review_old_login_hook`; test-mode skips live home |

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
| **TP-CF-APR-08** | test_cf_approver | have | heal rewrites old `dns-cli`, `dns-cli-hook`, and `login-review-hook` to `dns-review-hooks` |
| **TP-CF-APR-09** | test_cf_approver | have | Type 1 `interactive` reviews `dns-adm` rc (`lpu_review_old_login_hook`); already-common not rewritten; snippet skip names login-hook-elev |
| **TP-LPU-08** | `tests/test_cf_lpu.sh` | have | L-M15 login-hook-symlink helper; test-mode skips live `/usr/local/bin` |

**Map:** `reviews/test-plan.md`

---

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-09-13 | Active 1.2.0 | Doorbell `/usr/local/bin/dns-review-hooks`. Heal / Type 1 `interactive` rewrite old product-binary, `dns-cli-hook`, and sibling `login-review-hook`. **MUST NOT** plant leftover `dns-cli-hook` or sibling doorbell in `dns-adm` rc. **TP-CF-APR-08** · **TP-CF-APR-09**. |
| 2026-09-08 | Active 1.1.0 | HOOK-M1 skip hides sudo password-required and names `login-hook-elev` next. HOOK-M6 Type 1 `interactive` reviews `dns-adm` rc (sibling `lpu_review_old_login_hook`). **TP-CF-APR-09**. |
| 2026-09-08 | Active 1.0.0 | Independent login-hook REQ. Soft link `/usr/local/bin/${APP_NAME}-hook` so similar apps can utilize the hook. Heal of `dns-adm` rewrites old `dns-cli interactive` to `dns-cli-hook`. Split from `requirement-dns-approver`. |

---

**Last Updated**: 2026-09-13 (1.2.0)  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
