# Report: local ship-unit review — cf-cli 1.2.0

**Date:** 2026-08-17  
**Mode:** local uncommitted (staged + unstaged + untracked)  
**Status:** open items  
**Suite:** `./tests/run.sh` PASS=235 FAIL=0 SKIP=0

## Summary

cf-cli 1.2.0 specializes the template into v2 vault slots, zone-slot CRUD, stored A-record mode, and stubbed DNS/IP suites. Offline tests are clean. Token is not placed on curl argv. Dominant ship-unit risks: mode switch fail-open when the live count runs in `$()`, leftover `--config` files on interrupt, `vault input` wiping labels, and mutate paths that report success without checking the Cloudflare envelope.

## Issues

### Issue 1 -- Severity: bug
- File: src/cf-cli:2332
- Description: Mode switch captures `cf_vault_live_ipv4_count` in `$()`. `out_die_code` inside command substitution only ends the subshell, so `_cnt` is empty and the mode is rewritten anyway. Cloudflare down or `dns_api_failed` fail-open against MODE-M8.
- Suggestion: Call the live count in the current shell; on list/zone failure `out_die_code` and do not treat empty as 0/1.
- Lesson: L-MODE-SUBSHELL-01
- Test: TP-CF-MODE-05 (extend for API-fail path)
- Status: open

### Issue 2 -- Severity: bug
- File: src/cf-cli:2197
- Description: Missing token/zone/domain makes `cf_vault_live_ipv4_count` print `0` and return success, so the switch gate treats “cannot count” as safe.
- Suggestion: Die with `vault_incomplete` / `dns_api_failed`. Only a parsed `success=true` envelope may yield a count.
- Test: TP-CF-MODE-*
- Status: open

### Issue 3 -- Severity: bug
- File: src/cf-cli:2611
- Description: `cf_api_curl` writes Bearer into a 0600 `--config` file and unlinks only after curl returns. No EXIT/INT/TERM trap (V-M14). SIGINT leaves the token on disk.
- Suggestion: Trap-unlink hdr/body/data temps. Keep `--config` (do not put the token on argv).
- Lesson: L-VAULT-NL-01 related (token file hygiene)
- Status: open

### Issue 4 -- Severity: bug
- File: src/cf-cli:2071
- Description: `vault input` replaces the subdomain list with one `label|non-round-robin`. Extra labels are deleted; an existing round-robin label is forced back with no `ipv4_count` gate.
- Suggestion: Keep `CFV_SUBPAIRS` unless creating the first label; run the same switch gate as `vault subdomain mode`.
- Status: open

### Issue 5 -- Severity: bug
- File: src/cf-cli:2826
- Description: After POST/PUT/DELETE, add/update/remove never inspect `CF_API_HTTP` or envelope `success` (API-M7). A 4xx still prints `status=created`.
- Suggestion: Require HTTP 200 and `success=true` or `out_die_code dns_api_failed`. Close a TP-CF-API row.
- Test: TP-CF-API-01 (todo)
- Status: open

### Issue 6 -- Severity: bug
- File: tests/test_cf_live.sh:66
- Description: `assert_not_contains` uses the live token as the needle. On failure `t_fail` can print up to 160 chars of the secret.
- Suggestion: Fail as `token leaked in JSON` without interpolating the secret.
- Status: open

### Issue 7 -- Severity: suggestion
- File: src/cf-cli:1928
- Description: `CFV_TOKEN=$(cf_vault_read_token_file …)` has the same `$()` / `out_die_code` problem (0644 token-file can emit two JSON errors).
- Suggestion: Set `CFV_TOKEN` in the current shell.
- Status: open

### Issue 8 -- Severity: suggestion
- File: src/cf-cli:1558
- Description: Tool check accepts `python3` or `jq`, but v2 writers require `python3`.
- Suggestion: Require `python3` for v2 (`json_tool_missing`) or add jq writers.
- Status: open

### Issue 9 -- Severity: suggestion
- File: docs/requirements/index.md:55
- Description: Agent rule 9 still calls v2 layout and stored mode Gap while ship unit 1.2.0 implements them. LPU / inbound JSON correctly stay Gap.
- Suggestion: Align Implemented vs Gap wording.
- Status: open

### Issue 10 -- Severity: suggestion
- File: README.md:3
- Description: User-facing version leftovers still say 1.1.0 in several law/review files. Ship-unit SSOT is `VERSION="1.2.0"`.
- Suggestion: Align product-facing notes with 1.2.0.
- Status: open

### Issue 11 -- Severity: nit
- File: src/cf-cli:1418
- Description: `cf_labels_append` is unused; add concatenates `CFV_SUBPAIRS` with a literal newline.
- Suggestion: Call the helper or delete it and retarget L-VAULT-NL-01.
- Status: open

## Verdict

Approve with follow-ups for the offline ship unit. Do not treat mode-switch as fail-closed until Issues 1–2 are fixed. Live D-M15/D-M16 on this token is separately blocked — see `reports/2026-08-17-review-live-token-crms-hk.md`.
