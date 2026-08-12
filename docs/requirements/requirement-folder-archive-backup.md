**file**: docs/requirements/requirement-folder-archive-backup.md  
**Status**: Active (Version 1.2.0)  
**Area**: backup  
**Key**: `requirement-folder-archive-backup`  
**Optional RQ-ID**: `RQ-FOLDER-ARCHIVE-BACKUP`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **product Single Source of Truth** for **folder archive backup and restore operations**: validate a source directory, create a gzip tar archive in user staging, allocate a non-overwriting durable name, deposit into a host backup tree (with elevation when required), **verify** integrity (counts and size), **restore** archives to a host project path, and report results.

**Restore destination SSOT (default):** the **hard-disk** host version (`${PROJECTS_ROOT}/${project}`) — the **reverse** of the harness **ram-drive-first** ops rule (which selects RAM as operational SSOT when a RAM-drive project tree is present). Operators may override with an explicit destination or `RESTORE_HOST=ram-drive` / `--ram`.

It is **not** a domain four-pillar file. Domain surface (CLI verbs, help/about) lives in `requirement-domain-folder-backup`. Elevation and sudoers **files** live in `requirement-three-layer-privilege-model`.

**Retention (peer SSOT — not duplicated here):**

| Cap | Default | Law |
|-----|---------|-----|
| **Total** per project basename | **30** | `requirement-folder-archive-backup-retention-total` |
| **Daily** per basename per `YYYYMMDD` | **5** | `requirement-folder-archive-backup-retention-daily` |

After successful deposit + verify, product **MUST** enforce those peers (daily prune then total prune).

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Scope and non-goals

| In scope | Out of scope (unless a future requirement adds them) |
|----------|------------------------------------------------------|
| One-shot `backup <source-folder>` archive + deposit + verify | Continuous scheduler / daemon |
| One-shot `restore <archive|prefix> [dest]` extract + verify | Cloud upload / remote sync |
| Local tar.gz create/extract as invoking user (after optional elev stage fetch) | Interactive GUI restore |
| Durable host deposit under configured root/notation | Full disk imaging |
| Default restore dest = **hard-disk** host version (reverse of ram-drive-first) | Dual-write RAM+disk on restore |
| Count/size verification (backup and restore) | Silent “best effort” partial success |
| Restore dest **whitelist** (incl. `/etc/{{username}}` for invoking user; never `/etc/passwd`) | Blanket allow of all `/etc/*`; restore into `/etc/passwd`; unrestricted extract to OS roots |

### 2.2 Source validation

1. **MUST** require a non-empty source operand.  
2. **MUST** resolve the source to an absolute path that is a **directory**.  
3. **MUST** require the directory to be **readable** by the invoking user.  
4. **MUST** fail closed (non-zero) if missing, not a directory, unreadable, or unresolvable.  
5. **MUST NOT** accept a source that is only a regular file as a “folder backup” without a separate explicit product redesign.

### 2.3 Archive create (Type 0 — invoking user)

1. **MUST** create a **gzip-compressed tar** (`tar -czf` or equivalent).  
2. **MUST** create the archive as the **invoking user** (not as root for the tar step).  
3. **MUST** stage under the product **effective storage** root (scratch/cache resolve) — **not** as an unprivileged direct write into the durable host backup root.  
4. **MUST** place the staged object at a **single path segment** under the storage root so elevation wildcards can match (e.g. `${EFFECTIVE_STORAGE_DIR}/${ARCHIVE_NAME}`).  
5. **MUST** set restrictive stage mode when possible (e.g. `0600`).  
6. **MUST** fail closed if `tar` (or required compression) is missing or tar fails.  
7. **SHOULD** invoke tar so the top-level archive entry is the source folder **basename** (`tar -C parent leaf`).  
8. **MUST** clean up staged files on failure/success via trap or equivalent (no orphaned large stage files left indefinitely on success).

### 2.4 Archive naming (SSOT)

```text
${SOURCE_FOLDER_NAME}-YYYYMMDD-N.tar.gz
```

| Token | Meaning |
|-------|---------|
| `SOURCE_FOLDER_NAME` | Path-safe basename of the source directory |
| `YYYYMMDD` | Local calendar day at backup start (`date +%Y%m%d`) |
| `N` | Positive integer starting at `1`; next free for that basename+day under the durable deposit directory |

Rules:

1. **MUST NOT** overwrite an existing durable archive with the same final name.  
2. **MUST** allocate the next free `N` (no zero-padding unless a later requirement standardizes width).  
3. Basename **MUST** be a single path segment (no `/`); sanitize or reject unsafe names.  
4. Empty, `.`, or `..` basenames **MUST** fail closed.

### 2.5 Durable deposit path

| Concept | Role |
|---------|------|
| `BACKUP_ROOT` | Host durable root for deposited archives |
| `BACKUP_NOTATION` | Product subdirectory under the root |
| Deposit directory | `${BACKUP_ROOT}/${BACKUP_NOTATION}/` |
| Final archive path | `${BACKUP_ROOT}/${BACKUP_NOTATION}/${SOURCE_FOLDER_NAME}-YYYYMMDD-N.tar.gz` |

Rules:

1. Deposit of the durable object into a root-owned tree **MUST** use the **Type 1** elevated path defined by `requirement-three-layer-privilege-model` (allowlisted sudo or root).  
2. **MUST NOT** claim success if the durable file is not present after deposit.  
3. On deposit failure, **MUST** fail closed; **SHOULD** clean staging after a clear error.  
4. Deposited mode **SHOULD** be restrictive (e.g. `0640`) when elevation can set mode.  
5. **MUST NOT** grant unrestricted filesystem write via product elevation (destination-bound only).

### 2.6 Backup verification (mandatory)

Backup is **not complete** until verification rules below pass (or explicit fail-closed).

#### 2.6.1 Inventories

| Metric | Definition |
|--------|------------|
| **Source entries** | Count of paths from `find <source>` (includes the source root directory) |
| **Source files** | Count of regular files under source (`find -type f`) |
| **Archive members** | Lines from `tar -tzf` (all members) |
| **Archive files** | Members whose path does **not** end with `/` (non-directory entries) |
| **Archive size** | Byte size of the archive file |

#### 2.6.2 Stages of verification

| Stage | Required checks | Fail-closed |
|-------|-----------------|-------------|
| **A — Staged archive** | Members == source entries; archive files == source files; size > 0 | **Yes** |
| **B — After deposit** | Durable path exists; size == staged size | **Yes** |
| **C — Deposited re-list** (when possible) | Members/files match stage (and thus source) via direct read or Type 1 `tar -tzf` | **Yes** when re-list succeeds with counts; see 2.6.3 if re-list unavailable |

#### 2.6.3 Deposited re-list availability

1. Deposited archives may be unreadable to the invoking user (e.g. `root:root` `0640`).  
2. Re-list **MAY** use allowlisted `sudo -n tar -tzf <deposit-dir>/*` only (list; **no extract**). Sudoers content SSOT: `requirement-three-layer-privilege-model`.  
3. If re-list is **unavailable**, success is allowed **only** when stage verification (A) and deposited size match (B) passed; human output **MUST** state that re-list was unavailable and that installing `tar -tzf` allowlist enables full re-verify.  
4. If re-list **is** available, **MUST** fail closed on member/file count mismatch.  
5. **MUST NOT** mark `verified=true` if stage verify or size match failed.

#### 2.6.4 Operator-visible verification

Human success **MUST** include at least:

- destination path  
- `source_files`  
- `archive_files` (or members)  
- size  
- verification mode (`dest_tar_list+size` or `stage_counts+dest_size`)

### 2.6b Restore (mandatory)

#### 2.6b.1 Command shape

```text
{{APP_NAME}} restore <archive|project-prefix> [dest-dir]
```

| Operand | Meaning |
|---------|---------|
| `archive` | Exact file under deposit, absolute path, or `NAME-YYYYMMDD-N.tar.gz` |
| `project-prefix` | Latest matching `NAME-YYYYMMDD-N.tar.gz` under deposit (lexicographic sort) |
| `dest-dir` | Optional explicit extract target (overrides host SSOT) |

Flags: `--force` (allow non-empty dest), `--disk` (hard-disk host), `--ram` (RAM-drive host).

#### 2.6b.2 Destination SSOT (default hard-disk)

| Host | Path family | When selected |
|------|-------------|----------------|
| **hard-disk** (default) | `${PROJECTS_ROOT}/${project}` | Default; `--disk`; `RESTORE_HOST=hard-disk` |
| **ram-drive** | `${RAM_ROOT}/${project}` (default `RAM_ROOT=/dev/shm`) | `--ram`; `RESTORE_HOST=ram-drive` |
| **explicit** | User-supplied `dest-dir` | Second positional operand |

1. **MUST** default restore destination host to **hard-disk** (reverse of ram-drive-first ops SSOT).  
2. **MUST** derive `${project}` from archive naming `NAME-YYYYMMDD-N.tar.gz` (strip date-N suffix).  
3. **MUST** resolve `PROJECTS_ROOT` from env or documented detection; fail closed if hard-disk default needed and root unresolved.  
4. **MUST NOT** dual-write RAM and hard-disk in one restore.  
5. **MUST** accept a restore destination only if it passes the **restore destination whitelist** (§2.6b.2a). Paths not on the whitelist **MUST** fail closed (including under `/etc` unless a whitelist row applies).  
6. **MUST** fail closed if dest exists and is non-empty unless `--force`.

#### 2.6b.2a Restore destination whitelist (mandatory — `/etc/{{username}}`)

**Model:** restore destinations are **deny-by-default** for host-critical / FHS system prefixes. Allowed targets are only those that match a **whitelist** row below. Under `/etc`, the **only** product whitelist shape is **`/etc/{{username}}`** (invoking user), **except** the system account database path **`/etc/passwd`**, which is **never** allowed.

**Tokens:**

| Token | Definition |
|-------|------------|
| **`{{username}}`** | Invoking login name: `id -un` (single path segment; not empty, not `.` / `..`, no `/`) |
| **`/etc/{{username}}`** | Exact path `/etc/<username>` (e.g. user `sudo-adm` → `/etc/sudo-adm`) |
| **Under home** | Strict children: `/etc/<username>/…` |

**Always refuse (hard deny — never whitelist):**

| Class | Paths (resolved absolute) |
|-------|---------------------------|
| **OS roots (exact)** | `/`, `/bin`, `/boot`, `/dev`, `/etc`, `/lib`, `/lib64`, `/proc`, `/root`, `/run`, `/sbin`, `/sys`, `/usr`, `/var` (exact match only for these roots) |
| **`/etc/passwd`** | **Always refuse** — system account database; **not** a restore dest, even if `{{username}}` were literally `passwd` |
| **Deposit tree** | `${BACKUP_ROOT}`, `${BACKUP_ROOT}/${BACKUP_NOTATION}`, and extracts that would write *into* the durable deposit as dest |
| **Other product-defined hard denies** | Any additional exact roots / critical files the ship unit documents as hard deny |

**Whitelist (allow only if dest matches one row after resolve):**

| ID | Allowed destination | Notes |
|----|---------------------|-------|
| **W-DISK** | `${PROJECTS_ROOT}/…` under resolved hard-disk projects root | Default host SSOT; project trees |
| **W-RAM** | `${RAM_ROOT}/…` when restore host is ram-drive | Ephemeral host |
| **W-ETC-USER** | **`/etc/{{username}}`** or a path **strictly under** `/etc/{{username}}/` | **Only** invoking `{{username}}`. Example: `sudo-adm` → `/etc/sudo-adm`. **MUST NOT** match `/etc/passwd` (hard deny above wins). **MUST NOT** allow `/etc/<other-user>` |
| **W-HOME** | Exact **passwd home** of the **invoking user** (`getent passwd $(id -un)` field 6), **or strict child**, when that home is **not** already covered by W-ETC-USER | Covers non-`/etc` homes (e.g. `/var/www/…`, `/home/…`). If passwd home is `/etc/{{username}}`, W-ETC-USER is the `/etc` SSOT row |
| **W-TMP / stage family** | Product-documented user-writable temp/stage trees (e.g. under `/tmp`, `/dev/shm` product prefixes) when used as explicit dest | Not a substitute for deposit tree |
| **W-OTHER** | Only if a **future requirement revision** adds an explicit additional row | Do not invent rows in code without law |

**`/etc` rules (normative):**

1. **Exact `/etc` MUST always refuse.**  
2. **`/etc/passwd` MUST always refuse** (hard deny; exception never applies).  
3. **Paths under `/etc/…` MUST refuse by default.**  
4. **Whitelist exception = W-ETC-USER only for `/etc`:** dest **MUST** be allowed by the dest gate when resolved dest is exactly **`/etc/{{username}}`** or a **strict child** of **`/etc/{{username}}/`**, where `{{username}}` is the **invoking** user — **unless** the path is hard-denied (`/etc/passwd`).  
5. **MUST NOT** whitelist all of `/etc/*`, package dirs, or arbitrary siblings (e.g. `/etc/nginx-adm` when invoker is `sudo-adm`).  
6. **MUST NOT** allow user **A** to restore into `/etc/<B>` for a different username **B**.  
7. Evaluation order: **hard deny first** (including `/etc/passwd` and exact `/etc`), then whitelist match. Hard deny wins over any W-* row.  
8. Other FHS prefixes (`/usr`, `/var`, …): exact roots refuse; under-prefix paths allow only via other W-* rows (W-DISK, W-HOME, …) — **not** via W-ETC-USER.

**Must not confuse:**

| Concern | Law |
|---------|-----|
| **`/etc/{{username}}` (W-ETC-USER)** | Restore dest path shape for accounts with home-style trees under `/etc/<user>` |
| **`/etc/passwd`** | System file — **never** a whitelist hit |
| **Restore dest whitelist** (this section) | Type 0 path gate before extract |
| **Sudoers command allowlist** | Type 1 deposit / stage fetch only — does **not** authorize dest under `/etc` |
| **Destructive-path denylist** (delete plane) | Orthogonal skill/term; do not merge into restore dest law |

#### 2.6b.3 Extract and privilege

1. Prefer Type 0 `tar -xzf` on a **user-readable** archive.  
2. If deposit archive is unreadable (e.g. `root:root` `0640`), **MAY** use Type 1 allowlisted `sudo -n cp` from deposit → user stage, then Type 0 extract.  
3. **MUST NOT** allowlisted unrestricted extract to arbitrary system paths; Type 1 remains deposit→stage (and list) only — **not** extract-as-root into `/etc`.  
4. Extract **SHOULD** use `tar -C parent` so the archive top-level folder name is preserved.  
5. After extract, **MUST** verify tree entry/file counts against archive inventory when list is available; fail closed on mismatch.  
6. Human success **MUST** report destination, host class, and verified file counts.  
7. When dest is **W-ETC-USER** (e.g. `/etc/sudo-adm`), extract still runs as the **invoking user** (Type 0); if the tree is not writable by that user, fail closed with a clear permission error — **do not** widen sudoers to fix writability without a separate privilege redesign.

#### 2.6b.4 List

With no restore operand (or explicit list behavior), product **SHOULD** list available deposit archives and show usage (fail closed with non-zero if used as incomplete restore).

### 2.7 Machine contract (JSON)

Successful backup JSON **SHOULD** include:

| Field | Meaning |
|-------|---------|
| `type` / status | Product success convention |
| `app` | Product app name |
| `source` | Absolute source directory |
| `archive_name` | Final basename |
| `destination` | Full durable path |
| `backup_notation` | Notation used |
| `source_entries` | Source entry count |
| `source_files` | Source regular-file count |
| `archive_members` | Member count used for verify report |
| `archive_files` | Non-directory member count |
| `archive_size` | Bytes |
| `verified` | `true` when §2.6 passed |
| `verify_mode` | `dest_tar_list+size` or `stage_counts+dest_size` |
| `version` | Product version when useful |

Errors **MUST** use structured error emission with stable codes when feasible (e.g. `source_invalid`, `tar_failed`, `sudo_required`, `deposit_failed`, `verify_failed`).

### 2.8 Tools and environment

| Tool / input | Requirement |
|--------------|-------------|
| `tar` | **MUST** exist for create and list |
| Compression | gzip via `tar -z` or equivalent **MUST** work |
| `find` | **MUST** exist for source inventory (or documented equivalent) |
| `sudo` | Required for non-root deposit when durable tree is not user-writable |
| Storage resolve | Stage root from product storage rules (peer shell storage requirement) |

### 2.9 Failure matrix (minimum)

| Condition | Expected |
|-----------|----------|
| No source operand | Non-zero; usage/error |
| Source missing / not dir / unreadable | Non-zero |
| tar missing or tar fails | Non-zero; no false success |
| Stage verify count mismatch | Non-zero; no deposit success claim |
| Deposit unauthorized / fails | Non-zero; hint toward print-sudoers / admin when elevation missing |
| Dest missing after deposit | Non-zero |
| Dest size ≠ stage size | Non-zero |
| Dest re-list count mismatch (when listed) | Non-zero |
| Restore dest not on whitelist (§2.6b.2a) | Non-zero; refuse message names gate (not “sudoers missing”) |
| Restore dest = exact `/etc` (or other hard-deny root) | Non-zero |
| Restore dest = **`/etc/passwd`** | Non-zero always (hard deny) |
| Restore dest = **`/etc/{{username}}`** (or under it) for **invoking** user (W-ETC-USER) | Allowed by dest gate (other restore rules still apply) |
| Restore dest = `/etc/<other-user>` | Non-zero (not W-ETC-USER for invoker) |

### 2.10 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **Product / APP_NAME** | `folder-backup` |
| **Ship unit** | `src/folder-backup` |
| **VERSION** | `1.6.0` |
| **CLI verbs** | `backup` → `fb_backup`; `restore` → `fb_restore` |
| **Handlers** | `fb_deposit_archive`, `fb_verify_archive_counts`, `fb_count_*`, `fb_tar_list_stream`, `fb_fetch_archive_readable` |
| **BACKUP_ROOT** | `/var/backup` |
| **BACKUP_NOTATION default** | `folder-backup` |
| **Deposit directory** | `/var/backup/folder-backup` |
| **RESTORE_HOST_DEFAULT** | `hard-disk` (reverse of ram-drive-first) |
| **PROJECTS_ROOT** | env or auto-detect (e.g. `…/prjs`) |
| **RAM_ROOT** | `/dev/shm` |
| **Stage roots** | `/dev/shm/folder-backup-<user>`, `/tmp/folder-backup-<user>`, cache fallback |
| **Archive pattern** | `${SOURCE_FOLDER_NAME}-YYYYMMDD-N.tar.gz` |
| **Verify modes implemented** | `dest_tar_list+size`, `stage_counts+dest_size` |
| **Elevated Cmnds** | deposit cp/install; `tar -tzf` list; restore `cp` deposit→stage |
| **Restore dest gate** | **Whitelist** §2.6b.2a (`fb_refuse_restore_dest` must align: W-ETC-USER `/etc/{{username}}`; never `/etc/passwd`) |
| **W-ETC-USER example (host)** | Invoker `sudo-adm` → allow `/etc/sudo-adm` (+ children); refuse `/etc/passwd`, `/etc/nginx-adm` |
| **Incident** | `docs/incidents/incident-20260812-001-restore-blocklist-refuses-home-under-etc.md` |
| **Suite** | `tests/test_domain_folder_backup.sh` (TP-FOLDER-BACKUP-*) |
| **Primary TP map** | `reviews/test-plan.md` · `reviews/requirement-test-matrix.md` |

### 2.11 Why This Requirement Exists (CIAO)

- **Principle 12 – Right Backup & Restore Strategy**: Dated numbered archives; no silent overwrite; recoverability for folder trees.  
- **Principle 1 – Caution**: Fail closed on bad source, tar, deposit, verify.  
- **Principle 9 – Three Types of Commands**: Tar as Type 0; deposit/verify elev as Type 1 sub-steps only.  
- **Principle 10 – Least privilege**: No “run whole CLI as root.”  
- **Principle 5 – Output SSOT**: Counts and paths via `out_*` / JSON.  
- **Principle 11 – Temps**: Stage under storage resolve; cleanup traps.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution:** Validate, verify, fail loud.  
- **Intentional:** Naming, deposit, and verify modes are explicit.  
- **Anti-fragile:** Stage first; elevation only for deposit/list; clear operator recovery.  
- **Over-protect:** Never skip stage verify; never claim success without size match after deposit; restore dest whitelist is `/etc/{{username}}` only under `/etc` — never `/etc/passwd` or all of `/etc/*`.  
- **Anti-fragile (restore):** Accounts with trees at `/etc/{{username}}` remain recoverable for the **invoking** owner via **W-ETC-USER**.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Overwrite existing `…-YYYYMMDD-N.tar.gz` archives by default.  
2. Skip stage count verification or deposit size verification for “speed.”  
3. Claim backup success when deposit or verification failed.  
4. Write unprivileged durable archives into root-owned `/var/backup` without elevation policy.  
5. Extract archives during verify (list-only).  
6. Move this operational backup law solely into a **domain** four-pillar file (domain may list verbs; this file owns behavior).  
7. Cite templates/skills as product-source behavioral authority.  
8. Implement restore dest as a pure prefix ban on all `/etc/*` **without** whitelist **W-ETC-USER** (`/etc/{{username}}` for the invoking user).  
9. Whitelist **all** of `/etc` or `/etc/*`, allow restore into **`/etc/passwd`**, or allow `/etc/<other-user>` for a different account.  
10. “Fix” W-ETC-USER writability by adding Type 1 extract/`cp` into arbitrary `/etc` paths.

**Violating this rule is a critical backup regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | Source validation fails closed for missing/invalid/unreadable dirs |
| AC-2 | Archive is gzip tar created as invoking user in stage storage |
| AC-3 | Name matches `${SOURCE_FOLDER_NAME}-YYYYMMDD-N.tar.gz` with next-N no overwrite |
| AC-4 | Durable path is under `${BACKUP_ROOT}/${BACKUP_NOTATION}/` |
| AC-5 | Stage verify: members/files match source |
| AC-6 | Deposit size matches stage; dest exists |
| AC-7 | Success reports source_files / archive_files / size / mode |
| AC-8 | JSON includes verify fields when JSON mode used |
| AC-9 | Same-day second backup increments N |
| AC-10 | Deposit failure without elevation is fail-closed with operator hint |
| AC-11 | Restore defaults to hard-disk host path unless overridden |
| AC-12 | Restore refuses non-empty dest without `--force` |
| AC-13 | Restore verifies tree counts against archive when listable |
| AC-14 | Missing archive fail-closed |
| AC-15 | Restore dest gate is **whitelist** (§2.6b.2a): exact `/etc` and other hard-deny roots refuse; dest not on any W-* row refuses |
| AC-16 | **W-ETC-USER:** dest `/etc/{{username}}` or strict child, with `{{username}}` = invoking `id -un`, dest gate **allows** (e.g. `sudo-adm` → `/etc/sudo-adm`) |
| AC-17 | Dest `/etc/<other-user>` is **not** allowed for a different invoker |
| AC-18 | Dest **`/etc/passwd` always refuses** (hard deny; not whitelisted even if username were `passwd`) |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-domain-folder-backup` | Domain surface (verbs, help, about); defers behavior here |
| `requirement-folder-archive-backup-retention-total` | Max **30** archives per basename; oldest-first prune |
| `requirement-folder-archive-backup-retention-daily` | Max **5** archives per basename per day; lowest-`N` same-day prune |
| `requirement-three-layer-privilege-model` | Type 1 deposit + sudoers + tar -tzf allowlist |
| `requirement-shell-cli-storage` | Stage root resolve |
| `requirement-shell-cli-interface` | Dispatch `backup` |
| `requirement-shell-output-requirements` | `out_*` / JSON |
| `requirement-shell-idempotency` | Next-N / re-run safety |
| `requirement-project-folder` | Host path layout |
| `docs/requirements/index.md` | Registry |

---

## Design-time verification

| TP family / ID | Suite | Status | Covers |
|----------------|-------|--------|--------|
| **TP-FOLDER-BACKUP-03** | `tests/test_domain_folder_backup.sh` | have | No source operand |
| **TP-FOLDER-BACKUP-04** | same | have | Missing source dir |
| **TP-FOLDER-BACKUP-05** | same | have | Deposit fail-closed |
| **TP-FOLDER-BACKUP-06** | same | have | Naming pattern / date / tar.gz |
| **TP-FOLDER-BACKUP-07** | same | have when elev | Deposit + verify report |
| **TP-FOLDER-BACKUP-08** | same | have when elev | Next-N |
| **TP-FOLDER-BACKUP-10** | same | have | Leaf basename |
| **TP-FOLDER-BACKUP-11..13** | same | have | Restore missing / explicit dest / hard-disk default |
| **TP-FOLDER-BACKUP-16** | same | **have** | W-ETC-USER: allow `/etc/{{username}}`; refuse `/etc/passwd` and `/etc/<other>` |

**Matrix:** `reviews/requirement-test-matrix.md`  
**Map:** `reviews/test-plan.md`

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-03 | Active 1.0.0 | Split operational backup law out of domain; full create/name/deposit/verify coverage |
| 2026-08-03 | Active 1.1.0 | **Restore** feature; default dest host = hard-disk (reverse of ram-drive-first) |
| 2026-08-12 | Active 1.2.0 | Restore dest **whitelist** §2.6b.2a: **W-ETC-USER** = `/etc/{{username}}` (invoker); hard-deny `/etc` and **`/etc/passwd`** (INC-20260812-001) |

---

**Last Updated**: 2026-08-12  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; incident `docs/incidents/incident-20260812-001-restore-blocklist-refuses-home-under-etc.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
