# Requirement ↔ test matrix — dns-cli

**Updated:** 2026-08-21  
**Product VERSION:** 1.11.0  
**Suite:** `tests/run.sh`

| Requirement key | Area | TP families | Coverage notes |
|-----------------|------|-------------|----------------|
| requirement-class-software-dev | class | TP-CLI-01, TP-CLI-11, **TP-ARSA-01**, **TP-FENCE-01** | Syntax + stack residual; dest-fence review; no online package |
| requirement-actor-role-subject-approver | architecture | **TP-ARSA-01** · **TP-ARSA-02** | Five-column catalog; Submitter before Approver |
| requirement-approval-fencing-condition | architecture | **TP-FENCE-01** · **TP-FENCE-03** · **TP-FENCE-05** · **TP-FENCE-06** · **TP-FENCE-09..15** | Dest fence catalog; dest tables still print; Type 0 `fence-test` |
| requirement-incorrect-json-format | architecture | **TP-FENCE-01** · **TP-FENCE-02** · **TP-FENCE-04** · **TP-FENCE-05** · **TP-FENCE-06** · **TP-FENCE-08** · **TP-FENCE-09..17** · TP-CF-REQ-10 · TP-CF-REQ-13 · TP-CF-REQ-16 · TP-CF-REQ-17 | Independent dest Fence; dest-owned allowlist; sudoer `kind` known; Type 0 `submit_app` / `submit_version`; per-row `test-json-format`; list tester `fence-test`; live dest **TP-FENCE-07** skip |
| requirement-bootstrap-chain | architecture | TP-CLI-04, TP-CLI-10, TP-CLI-13 | Online and backup surfaces absent |
| requirement-project-folder | architecture | TP-LC-01 | src ship unit + user bin |
| requirement-least-privilege-user | architecture | TP-LPU-01..07 | **have** 01–07 (stub); **TP-LPU-03** Type 2 switch / `lpu_required`; **07** dest fence table |
| requirement-three-layer-privilege-model | architecture | TP-PRIV-01..10 | **have** — print-sudoers / setup / generate+submit / role table / dest fence table |
| requirement-sudoer-json-file | architecture | TP-SUDOER-JSON-01..03,08..21 · TP-PRIV-05..08 | **have** — two JSON kinds + dest-owned queued allowlist + independent dest + role table + setup auto-submit + dest fence table |
| requirement-shell-cli-interface | shell | TP-CLI-* (incl. **TP-CLI-14** · **TP-CLI-15** · **TP-CLI-16**) · **TP-FENCE-09..15** | Commands, flags, dispatch; dual mention; test-purpose `fence-test` |
| requirement-shell-cli-zero-arguments | shell | TP-CLI-07 | Type N help |
| requirement-shell-local-self-management | shell | TP-LC-* (incl. **09/10** mode) | install/uninstall/where-is-me; **0755** |
| requirement-shell-output-requirements | shell | TP-CLI-03,05,08,09 | JSON / quiet / errors |
| requirement-shell-modular-function-design | shell | (indirect) | no `fb_*`; `app_main` / `out_*` |
| requirement-shell-idempotency | shell | TP-LC-03,07 | Re-install / uninstall absent |
| requirement-shell-interactive-vs-noninteractive | shell | TP-LC-05 | Uninstall confirm |
| requirement-shell-cli-storage | shell | TP-CLI-12 | Isolation |
| requirement-domain-cloudflare-dns | domain | TP-CF-DNS-* · TP-CF-ACTOR-* | **have** — stubbed curl; actor verbs fail closed |
| requirement-dns-actor-table | architecture | TP-CF-ACTOR-01..09 | **have** — routed submit/approve/interactive; dest fence table ACT-M8 |
| requirement-dns-approver | architecture | TP-CF-APR-01..06 | **have** — `.bashrc` / missing `.profile` heal |
| requirement-cloudflare-dns-mode | domain | TP-CF-MODE-01..08 have; 06/09/10 todo | stored mode + RR add/status + switch lock |
| requirement-cloudflare-dns-request | domain | TP-CF-REQ-01..16 | **have** — inbound JSON types; dest-written `submit_by` after format check; DNS dest rejects sudoer `kind` |
| requirement-external-ipv4 | shell | TP-CF-IP-01..04, TP-CLI-04 | **have** — vault-free `ip`; IPv6 MUST NOT |
| requirement-application-local-vault | shell | TP-AV-01..08 have | specify + LPU dest = local vaults / global vault from ordinary login |
| requirement-cloudflare-vault | domain | TP-CF-VAULT-01..33 have | v2 zone-slot CRUD + list verify; default dest Implemented 1.8.0 |
| requirement-cloudflare-api | domain | TP-CF-DNS-* have; TP-CF-API-01..03 | envelope/pagination todo; argv token have; A only |

**Absent by design (no TP Core):** online-install, remote self-management, automatic channel checksum, folder-archive backup/restore, sudoers-manager extras.

**Honesty:** Type 0 TP-CLI / TP-LC (incl. **TP-CLI-14** dual mention), v2 vault TP-CF-VAULT-01..33, **TP-AV-01..08**, TP-CF-MODE-01..08, TP-CF-APR-01..06, TP-LPU-01..07, TP-PRIV-01..10, TP-CF-ACTOR-01..09, TP-SUDOER-JSON-* (incl. **21**), **TP-CF-REQ-01..17**, **TP-ARSA-01/02**, **TP-FENCE-01..06**, **TP-FENCE-08**, and **TP-FENCE-09..17** are **have** against `src/dns-cli` **1.12.0**. **TP-FENCE-07** is **skip** (live sibling dest unknown-key; dest 1.8.1 still refuses `kind`).
