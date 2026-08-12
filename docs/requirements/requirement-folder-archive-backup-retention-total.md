**file**: docs/requirements/requirement-folder-archive-backup-retention-total.md  
**Status**: Active (Version 1.0.0)  
**Area**: backup  
**Key**: `requirement-folder-archive-backup-retention-total`  
**Optional RQ-ID**: `RQ-FOLDER-ARCHIVE-BACKUP-RETENTION-TOTAL`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)  
**Mold**: **`LM-FOLDER-ARCHIVE-BACKUP-RETENTION-TOTAL`** (`template-folder-archive-backup-retention-total.md`)

## 1. Purpose

This requirement is the **product Single Source of Truth** for the **maximum total number of durable folder-backup archives kept per project basename** under the deposit directory.

| Constant | Default | Meaning |
|----------|---------|---------|
| **`MAX_TOTAL_BACKUPS`** | **30** | After successful deposit, if more than 30 matching archives exist for that basename, **remove oldest** until count ≤ 30 |

It does **not** own create/name/deposit/verify/restore (those stay in `requirement-folder-archive-backup`). Daily per-day cap is **`requirement-folder-archive-backup-retention-daily`**.

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Scope of count

1. **MUST** count only files under  
   `${BACKUP_ROOT}/${BACKUP_NOTATION}/`  
   matching  
   `${SOURCE_FOLDER_NAME}-YYYYMMDD-N.tar.gz`  
   for the **same** `SOURCE_FOLDER_NAME` as the backup just deposited (or the basename under prune).  
2. **MUST NOT** count other projects’ basenames toward this total.  
3. **MUST NOT** count stage trees, hop trees (`.h1-backup-*` / `.h2-backup-*`), or non-matching names.  
4. Scope is **per project basename**, not one global 30 across all projects in the deposit dir.

### 2.2 Cap

1. Default **`MAX_TOTAL_BACKUPS=30`**.  
2. Env **`MAX_TOTAL_BACKUPS`** **MAY** override when set to a positive integer; empty/invalid **MUST** fall back to **30**.  
3. **MUST NOT** treat `0` or negative as “unlimited.”

### 2.3 When to enforce

1. **MUST** run retention **after** successful durable deposit **and** backup verification for that run.  
2. **MUST NOT** prune older archives because of a **failed** backup.  
3. **MUST NOT** use prune as a substitute for next-`N` allocation (no overwrite of existing names).

### 2.4 Oldest-first prune

1. **Oldest** = smallest `YYYYMMDD`, then smallest `N` among matching archives.  
2. **MUST** delete oldest first until count ≤ `MAX_TOTAL_BACKUPS`.  
3. **MUST** prefer retaining the just-deposited archive: remove **older** files first.  
4. After prune, matching count **MUST** be ≤ 30 (or effective cap).

### 2.5 Delete safety

1. **MUST** delete only individual matching `.tar.gz` archive files under  
   `${BACKUP_ROOT}/${BACKUP_NOTATION}/`.  
2. **MUST NOT** recursively delete the deposit directory, `/var/backup`, or any path outside the notation dir.  
3. **MUST NOT** delete other basenames or non-pattern files.  
4. When deposit is root-owned, delete **MUST** use Type 1 **narrow** allowlisted remove (or root) of matching archives only — elev law peer: `requirement-three-layer-privilege-model` (add Table A row when implemented; **MUST NOT** `NOPASSWD: ALL` or unrestricted `rm`).  
5. If prune cannot run (no elev) while count remains above cap, product **MUST** fail closed with operator hint **or** emit a clear non-success residual — **MUST NOT** silently ignore required retention.

### 2.6 Interaction with daily retention

1. When daily retention is Active, **daily prune SHOULD run before total prune**.  
2. Total cap **MUST NOT** allow more than the daily cap on a single day when daily law is Active.

### 2.7 Operator visibility

1. Human mode **SHOULD** log removed basenames/paths (or counts) and remaining count vs cap.  
2. JSON mode **SHOULD** include `retention_total_cap`, `retention_total_removed`, `retention_total_remaining` when prune runs.

### 2.8 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **Product / APP_NAME** | `folder-backup` |
| **Ship unit** | `src/folder-backup` |
| **Deposit** | `/var/backup/folder-backup/` (env `BACKUP_ROOT` / `BACKUP_NOTATION`) |
| **Naming** | `${SOURCE_FOLDER_NAME}-YYYYMMDD-N.tar.gz` |
| **MAX_TOTAL_BACKUPS** | `30` (env override allowed) |
| **Prune timing** | after successful `fb_backup` deposit + verify |
| **Elev delete** | `print-sudoers`: `/bin/rm -f` + `/usr/bin/rm -f` under deposit `*.tar.gz` only |
| **Peer ops law** | `requirement-folder-archive-backup` |
| **Peer daily** | `requirement-folder-archive-backup-retention-daily` |

### 2.9 Why This Requirement Exists (CIAO)

- **Principle 12 – Backup:** Recoverability with **bounded** deposit growth.  
- **Principle 1 – Caution:** Pattern-matched delete only.  
- **Principle 10 – Least privilege:** No broad filesystem delete elev.  
- **Anti-fragile:** Disk/fill risk reduced without overwriting history arbitrarily.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- Cap is intentional product law (30).  
- Oldest-first; per-basename isolation.  
- Fail closed on unsafe paths and missing elev when prune is required.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Leave per-basename total unbounded while this requirement is Active.  
2. Prune **other** projects’ archives to free slots for this basename.  
3. Implement retention via `rm -rf` of deposit or host roots.  
4. Overwrite existing archives instead of deleting oldest.  
5. Delete the newest archive while older matching archives remain.  
6. Add unrestricted `rm` / shell elev for “cleanup convenience.”  
7. Confuse this total cap with the **daily** cap (peer daily requirement).

**Violating this rule is a critical retention / data-loss process regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | Default total cap is **30** per `SOURCE_FOLDER_NAME` |
| AC-2 | After successful backup, if count > 30, oldest removed until ≤ 30 |
| AC-3 | Other basenames never deleted by this prune |
| AC-4 | Non-matching files under deposit not deleted |
| AC-5 | Failed backup does not trigger prune of prior archives |
| AC-6 | Just-deposited archive retained when older archives exist |
| AC-7 | Missing elev for required delete is fail-closed or explicitly reported |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-folder-archive-backup` | Create / deposit / verify / restore ops SSOT |
| `requirement-folder-archive-backup-retention-daily` | Max **5** per basename per day |
| `requirement-three-layer-privilege-model` | Narrow elev for deposit delete when needed |
| `requirement-shell-idempotency` | Next-N no overwrite (orthogonal to prune) |
| `requirement-domain-folder-backup` | Domain surface only |
| `docs/requirements/index.md` | Registry |

---

## Design-time verification

| TP family / ID | Suite | Status |
|----------------|-------|--------|
| **TP-FOLDER-BACKUP-17** | `tests/test_domain_folder_backup.sh` | **have** — total cap prune |
| **TP-FOLDER-BACKUP-17b** | same | **have** — no cross-basename delete |

**Matrix:** `reviews/requirement-test-matrix.md`  
**Map:** `reviews/test-plan.md`

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-12 | Active 1.0.0 | Total cap **30** per basename; oldest-first prune after successful deposit |

---

**Last Updated**: 2026-08-12  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; mold **`LM-FOLDER-ARCHIVE-BACKUP-RETENTION-TOTAL`**; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
