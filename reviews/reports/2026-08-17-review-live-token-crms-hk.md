# Report: live token review/test — cf-cli 1.2.0

**Date:** 2026-08-17  
**Mode:** Type 0 specify as `leolio` (not `cf-adm`) on zone `crms.hk`  
**Status:** live re-verified after `zone:dns:edit` — sufficient for D-M15/D-M16  
**Operator:** `leolio`  
**Zone:** `crms.hk` (`4338539b9b4a6b5184910370ec9bfb08`)  
**Account:** `d96afb25d51b9331939cc8ab866ffa20`  
**Token id:** `d50fba2a0518c81c0c7739f915841c13` (used as vault `user_id`; `/user` is 403 — not a dashboard user-id)  
**Method:** disk + `./tests/run.sh` + live `CF_LIVE=1` + extra probe on `cf-cli-tmp` only

## Summary

Offline `./tests/run.sh` is clean: **PASS=235 FAIL=0 SKIP=0**. The same temporary token first listed and mutated A records on probe `cf-cli-tmp.crms.hk`. Mid-session, `GET/POST /zones/:id/dns_records` flipped to HTTP 403 / Cloudflare `10000 Authentication error` while `/user/tokens/verify` and `GET /zones/:id` stayed 200. After the operator added `zone:zone:edit`, DNS is still 403 and `GET /zones/:id/settings` is 403 / `9109`. That grant is Zone **settings** edit, not Zone **DNS** edit. Official `TP-CF-LIVE` after the flip: **PASS=5 FAIL=4**. Specify vault was torn down. Probe label has no public A. Apex / staging / test still resolve through Cloudflare proxy addresses.

## Issues

### Issue 1 -- Severity: bug
- File: (operator token, not ship unit)
- Description: After the token was edited to allow `zone:zone:edit`, live DNS CRUD remains 403 `10000 Authentication error`. `zone:zone:edit` is Zone → Zone → Edit (settings). `add` / `status` / `update` / `remove` need Zone → **DNS** → Edit (`#dns_records:edit`, which includes list/read). Editing the token mid-session also matches the flip from working DNS to 403.
- Suggestion: On this token (or a new temp token), restore **Zone / DNS / Edit** scoped to **crms.hk**. Keep Zone / Zone / Read. `zone:zone:edit` is not required for D-M15/D-M16. Then re-run `CF_LIVE=1 sh tests/test_cf_live.sh`.
- Lesson: L-LIVE-PERM-01
- Test: TP-CF-LIVE-03 / TP-CF-LIVE-04
- Status: open

### Issue 2 -- Severity: suggestion
- File: tests/test_cf_live.sh:68
- Description: Official live suite only covers seed / status / add / remove / account remove. Extra live review (before the 403 flip) already exercised non-RR in-place update, RR switch at count=1, RR second A, mode lock at N=2, `--from` / `--ip` gates, switch-back at count=0, and IPv6 reject (17 pass / 3 fail, the fails were the first 403s).
- Suggestion: When DNS permission is restored, promote the extra probe cases into `tests/test_cf_live.sh` or keep them as an optional Type 0 operator script. Do not put them in `./tests/run.sh` (D-M10).
- Test: TP-CF-LIVE-*
- Status: open

### Issue 3 -- Severity: nit
- File: reviews/index.md:5
- Description: Index was stale (suite 163; missing vault-CRUD and earlier live reports) while ship unit is 1.2.0 and offline suite is 235.
- Suggestion: Keep index + README baseline in the same change as each live/offline pass.
- Status: closed (updated this pass)

## Live evidence

| Check | Result |
|-------|--------|
| Invoking user | `leolio` (not `cf-adm`) |
| Token verify | 200 `status=active` |
| `GET /zones/:id` | 200 zone `crms.hk` |
| `GET /user` | 403 (no User Read; expected) |
| First A-list (before edit) | 200 — `crms.hk` 172.237.21.158 proxied; `staging` 172.238.24.178 proxied; `test` 172.237.6.185 proxied; no `cf-cli-tmp` |
| Extra live probe | PASS=17 FAIL=3 (first `status` + one RR `update --from` hit 403 list) |
| After `zone:zone:edit` | `dns_records` 403/10000; `settings` 403/9109 |
| `CF_LIVE=1 sh tests/test_cf_live.sh` | PASS=5 FAIL=4 (LIVE-03/04 list+add 403; LIVE-01/02/05 pass) |
| `./tests/run.sh` | PASS=235 FAIL=0 SKIP=0 |
| Teardown | `.live-vault/` removed; public resolver has no `cf-cli-tmp.crms.hk` |

Extra live cases that passed against the real API before the permission flip: seed + no token in JSON; list `zone_id`; add created / already; non-RR in-place update; switch to round-robin at count=1; RR add second IP; status `ipv4_count=2`; mode lock at N=2; RR update without `--from`; RR remove without `--ip`; RR remove `--ip`; force remove remaining; switch back at count=0; IPv6 rejected.

## Non-findings

| Check | Result |
|-------|--------|
| Token in vault JSON / list JSON | not present (asserted) |
| Default suite stays offline | `./tests/run.sh` does not source `test_cf_live.sh` |
| Probe target | only `cf-cli-tmp`; not `@` / `www` |
| LPU `/etc/cf-adm` | not used (honest Gap) |
| Submit/approve inbound | not exercised (honest Gap) |

## Re-verify after `zone:dns:edit` (same day)

Operator added **Zone → DNS → Edit** on `crms.hk`. Same token id, still no User Read.

| Check | Result |
|-------|--------|
| Token verify | 200 `active` |
| `GET /zones/:id` | 200 |
| `GET /dns_records?type=A` | 200 — same 3 production A rows |
| Probe POST / PUT / DELETE `cf-cli-tmp` | 200 |
| `GET /user` | 403 / 9109 (expected; vault still uses token id) |
| `GET /zones/:id/settings` | 403 / 9109 (not needed) |
| `CF_LIVE=1 sh tests/test_cf_live.sh` | **PASS=9 FAIL=0 SKIP=0** |
| Production A after suite + teardown | unchanged; no `cf-cli-tmp` |

## Verdict

**Yes — `zone:dns:edit` on `crms.hk` is good enough** for this product’s live path (zone GET + A list/create/update/delete + Type 0 specify vault). `zone:zone:edit` is not required. User Read is not required if vault `user_id` stays the token id (stay-honest: that is not a dashboard user-id).

**Revoke** the temporary API token in the dashboard when this session is done.
