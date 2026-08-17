**file**: docs/requirements/requirement-least-privilege-user.md  
**Status**: Active (Version 1.0.0) — law Active; host create **Gap**  
**Area**: architecture  
**Key**: `requirement-least-privilege-user`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **Single Source of Truth** for the dedicated **least-privilege user (LPU)** that owns dns-cli’s Cloudflare **API-account vault**.

The operator is **`dns-adm`**. It owns **one** host vault with **N domains**. Each domain is **1 : 1** with one API token and **1 : 1** with one Cloudflare user-id; each domain is **1 : N** with subdomains. `dns-adm` therefore holds **multiple** Cloudflare user-ids. It is **not** itself a Cloudflare user-id.

Elev **Tables A/B/C**, Type 0/1/2 command map, and F6 dest-write rules live in `requirement-three-layer-privilege-model`. Vault **schema** (multi-account, per-domain-id token, subdomains) lives in `requirement-cloudflare-vault`. Default vault **path** lives in `requirement-application-local-vault`. This file owns **who** `dns-adm` is (F1–F7).

`dns-adm` **is** the approver for inbound DNS request JSON (`requirement-dns-actor-table`). Approval-subject: Cloudflare DNS request (`add` / `update` / `remove` / `mode`). **Anyone** may submit. **MUST NOT** invent a second approver account. Login-hook heal (`.bashrc` / missing `.profile`) is `requirement-dns-approver`.

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Operator class

**L-M1.** The product **MUST** provide exactly one LPU leaf for the Cloudflare API-account surface: username **`dns-adm`**, primary group **`dns-adm`**.

**L-M2.** Day-to-day vault and DNS work that uses the **default** LPU vault **MUST** run **as `dns-adm`** (Type 2). Invoker root or another login **MUST** context-switch (`sudo -u dns-adm`) rather than read/write the default vault as themselves.

**L-M3.** `--vault-dir` / `CF_VAULT_DIR` specify (owned by `requirement-application-local-vault`) **MAY** be used by the invoking user (Type 0) for QA. Specify does **not** create the LPU.

**L-M4.** `ip`, `help`, `version`, `about`, `install`, `uninstall`, `where-is-me` **MUST NOT** require `dns-adm` to exist.

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

**Symlinks: none.**

### 2.4 Affected folders (F5)

Bare home **MUST NOT** appear here.

| Path | Owner / mode | Role |
|------|----------------|------|
| `/etc/dns-adm/vault/` (or `${SYSTEM_USER_HOME}/vault/` when home fell back) | `dns-adm:dns-adm` · `0700` | Multi-account Cloudflare vault (schema in vault law) |

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

**L-M9.** `setup` **MUST NOT** require `SUDO_USER` to already be `dns-adm`. Re-run when the account exists: success no-op for useradd; still heal home mode, F5 dir, and F6 dest.

### 2.8 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **Product** | `dns-cli` |
| **LPU** | `dns-adm` |
| **F3 default** | `/etc/dns-adm` (preferred-/etc) |
| **F4** | none |
| **F5** | `/etc/dns-adm/vault/` |
| **F6** | `/etc/dns-adm/sudoers` |
| **F7** | `remove-lpu` |
| **Handlers (target)** | `lpu_setup`, `lpu_remove` |
| **Ship unit** | **Gap** — `src/dns-cli` has no `setup` / `remove-lpu` / `dns-adm` create |
| **Approval-subject** | Cloudflare DNS request JSON (`requirement-cloudflare-dns-request`) |
| **Proof family** | **TP-LPU-*** (todo) |

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

**Violating this rule is a critical least-privilege identity regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-L1 | `setup` creates `dns-adm`, home, `0700` vault dir, and F6 dest `0440` (when implemented) |
| AC-L2 | Re-`setup` is success no-op + heal |
| AC-L3 | Default vault I/O as non-`dns-adm` context-switches or fails `lpu_required` |
| AC-L4 | `--vault-dir` works without the LPU (QA) |
| AC-L5 | `remove-lpu` does not run from Type 0 `uninstall` |
| AC-L6 | Stay-honest: ship unit **Gap** until `lpu_*` exists |

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
| **TP-LPU-01** | `tests/test_cf_lpu.sh` | todo | `setup` creates account+home+vault dir (fakeroot / stub) |
| **TP-LPU-02** | `tests/test_cf_lpu.sh` | todo | re-`setup` no-op |
| **TP-LPU-03** | `tests/test_cf_lpu.sh` | todo | default vault as other user → `lpu_required` or switch |
| **TP-LPU-04** | `tests/test_cf_lpu.sh` | todo | `--vault-dir` without LPU still works |
| **TP-LPU-05** | `tests/test_cf_lpu.sh` | todo | `uninstall` does not `userdel` |
| **TP-LPU-06** | `tests/test_cf_lpu.sh` | todo | `remove-lpu` without `--force` in JSON → `confirm_required` |

**Matrix:** `reviews/requirement-test-matrix.md`  
**Map:** `reviews/test-plan.md`

---

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-17 | Active 1.0.0 | LPU `dns-adm` registered; host create Gap; owns **one** multi-zone vault |

---

**Last Updated**: 2026-08-17  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
