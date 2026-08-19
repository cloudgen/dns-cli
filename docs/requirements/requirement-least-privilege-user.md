**file**: docs/requirements/requirement-least-privilege-user.md  
**Status**: Active (Version 1.11.0) — dest Fence row points at `requirement-incorrect-json-format`  
**Area**: architecture  
**Key**: `requirement-least-privilege-user`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **Single Source of Truth** for the dedicated **least-privilege user (LPU)** that owns dns-cli’s Cloudflare **API-account vault**.

The operator is **`dns-adm`**. It owns **one** host vault with **N domains**. Each domain is **1 : 1** with one API token and **1 : 1** with one Cloudflare user-id; each domain is **1 : N** with subdomains. `dns-adm` therefore holds **multiple** Cloudflare user-ids. It is **not** itself a Cloudflare user-id.

Elev **Tables A/B/C**, Type 0/1/2 command map, and F6 dest-write rules live in `requirement-three-layer-privilege-model`. Vault **schema** (multi-account, per-domain-id token, subdomains) lives in `requirement-cloudflare-vault`. Default vault **path** lives in `requirement-application-local-vault`. This file owns **who** `dns-adm` is (F1–F7).

`dns-adm` **is** the approver for inbound DNS request JSON (`requirement-dns-actor-table`). Approval-subject: Cloudflare DNS request (`add` / `update` / `remove` / `mode`). **Anyone** may submit. **MUST NOT** invent a second approver account. Login-hook heal (`.bashrc` / missing `.profile`) is `requirement-dns-approver`.

`dns-adm` **is not** the sudoer-JSON approver. Print sudoer file (`print-sudoers`) and JSON generate/submit roles live in `requirement-sudoer-json-file` §2.0. Sibling approver is **`sudoer-adm`**.

### 1.1 Human-facing

**In one sentence:** **`dns-adm`** is the dedicated account that **owns the Cloudflare vault** and **approves inbound DNS JSON**. A host admin creates it once with `sudo dns-cli setup`.

| Box | Meaning | Example |
|-----|---------|---------|
| Host admin | Creates the account | `sudo dns-cli setup` |
| `dns-adm` | Holds tokens; approves DNS files | vault + `interactive` |
| Not this | Sibling sudoer approver | `sudoer-adm` |

| Includes | Excludes |
|----------|----------|
| Who `dns-adm` is (home, vaults child, sudoers fragment dest) | Inventing `dns-apr` |
| Setup does **not** `chown` sibling inbound | Writing `/etc/sudoers.d` |

| Surface | What you open | What for |
|---------|---------------|----------|
| `sudo dns-cli setup` | Command | Create / heal account |
| `dns-adm` home | Directory | Vault + hook |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| First-time host prepare | Password sudo / already root | `sudo dns-cli setup` |

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Operator class

**L-M1.** The product **MUST** provide exactly one LPU leaf for the Cloudflare API-account surface: username **`dns-adm`**, primary group **`dns-adm`**.

**L-M2.** Day-to-day vault and DNS work that uses the **default** LPU vault **MUST** run **as `dns-adm`** (Type 2). Invoker root or another login **MUST** context-switch (`sudo -u dns-adm`) rather than read/write the default vault as themselves.

**L-M3.** `--vault-dir` / `CF_VAULT_DIR` specify (owned by `requirement-application-local-vault`) **MAY** be used by the invoking user (Type 0) for QA. Specify does **not** create the LPU.

**L-M4.** `ip`, `help`, `version`, `about`, `install`, `uninstall`, `where-is-me`, `print-sudoers`, `generate-sudoer-request`, and `submit-sudoer-request` **MUST NOT** require `dns-adm` to exist. Submit still needs sibling `sudoer-cli` / `sudoer-adm` (not this LPU).

### 2.2 Identity (F1–F3 · Shell)

| Field | Rule |
|-------|------|
| **Username / group** | `dns-adm` / `dns-adm` |
| **F1 UID** | **Not fixed** — distro-assigned. Collision with an existing other account → fail closed `lpu_exists` |
| **F2 GID** | Matching new group `dns-adm` (distro-assigned) |
| **Shell** | `/bin/bash` |
| **F3 home** | Prefer **`/etc/dns-adm`**. If that path is taken by another owner, **`/home/dns-adm`**. Explicit `--home` / product override wins. Record selection reason on create. |
| **Home owner/mode** | `dns-adm:dns-adm` · `0755` |
| **Password login** | Locked (no password). Interactive login **MAY** use the shell for ops; it is not a human full-admin account |

**L-M5.** **MUST NOT** change a live UID/GID/home without explicit operator order (migration).

### 2.3 Symlink map (F4)

| Link | Target | Role |
|------|--------|------|
| `${SYSTEM_USER_HOME}/dns-request` | `/var/dns-cli/dns-request` | F4 view of public DNS inbound |

**MUST NOT** put the public inbound itself under F3 home. Type 0 writes the public real path.

### 2.4 Affected folders (F5)

Bare home **MUST NOT** appear here.

| Path | Owner / mode | Role |
|------|----------------|------|
| `${SYSTEM_USER_HOME}/.local/vaults/` | `dns-adm:dns-adm` · `0700` | LPU local vaults root (same family as Type 0; LPU home) |
| `${SYSTEM_USER_HOME}/.local/vaults/dns-cli/` | `dns-adm:dns-adm` · `0700` | Multi-account Cloudflare vault (schema in vault law) |
| `/var/dns-cli/` | `dns-adm:dns-adm` · `0755` | Public DNS approval root |
| `/var/dns-cli/dns-request` | `dns-adm:dns-adm` · `3773` | Public inbound (Type 0 write; Type 0 **MUST NOT** `mkdir`) |
| `/var/dns-cli/dns-accepted` | `dns-adm:dns-adm` · `0700` | Accepted archive |
| `/var/dns-cli/dns-declined` | `dns-adm:dns-adm` · `0700` | Declined archive |

**L-M6.** `setup` **MUST** `mkdir` only listed F5 paths (plus F3 home). **MUST NOT** chown `/`, `/etc`, or foreign homes.

### 2.5 Sudoers file (F6)

| Property | Rule |
|----------|------|
| **Dest** | `/etc/dns-adm/sudoers` |
| **Owner / mode** | `root:root` · `0440` |
| **Contents** | **Only** Table A from `requirement-three-layer-privilege-model` |
| **Write** | Type 1 `setup` after `visudo -c`. Type 0 **MUST NOT** write dest |
| **Backup on rewrite/remove** | `/etc/sudoer-backup/` — **MUST NOT** land under `/etc/sudoers.d/` |
| **EOF** | Last content line LF-terminated **plus one extra blank line** |

**L-M7.** **MUST NOT** write `/etc/passwd` or `/etc/sudoers.d`. **MUST NOT** emit `ALL=(ALL) ALL`, a shell Cmnd, or `useradd`.

### 2.6 Remove (F7)

**L-M8.** Teardown verb is Type 1 **`remove-lpu`** (not Type 0 `uninstall`).

Order:

1. Confirm unless `--force`; non-interactive without `--force` → `confirm_required`.  
2. Backup then remove F6 dest → `/etc/sudoer-backup/`.  
3. Reverse F4 (none).  
4. **MUST NOT** delete vault files as a side-effect before account removal — operator **SHOULD** `vault` export/clear first; `userdel -r` then removes F3 home (and the F5 vault subtree).  
5. `userdel -r dns-adm` (+ `groupdel` if the group is empty). Home path **MUST** come from passwd — **MUST NOT** hardcode `rm -rf` of home.

Absent account → success no-op.

### 2.7 Create vs remove

| Artifact | Create (`setup`) | Remove (`remove-lpu`) |
|----------|------------------|------------------------|
| Account + F3 home | Type 1 `useradd` (Table C — **not** in F6) | `userdel -r` |
| F5 vault dir | `mkdir` `0700` | goes with home via `userdel -r` |
| F6 dest | `visudo -c` + install `0440` | backup + unlink dest |

**L-M9.** `setup` **MUST NOT** require `SUDO_USER` to already be `dns-adm`. Re-run when the account exists: success no-op for useradd; still heal home mode, F5 dir, F6 dest, and login-hook rc. After any create or modify of that home’s `.bashrc` / `.profile` (and the same rc class), dest **MUST** align **shell-rc file ownership** to **`dns-adm`**. Writer euid **MUST NOT** remain the owner. This is **not** queue file-ownership (L-M13).

**L-M10.** After rc heal, `setup` **MUST** auto-queue a `login-hook-elev` JSON sudoer request when sibling `sudoer-cli` + `sudoer-adm` + writable inbound exist (`requirement-sudoer-json-file`). **MUST** write inbound (dest request-id grammar). **MUST NOT** call dest Type 0 `add-sudoer-request`. Dest Type 0 self-scope **MUST NOT** apply to `setup` (blockage, not dest approval). Missing sibling → skip (setup succeeds). **MUST NOT** `mkdir` inbound, **`chown` inbound**, or write `/etc/sudoers.d`. This is **not** Type 0 `submit-sudoer-request`.

**L-M11. Submit vs setup door.** Who may **submit**: current login, Type 0, no sudo, `type-2-switch` only. Who may **setup**: host admin, Type 1, password `sudo` / already root. **MUST NOT** confuse them. Dest approval does **not** test who submitted.

**L-M12. Three dests.** Setup/account create queues hook JSON; after approve the dest is `/etc/sudoers.d/dns-cli-dns-adm`. Type 0 submit after approve is `/etc/sudoers.d/dns-cli-<invoker>`. F6 is `/etc/dns-adm/sudoers`. Type 2 default-ops grant is F6 or the **invoker** file — **not** `dns-cli-dns-adm`. **MUST NOT** describe setup as writing `dns-cli-leolio`.

**L-M13. Queue ownership.** `setup` **MUST NOT** `chown` dest inbound JSON to `dns-adm` (or any subject). Dest **`sudoer-adm`** takes file-ownership. The JSON username field is **not** the Unix owner. DNS `approve` / `reject` **MUST** take file-ownership as `dns-adm` **before** any queue move. Login-hook `interactive` (`dns-adm` via `sudo -n`) **MUST** take file-ownership of inbound as `dns-adm` **at the beginning**, then review (`requirement-dns-actor-table` ACT-M4 / ACT-M6). Incident **INC-20260818-003**.

**Dest approval fencing conditions (closed).** Dest `approve` / `reject` / review **MUST** fail closed on inbound **only** for **incorrect JSON format**. Dest **MUST NOT** add extra fencing conditions.

| Condition | Dest approve / reject / review |
|-----------|--------------------------------|
| **Incorrect JSON format** | **Fence** — fail closed. Independent REQ: `requirement-incorrect-json-format` |
| File-ownership | **MUST NOT** fence — take ownership as dest LPU |
| Who submitted / dest Type 0 self-scope | **MUST NOT** fence |
| JSON username field ≠ dest LPU | **MUST NOT** fence |
| Filename subject token ≠ JSON username field | **MUST NOT** fence — user SSOT is the JSON field |
| Dest-written `submit_by` / missing `submit_by` | **MUST NOT** fence — dest interactive writes it after format check |

**Incorrect JSON format** includes: not a regular file; not one parseable JSON object; closed-schema fail; field types/enums invalid; basename grammar fail; basename **action** ≠ JSON `action`. Dest **MUST NOT** take the user from the filename; user SSOT is the JSON username field. Type 0 submit self-scope and Type 1 **authz** are **not** dest inbound-file fences. Peer: ACT-M8 · SJ-M5.

### 2.8 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **Product** | `dns-cli` |
| **LPU** | `dns-adm` |
| **F3 default** | `/etc/dns-adm` (preferred-/etc) |
| **F4** | `${SYSTEM_USER_HOME}/dns-request` → `/var/dns-cli/dns-request` |
| **F5** | vaults child + `/var/dns-cli/` trio |
| **F6** | `/etc/dns-adm/sudoers` |
| **F7** | `remove-lpu` |
| **Handlers (target)** | `lpu_setup`, `lpu_remove`, `lpu_submit_login_hook_sudoer_request`, `lpu_type2_maybe_reexec` |
| **Ship unit** | **Implemented** on `src/dns-cli` **1.5.0** (`lpu_setup` / `lpu_remove`; host `useradd` as root; `CF_TEST_LPU=1` stub for CI). F5 dest family **1.8.0**. Type 2 switch **1.8.2** |
| **Approval-subject** | Cloudflare DNS request JSON (`requirement-cloudflare-dns-request`) |
| **Proof family** | **TP-LPU-01..06** have (stub). **TP-LPU-03** default vault as other user → `lpu_required` |

### 2.9 Why This Requirement Exists (Direct CIAO Alignment)

- **CIAO Principle 10 – Least-Privilege User**: One sized operator owns API tokens.  
- **CIAO Principle 9 – Three Types of Commands**: Create is Type 1; vault/DNS as `dns-adm` is Type 2.  
- **CIAO Principle 1 – Caution**: Tokens leave the invoking user’s home.  
- **CIAO Principle 22 – File modes**: Home 0755; vault 0700; F6 0440.  
- **CIAO Principle 21 – Dual policies**: Portable F1–F7 shape; filled notes.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution:** Distro-assigned UID; fail closed on collision.  
- **Intentional:** One LPU for the Cloudflare API-account surface; nginx/gitlab operators are different leaves.  
- **Anti-fragile:** `setup` / `remove-lpu` idempotent; `--vault-dir` keeps tests off the live LPU tree.  
- **Over-protect:** Uninstall never removes the LPU; F6 never grants a shell.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Skip F4, F5, or F6 “because Cloudflare is only an API.”  
2. List bare `/etc/dns-adm` inside affected folders.  
3. Write `/etc/passwd` or `/etc/sudoers.d`, or put F6 backups under `/etc/sudoers.d/`.  
4. Treat Type 0 `uninstall` as F7.  
5. Claim `dns-adm` Implemented while `setup` does not `useradd`.  
6. Collapse `dns-adm` with `nginx-adm` / `gitlab-adm` / the invoking human.  
7. Store tokens in the invoking user’s XDG tree as the **default** production vault.  
8. Fix a UID/GID in core rules as if every host shared it.  
9. Invent a second approver leaf after this redesign — `dns-adm` **is** the approver.  
10. Dump glossary/skill paths into this file.  
11. Add a dest inbound fence that is not **incorrect JSON format** (who submitted, dest Type 0 self-scope, JSON username ≠ dest LPU).

**Violating this rule is a critical least-privilege identity regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-L1 | `setup` creates `dns-adm`, home, `0700` `${SYSTEM_USER_HOME}/.local/vaults/dns-cli/`, and F6 dest `0440` |
| AC-L2 | Re-`setup` is success no-op + heal |
| AC-L2a | `setup` writes `login-hook-elev` inbound when sibling dest exists; skips when missing |
| AC-L2b | Dest Type 0 self-scope does not apply to `setup` (SJ-M3 / L-M11) |
| AC-L2c | `setup` does not `chown` dest inbound (SJ-M5 / L-M13) |
| AC-L2d | After setup rc heal, `.bashrc` / `.profile` owner is `dns-adm` (shell-rc-file-ownership; L-M9) |
| AC-L2d | Dest approval fencing conditions closed: dest inbound fence is incorrect JSON format only (L-M13) |
| AC-L3 | Default vault I/O as non-`dns-adm` context-switches or fails `lpu_required` |
| AC-L4 | `--vault-dir` works without the LPU (QA) |
| AC-L5 | `remove-lpu` does not run from Type 0 `uninstall` |
| AC-L6 | Stay-honest: `setup` Implemented on 1.5.0; Type 2 default-vault switch Implemented on 1.8.2 |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-three-layer-privilege-model` | Type map + Tables A/B/C + dest write |
| `requirement-application-local-vault` | Default path under F5 |
| `requirement-cloudflare-vault` | Multi-account schema |
| `requirement-domain-cloudflare-dns` | Consumes selected account |
| `requirement-shell-cli-interface` | `setup` / `remove-lpu` names |
| `requirement-shell-local-self-management` | `uninstall` ≠ F7 |
| `docs/requirements/index.md` | Registry |

---

## Design-time verification

| TP family / ID | Suite | Status | Note |
|----------------|-------|--------|------|
| **TP-LPU-01** | `tests/test_cf_lpu.sh` | have | `setup` creates account+home+`${home}/.local/vaults/dns-cli` (stub) |
| **TP-LPU-02** | `tests/test_cf_lpu.sh` | have | re-`setup` heal |
| **TP-LPU-03** | `tests/test_cf_lpu.sh` | have | default vault as other user → `lpu_required`; specify skips switch |
| **TP-LPU-04** | `tests/test_cf_lpu.sh` | have | `--vault-dir` without LPU still works |
| **TP-LPU-05** | `tests/test_cf_lpu.sh` | have | `uninstall` does not `userdel` |
| **TP-LPU-06** | `tests/test_cf_lpu.sh` | have | `remove-lpu` without `--force` in JSON → `confirm_required` |
| **TP-LPU-07** | `tests/test_cf_lpu.sh` | have | L-M13 dest inbound fence is incorrect JSON format only |

**Matrix:** `reviews/requirement-test-matrix.md`  
**Map:** `reviews/test-plan.md`

---

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-19 | Active 1.11.0 | Dest Fence row points at `requirement-incorrect-json-format` |
| 2026-08-19 | Active 1.10.0 | L-M13 user SSOT is the JSON username field, not the filename token |
| 2026-08-19 | Active 1.9.0 | L-M13 login-hook `interactive` takes inbound file-ownership as `dns-adm` **at the beginning** |
| 2026-08-18 | Active 1.8.0 | L-M13 dest approval fencing conditions closed: incorrect JSON format only |
| 2026-08-18 | Active 1.7.0 | L-M13 setup MUST NOT `chown` dest inbound; DNS queue move `chown`s first (INC-20260818-003) |
| 2026-08-18 | Active 1.6.0 | F4 inbound view + F5 `/var/dns-cli/` trio (1.9.0 DNS inbound) |
| 2026-08-18 | Active 1.5.0 | L-M12 three dests: setup → `dns-cli-dns-adm`; Type 0 submit → `dns-cli-<invoker>` |
| 2026-08-18 | Active 1.4.0 | Type 2 default-vault switch Implemented (1.8.2 / TP-LPU-03) |
| 2026-08-18 | Active 1.3.0 | L-M11 submit-vs-setup door; dest Type 0 self-scope MUST NOT apply to setup |
| 2026-08-18 | Active 1.2.0 | F5 dest = `${SYSTEM_USER_HOME}/.local/vaults/` + `dns-cli/` child; no hardcode `/etc/dns-adm/vault/` |
| 2026-08-18 | Active 1.1.0 | L-M10: setup auto-queues login-hook sudoer request when sibling exists |
| 2026-08-18 | Active 1.0.0 | Ship unit `setup` / `remove-lpu` Implemented (1.5.0); Type 2 switch still Gap |
| 2026-08-17 | Active 1.0.0 | LPU `dns-adm` registered; host create Gap; owns **one** multi-zone vault |

---

**Last Updated**: 2026-08-19  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
