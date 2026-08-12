**file**: docs/requirements/requirement-folder-archive-backup-retention-daily.md  
**Status**: Active (Version 1.0.0)  
**Area**: backup  
**Key**: `requirement-folder-archive-backup-retention-daily`  
**Optional RQ-ID**: `RQ-FOLDER-ARCHIVE-BACKUP-RETENTION-DAILY`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)  
**Mold**: **`LM-FOLDER-ARCHIVE-BACKUP-RETENTION-DAILY`** (`template-folder-archive-backup-retention-daily.md`)

## 1. Purpose

This requirement is the **product Single Source of Truth** for the **maximum number of durable folder-backup archives kept per project basename on a single calendar day**.

| Constant | Default | Meaning |
|----------|---------|---------|
| **`MAX_DAILY_BACKUPS`** | **5** | After successful deposit, if more than 5 matching archives exist for that basename **and day**, **remove the oldest of that day** until count ≤ 5 |

It does **not** own create/name/deposit/verify/restore (`requirement-folder-archive-backup`). Total cap across days is **`requirement-folder-archive-backup-retention-total`** (default **30**).

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Scope of count (day bucket)

1. **MUST** count only files under  
   `${BACKUP_ROOT}/${BACKUP_NOTATION}/`  
   matching  
   `${SOURCE_FOLDER_NAME}-YYYYMMDD-N.tar.gz`  
   for the **same** `SOURCE_FOLDER_NAME` and the **same** `YYYYMMDD` (local calendar day at backup start — same SSOT as archive naming).  
2. **MUST NOT** count other days toward the daily cap.  
3. **MUST NOT** count other basenames.  
4. **MUST NOT** count stage/hop/non-product files.

### 2.2 Cap

1. Default **`MAX_DAILY_BACKUPS=5`**.  
2. Env **`MAX_DAILY_BACKUPS`** **MAY** override when set to a positive integer; empty/invalid **MUST** fall back to **5**.  
3. **MUST NOT** treat `0` or negative as “unlimited.”

### 2.3 When to enforce

1. **MUST** run daily retention **after** successful durable deposit **and** backup verification for that run.  
2. **MUST NOT** prune on failed backup.  
3. **MUST NOT** overwrite an existing same-day `N` to stay under 5 — allocate next free `N`, then prune oldest **of that day**.

### 2.4 Oldest of current day

1. Within the same basename and same `YYYYMMDD`, **oldest** = lowest **`N`**.  
2. **MUST** remove only archives in **that day’s** set until day count ≤ `MAX_DAILY_BACKUPS`.  
3. **MUST NOT** remove a **previous (or future) day’s** archive to satisfy the **daily** cap.  
4. **MUST** retain higher-`N` (newer same-day) when lower-`N` same-day archives exist to prune.  
5. After prune, same-day matching count **MUST** be ≤ 5 (or effective cap).

### 2.5 Delete safety

1. **MUST** delete only individual matching `.tar.gz` files under  
   `${BACKUP_ROOT}/${BACKUP_NOTATION}/`.  
2. **MUST NOT** recursively delete deposit or host roots.  
3. **MUST NOT** delete other basenames or non-pattern files.  
4. Root-owned deposit delete **MUST** use Type 1 narrow allowlisted remove (or root) — peer `requirement-three-layer-privilege-model`; **MUST NOT** unrestricted `rm`.  
5. If prune cannot run while day count remains above cap, **MUST** fail closed with operator hint **or** emit clear non-success residual — no silent ignore.

### 2.6 Interaction with total retention

1. When total retention is Active, **daily prune SHOULD run before total prune**.  
2. Daily cap **MUST NOT** raise the total cap (30).  
3. Total prune **MUST NOT** leave more than 5 archives for a single basename+day when this requirement is Active (total prune removes oldest overall, which may be older days first — daily prune still enforces same-day 5).

### 2.7 Operator visibility

1. Human mode **SHOULD** report day, files removed, remaining same-day count, and cap.  
2. JSON mode **SHOULD** include `retention_daily_cap`, `retention_daily_day`, `retention_daily_removed`, `retention_daily_remaining` when prune runs.

### 2.8 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **Product / APP_NAME** | `folder-backup` |
| **Ship unit** | `src/folder-backup` |
| **Deposit** | `/var/backup/folder-backup/` (env `BACKUP_ROOT` / `BACKUP_NOTATION`) |
| **Naming** | `${SOURCE_FOLDER_NAME}-YYYYMMDD-N.tar.gz` |
| **MAX_DAILY_BACKUPS** | `5` (env override allowed) |
| **Day SSOT** | `date +%Y%m%d` at backup start |
| **Prune timing** | after successful `fb_backup` deposit + verify |
| **Elev delete** | `print-sudoers`: `/bin/rm -f` + `/usr/bin/rm -f` under deposit `*.tar.gz` only |
| **Peer ops law** | `requirement-folder-archive-backup` |
| **Peer total** | `requirement-folder-archive-backup-retention-total` |

### 2.9 Why This Requirement Exists (CIAO)

- **Principle 12:** Same-day re-runs must not flood the deposit.  
- **Principle 1:** Day-scoped deletes only.  
- **Principle 10:** Narrow elev for durable delete.  
- **Anti-fragile:** Thrash-safe daily ceiling of **5**.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- Cap 5/day is intentional product law.  
- Lowest-`N` same-day first; never other days for daily rule.  
- Fail closed on unsafe paths and missing elev when prune is required.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Leave same-day per-basename count unbounded while this requirement is Active.  
2. Delete **other days’** archives to satisfy the **daily** cap.  
3. Delete other basenames or non-product files.  
4. Overwrite same-day archives instead of pruning lowest `N`.  
5. Remove newest same-day archive while older same-day `N` remain.  
6. Add unrestricted `rm` / shell elev for cleanup.  
7. Confuse daily cap with **total** cap (peer total requirement, default 30).

**Violating this rule is a critical retention / data-loss process regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | Default daily cap is **5** per basename per `YYYYMMDD` |
| AC-2 | After successful backup, if same-day count > 5, lowest-`N` same-day removed until ≤ 5 |
| AC-3 | Other days’ archives not removed by daily prune |
| AC-4 | Other basenames not removed |
| AC-5 | Failed backup does not trigger daily prune |
| AC-6 | Newest same-day archive retained when lower-`N` same-day exist |
| AC-7 | Missing elev for required delete is fail-closed or explicitly reported |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-folder-archive-backup` | Create / deposit / verify / restore ops SSOT |
| `requirement-folder-archive-backup-retention-total` | Max **30** total per basename |
| `requirement-three-layer-privilege-model` | Narrow elev for deposit delete when needed |
| `requirement-shell-idempotency` | Next-N no overwrite |
| `requirement-domain-folder-backup` | Domain surface only |
| `docs/requirements/index.md` | Registry |

---

## Design-time verification

| TP family / ID | Suite | Status |
|----------------|-------|--------|
| **TP-FOLDER-BACKUP-18** | `tests/test_domain_folder_backup.sh` | **have** — daily cap prune lowest N |
| **TP-FOLDER-BACKUP-18b** | same | **have** — daily prune does not touch other days / other basename |

**Matrix:** `reviews/requirement-test-matrix.md`  
**Map:** `reviews/test-plan.md`

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-12 | Active 1.0.0 | Daily cap **5** per basename per day; oldest same-day `N` first |

---

**Last Updated**: 2026-08-12  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; mold **`LM-FOLDER-ARCHIVE-BACKUP-RETENTION-DAILY`**; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
