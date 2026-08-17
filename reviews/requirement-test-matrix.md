# Requirement ↔ test matrix — dns-cli

**Updated:** 2026-08-17  
**Product VERSION:** 1.4.0  
**Suite:** `tests/run.sh`

| Requirement key | Area | TP families | Coverage notes |
|-----------------|------|-------------|----------------|
| requirement-class-software-dev | class | TP-CLI-01, TP-CLI-11 | Syntax + stack residual; no online package |
| requirement-bootstrap-chain | architecture | TP-CLI-04, TP-CLI-10, TP-CLI-13 | Online and backup surfaces absent |
| requirement-project-folder | architecture | TP-LC-01 | src ship unit + user bin |
| requirement-least-privilege-user | architecture | TP-LPU-01..06 | **todo** — `dns-adm` create/heal/remove |
| requirement-three-layer-privilege-model | architecture | TP-PRIV-01..04 | **todo** — print-sudoers / setup elev |
| requirement-shell-cli-interface | shell | TP-CLI-* | Commands, flags, dispatch |
| requirement-shell-cli-zero-arguments | shell | TP-CLI-07 | Type N help |
| requirement-shell-local-self-management | shell | TP-LC-* (incl. **09/10** mode) | install/uninstall/where-is-me; **0755** |
| requirement-shell-output-requirements | shell | TP-CLI-03,05,08,09 | JSON / quiet / errors |
| requirement-shell-modular-function-design | shell | (indirect) | no `fb_*`; `app_main` / `out_*` |
| requirement-shell-idempotency | shell | TP-LC-03,07 | Re-install / uninstall absent |
| requirement-shell-interactive-vs-noninteractive | shell | TP-LC-05 | Uninstall confirm |
| requirement-shell-cli-storage | shell | TP-CLI-12 | Isolation |
| requirement-domain-cloudflare-dns | domain | TP-CF-DNS-* · TP-CF-ACTOR-* | **have** — stubbed curl; actor verbs fail closed |
| requirement-dns-actor-table | architecture | TP-CF-ACTOR-01..06 | **have** — unrouted submit/approve/interactive |
| requirement-dns-approver | architecture | TP-CF-APR-01..06 | **have** — `.bashrc` / missing `.profile` heal |
| requirement-cloudflare-dns-mode | domain | TP-CF-MODE-01..08 have; 06/09/10 todo | stored mode + RR add/status + switch lock |
| requirement-cloudflare-dns-request | domain | TP-CF-REQ-01..08 | **todo** — inbound JSON types; submit/approve Gap |
| requirement-external-ipv4 | shell | TP-CF-IP-01..04, TP-CLI-04 | **have** — vault-free `ip`; IPv6 MUST NOT |
| requirement-application-local-vault | shell | TP-AV-01..06 have; TP-AV-07 todo | specify have; default LPU path todo |
| requirement-cloudflare-vault | domain | TP-CF-VAULT-01..33 have | v2 zone-slot CRUD + list verify; LPU dest Gap |
| requirement-cloudflare-api | domain | TP-CF-DNS-* have; TP-CF-API-01..03 | envelope/pagination todo; argv token have; A only |

**Absent by design (no TP Core):** online-install, remote self-management, automatic channel checksum, folder-archive backup/restore, sudoers-manager extras.

**Honesty:** Type 0 TP-CLI / TP-LC, v2 vault TP-CF-VAULT-01..33, TP-CF-MODE-01..08, and TP-CF-APR-01..06 are **have** against `src/dns-cli` **1.4.0**. Inbound submit/approve/`interactive` remain **Gap**. LPU / Type 1 setup remain **todo**.
