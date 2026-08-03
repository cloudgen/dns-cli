# Test plan — folder-backup

Maps **TP-*** coverage to `tests/`.  
**Suite entry:** `./tests/run.sh`  
**Ship unit:** `src/folder-backup`  
**Last update:** 2026-08-03  
**Last suite run:** PASS=93 FAIL=0 SKIP=0 (2026-08-03; backup verify counts + host sudoers deposit)

Status: **have** = automated today · **todo** = needed · **optional** · **n/a** · **skip** (environment)

---

## Baseline coverage

| Area | Status | Evidence |
|------|--------|----------|
| Syntax `sh -n` | have | TP-CLI-01 |
| version / help / about human + JSON | have | TP-CLI-02..06 |
| Type N empty argv = help | have | TP-CLI-07 |
| Unknown + quiet + set -u HOME | have | TP-CLI-08..11 |
| Storage isolation | have | TP-CLI-12 |
| No online verbs / no SCRIPT_URL UX | have | TP-CLI-04, TP-CLI-10 |
| Local install / idempotent / uninstall | have | TP-LC-01..08 |
| Domain surface (print-sudoers allowlist text) | have | TP-FOLDER-BACKUP-01..02 · domain REQ |
| Backup ops (name, fail-closed, verify) | have | TP-FOLDER-BACKUP-03..06 · **requirement-folder-archive-backup** |
| Elevated deposit + next-N + verify | have (root **or** allowlisted `sudo -n`) | TP-FOLDER-BACKUP-07/08 |
| Online curl / companion checksum | n/a | Local-only product |

---

## TP rows

### TP-CLI (CLI surface)

| TP-ID | Intent | Suite | Primary requirement(s) | Status |
|-------|--------|-------|------------------------|--------|
| TP-CLI-01 | `sh -n` ship unit | `tests/test_cli.sh` | requirement-shell-cli-interface | **have** |
| TP-CLI-02 | version human | test_cli | requirement-shell-cli-interface | **have** |
| TP-CLI-03 | version JSON | test_cli | requirement-shell-output-requirements | **have** |
| TP-CLI-04 | help local verbs; no online | test_cli | requirement-shell-cli-interface · domain | **have** |
| TP-CLI-05 | help JSON short | test_cli | requirement-shell-output-requirements | **have** |
| TP-CLI-06 | about JSON storage + domain fields | test_cli | requirement-shell-cli-storage · domain | **have** |
| TP-CLI-07 | empty argv Type N help | test_cli | requirement-shell-cli-zero-arguments | **have** |
| TP-CLI-08 | unknown fail-closed | test_cli | requirement-shell-cli-interface | **have** |
| TP-CLI-09 | quiet suppresses version | test_cli | requirement-shell-output-requirements | **have** |
| TP-CLI-10 | online verbs rejected | test_cli | requirement-bootstrap-chain | **have** |
| TP-CLI-11 | env -u HOME version | test_cli | class / defensive | **have** |
| TP-CLI-12 | storage isolation | test_cli | requirement-shell-cli-storage | **have** |

### TP-LC (local lifecycle)

| TP-ID | Intent | Suite | Primary requirement(s) | Status |
|-------|--------|-------|------------------------|--------|
| TP-LC-01 | install → USER_BIN | test_local_lifecycle | requirement-shell-local-self-management | **have** |
| TP-LC-02 | installed binary version | test_local_lifecycle | local self-management | **have** |
| TP-LC-03 | reinstall already-installed | test_local_lifecycle | requirement-shell-idempotency | **have** |
| TP-LC-04 | where-is-me | test_local_lifecycle | local self-management | **have** |
| TP-LC-05 | uninstall JSON no force fail-closed | test_local_lifecycle | interactive-vs-noninteractive | **have** |
| TP-LC-06 | uninstall --force removes | test_local_lifecycle | local self-management | **have** |
| TP-LC-07 | uninstall absent no-op | test_local_lifecycle | idempotency | **have** |
| TP-LC-08 | about shows installed | test_local_lifecycle | local self-management | **have** |

### TP-FOLDER-BACKUP (domain subject)

| TP-ID | Intent | Suite | Primary requirement(s) | Status |
|-------|--------|-------|------------------------|--------|
| TP-FOLDER-BACKUP-01 | print-sudoers stdout; no /etc; tar -tzf allowlist | test_domain_folder_backup | three-layer · domain surface | **have** |
| TP-FOLDER-BACKUP-02 | print-sudoers file; narrow | test_domain_folder_backup | three-layer privilege | **have** |
| TP-FOLDER-BACKUP-03 | backup missing operand | test_domain_folder_backup | **folder-archive-backup** | **have** |
| TP-FOLDER-BACKUP-04 | backup missing dir | test_domain_folder_backup | **folder-archive-backup** | **have** |
| TP-FOLDER-BACKUP-05 | deposit fail-closed without working sudo | test_domain_folder_backup | folder-archive-backup · three-layer | **have** (PATH fake-sudo; valid with host sudoers) |
| TP-FOLDER-BACKUP-06 | archive name YYYYMMDD + tar.gz | test_domain_folder_backup | **folder-archive-backup** · idempotency | **have** |
| TP-FOLDER-BACKUP-07 | elevated deposit + verify counts (root or sudo -n) | test_domain_folder_backup | **folder-archive-backup** · three-layer | **have** (host sudoers or root) |
| TP-FOLDER-BACKUP-08 | same-day next-N no overwrite | test_domain_folder_backup | **folder-archive-backup** · idempotency | **have** (host sudoers or root) |
| TP-FOLDER-BACKUP-09 | about domain diagnostics | test_domain_folder_backup | domain about pillar | **have** |
| TP-FOLDER-BACKUP-10 | leaf basename in archive name | test_domain_folder_backup | **folder-archive-backup** | **have** |
| TP-FOLDER-BACKUP-11 | restore missing archive fail-closed | test_domain_folder_backup | **folder-archive-backup** | **have** |
| TP-FOLDER-BACKUP-12 | restore to explicit dest + verify | test_domain_folder_backup | **folder-archive-backup** | **have** |
| TP-FOLDER-BACKUP-13 | restore default host hard-disk + non-empty refuse | test_domain_folder_backup | **folder-archive-backup** | **have** |

---

## Rules

1. Closing a **bug** finding updates the matching TP to **have**.  
2. Do not mark TP **have** without a suite assertion (or honest skip/n/a).  
3. Do not reintroduce online TP-CURL/TP-CSUM as Core without product-mode change.  
