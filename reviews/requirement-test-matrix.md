# Requirement ↔ test matrix — dns-cli

**Updated:** 2026-08-18  
**Product VERSION:** 1.6.0  
**Suite:** `tests/run.sh`

| Requirement key | Area | TP families | Coverage notes |
|-----------------|------|-------------|----------------|
| requirement-class-software-dev | class | TP-CLI-01, TP-CLI-11 | Syntax + stack residual; no online package |
| requirement-bootstrap-chain | architecture | TP-CLI-04, TP-CLI-10, TP-CLI-13 | Online and backup surfaces absent |
| requirement-project-folder | architecture | TP-LC-01 | src ship unit + user bin |
| requirement-least-privilege-user | architecture | TP-LPU-01..06 | **have** 01–02, 04–06 (stub); **TP-LPU-03** Type 2 switch todo |
| requirement-three-layer-privilege-model | architecture | TP-PRIV-01..09 | **have** — print-sudoers / setup / generate+submit / role table |
| requirement-sudoer-json-file | architecture | TP-SUDOER-JSON-01..03,08,09 · TP-PRIV-05..08 | **have** — JSON grant + independent dest + role table |
| requirement-shell-cli-interface | shell | TP-CLI-* (incl. **TP-CLI-14** · **TP-CLI-15**) | Commands, flags, dispatch; dual mention + topic-owner samples |
| requirement-shell-cli-zero-arguments | shell | TP-CLI-07 | Type N help |
| requirement-shell-local-self-management | shell | TP-LC-* (incl. **09/10** mode) | install/uninstall/where-is-me; **0755** |
| requirement-shell-output-requirements | shell | TP-CLI-03,05,08,09 | JSON / quiet / errors |
| requirement-shell-modular-function-design | shell | (indirect) | no `fb_*`; `app_main` / `out_*` |
| requirement-shell-idempotency | shell | TP-LC-03,07 | Re-install / uninstall absent |
| requirement-shell-interactive-vs-noninteractive | shell | TP-LC-05 | Uninstall confirm |
| requirement-shell-cli-storage | shell | TP-CLI-12 | Isolation |
| requirement-domain-cloudflare-dns | domain | TP-CF-DNS-* · TP-CF-ACTOR-* | **have** — stubbed curl; actor verbs fail closed |
| requirement-dns-actor-table | architecture | TP-CF-ACTOR-01..07 | **have** — unrouted submit/approve/interactive; MUST NOT absorb sudoer roles |
| requirement-dns-approver | architecture | TP-CF-APR-01..06 | **have** — `.bashrc` / missing `.profile` heal |
| requirement-cloudflare-dns-mode | domain | TP-CF-MODE-01..08 have; 06/09/10 todo | stored mode + RR add/status + switch lock |
| requirement-cloudflare-dns-request | domain | TP-CF-REQ-01..08 | **todo** — inbound JSON types; submit/approve Gap |
| requirement-external-ipv4 | shell | TP-CF-IP-01..04, TP-CLI-04 | **have** — vault-free `ip`; IPv6 MUST NOT |
| requirement-application-local-vault | shell | TP-AV-01..06 have; TP-AV-07 todo | specify have; default LPU path todo |
| requirement-cloudflare-vault | domain | TP-CF-VAULT-01..33 have | v2 zone-slot CRUD + list verify; LPU dest Gap |
| requirement-cloudflare-api | domain | TP-CF-DNS-* have; TP-CF-API-01..03 | envelope/pagination todo; argv token have; A only |

**Absent by design (no TP Core):** online-install, remote self-management, automatic channel checksum, folder-archive backup/restore, sudoers-manager extras.

**Honesty:** Type 0 TP-CLI / TP-LC (incl. **TP-CLI-14** dual mention), v2 vault TP-CF-VAULT-01..33, TP-CF-MODE-01..08, TP-CF-APR-01..06, TP-LPU-01..02/04..06, TP-PRIV-01..09, TP-CF-ACTOR-01..07, and TP-SUDOER-JSON-* are **have** against `src/dns-cli` **1.6.0**. Inbound **DNS** submit/approve/`interactive` and Type 2 default-vault switch remain **Gap**.
