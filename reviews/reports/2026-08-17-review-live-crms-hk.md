# Review — live `crms.hk` Type 0 as `leolio`

**Date:** 2026-08-17  
**Operator:** `leolio` (not `cf-adm`; no `/etc/cf-adm`)  
**Zone:** `crms.hk` (`4338539b9b4a6b5184910370ec9bfb08`)  
**Account:** `d96afb25d51b9331939cc8ab866ffa20`  
**Token permissions:** `#dns_records:edit` `#dns_records:read` `#zone:read`  
**Token `/user`:** HTTP 403 (no User Read)  
**Vault `user_id` used:** token id `d50fba2a0518c81c0c7739f915841c13` (stay-honest: **not** a dashboard user-id)

## Suite

`CF_LIVE=1 sh tests/test_cf_live.sh` → **PASS=8 FAIL=0 SKIP=0**

| TP | Result |
|----|--------|
| TP-CF-LIVE-01 invoking user `leolio` | pass |
| TP-CF-LIVE-02 specify vault add / no token in JSON | pass |
| TP-CF-LIVE-03 live `status` of `cf-cli-tmp.crms.hk` | pass |
| TP-CF-LIVE-04 probe `add` then `remove` | pass |
| TP-CF-LIVE-05 `vault account remove` | pass |

`./tests/run.sh` was not required for this live pass (stays offline by law).

## Zone before / after

Existing A records **unchanged**:

| Name | Content | Proxied |
|------|---------|---------|
| `crms.hk` | 172.237.21.158 | true |
| `staging.crms.hk` | 172.238.24.178 | true |
| `test.crms.hk` | 172.237.6.185 | true |

Probe `cf-cli-tmp.crms.hk` is **absent** after teardown. Specify dir `.live-vault/` **removed**.

## Findings

1. Type 0 `--vault-dir` works as `leolio` with a real zone. `cf-adm` is not required.  
2. Token is zone-scoped as intended; `/user` 403 is expected without User Read. Vault still requires a 32-hex `user_id` — live seed used the **token id**. Do not treat that as a Cloudflare user-id.  
3. Probe used documentation IPv4 `203.0.113.10` (created then deleted). Apex / staging / test were not written.  
4. Bearer secret was pasted in chat earlier — **revoke this token** in the dashboard.

## Verdict

Pass for live Type 0 review/test on `crms.hk` as `leolio`. Revoke the temp token.
