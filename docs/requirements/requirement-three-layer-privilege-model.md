**file**: docs/requirements/requirement-three-layer-privilege-model.md  
**Status**: Active (Version 1.0.0) — law Active; Type 1/2 routes **Gap**  
**Area**: architecture  
**Key**: `requirement-three-layer-privilege-model`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **Single Source of Truth** for dns-cli’s **Type 0 / Type 1 / Type 2** map and for **elev Tables A/B/C**.

It exists because the product now creates LPU **`dns-adm`** and must say **who** may create that account, **who** may run Cloudflare vault/DNS as that account, and **what** a sudoers dest may contain.

Identity F1–F7 live in `requirement-least-privilege-user`. Domain verb semantics live in `requirement-domain-cloudflare-dns`. This file **MUST NOT** invent a second F1–F7 table or a second DNS catalog.

This product is **not** a sudoers-manager. **Absent:** `print-sudoers-install-script`, `remove-project-sudoers`, backup/restore.

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Layer map

| Layer | Privilege | Actor | Responsibilities |
|-------|-----------|-------|------------------|
| **Type 0** | Invoking user | Any login | `help`, `version`, `about`, `install`, `uninstall`, `where-is-me`, `ip`, `print-sudoers` (stdout/draft only), vault/DNS **when** `--vault-dir` / `CF_VAULT_DIR` is specified |
| **Type 1** | Elevated (password `sudo` / already-root) | Host admin | `setup` (create `dns-adm` + F3/F5/F6), `remove-lpu` |
| **Type 2** | Dedicated LPU | `dns-adm` | Default-vault `vault` + `add` / `update` / `remove` / `status` / `show` |

**P-M1.** Every routed command **MUST** sit in exactly one layer (or document a Type 0 entry with an explicit Type 1/2 sub-step).

**P-M2.** Prefer the lowest safe layer. Cloudflare HTTPS is not a reason to run as root.

**P-M3.** Type 1 **MUST** use in-tool password `sudo` (or already-root) for Table C jobs. **MUST NOT** be `sudo -n` for `setup` / `remove-lpu`. **MUST NOT** require `SUDO_USER` to be `dns-adm` (**T1-BOOTSTRAP-N**).

**P-M4.** Type 2 default-vault ops: if euid is not `dns-adm`, the CLI **MUST** re-exec `sudo -u dns-adm` of the **managed global** binary (Table A). If that sudo is unavailable → `lpu_required`. Specified `--vault-dir` **MUST NOT** force this switch.

### 2.2 Table A — Sudoers Cmnd set (fragment contents only)

Not a live-command whitelist. `print-sudoers` and dest `/etc/dns-adm/sudoers` **MUST** be ⊆ these rows.

| ID | Job | Binary (absolute) | Fixed args | Source | Dest | Invoker CLI | Run-as | NOPASSWD? | Sudoers line shape |
|----|-----|-------------------|------------|--------|------|-------------|--------|-----------|--------------------|
| **ELEV-CF-01** | Run managed dns-cli as `dns-adm` | `${GLOBAL_BIN}/dns-cli` (`/usr/local/bin/dns-cli`) | (none — argv follows) | — | — | Type 2 context-switch; operator `sudo -u dns-adm dns-cli …` | `dns-adm` | yes | `%sudo ALL=(dns-adm) NOPASSWD: /usr/local/bin/dns-cli` |

**P-M5.** Production fragment **MUST NOT** elevate `${USER_BIN}/dns-cli`. Local-only install is **test_local** — `setup` **SHOULD** refuse to install F6 dest unless a global managed binary exists, or warn TEST MODE and require `--force`.

### 2.3 Table B — Forbidden in sudoers

| ID | Forbidden | Why |
|----|-----------|-----|
| **FORB-01** | `ALL=(ALL) ALL` / `NOPASSWD: ALL` | Broad admin |
| **FORB-02** | Bare `/bin/sh` / `/bin/bash` / `su` as Cmnd | Residual shell |
| **FORB-03** | `useradd` / `userdel` / `visudo` / package managers | Table C / wrong surface |
| **FORB-04** | Write `/etc/sudoers.d` or `/etc/passwd` | Dest is `/etc/dns-adm/sudoers` |
| **FORB-05** | Elevate `/tmp/…` or `${USER_BIN}/dns-cli` under production Pass | Trust tier |

### 2.4 Table C — Script jobs (not sudoers)

| Job | Tool | When |
|-----|------|------|
| Create account + home | `sudo useradd` | Type 1 `setup` |
| Create group if needed | `sudo groupadd` | Type 1 `setup` |
| Install F6 dest | `visudo -c` then `install -m 0440` as root | Type 1 `setup` |
| Backup F6 | copy → `/etc/sudoer-backup/` | `setup` rewrite / `remove-lpu` |
| Remove account | `sudo userdel -r` | Type 1 `remove-lpu` |

Unlisted live tools are **not** forbidden. **MUST NOT** copy Table C into the fragment.

### 2.5 Commands owned here

| Command | Type | Behavior |
|---------|------|----------|
| `setup` | Type 1 | Create `dns-adm` + F3 + F5 + F6 dest. Idempotent. Password `sudo` / already-root |
| `remove-lpu` | Type 1 | F7 order in LPU law. Confirm unless `--force` |
| `print-sudoers` | Type 0 | Emit Table A fragment to stdout (or a user-writable path). **MUST NOT** write dest. Human output **MUST** include admin steps: `visudo -c`, mode `0440`, dest `/etc/dns-adm/sudoers` |
| `submit` | Type 0 | Inbound JSON drop — **Gap** (`requirement-dns-actor-table`) |
| `approve` / `reject` / `interactive` | Type 1 | Approver move + login review — **Gap**; runas **`dns-adm`** after F6 (same LPU as Type 2 vault/DNS) |

**P-M6.** `print-sudoers` **MUST** end with a newline plus extra blank line. **MUST NOT** contain tokens, keys, or passwords.

**P-M7.** Trimmed parent verbs `print-sudoers-install-script` and `remove-project-sudoers` **MUST** remain unknown.

### 2.6 Example fragment (product — review before dest install)

```sudoers
# dns-cli — run managed CLI as dns-adm (review before install)
# Generated: dns-cli print-sudoers
# Dest: /etc/dns-adm/sudoers
# Admin: visudo -c -f DEST && install -m 0440 DEST /etc/dns-adm/sudoers
# Trust: production only when /usr/local/bin/dns-cli is the managed binary

%sudo ALL=(dns-adm) NOPASSWD: /usr/local/bin/dns-cli

```

### 2.7 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **Product** | `dns-cli` |
| **Type 2 user** | `dns-adm` |
| **Print command** | `print-sudoers` |
| **Admin install-script** | **N/A** — Type 1 `setup` writes dest |
| **Draft path** | stdout, or optional user-writable path argument |
| **Installed dest** | `/etc/dns-adm/sudoers` |
| **Elev-table SSOT** | **this file** |
| **Trust tier** | production = global managed binary; USER_BIN = test_local |
| **Handlers (target)** | `lpu_setup`, `lpu_remove`, `lpu_print_sudoers` |
| **Ship unit** | **Gap** |
| **Proof family** | **TP-PRIV-*** (todo) |

### 2.8 Why This Requirement Exists (Direct CIAO Alignment)

- **CIAO Principle 9 – Three Types of Commands**: Explicit Type 0/1/2.  
- **CIAO Principle 10 – Least privilege**: Fragment runas `dns-adm`, never root ALL.  
- **CIAO Principle 1 – Caution**: Password `sudo` is approval for `setup`.  
- **CIAO Principle 21 – Dual policies**: Filled tables; no hollow “uses sudo.”

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution:** Table A is fragment lines only.  
- **Intentional:** Bootstrap vs day-to-day are different layers.  
- **Anti-fragile:** Specify-vault QA stays Type 0.  
- **Over-protect:** No `/etc/sudoers.d`; dest backups under `/etc/sudoer-backup/`.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Collapse Type 0/1/2 into “just run as root.”  
2. Put `useradd` in sudoers.  
3. Write `/etc/passwd` or `/etc/sudoers.d`.  
4. Elevate `${USER_BIN}/dns-cli` under a production Pass.  
5. Reintroduce `print-sudoers-install-script` / `remove-project-sudoers` / backup / restore without a new user order.  
6. Invent a live-command denylist beyond Table B.  
7. Claim Type 1 Implemented while `setup` is absent.  
8. Duplicate Tables A/B/C in the domain or LPU files.

**Violating this rule is a critical privilege / LLM-escape regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-P1 | Help (when routed) lists `setup` / `remove-lpu` / `print-sudoers` and does not list backup/restore/install-script |
| AC-P2 | `print-sudoers` writes no dest and matches Table A |
| AC-P3 | `setup` uses password `sudo` or already-root — not `sudo -n` |
| AC-P4 | Default-vault DNS as a non-`dns-adm` user needs Table A or fails `lpu_required` |
| AC-P5 | Stay-honest Gap until routes exist |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-least-privilege-user` | F1–F7 identity |
| `requirement-shell-cli-interface` | Dispatch + privilege column |
| `requirement-domain-cloudflare-dns` | Type 2 verb catalog |
| `requirement-application-local-vault` | Specify stays Type 0 |
| `requirement-bootstrap-chain` | Backup/restore still absent |
| `docs/requirements/index.md` | Registry |

---

## Design-time verification

| TP family / ID | Suite | Status | Note |
|----------------|-------|--------|------|
| **TP-PRIV-01** | `tests/test_cf_lpu.sh` | todo | `print-sudoers` ⊆ Table A; no dest write |
| **TP-PRIV-02** | `tests/test_cf_lpu.sh` | todo | unknown: install-script / remove-project-sudoers / backup / restore |
| **TP-PRIV-03** | `tests/test_cf_lpu.sh` | todo | `setup` without root/sudo fails closed |
| **TP-PRIV-04** | `tests/test_cf_lpu.sh` | todo | fragment has no ALL / no shell |

**Matrix:** `reviews/requirement-test-matrix.md`  
**Map:** `reviews/test-plan.md`

---

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-17 | Active 1.0.0 | Type map + Tables A/B/C for `dns-adm`; implementation Gap |

---

**Last Updated**: 2026-08-17  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
