# Requirement ↔ test matrix — folder-backup

**Updated:** 2026-08-09  
**Product VERSION:** 1.4.4  
**Suite:** `tests/run.sh` (PASS=138 FAIL=0 SKIP=2)

| Requirement key | Area | TP families | Coverage notes |
|-----------------|------|-------------|----------------|
| requirement-class-software-dev | class | TP-CLI-01, TP-CLI-11 | Syntax + stack residual; no online package |
| requirement-bootstrap-chain | architecture | TP-CLI-04, TP-CLI-10 | Online surface absent |
| requirement-project-folder | architecture | TP-LC-01, TP-FOLDER-BACKUP-06 | src ship unit; deposit path naming |
| requirement-three-layer-privilege-model | architecture | TP-FOLDER-BACKUP-01, **01b**, 01c, 02, 05, **14**, **15**, **15b** | Trust tiers **S13**; per-user draft/host paths **AC-14**; install-script §2.3.3a; multi-draft remove choose **AC-15**; deposit fail-closed |
| requirement-folder-archive-backup | backup | TP-FOLDER-BACKUP-03..08, 10..13 | Source/name/deposit/verify/next-N/**restore** (ops SSOT) |
| requirement-shell-cli-interface | shell | TP-CLI-* | Commands, flags, dispatch (incl. new sudoers verbs) |
| requirement-shell-cli-zero-arguments | shell | TP-CLI-07 | Type N help |
| requirement-shell-local-self-management | shell | TP-LC-* (incl. **09/10** mode) | install/uninstall/where-is-me; **0755** multi-user; global preferred for elev |
| requirement-shell-output-requirements | shell | TP-CLI-03,05,08,09 | JSON / quiet / errors |
| requirement-shell-modular-function-design | shell | (indirect) | `fb_print_sudoers*`, `fb_remove_project_sudoers`, deposit/restore |
| requirement-shell-idempotency | shell | TP-LC-03,07 · TP-FOLDER-BACKUP-06,08 | Re-install; next-N |
| requirement-shell-interactive-vs-noninteractive | shell | TP-LC-05 · TP-FOLDER-BACKUP-15 · **15b** | Uninstall / remove-project-sudoers confirm; multi-draft non-interactive path required |
| requirement-shell-cli-storage | shell | TP-CLI-12 · domain staging | Isolation + per-user stage roots |
| requirement-domain-folder-backup | domain | TP-FOLDER-BACKUP-01,02,09,14,15 · TP-CLI-04,06 | Surface verbs/help/about; privilege peers three-layer |

**Checklist / mold (harness, not product suite):** **S11–S12** elev tables (when claimed); **S13** trust tier — agent path `SK-CREATE-SUDOERS-FILE` / `CL-CREATE-SUDOERS-SECURITY`.

**Absent by design (no TP Core):** online-install, remote self-management, automatic channel checksum.
