# Test plan — dns-cli

Maps **TP-*** coverage to `tests/`.  
**Suite entry:** `./tests/run.sh`  
**Ship unit (live):** `src/dns-cli`  
**Product VERSION:** 1.9.7  
**Last plan update:** 2026-08-19  
**Last suite run:** PASS=599 FAIL=0 SKIP=0 (2026-08-19)

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
| Backup / restore / sudoers-manager extras | n/a | Absent by design |
| LPU `dns-adm` / Type 1 setup | have | TP-LPU-* / TP-PRIV-01..04 |
| JSON sudoer generate / submit | have | TP-SUDOER-JSON-* / TP-PRIV-05..09 |
| Dual mention (CI-M1) | have | TP-CLI-14 |
| Human-intro standard on every REQ | have | TP-CLI-16 |
| Role tables stay split | have | TP-PRIV-09 · TP-SUDOER-JSON-09 · TP-CF-ACTOR-07 |
| Multi-account vault (v2) | have | TP-CF-VAULT-18..33 |
| A-record mode (stored + switch) | have | TP-CF-MODE-01..08 (09/10 partial) |
| Online curl / companion checksum | n/a | Local-only product |
| Cloudflare vault | have | TP-CF-VAULT-* |
| Cloudflare DNS / ipinfo | have | TP-CF-DNS-* (stubbed curl; no public net) |
| Live `crms.hk` as invoking user | skip | TP-CF-LIVE-* (`CF_LIVE=1`; not in `run.sh`) |

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
| TP-CLI-14 | Dual mention: each routed verb in ≥2 REQs (CLI + topic-owner) | test_cli | requirement-shell-cli-interface CI-M1 | **have** |
| TP-CLI-15 | Topic-owner has a complete `dns-cli …` sample per verb / vault store subcommand | test_cli | requirement-shell-cli-interface CI-M1a | **have** |
| TP-CLI-16 | Every `requirement-*.md` has §1.1 Human-facing + one-sentence lead | test_cli | project-requirements human-intro standard | **have** |

### TP-CF-ACTOR (submit / approve actors)

| TP-ID | Intent | Suite | Primary requirement(s) | Status |
|-------|--------|-------|------------------------|--------|
| TP-CF-ACTOR-01 | `submit` routed; no file fails closed | `tests/test_cli.sh` | requirement-dns-actor-table | **have** |
| TP-CF-ACTOR-02 | `approve` routed | test_cli | requirement-dns-actor-table | **have** |
| TP-CF-ACTOR-03 | `reject` routed | test_cli | requirement-dns-actor-table | **have** |
| TP-CF-ACTOR-04 | `interactive` routed; `--json` fail closed | test_cli | requirement-dns-actor-table | **have** |
| TP-CF-ACTOR-05 | help lists those verbs | test_cli | requirement-dns-actor-table · interface | **have** |
| TP-CF-ACTOR-06 | empty argv is help | test_cli (TP-CLI-07) | requirement-dns-actor-table · zero-arguments | **have** |
| TP-CF-ACTOR-07 | actor table MUST NOT absorb printer / submit-sudoer-request / sudoer-adm | test_cli | requirement-dns-actor-table ACT-M3a | **have** |
| TP-CF-ACTOR-08 | dest MUST NOT fence on file-ownership (ACT-M7) | test_cli | requirement-dns-actor-table ACT-M7 | **have** |
| TP-CF-ACTOR-09 | dest inbound fence is incorrect JSON format (ACT-M8) | test_cli | requirement-dns-actor-table ACT-M8 | **have** |

### TP-CF-APR (approver hook heal)

| TP-ID | Intent | Suite | Primary requirement(s) | Status |
|-------|--------|-------|------------------------|--------|
| TP-CF-APR-01 | interactive approver heals `.bashrc` hook | `tests/test_cf_approver.sh` | requirement-dns-approver | **have** |
| TP-CF-APR-02 | missing `.profile` created and sources `.bashrc` | test_cf_approver | requirement-dns-approver | **have** |
| TP-CF-APR-03 | existing `.profile` not overwritten | test_cf_approver | requirement-dns-approver | **have** |
| TP-CF-APR-07 | rc heal aligns owner to corresponding user | test_cf_approver | requirement-dns-approver APR-M4 · term shell-rc-file-ownership | **have** |
| TP-CF-APR-04 | non-approver does not write rc | test_cf_approver | requirement-dns-approver | **have** |
| TP-CF-APR-05 | `--json` does not heal | test_cf_approver | requirement-dns-approver | **have** |
| TP-CF-APR-06 | second heal idempotent | test_cf_approver | requirement-dns-approver | **have** |

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

### TP-CF-VAULT (Cloudflare vault)

| TP-ID | Intent | Suite | Primary requirement(s) | Status |
|-------|--------|-------|------------------------|--------|
| TP-CF-VAULT-01 | dir 0700 / files 0600 | `tests/test_cf_vault.sh` | requirement-cloudflare-vault | **have** |
| TP-CF-VAULT-02 | no specify + no LPU (`HOME=/tmp` / `env -u HOME`) → `lpu_missing` | test_cf_vault | requirement-cloudflare-vault | **have** |
| TP-CF-VAULT-03 | token redacted in show/about JSON | test_cf_vault | requirement-cloudflare-vault · output | **have** |
| TP-CF-VAULT-04 | last-label remove fail-closed | test_cf_vault | requirement-cloudflare-vault | **have** |
| TP-CF-VAULT-05 | `--token-file` 0644 → `vault_insecure` | test_cf_vault | requirement-cloudflare-vault | **have** |
| TP-CF-VAULT-06 | token absent from `vault.json` | test_cf_vault | requirement-cloudflare-vault | **have** |
| TP-CF-VAULT-07 | `vault input` refuses `--json` | test_cf_vault | requirement-cloudflare-vault | **have** |
| TP-CF-VAULT-08 | `vault subdomain add` + `list` | test_cf_vault | requirement-cloudflare-vault | **have** |
| TP-CF-VAULT-09 | `vault clear` needs `--force`; files removed | test_cf_vault | requirement-cloudflare-vault | **have** |
| TP-CF-VAULT-10 | bad zone_id → `vault_invalid` | test_cf_vault | requirement-cloudflare-vault | **have** |
| TP-CF-VAULT-11 | env does not overwrite; `vault set` rewrites | test_cf_vault | requirement-cloudflare-vault | **have** |
| TP-CF-VAULT-12 | `--token` argv rejected | test_cf_vault | requirement-cloudflare-vault | **have** |
| TP-CF-VAULT-13 | `XDG_CONFIG_HOME=/tmp` without specify → `lpu_missing` | test_cf_vault | requirement-cloudflare-vault | **have** |
| TP-CF-VAULT-14 | uninstall does not delete vault | test_cf_vault | requirement-cloudflare-vault · local-self-management | **have** |
| TP-CF-VAULT-15 | vault.json 0644 → `vault_insecure` | test_cf_vault | requirement-cloudflare-vault | **have** |
| TP-CF-VAULT-16 | unknown schema_version → `vault_invalid` | test_cf_vault | requirement-cloudflare-vault | **have** |
| TP-CF-VAULT-17 | slash host-label → `vault_invalid` | test_cf_vault | requirement-cloudflare-vault | **have** |
| TP-CF-VAULT-18 | two domain-ids + distinct tokens | test_cf_vault | requirement-cloudflare-vault | **have** |
| TP-CF-VAULT-19 | omit `--domain` when N≠1 and no default → `domain_required` | test_cf_vault | requirement-cloudflare-vault | **have** |
| TP-CF-VAULT-20 | `vault account add` duplicate → `domain_exists` | test_cf_vault | requirement-cloudflare-vault | **have** |
| TP-CF-VAULT-21 | v1 root layout → `vault_invalid` | test_cf_vault | requirement-cloudflare-vault | **have** |
| TP-CF-VAULT-22 | last subdomain remove fail-closed per domain-id | test_cf_vault | requirement-cloudflare-vault | **have** |
| TP-CF-VAULT-23 | missing `user_id` → `vault_incomplete` / `vault_invalid` | test_cf_vault | requirement-cloudflare-vault | **have** |
| TP-CF-VAULT-25 | two domains same `user_id` → `vault_invalid` | test_cf_vault | requirement-cloudflare-vault | **have** |
| TP-CF-VAULT-24 | same `zone_id` on two domain-ids → `vault_invalid` | test_cf_vault | requirement-cloudflare-vault | **have** |
| TP-CF-VAULT-26 | `subdomain add` stores `mode=non-round-robin` | test_cf_vault | requirement-cloudflare-vault | **have** |
| TP-CF-VAULT-27 | bare-string `subdomains` → `vault_invalid` | test_cf_vault | requirement-cloudflare-vault | **have** |
| TP-CF-VAULT-28 | `account add` then `list` shows slot fields (no token) | test_cf_vault | requirement-cloudflare-vault | **have** |
| TP-CF-VAULT-29 | `account modify --zone-id` then `list` shows new zone_id | test_cf_vault | requirement-cloudflare-vault | **have** |
| TP-CF-VAULT-30 | `account remove --force` then `list` omits domain-id | test_cf_vault | requirement-cloudflare-vault | **have** |
| TP-CF-VAULT-31 | `vault zone add\|list\|modify\|remove` aliases `account` | test_cf_vault | requirement-cloudflare-vault | **have** |
| TP-CF-VAULT-32 | subdomain add → list → modify → list → remove → list | test_cf_vault | requirement-cloudflare-vault | **have** |
| TP-CF-VAULT-33 | add/modify/remove/list JSON never include token | test_cf_vault | requirement-cloudflare-vault | **have** |
| TP-CF-VAULT-34 | new token probes `_test_<ts>` then deletes; fail `token_probe_failed` does not persist | test_cf_vault | requirement-cloudflare-vault V-M21 | **have** |

### TP-AV (application local vault specify)

| TP-ID | Intent | Suite | Primary requirement(s) | Status |
|-------|--------|-------|------------------------|--------|
| TP-AV-01 | `--vault-dir` absolute path used | `tests/test_cf_vault.sh` | requirement-application-local-vault | **have** |
| TP-AV-02 | `CF_VAULT_DIR` env used | test_cf_vault | requirement-application-local-vault | **have** |
| TP-AV-03 | `--vault-dir /tmp/…` → `vault_insecure` | test_cf_vault | requirement-application-local-vault | **have** |
| TP-AV-04 | relative `--vault-dir` → `vault_insecure` | test_cf_vault | requirement-application-local-vault | **have** |
| TP-AV-05 | `help` lists `--vault-dir` and `CF_VAULT_DIR` | test_cf_vault | requirement-application-local-vault | **have** |
| TP-AV-06 | specified vault works when `HOME=/tmp` | test_cf_vault | requirement-application-local-vault | **have** |
| TP-AV-07 | no specify + no LPU → `lpu_missing` | test_cf_vault | requirement-application-local-vault | **have** |
| TP-AV-08 | dest is local vaults; Type 2 dest is global vault from ordinary login | test_cli | requirement-application-local-vault AV-M11 | **have** |

### TP-LPU (dns-adm account)

| TP-ID | Intent | Suite | Primary requirement(s) | Status |
|-------|--------|-------|------------------------|--------|
| TP-LPU-01 | `setup` creates account+home+`${home}/.local/vaults/dns-cli` | `tests/test_cf_lpu.sh` | requirement-least-privilege-user | **have** |
| TP-LPU-02 | re-`setup` no-op | test_cf_lpu | requirement-least-privilege-user | **have** |
| TP-LPU-03 | default vault as other user → `lpu_required` | test_cf_lpu | requirement-least-privilege-user | **have** |
| TP-LPU-04 | `--vault-dir` without LPU still works | test_cf_lpu | requirement-least-privilege-user | **have** |
| TP-LPU-05 | `uninstall` does not `userdel` | test_cf_lpu | requirement-least-privilege-user · local-self-management | **have** |
| TP-LPU-06 | `remove-lpu` JSON without `--force` → `confirm_required` | test_cf_lpu | requirement-least-privilege-user | **have** |
| TP-LPU-07 | dest inbound fence is incorrect JSON format (L-M13 table) | test_cf_lpu | requirement-least-privilege-user L-M13 | **have** |

### TP-PRIV (Type map / fragment)

| TP-ID | Intent | Suite | Primary requirement(s) | Status |
|-------|--------|-------|------------------------|--------|
| TP-PRIV-01 | `print-sudoers` ⊆ Table A; no dest write | `tests/test_cf_lpu.sh` | requirement-three-layer-privilege-model | **have** |
| TP-PRIV-02 | install-script / remove-draft / backup / restore unknown | test_cf_lpu | requirement-three-layer-privilege-model | **have** |
| TP-PRIV-03 | `setup` without root/sudo fails closed | test_cf_lpu | requirement-three-layer-privilege-model | **have** |
| TP-PRIV-04 | fragment has no ALL / no shell | test_cf_lpu | requirement-three-layer-privilege-model | **have** |
| TP-PRIV-05 | generate refuses `/etc`; dest is local | test_cf_lpu | requirement-sudoer-json-file · three-layer | **have** |
| TP-PRIV-06 | submit missing dest CLI fail-closed | test_cf_lpu | requirement-sudoer-json-file | **have** |
| TP-PRIV-07 | submit stub inbound; no `/etc/sudoers.d` write | test_cf_lpu | requirement-sudoer-json-file | **have** |
| TP-PRIV-08 | refuse OS-tool / runas-root grant | test_cf_lpu | requirement-sudoer-json-file | **have** |
| TP-PRIV-09 | three-layer §2.1a role table present (printer / generator / submitter) | test_cf_lpu | requirement-three-layer-privilege-model AC-P7 | **have** |
| TP-PRIV-10 | dest inbound fence is incorrect JSON format (P-M13 table) | test_cf_lpu | requirement-three-layer-privilege-model P-M13 | **have** |

### TP-SUDOER-JSON (JSON grant body)

| TP-ID | Intent | Suite | Primary requirement(s) | Status |
|-------|--------|-------|------------------------|--------|
| TP-SUDOER-JSON-01 | generate path is only `/usr/local/bin/dns-cli` | `tests/test_cf_lpu.sh` | requirement-sudoer-json-file | **have** |
| TP-SUDOER-JSON-02 | no mkdir/cp/tar/rm/install/chmod in JSON | test_cf_lpu | requirement-sudoer-json-file | **have** |
| TP-SUDOER-JSON-03 | default generate is `type-2-switch`; runas `dns-adm`; args `[]`; service `dns-cli` | test_cf_lpu | requirement-sudoer-json-file | **have** |
| TP-SUDOER-JSON-08 | generate dest readable without sudo | test_cf_lpu | requirement-sudoer-json-file | **have** |
| TP-SUDOER-JSON-09 | §2.0 role table (printer / generator / submitter / sudoer-adm) | test_cf_lpu | requirement-sudoer-json-file AC-11 | **have** |
| TP-SUDOER-JSON-10 | generate writes `kind` | test_cf_lpu | requirement-sudoer-json-file | **have** |
| TP-SUDOER-JSON-11 | `--kind login-hook-elev` → username `dns-adm`, runas `root`, args `interactive` | test_cf_lpu | requirement-sudoer-json-file | **have** |
| TP-SUDOER-JSON-12 | Type 0 submit of hook kind fails closed | test_cf_lpu | requirement-sudoer-json-file | **have** |
| TP-SUDOER-JSON-13 | setup auto-submits hook kind when sibling stub present | test_cf_lpu | requirement-sudoer-json-file · LPU | **have** |
| TP-SUDOER-JSON-16 | dest Type 0 `self_scope` does not block setup inbound write | test_cf_lpu | requirement-sudoer-json-file SJ-M3 | **have** |
| TP-SUDOER-JSON-14 | setup skips auto-submit when sibling missing | test_cf_lpu | requirement-sudoer-json-file · LPU | **have** |
| TP-SUDOER-JSON-15 | law names both kinds | test_cf_lpu | requirement-sudoer-json-file | **have** |
| TP-SUDOER-JSON-17 | law names switch dest ≠ hook dest ≠ F6 | test_cf_lpu | requirement-sudoer-json-file | **have** |
| TP-SUDOER-JSON-18 | setup hook write does not `chown`; law names SJ-M5 | test_cf_lpu | requirement-sudoer-json-file SJ-M5 | **have** |
| TP-SUDOER-JSON-19 | dest MUST NOT fence on file-ownership | test_cf_lpu | requirement-sudoer-json-file SJ-M5 | **have** |
| TP-SUDOER-JSON-20 | dest inbound fence is incorrect JSON format | test_cf_lpu | requirement-sudoer-json-file SJ-M5 | **have** |

### TP-CF-DNS (Cloudflare DNS + ipinfo)

| TP-ID | Intent | Suite | Primary requirement(s) | Status |
|-------|--------|-------|------------------------|--------|
| TP-CF-DNS-01 | add no-op same IP | `tests/test_cf_dns.sh` | requirement-domain-cloudflare-dns | **have** |
| TP-CF-DNS-02 | add-implies-update different IP | test_cf_dns | requirement-domain-cloudflare-dns | **have** |
| TP-CF-DNS-03 | implicit non-RR N>1 → `dns_multi_record`; `status --force` still fail | test_cf_dns | requirement-domain-cloudflare-dns | **have** |
| TP-CF-DNS-04 | `add --force` collapse (repair, not switch) | test_cf_dns | requirement-domain-cloudflare-dns | **have** |
| TP-CF-DNS-05 | empty argv does not network | test_cf_dns | requirement-domain-cloudflare-dns · zero-arguments | **have** |
| TP-CF-DNS-06 | `--ip` override; reject 127/8 | test_cf_dns | requirement-domain-cloudflare-dns | **have** |
| TP-CF-DNS-07 | status real resolver A + `in_sync` | test_cf_dns | requirement-domain-cloudflare-dns | **have** |
| TP-CF-DNS-08 | two domain-ids → `domain_required` without `--domain` | test_cf_dns | requirement-domain-cloudflare-dns | **todo** |

### TP-CF-MODE (A-record mode)

| TP-ID | Intent | Suite | Primary requirement(s) | Status |
|-------|--------|-------|------------------------|--------|
| TP-CF-MODE-01 | new label defaults `non-round-robin` | `tests/test_cf_dns.sh` | requirement-cloudflare-dns-mode | **have** |
| TP-CF-MODE-02 | non-RR different IP updates in place (not second A) | test_cf_dns | requirement-cloudflare-dns-mode | **have** |
| TP-CF-MODE-03 | switch to RR when `ipv4_count`=1 | test_cf_dns | requirement-cloudflare-dns-mode | **have** |
| TP-CF-MODE-04 | RR add second distinct IPv4 | test_cf_dns | requirement-cloudflare-dns-mode | **have** |
| TP-CF-MODE-05 | switch when count≥2 → `dns_mode_locked` | test_cf_dns | requirement-cloudflare-dns-mode | **have** |
| TP-CF-MODE-06 | RR → non-RR when count is 0 or 1 | test_cf_dns | requirement-cloudflare-dns-mode | **todo** |
| TP-CF-MODE-07 | IPv6 / AAAA rejected; not counted | test_cf_dns | requirement-cloudflare-dns-mode · external-ipv4 | **have** |
| TP-CF-MODE-08 | RR `status` N=2 succeeds | test_cf_dns | requirement-cloudflare-dns-mode | **have** |
| TP-CF-MODE-09 | `--force` collapse is not a switch | test_cf_dns | requirement-cloudflare-dns-mode | **todo** |
| TP-CF-MODE-10 | empty argv does not switch | test_cf_dns | requirement-cloudflare-dns-mode · zero-arguments | **todo** |
| TP-CF-MODE-11 | live count fail (HTTP 000/403) must not switch | test_cf_dns | requirement-cloudflare-dns-mode MODE-M8 | **todo** |

### TP-CF-REQ (DNS request JSON)

| TP-ID | Intent | Suite | Primary requirement(s) | Status |
|-------|--------|-------|------------------------|--------|
| TP-CF-REQ-01 | accept `add` non-RR example | `tests/test_cf_request.sh` | requirement-cloudflare-dns-request | **have** |
| TP-CF-REQ-02 | accept `add` RR example | test_cf_request | requirement-cloudflare-dns-request | **have** |
| TP-CF-REQ-03 | accept `update` + RR `from_ipv4` | test_cf_request | requirement-cloudflare-dns-request | **have** |
| TP-CF-REQ-04 | accept `remove` variants | test_cf_request | requirement-cloudflare-dns-request | **have** |
| TP-CF-REQ-05 | accept both `mode` examples | test_cf_request | requirement-cloudflare-dns-request | **have** |
| TP-CF-REQ-06 | unknown action / extra key fail | test_cf_request | requirement-cloudflare-dns-request | **have** |
| TP-CF-REQ-07 | IPv6 or token in body fail | test_cf_request | requirement-cloudflare-dns-request | **have** |
| TP-CF-REQ-08 | `mode` plus `ipv4` fail | test_cf_request | requirement-cloudflare-dns-request | **have** |
| TP-CF-REQ-09 | `cf_req_move` `chown`s to LPU before `mv`; skip in test mode | test_cf_request | requirement-dns-actor-table ACT-M6 | **have** |
| TP-CF-REQ-10 | dest inbound fence is incorrect JSON format (REQ-M9 table) | test_cf_request | requirement-cloudflare-dns-request REQ-M9 | **have** |
| TP-CF-REQ-11 | login-hook `interactive` takes inbound ownership at the beginning | test_cf_request | requirement-dns-actor-table ACT-M4 · requirement-dns-approver APR-M3 | **have** |
| TP-CF-REQ-12 | approval question is one-off `prompt_yes_no` (yes=approve, no=reject) | test_cf_request | requirement-dns-actor-table ACT-M4 · term approval-question | **have** |
| TP-CF-REQ-13 | dest fence first; human-facing match; no question on match | test_cf_request | requirement-dns-actor-table ACT-M4 · ACT-M8 · term approval-system | **have** |
| TP-CF-REQ-14 | user SSOT is JSON `subject`; dest MUST NOT fence on filename token | test_cf_request | requirement-dns-actor-table ACT-M8 · requirement-cloudflare-dns-request REQ-M9 · term json-username-field | **have** |
| TP-CF-REQ-15 | interactive records original owner; dest-writes `submit_by` if format is clear | test_cf_request | requirement-dns-actor-table ACT-M4 · requirement-cloudflare-dns-request REQ-M3a | **have** |
| TP-ARSA-01 | software-dev class MUST consider actor / role / subject / approver even if no dest approver | test_cli | requirement-class-software-dev | **have** |
| TP-ARSA-02 | catalog prints Actor / Role / Subject / Submitter / Approver; anyone or the actor itself | test_cli | requirement-actor-role-subject-approver | **have** |
| TP-FENCE-01 | software-dev class MUST review dest fences; each Fence is an independent REQ or residual none | test_cli | requirement-class-software-dev §2.9 · AC-9 | **have** |
| TP-FENCE-02 | requirement-incorrect-json-format exists; dest tables point at it | test_cli | requirement-incorrect-json-format · requirement-dns-actor-table | **have** |

### TP-CF-LIVE (optional real zone — invoking user)

| TP-ID | Intent | Suite | Primary requirement(s) | Status |
|-------|--------|-------|------------------------|--------|
| TP-CF-LIVE-01 | skip unless `CF_LIVE=1`; refuse `dns-adm` | `tests/test_cf_live.sh` | requirement-domain-cloudflare-dns D-M15 | **skip** |
| TP-CF-LIVE-02 | `vault account add` via `--vault-dir` as `$USER` | test_cf_live | requirement-cloudflare-vault | **skip** |
| TP-CF-LIVE-03 | live `status` of probe FQDN | test_cf_live | requirement-domain-cloudflare-dns | **skip** |
| TP-CF-LIVE-04 | probe `add` then `remove` (`dns-cli-tmp`) | test_cf_live | requirement-domain-cloudflare-dns D-M16 | **skip** |
| TP-CF-LIVE-05 | `vault account remove` + operator revokes token | test_cf_live · `tests/live/teardown.sh` | requirement-domain-cloudflare-dns D-M16 | **skip** |

### TP-CF-API (Cloudflare HTTPS)

| TP-ID | Intent | Suite | Primary requirement(s) | Status |
|-------|--------|-------|------------------------|--------|
| TP-CF-API-01 | envelope `success` false → `dns_api_failed` | `tests/test_cf_dns.sh` | requirement-cloudflare-api | **todo** |
| TP-CF-API-02 | `--token` argv rejected | test_cf_vault | requirement-cloudflare-api · vault | **have** |
| TP-CF-API-03 | `total_pages` > 1 still counts all A for the name | test_cf_dns | requirement-cloudflare-api | **todo** |

### TP-CF-IP (public IPv4 display)

| TP-ID | Intent | Suite | Primary requirement(s) | Status |
|-------|--------|-------|------------------------|--------|
| TP-CF-IP-01 | `--json ip --ip` works without vault | `tests/test_cf_ip.sh` | requirement-external-ipv4 | **have** |
| TP-CF-IP-02 | `ip` hits ipinfo stub only (no Cloudflare) | test_cf_ip | requirement-external-ipv4 | **have** |
| TP-CF-IP-03 | `ip --ip 127.0.0.1` → `ip_lookup_failed` | test_cf_ip | requirement-external-ipv4 | **have** |
| TP-CF-IP-04 | ipinfo HTTP 429 → `ip_lookup_failed` | test_cf_ip | requirement-external-ipv4 | **have** |

---

## Rules

1. Closing a **bug** finding updates the matching TP to **have**.  
2. Do not mark TP **have** without a suite assertion (or honest skip/n/a).  
3. Do not reintroduce online TP-CURL/TP-CSUM or TP-FOLDER-BACKUP as Core without product-mode change.  
4. Domain proof uses **TP-CF-VAULT-***, **TP-CF-DNS-***, and **TP-CF-IP-***. LPU/setup proof uses **TP-LPU-*** / **TP-PRIV-***. JSON sudoer submitter uses **TP-SUDOER-JSON-*** / **TP-PRIV-05..09**. Dual mention uses **TP-CLI-14**. Actor-table split uses **TP-CF-ACTOR-07**.
