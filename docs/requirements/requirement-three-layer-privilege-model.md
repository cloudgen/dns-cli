**file**: docs/requirements/requirement-three-layer-privilege-model.md  
**Status**: Active (Version 1.1.1)  
**Area**: architecture  
**Key**: `requirement-three-layer-privilege-model`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **project Single Source of Truth** for the **three-layer privilege model** as applied to **folder-backup**: which operations run as the invoking user, which use **narrow elevated sudo**, and what is out of scope.

It is also the **product law SSOT for working with sudoers fragment files**: how the CLI **emits** a draft, what the fragment **must / must not** contain, how an **admin** validates and installs under `/etc/sudoers.d/`, how **runtime deposit** uses allowlisted `sudo -n`, and how **fail-closed** behaves when elevation is missing.

Domain backup semantics (naming, tar, pillars) live in `requirement-domain-folder-backup.md`. Agent procedure for security-gated create is **`SK-CREATE-SUDOERS-FILE`** (not product-source authority).

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Layer map (this product)

| Layer | Privilege | Actor | folder-backup responsibilities |
|-------|-----------|-------|--------------------------------|
| **Type 0** | Invoking user | End user / automation | Local install/uninstall, diagnostics, path report, tar.gz **create** in user staging, **print / write draft** sudoers fragment |
| **Type 1** | Elevated (controlled sudo) | root via **allowlisted** command only | **mkdir** (deposit dir only when allowlisted) + **copy/install** staged archive into `/var/backup/folder-backup/` only |
| **Type 2** | Dedicated least-privilege system user | App runtime user | **Not used** — no dedicated app user required |

### 2.2 Least-privilege rules

1. **MUST NOT** require the whole CLI to run as root for normal backup creation.  
2. **MUST** create the tar.gz archive as the invoking user in isolated staging.  
3. **MUST** elevate only for the **deposit** step (and only via allowlisted sudo).  
4. **MUST NOT** grant unrestricted shell, package install, or arbitrary `cp` across the filesystem.  
5. **MUST NOT** open unapproved network egress as part of privilege design (local-only product).  
6. **MUST NOT** treat “sudoers installed” as permission to broaden Cmnds later without a new security review.

---

### 2.3 Working with sudoers fragment files (normative)

#### 2.3.1 Roles and artifacts

| Role | May | Must not |
|------|-----|----------|
| **End user / automation** | Run `print-sudoers`; run `backup` after admin install | Write `/etc/sudoers.d/` as Type 0 |
| **CLI (Type 0)** | Emit fragment to **stdout** or a **user-writable draft path** | Silently install or rewrite `/etc/sudoers.d/*` |
| **Admin (root)** | `visudo -c`, install with mode `0440`, pre-create deposit dir ownership if needed | Install fragments that grant shell/`ALL` |
| **Agent (harness)** | Follow **`SK-CREATE-SUDOERS-FILE`** + **`CL-CREATE-SUDOERS-SECURITY`** before drafting | Auto-write `/etc`; emit without Pass review |

| Artifact | Location (this product) | Authority |
|----------|-------------------------|-----------|
| **Draft fragment** | stdout **or** `${HOME}/.config/folder-backup/sudoers.fragment` (or path arg to `print-sudoers`) | Type 0 write only |
| **Installed fragment** | `/etc/sudoers.d/folder-backup` | Admin only; mode `0440` |
| **Security review (pre-emit)** | `reviews/reports/YYYY-MM-DD-sudoers-security-folder-backup.md` (and local security checklist trail when used) | Required before **agent create** of a new draft |
| **External sudoers audit record** | `docs/whitelists/external-sudoers/records/WS-*.md` | Optional audit; no secrets |

#### 2.3.2 Operator workflow (mandatory order)

| Step | Who | Action |
|------|-----|--------|
| 1 | User | Install ship unit locally/global (`folder-backup install`) so managed path exists |
| 2 | User | Run `folder-backup print-sudoers` **or** `folder-backup print-sudoers <draft-path>` |
| 3 | CLI (Type 0) | Emit **narrow** fragment for the **invoking user** (login name from runtime identity) |
| 4 | **Admin** | Review text; `sudo visudo -c -f <draft>`; `sudo install -m 0440 <draft> /etc/sudoers.d/folder-backup` |
| 5 | **Admin** | Optional: ensure `/var/backup/folder-backup` exists with safe ownership/mode |
| 6 | User | Run `folder-backup backup <dir>`; deposit uses **only** allowlisted `sudo -n` commands |

#### 2.3.3 `print-sudoers` (Type 0) product rules

1. **MUST** emit reviewable plain text suitable for `sudoers(5)` (no passwords, tokens, or private keys).  
2. **MUST NOT** write `/etc/sudoers.d/` or any path under `/etc` from the unprivileged CLI path.  
3. **MUST** target the **invoking user** in User specification lines (product default: current user).  
4. **MUST** document short **admin steps** in human output: `visudo -c`, install mode `0440`, destination name.  
5. When a **path argument** is given, **MUST** write the fragment only to that user-writable path (create parent dirs as needed) and report success via `out_*`.  
6. When **no path** is given, **MUST** print the fragment to **stdout** (plus admin hints on stderr/info channels per output SSOT).  
7. Re-running `print-sudoers` **MUST** be safe (idempotent emit; does not mutate installed `/etc` file).  
8. Fragment content **MUST** match product deposit paths and staging roots used by `fb_deposit_archive` / storage resolve (so allowlisted wildcards actually match runtime stage paths).

#### 2.3.4 Fragment content constraints (mandatory)

Generated or admin-installed fragments for this product **MUST**:

| Rule | Detail |
|------|--------|
| **User-bound** | Only the intended login (e.g. `grok-agent`) — not `ALL` users |
| **Cmnd absolute** | Absolute paths for `/usr/bin/*` and `/bin/*` variants as needed on the host |
| **Destination-bound** | Writable targets limited to `/var/backup/folder-backup/` (and `mkdir -p` of that dir only) |
| **Stage-bound** | `cp` / `install` sources limited to product staging roots for that user (`/dev/shm/folder-backup-<user>/*`, `/tmp/folder-backup-<user>/*`, and cache fallback `${HOME}/.cache/folder-backup-<user>/*` when used) |
| **No broad rights** | **MUST NOT** include `ALL=(ALL) ALL`, `NOPASSWD: ALL`, unrestricted shells (`/bin/sh`, `/bin/bash` as bare Cmnd), or unrestricted `rm`/`chmod`/`chown` over `/` |
| **NOPASSWD scope** | `NOPASSWD:` **MAY** be used **only** for the listed deposit Cmnds so non-interactive `sudo -n` deposit works; residual risk **MUST** be stated in the security review |
| **No secrets** | No passwords, API keys, or private key material in the file or comments |
| **Comments** | Header **SHOULD** state purpose, product, date/generator, and that admin must `visudo -c` |

#### 2.3.4a Example sudoers fragment (this product)

**Illustrative / normative shape** for **folder-backup** deposit after security review Pass.  
**Not** a secret. Admin **MUST** still run `visudo -c` on the host before install.  
**Source of truth for a host apply:** draft often at `${HOME}/.config/folder-backup/sudoers.fragment`; installed at `/etc/sudoers.d/folder-backup`.  
`print-sudoers` may emit an equivalent narrow shape (combined Cmnd lines / `folder-backup-*` stage wildcards); both **MUST** obey §2.3.4.

```sudoers
# folder-backup — narrow deposit allowlist
# Generated: 2026-08-03
# Skill: SK-CREATE-SUDOERS-FILE
# Security review: Pass (reviews/reports/2026-08-03-sudoers-security-folder-backup.md)
# Target user: grok-agent (current user at generation)
# Managed binary (local): /var/www/grok.dr-sense.com/.local/bin/folder-backup
# DO NOT use without: sudo visudo -c -f <this-file>
# Admin install:
#   sudo install -m 0440 <this-file> /etc/sudoers.d/folder-backup
#
# Scope: create deposit dir + copy/install staged archives into
# /var/backup/folder-backup/ only. No full shell. No ALL.

# Create notation directory only
grok-agent ALL=(root) NOPASSWD: /usr/bin/mkdir -p /var/backup/folder-backup
grok-agent ALL=(root) NOPASSWD: /bin/mkdir -p /var/backup/folder-backup

# Deposit from product staging roots (per-user storage isolation)
grok-agent ALL=(root) NOPASSWD: /usr/bin/cp /dev/shm/folder-backup-grok-agent/* /var/backup/folder-backup/
grok-agent ALL=(root) NOPASSWD: /bin/cp /dev/shm/folder-backup-grok-agent/* /var/backup/folder-backup/
grok-agent ALL=(root) NOPASSWD: /usr/bin/cp /tmp/folder-backup-grok-agent/* /var/backup/folder-backup/
grok-agent ALL=(root) NOPASSWD: /bin/cp /tmp/folder-backup-grok-agent/* /var/backup/folder-backup/
grok-agent ALL=(root) NOPASSWD: /usr/bin/cp /var/www/grok.dr-sense.com/.cache/folder-backup-grok-agent/* /var/backup/folder-backup/
grok-agent ALL=(root) NOPASSWD: /bin/cp /var/www/grok.dr-sense.com/.cache/folder-backup-grok-agent/* /var/backup/folder-backup/

# install -m 0640 <stage-file> <dest-file>
grok-agent ALL=(root) NOPASSWD: /usr/bin/install -m 0640 /dev/shm/folder-backup-grok-agent/* /var/backup/folder-backup/*
grok-agent ALL=(root) NOPASSWD: /usr/bin/install -m 0640 /tmp/folder-backup-grok-agent/* /var/backup/folder-backup/*
grok-agent ALL=(root) NOPASSWD: /usr/bin/install -m 0640 /var/www/grok.dr-sense.com/.cache/folder-backup-grok-agent/* /var/backup/folder-backup/*

# Mode on deposited archives under notation dir only
grok-agent ALL=(root) NOPASSWD: /usr/bin/chmod 0640 /var/backup/folder-backup/*
grok-agent ALL=(root) NOPASSWD: /bin/chmod 0640 /var/backup/folder-backup/*

# Post-deposit verification (list members only; no extract)
grok-agent ALL=(root) NOPASSWD: /usr/bin/tar -tzf /var/backup/folder-backup/*
grok-agent ALL=(root) NOPASSWD: /bin/tar -tzf /var/backup/folder-backup/*
```

**What this example intentionally omits:** `NOPASSWD: ALL`, shell Cmnds, package managers, writes outside `/var/backup/folder-backup/`, and elevation of arbitrary paths under `/tmp/*`.

#### 2.3.5 Admin install rules

1. Admin **MUST** validate with `visudo -c -f <file>` before install.  
2. Admin **MUST** install with restrictive mode (typically **`0440`**, owner `root:root`).  
3. Preferred installed path: **`/etc/sudoers.d/folder-backup`**.  
4. Product CLI and agents **MUST NOT** perform this install as a silent Type 0 side effect.  
5. After install, deposit dir **`/var/backup/folder-backup`** **SHOULD** exist (fragment may allowlisted-create it; admin may pre-create).

#### 2.3.6 Runtime elevation after sudoers install

| Rule | Detail |
|------|--------|
| **Invocation** | Non-root deposit **MUST** use `sudo -n` for allowlisted steps after passwordless fragment install |
| **Scope** | Only deposit of the **just-staged** archive into `/var/backup/folder-backup/` (plus allowlisted mkdir of that dir) |
| **Root path** | If `id -u` is 0, deposit **MAY** copy without sudo into the destination |
| **Logging** | Report success/failure via `out_*`; **never** print sudo passwords |
| **Probe honesty** | Diagnostics that report sudo status **SHOULD NOT** claim elevation is impossible solely because `sudo -n true` fails when only **narrow** Cmnds are allowlisted (prefer probing an allowlisted no-op such as allowlisted `mkdir -p` of the deposit dir) |

#### 2.3.7 Fail-closed (mandatory)

If sudo is missing, not authorized for the deposit Cmnd, or the destination cannot be written:

1. Deposit **MUST** fail with non-zero exit.  
2. Human error **MUST** point to `print-sudoers` and admin install under `/etc/sudoers.d/`.  
3. **MUST NOT** silently skip deposit and claim backup success.  
4. **MUST NOT** fall back to writing archives into `/var/backup/...` as an unprivileged user when that path is not writable.

#### 2.3.8 Agent / harness create path (when creating or revising fragments)

When an agent **creates or materially revises** a sudoers draft (beyond re-running product `print-sudoers`):

1. **MUST** follow **`SK-CREATE-SUDOERS-FILE`**.  
2. **MUST** complete **`CL-CREATE-SUDOERS-SECURITY`** with **Pass** before writing the draft file.  
3. **MUST** identify **target user** (default: current user).  
4. **MUST** prove a **managed binary** install exists at global and/or local install location for `folder-backup` when the fragment elevates product-specific helpers; for OS-tool-only deposit (`mkdir`/`cp`/`install`/`chmod` with fixed trees), review **MUST** still document stage and destination bounds.  
5. **MUST** publish a short security review under `reviews/reports/` (or filled checklist) with verdict **Pass**.  
6. **MUST NOT** default the write target to `/etc/sudoers.d/`.  
7. **SHOULD** update `docs/whitelists/external-sudoers/records/WS-*` when the fragment is **applied** on a host (no secrets).

---

### 2.4 Runtime elevation contract (summary)

| Rule | Detail |
|------|--------|
| Invocation | `sudo -n` after passwordless fragment; non-interactive without ticket **fails closed** |
| Scope | Deposit only — not package install, not shell |
| Destination create | Allowlisted `mkdir -p /var/backup/folder-backup` only when fragment permits |
| Staging | Per-user storage under `/dev/shm/folder-backup-<user>` (preferred), else `/tmp/...`, else cache fallback — **must** match fragment wildcards |

### 2.5 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **Product / APP_NAME** | `folder-backup` |
| **Ship unit** | `src/folder-backup` |
| **BACKUP_ROOT** | `/var/backup` |
| **BACKUP_NOTATION default** | `folder-backup` |
| **Deposit directory** | `/var/backup/folder-backup` |
| **Sudoers draft (default)** | `${HOME}/.config/folder-backup/sudoers.fragment` via `print-sudoers <path>` or agent draft path |
| **Admin install path** | `/etc/sudoers.d/folder-backup` |
| **Type 2 system user** | None |
| **CLI command** | `print-sudoers` → `fb_print_sudoers`; deposit → `fb_deposit_archive` |
| **Whitelist meaning** | **Sudoers command allowlist** (narrow lines) — not server-maintenance ops registry |
| **Applied host record** | `docs/whitelists/external-sudoers/records/WS-20260803-001-folder-backup.md` |
| **Security review (example)** | `reviews/reports/2026-08-03-sudoers-security-folder-backup.md` |
| **Agent skill / checklist** | `SK-CREATE-SUDOERS-FILE` · `CL-CREATE-SUDOERS-SECURITY` |
| **Example fragment** | §2.3.4a (full text); live draft often `${HOME}/.config/folder-backup/sudoers.fragment` |

### 2.6 Why This Requirement Exists (CIAO)

- **Principle 9 – Three Types of Commands**  
- **Principle 10 – Least-Privilege User**  
- **Principle 1 – Caution**: Fail closed without working sudoers  
- **Principle 20 – Over-protect**: Do not collapse elevation into “just run as root” or `NOPASSWD: ALL`

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution:** Narrow allowlist; admin review gate; fail closed.  
- **Intentional:** Type 0 archive vs Type 1 deposit vs Type 0 print-sudoers are separate.  
- **Anti-fragile:** Clear operator path when elevation missing; draft outside `/etc`.  
- **Over-protect:** No unrestricted sudoers templates; security review before agent create.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Grant `ALL=(ALL) NOPASSWD: ALL` or equivalent in product-generated fragments.  
2. Auto-write `/etc/sudoers.d` from an unprivileged `print-sudoers` or agent draft path.  
3. Require root for tar creation of user-readable source trees.  
4. Introduce Type 2 system user without explicit product redesign.  
5. Use elevation for unrelated package installs or shell escapes.  
6. Store passwords or private keys in sudoers records, fragments, or requirements.  
7. Emit a **new** agent-authored fragment without **Pass** security review (`CL-CREATE-SUDOERS-SECURITY`).  
8. Broaden wildcards to entire `/tmp/*` or home-wide trees without redesign + review.  
9. Mark deposit success when elevated copy failed.  
10. Cite templates/skills as product-source behavioral authority (source cites **this** requirement and peers).

**Violating this rule is a critical privilege regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | Layer map documents Type 0 vs Type 1 deposit vs no Type 2 |
| AC-2 | `print-sudoers` does not write `/etc/sudoers.d` |
| AC-3 | Deposit fails closed without working allowlisted sudo |
| AC-4 | Generated fragment is narrow (no ALL ALL / NOPASSWD: ALL) |
| AC-5 | Admin install path and `visudo -c` + mode `0440` documented in human output or product docs |
| AC-6 | Fragment stage paths align with runtime storage resolve for the user |
| AC-7 | With admin-installed allowlist, non-root `backup` can deposit via `sudo -n` (host-dependent proof) |
| AC-8 | Agent create path requires security review Pass before draft write |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-folder-archive-backup` | Backup ops that invoke Type 1 deposit/verify |
| `requirement-domain-folder-backup` | Domain surface; print-sudoers verb |
| `requirement-shell-cli-interface` | Command privilege labels (`backup`, `print-sudoers`) |
| `requirement-project-folder` | `/var/backup` deposit paths; config draft location |
| `requirement-shell-cli-storage` | Staging roots that must match sudoers wildcards |
| `requirement-shell-output-requirements` | `out_*` for print-sudoers and deposit errors |
| `docs/requirements/index.md` | Registry |

**Harness (not product source law):** term `sudoers-fragment` · skill `skill-create-sudoers-file.md` · checklist `checklist-create-sudoers-security.md` · policy `policy-least-privilege.md`

---

## Design-time verification

| TP family / ID | Suite | Status |
|----------------|-------|--------|
| **TP-FOLDER-BACKUP-01** | `tests/test_domain_folder_backup.sh` | have — print-sudoers emit; no Type 0 `/etc` write |
| **TP-FOLDER-BACKUP-02** | same | have — file draft; narrow content |
| **TP-FOLDER-BACKUP-05** | same | have — deposit fail-closed without working sudo |
| **TP-FOLDER-BACKUP-07** | same | have — elevated deposit (root **or** allowlisted `sudo -n`) |
| **TP-FOLDER-BACKUP-08** | same | have — next-N after elevated deposit |

**Matrix:** `reviews/requirement-test-matrix.md`  
**Map:** `reviews/test-plan.md`

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-03 | Active 1.0.0 | Privilege + basic sudoers fragment workflow for folder-backup |
| 2026-08-03 | Active 1.1.0 | Full **working with sudoers files** law: roles, content, admin install, fail-closed, agent security gate, RTM elev cases |
| 2026-08-03 | Active 1.1.1 | §2.3.4a **example sudoers fragment** (folder-backup deposit allowlist) |

---

**Last Updated**: 2026-08-03  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; mold `template-three-layer-privilege-model.md` (**`LM-THREE-LAYER-PRIVILEGE-MODEL`**); **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
