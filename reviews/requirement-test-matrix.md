# Requirement ↔ test matrix — folder-backup

**Updated:** 2026-08-03  
**Suite:** `tests/run.sh`

| Requirement key | Area | TP families | Coverage notes |
|-----------------|------|-------------|----------------|
| requirement-class-software-dev | class | TP-CLI-01, TP-CLI-11 | Syntax + stack residual; no online package |
| requirement-bootstrap-chain | architecture | TP-CLI-04, TP-CLI-10 | Online surface absent |
| requirement-project-folder | architecture | TP-LC-01, TP-FOLDER-BACKUP-06 | src ship unit; deposit path naming |
| requirement-three-layer-privilege-model | architecture | TP-FOLDER-BACKUP-01,02,05 | Sudoers print + deposit fail-closed (elev Cmnds) |
| requirement-folder-archive-backup | backup | TP-FOLDER-BACKUP-03..08,10..13 | Source/name/deposit/verify/next-N/**restore** (ops SSOT; not domain) |
| requirement-shell-cli-interface | shell | TP-CLI-* | Commands, flags, dispatch |
| requirement-shell-cli-zero-arguments | shell | TP-CLI-07 | Type N help |
| requirement-shell-local-self-management | shell | TP-LC-* | install/uninstall/where-is-me |
| requirement-shell-output-requirements | shell | TP-CLI-03,05,08,09 | JSON / quiet / errors |
| requirement-shell-modular-function-design | shell | (indirect) | Behavior via commands; `fb_*` domain |
| requirement-shell-idempotency | shell | TP-LC-03,07 · TP-FOLDER-BACKUP-06,08 | Re-install; next-N |
| requirement-shell-interactive-vs-noninteractive | shell | TP-LC-05 | Uninstall JSON no force |
| requirement-shell-cli-storage | shell | TP-CLI-12 · domain staging | Isolation + stage under storage |
| requirement-domain-folder-backup | domain | TP-FOLDER-BACKUP-01,02,09 · TP-CLI-04,06 | Domain surface (verbs/help/about); ops mapped to folder-archive-backup |

**Absent by design (no TP Core):** online-install, remote self-management, automatic channel checksum.
