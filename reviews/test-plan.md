# Test plan — folder-backup

Maps **TP-*** coverage to `tests/`.  
**Suite entry:** `./tests/run.sh`  
**Ship unit:** `src/folder-backup`  
**Product VERSION:** 1.4.1  
**Last plan update:** 2026-08-09  
**Last suite run:** PASS=131 FAIL=0 SKIP=0 (2026-08-09)

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
| Local install / idempotent / uninstall / mode 0755 | have | TP-LC-01..10 |
| Help lists sudoers verbs (print / install-script / remove draft) | have | TP-CLI-04 |
| Domain surface: print-sudoers allowlist + test-mode gate | have | TP-FOLDER-BACKUP-01, 01b, 01c, 02 |
| Admin install-script handoff (project-sudoers-file) | have | TP-FOLDER-BACKUP-14 |
| Remove project-sudoers draft only | have | TP-FOLDER-BACKUP-15 |
| Multi-draft remove choose / path-required | have | TP-FOLDER-BACKUP-15b |
| Per-user draft + installed sudoers basename | have | TP-FOLDER-BACKUP-14 · 15 |
| Backup ops (name, fail-closed, verify) | have | TP-FOLDER-BACKUP-03..06 · **requirement-folder-archive-backup** |
| Elevated deposit + next-N + verify | have (root **or** allowlisted `sudo -n`) | TP-FOLDER-BACKUP-07/08 |
| Restore (explicit + hard-disk default) | have | TP-FOLDER-BACKUP-11..13 |
| Online curl / companion checksum | n/a | Local-only product |

---

## TP rows

### TP-CLI (CLI surface)

| TP-ID | Intent | Suite | Primary requirement(s) | Status |
|-------|--------|-------|------------------------|--------|
| TP-CLI-01 | `sh -n` ship unit | `tests/test_cli.sh` | requirement-shell-cli-interface | **have** |
| TP-CLI-02 | version human | test_cli | requirement-shell-cli-interface | **have** |
| TP-CLI-03 | version JSON | test_cli | requirement-shell-output-requirements | **have** |
| TP-CLI-04 | help local verbs; print-sudoers + install-script + remove-project-sudoers; no online | test_cli | requirement-shell-cli-interface · domain | **have** |
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
| TP-LC-09 | installed mode is `0755` (readable+executable) | test_local_lifecycle | local self-management §2.3.1 | **have** |
| TP-LC-10 | reinstall without force heals `0711` → `0755` | test_local_lifecycle | local self-management §2.3.1 | **have** |

### TP-FOLDER-BACKUP (domain + privilege)

| TP-ID | Intent | Suite | Primary requirement(s) | Status |
|-------|--------|-------|------------------------|--------|
| TP-FOLDER-BACKUP-01 | print-sudoers with allow; TEST MODE banner; no Type 0 `/etc` write; tar -tzf | test_domain | three-layer §2.3.1a/§2.3.3 · domain | **have** |
| TP-FOLDER-BACKUP-01b | refuse print-sudoers without `--allow-test-local` when not production | test_domain | three-layer trust tier **S13** | **have** |
| TP-FOLDER-BACKUP-01c | restore-stage reverse cp allowlist in fragment | test_domain | three-layer · folder-archive-backup | **have** |
| TP-FOLDER-BACKUP-02 | print-sudoers to path; narrow; per-user stage; test mode in file | test_domain | three-layer privilege | **have** |
| TP-FOLDER-BACKUP-03 | backup missing operand | test_domain | **folder-archive-backup** | **have** |
| TP-FOLDER-BACKUP-04 | backup missing dir | test_domain | **folder-archive-backup** | **have** |
| TP-FOLDER-BACKUP-05 | deposit fail-closed without working sudo | test_domain | folder-archive-backup · three-layer | **have** |
| TP-FOLDER-BACKUP-06 | archive name YYYYMMDD + tar.gz | test_domain | **folder-archive-backup** · idempotency | **have** |
| TP-FOLDER-BACKUP-07 | elevated deposit + verify counts (root or sudo -n) | test_domain | **folder-archive-backup** · three-layer | **have** (host sudoers or root) |
| TP-FOLDER-BACKUP-08 | same-day next-N no overwrite | test_domain | **folder-archive-backup** · idempotency | **have** (host sudoers or root) |
| TP-FOLDER-BACKUP-09 | about domain diagnostics | test_domain | domain about pillar | **have** |
| TP-FOLDER-BACKUP-10 | leaf basename in archive name | test_domain | **folder-archive-backup** | **have** |
| TP-FOLDER-BACKUP-11 | restore missing archive fail-closed | test_domain | **folder-archive-backup** | **have** |
| TP-FOLDER-BACKUP-12 | restore to explicit dest + verify | test_domain | **folder-archive-backup** | **have** |
| TP-FOLDER-BACKUP-13 | restore default host hard-disk + non-empty refuse | test_domain | **folder-archive-backup** | **have** |
| TP-FOLDER-BACKUP-14 | print-sudoers-install-script: draft + admin script; sh -n; root required for install | test_domain | three-layer §2.3.3a · project-sudoers-file | **have** |
| TP-FOLDER-BACKUP-15 | remove-project-sudoers: force remove draft; refuse `/etc`; already absent; host elev probe | test_domain | three-layer §2.3.3b · project-sudoers-file | **have** |
| TP-FOLDER-BACKUP-15b | multi-draft: list + non-interactive requires path; explicit path removes one only | test_domain | three-layer AC-15 · L-SUDOERS-04 | **have** |
| TP-FOLDER-BACKUP-16 | restore dest whitelist: refuse `/etc/passwd` + exact `/etc` + `/etc/<other>`; W-ETC-USER `/etc/{{username}}` gate allow | test_domain | **folder-archive-backup** §2.6b.2a · INC-20260812-001 | **have** |
| TP-FOLDER-BACKUP-17 | total retention: after deposit, prune oldest until ≤30 per basename | test_domain | **retention-total** | **have** |
| TP-FOLDER-BACKUP-17b | total retention: no cross-basename delete | test_domain | **retention-total** | **have** |
| TP-FOLDER-BACKUP-18 | daily retention: same-day prune lowest N until ≤5 | test_domain | **retention-daily** | **have** |
| TP-FOLDER-BACKUP-18b | daily retention: does not delete other days / other basename | test_domain | **retention-daily** | **have** |

---

## Privilege / sudoers coverage map (reviewer quick ref)

| Behavior | TP | Law |
|----------|----|-----|
| User detection for fragment = `id -un` | implicit (fragment User lines in 01/02/14) | three-layer · skill SK-CREATE-SUDOERS-FILE |
| Trust tier test_local refuse without allow | 01b | §2.3.1a · **S13** |
| TEST MODE banner + uninstall soon | 01, 02 | §2.3.3 |
| Project-sudoers-file draft write | 02, 14 | term project-sudoers-file |
| Admin install script (no Type 0 `/etc`) | 14 | §2.3.3a |
| Remove draft only | 15 | §2.3.3b |
| Deposit fail-closed | 05 | §2.3.7 |
| Elev Tables S11–S12 | n/a automated (agent/harness) | mold + checklist; product OS-tool deposit |

---

## Optional / host-only (not Core CI blockers)

| Item | Status | Notes |
|------|--------|--------|
| Admin script `install` on live host | optional | Requires sudo account; suite only checks root gate |
| Global install → production trust tier | optional | Host: `sudo sh src/folder-backup install` then print-sudoers without allow |
| Fragment drift vs installed `/etc/sudoers.d` | optional | Security review host gate |

---

## Rules

1. Closing a **bug** finding updates the matching TP to **have**.  
2. Do not mark TP **have** without a suite assertion (or honest skip/n/a).  
3. Do not reintroduce online TP-CURL/TP-CSUM as Core without product-mode change.  
4. Trust-tier and project-sudoers-file changes require TP-FOLDER-BACKUP-01b/14/15 (or successors) stay **have**.  
