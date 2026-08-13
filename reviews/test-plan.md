# Test plan — cli-template

Maps **TP-*** coverage to `tests/`.  
**Suite entry:** `./tests/run.sh`  
**Ship unit:** `src/cli-template`  
**Product VERSION:** 1.0.0  
**Last plan update:** 2026-08-13  
**Last suite run:** PASS=80 FAIL=0 SKIP=0 (2026-08-13)

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
| Trimmed parent verbs fail closed | have | TP-CLI-13 |
| Local install / idempotent / uninstall / mode 0755 | have | TP-LC-01..10 |
| Backup / restore / sudoers emit | n/a | Absent by design (Type 0 template; not a backup product) |
| Online curl / companion checksum | n/a | Local-only product |

---

## TP rows

### TP-CLI (CLI surface)

| TP-ID | Intent | Suite | Primary requirement(s) | Status |
|-------|--------|-------|------------------------|--------|
| TP-CLI-01 | `sh -n` ship unit | `tests/test_cli.sh` | requirement-shell-cli-interface | **have** |
| TP-CLI-02 | version human | test_cli | requirement-shell-cli-interface | **have** |
| TP-CLI-03 | version JSON | test_cli | requirement-shell-output-requirements | **have** |
| TP-CLI-04 | help local verbs; no online; no backup/restore/sudoers | test_cli | requirement-shell-cli-interface · bootstrap-chain | **have** |
| TP-CLI-05 | help JSON short | test_cli | requirement-shell-output-requirements | **have** |
| TP-CLI-06 | about JSON storage; no domain fields | test_cli | requirement-shell-cli-storage | **have** |
| TP-CLI-07 | empty argv Type N help | test_cli | requirement-shell-cli-zero-arguments | **have** |
| TP-CLI-08 | unknown fail-closed | test_cli | requirement-shell-cli-interface | **have** |
| TP-CLI-09 | quiet suppresses version | test_cli | requirement-shell-output-requirements | **have** |
| TP-CLI-10 | online verbs rejected | test_cli | requirement-bootstrap-chain | **have** |
| TP-CLI-11 | env -u HOME version | test_cli | class / defensive | **have** |
| TP-CLI-12 | storage isolation | test_cli | requirement-shell-cli-storage | **have** |
| TP-CLI-13 | backup/restore/sudoers verbs unknown | test_cli | requirement-bootstrap-chain · interface | **have** |

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
| TP-LC-09 | installed mode is `0755` | test_local_lifecycle | local self-management §2.3.1 | **have** |
| TP-LC-10 | reinstall without force heals `0711` → `0755` | test_local_lifecycle | local self-management §2.3.1 | **have** |

---

## Rules

1. Closing a **bug** finding updates the matching TP to **have**.  
2. Do not mark TP **have** without a suite assertion (or honest skip/n/a).  
3. Do not reintroduce online TP-CURL/TP-CSUM or TP-FOLDER-BACKUP as Core without product-mode change.  
4. Do not add domain TP families or a `setup` verb — this product is Type 0 only.
