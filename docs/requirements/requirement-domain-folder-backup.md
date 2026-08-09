**file**: docs/requirements/requirement-domain-folder-backup.md  
**Status**: Active (Version 1.2.0)  
**Area**: domain  
**Key**: `requirement-domain-folder-backup`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **domain surface Single Source of Truth** for folder-backup: which **specialized CLI verbs** exist, what **help** and **about** must show, and how domain routing is labeled.

**Operational backup behavior** (create, name, deposit, verify, fail-closed matrix) is **not** owned here — it is owned by **`requirement-folder-archive-backup`**.  
**Elevation and sudoers files** are owned by **`requirement-three-layer-privilege-model`**.

This file remains the sole Active **`requirement-domain-*`** (four pillars).

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Pillar A — Specialized CLI subcommands

| Command | Operands / flags | Handler prefix | Behavior summary | Behavior SSOT |
|---------|------------------|----------------|------------------|---------------|
| `backup` | `<source-folder>` required | `fb_*` | Folder archive backup end-to-end | **`requirement-folder-archive-backup`** |
| `restore` | `<archive\|prefix> [dest]`; flags `--force` `--disk` `--ram` | `fb_*` | Restore archive (default dest: hard-disk host) | **`requirement-folder-archive-backup`** |
| `print-sudoers` | optional output path; `--allow-test-local` when test_local | `fb_*` | Emit **project-sudoers-file** (draft; no `/etc` write) | **`requirement-three-layer-privilege-model`** |
| `print-sudoers-install-script` | optional script path; same trust gate | `fb_*` | Admin handoff script under `/dev/shm` or temp (`install`/`uninstall`/`replace`/`status`) | **`requirement-three-layer-privilege-model`** §2.3.3a |
| `remove-project-sudoers` | optional path; `--force` | `fb_*` | Remove **project-sudoers-file** draft only (not `/etc`) | **`requirement-three-layer-privilege-model`** §2.3.3b |

**Routing:** Dispatcher in `app_main` (CLI interface) **MUST** route these verbs; unknown operands fail closed.

**Non-goals as subcommands:** remote sync, cloud upload, restore UI, schedule daemon (unless a future requirement adds them).

### 2.2 Pillar B — Specialized features (surface map only)

| Feature area | Domain role | Full law |
|--------------|-------------|----------|
| Folder archive backup | Expose `backup` verb | `requirement-folder-archive-backup` |
| Elevated deposit / verify elev | Product uses Type 1 sub-steps | `requirement-three-layer-privilege-model` + backup REQ |
| Sudoers draft print | Expose `print-sudoers` | `requirement-three-layer-privilege-model` |
| Admin sudoers install script | Expose `print-sudoers-install-script` | `requirement-three-layer-privilege-model` §2.3.3a · term `project-sudoers-file` |
| Remove project-sudoers draft | Expose `remove-project-sudoers` | `requirement-three-layer-privilege-model` §2.3.3b |

Domain **MUST NOT** restate full operational backup rules in a second competing SSOT. Pointers and verb catalog only.

### 2.3 Pillar C — Specialized project help items

`help` **MUST** show domain rows (in addition to Type 0 lifecycle):

| Help row | Text intent |
|----------|-------------|
| `backup <source-folder>` | Create tar.gz, deposit under backup notation, verify counts |
| `restore <archive\|prefix> [dest]` | Restore archive; default dest **hard-disk** host (reverse ram-drive-first) |
| `print-sudoers` | Emit **project-sudoers-file** (draft) for admin install |
| `print-sudoers-install-script` | Write admin script (`/dev/shm` or temp) for sudo install/uninstall/replace of project-sudoers-file |
| `remove-project-sudoers [path]` | Delete project-sudoers-file draft only (list/choose if multiple; confirm / `--force`; not `/etc`) |
| Env note | `BACKUP_*`, `PROJECTS_ROOT`, `RAM_ROOT`, `RESTORE_HOST_DEFAULT` |
| Privilege note | Archive as user; deposit/restore-stage need allowlisted sudo after admin installs fragment |

Examples in help **SHOULD** include:

```text
folder-backup install
folder-backup print-sudoers-install-script
# admin (sudo): sudo sh /dev/shm/folder-backup-<user>-sudoers-admin.sh install
# leave test elev: sudo sh …/…-sudoers-admin.sh uninstall
folder-backup backup /path/to/project
```

### 2.4 Pillar D — Specialized project about items

`about` **MUST** include domain diagnostics (in addition to Type 0):

| Field / line | Content |
|--------------|---------|
| Backup root | effective `BACKUP_ROOT` |
| Backup notation | effective `BACKUP_NOTATION` |
| Deposit directory | `${BACKUP_ROOT}/${BACKUP_NOTATION}` |
| Sudo deposit status | best-effort probe; honest if not fully probeable |
| Domain version note | Product `VERSION` remains Type 0 local version SSOT |

**About is not** a remote version-check and **must not** advertise online install channels.

### 2.5 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **Product / APP_NAME** | `folder-backup` |
| **Domain prefix** | `fb_` |
| **Ship unit** | `src/folder-backup` |
| **VERSION** | ship unit SSOT (see `src/folder-backup`) |
| **Primary user install** | `~/.local/bin/folder-backup` |
| **Backup operations SSOT** | `requirement-folder-archive-backup` |
| **Privilege / sudoers SSOT** | `requirement-three-layer-privilege-model` |
| **Bootstrap** | Specialized from selfmanaged architecture; online install **trimmed** |

### 2.6 Why This Requirement Exists (CIAO)

- **Principle 2 – Intentional**: Domain surface is explicit (four pillars) and not mixed with full ops law.  
- **Principle 5 – Output SSOT**: Help/about domain rows via product output system.  
- **Principle 9 – Three Types of Commands**: Domain labels Type 0 verbs that invoke Type 1 sub-steps under peer REQs.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution:** Do not invent a second backup SSOT in domain.  
- **Intentional:** Pillars A–D only; ops in backup requirement.  
- **Anti-fragile:** Clear ownership boundaries reduce drift.  
- **Over-protect:** Keep sole Active domain file; supersede before replace.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Duplicate full create/name/deposit/verify law here once `requirement-folder-archive-backup` is Active.  
2. Add online install or remote upload as silent domain behavior without new requirements.  
3. Put domain law into bootstrap parent selfmanaged.  
4. Leave help listing `backup` without an Active operational backup requirement.  
5. Create a second Active `requirement-domain-*` without superseding this one.

**Violating this rule is a critical domain regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | Four pillars present (subcommands, feature map, help, about) |
| AC-2 | `backup`, `print-sudoers`, `print-sudoers-install-script`, and `remove-project-sudoers` listed with peer SSOT pointers |
| AC-3 | Help lists backup + print-sudoers + install-script + remove-project-sudoers |
| AC-4 | About lists backup root / notation / deposit dir |
| AC-5 | Registered as sole Active domain SSOT |
| AC-6 | No competing full backup ops body (defers to folder-archive-backup) |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-folder-archive-backup` | **Operational backup SSOT** |
| `requirement-three-layer-privilege-model` | Elevation + sudoers |
| `requirement-shell-cli-interface` | Routes domain verbs |
| `requirement-bootstrap-chain` | Domain extend after trim |
| `docs/requirements/index.md` | Registry |

---

## Design-time verification

| TP family / ID | Suite | Status | Note |
|----------------|-------|--------|------|
| **TP-FOLDER-BACKUP-01,02** | `tests/test_domain_folder_backup.sh` | have | print-sudoers surface (privilege peer) |
| **TP-FOLDER-BACKUP-09** | same | have | about domain fields |
| **TP-CLI-04,06** | `tests/test_cli.sh` | have | help/about list domain verbs |
| **TP-FOLDER-BACKUP-03..08,10** | `tests/test_domain_folder_backup.sh` | have | **Primary map:** `requirement-folder-archive-backup` |

**Matrix:** `reviews/requirement-test-matrix.md`  
**Map:** `reviews/test-plan.md`

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-03 | Active 1.0.0 | Domain SSOT: folder tar.gz backup + sudoers deposit |
| 2026-08-03 | Active 1.1.0 | Verification rules (later moved to backup ops REQ) |
| 2026-08-03 | Active 1.2.0 | **Thin domain surface**; ops SSOT → `requirement-folder-archive-backup` |

---

**Last Updated**: 2026-08-03  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
