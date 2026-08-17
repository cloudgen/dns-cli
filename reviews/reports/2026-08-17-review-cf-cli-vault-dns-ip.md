# Product review: cf-cli (vault + DNS + ip + suites)

**Date:** 2026-08-17  
**Reviewer:** Grok 4.6  
**Product:** cf-cli `VERSION=1.1.0`  
**Ship unit:** `src/cf-cli`  
**Scope:** Type 0 lifecycle, Cloudflare vault, single-A DNS, `ip` QA verb, live requirements, suites  
**Method:** disk read of ship unit + requirements + tests; `sh tests/run.sh` actually run  
**Baseline:** **PASS=163 FAIL=0 SKIP=0** (2026-08-17, after vault coverage + fixes)

## Summary

cf-cli is specialized hop 1 from cli-template. Vault + DNS + `ip` are implemented and proven offline. This pass added vault store coverage (clear, subdomain add/list, schema, env vs set, uninstall) and fixed two real defects the new cases found: label concatenation and `vault set` not rewriting flags. Remaining work is publish (uncommitted 1.1.0), stale Gap wording in a few Type 0 REQs, live WA/WC grants, and TTY `vault input` (not Core).

## Strengths

| Area | Notes |
|------|--------|
| Type 0 | Empty argv is help; trimmed parent verbs fail closed; install mode 0755 |
| Vault safety | Token split from `vault.json`; HOME=/tmp and 0644 token-file fail closed |
| DNS | Single-A; `status --force` stays read-only; `--ip` override for tests |
| QA | `ip` displays public IPv4 without vault or Cloudflare |
| Isolation | Vault tests use `.ci-homes/`; curl stub never hits the public net |

## Findings

### CF-VAULT-01 — Severity: P1 (high)
- **Area:** vault subdomain list
- **Status:** fixed  
- **Location:** `cf_vault_cmd_subdomain` add path (now `cf_labels_append`)  
- **Description:** Adding a second host-label concatenated the last stored label (`home` + `office` → `homeoffice`) because `$(python print)` strips trailing newlines.  
- **Impact:** Vault would persist a single invalid/wrong label; DNS would target the wrong FQDN.  
- **Suggestion:** Keep `cf_labels_append`; TP-CF-VAULT-08 asserts `["home","office"]`.  
- **Cross-ref:** `requirement-cloudflare-vault` V-M9 · L-VAULT-NL-01  

### CF-VAULT-02 — Severity: P2 (medium)
- **Area:** vault set rewrite
- **Status:** fixed  
- **Location:** `cf_vault_cmd_set` / `cf_vault_apply_set_flags`  
- **Description:** `vault set --zone-id NEW` left the stored zone unchanged when a zone was already present (`merge_missing` only fills empty fields). V-M7 requires explicit set to rewrite.  
- **Impact:** Operators could not update zone/account/domain/token via `vault set` flags.  
- **Suggestion:** Flags on `vault set`/`init` rewrite; env still fills missing only. TP-CF-VAULT-11.  
- **Cross-ref:** `requirement-cloudflare-vault` V-M7 · L-VAULT-SET-01  

### CF-ID-01 — Severity: P3 (low)
- **Area:** identity defaults
- **Status:** fixed  
- **Location:** `inst_local_install` / `inst_local_uninstall` / `app_where_is_me` / `app_about`  
- **Description:** Fallback still said `APP_NAME:=cli-template`. Harmless when Config is set first; stale for anyone sourcing those functions unset.  
- **Suggestion:** Defaults now `cf-cli`.  

### CF-DOC-01 — Severity: P3 (low)
- **Area:** requirements honesty
- **Status:** fixed  
- **Location:** `requirement-bootstrap-chain`, `requirement-class-software-dev`, `requirement-project-folder`, `requirement-shell-local-self-management`, `docs/requirements/README.md` / `index.md`  
- **Description:** Type 0 notes still said identity/domain **Gap** / live `cli-template` while `src/cf-cli` was already Implemented.  
- **Impact:** Agents could treat shipped DNS as unimplemented.  
- **Suggestion:** Notes rebound to Implemented + `src/cf-cli` / `1.1.0` in this pass.  

### CF-WL-01 — Severity: P2 (medium)
- **Area:** whitelist
- **Status:** open (deferred for Core)  
- **Location:** `docs/whitelists/`  
- **Description:** Live Cloudflare/ipinfo still ungranted in WA/WC indexes (prior R5).  
- **Impact:** Host policy incomplete for live runs; Core suite does not need the public net.  
- **Suggestion:** Grant rows when first live QA is ordered.  

### CF-TEST-01 — Severity: P3 (low)
- **Area:** tests
- **Status:** deferred  
- **Location:** `cf_vault_cmd_input` TTY path / `prompt_secret`  
- **Description:** Interactive wizard is only proven as `--json` refuse (`confirm_required`). Echo-off TTY collect is not in Core.  
- **Impact:** Low for CI; operators still use `vault set` for non-interactive.  
- **Suggestion:** Optional expect/scripted TTY later; do not block 1.1.0.  

## Non-findings (explicitly OK)

| Check | Result |
|-------|--------|
| Token in `vault.json` / `vault show` JSON | absent (TP-CF-VAULT-03/06) |
| Empty argv calls ipinfo/Cloudflare | no (TP-CF-DNS-05) |
| `status --force` mutates multi-A | no (`dns_multi_record`) |
| Uninstall deletes vault | no (TP-CF-VAULT-14) |
| `--token` on argv | rejected (TP-CF-VAULT-12) |
| `ip` requires vault | no (TP-CF-IP-01) |
| Backup / restore / sudoers verbs | unknown (TP-CLI-13) |

## Priority remediation order

1. Publish 1.1.0 specialize (commit + create `cloudgen/cf-cli` with bound SSH vault).  
2. CF-WL-01 — grant live Cloudflare/ipinfo when first live run is needed.  
3. Optional: TTY `vault input` (CF-TEST-01).

## Coverage

| Family | Status |
|--------|--------|
| TP-CLI-* | have |
| TP-LC-* | have |
| TP-CF-VAULT-01..17 | have |
| TP-CF-DNS-01..07 | have |
| TP-CF-IP-01..04 | have |

C-full-product: **Sufficient** for implemented Core surfaces. TTY input remains optional.

## Related

| Artifact | Role |
|----------|------|
| `reviews/test-plan.md` | TP map |
| `reviews/requirement-test-matrix.md` | REQ → TP |
| `reviews/lessons.md` | L-VAULT-NL-01 · L-VAULT-SET-01 |
| `reviews/reports/2026-08-16-review-cf-cli-ship-unit.md` | prior ship-unit review |

**Written by:** Grok 4.6  
**Review status:** Code + doc-honesty findings **fixed**; CF-WL-01 / CF-TEST-01 deferred  
