# Review: cf-cli ship unit + vault/DNS + suites

**Date:** 2026-08-16  
**Scope:** `src/cf-cli`, `tests/test_cf_vault.sh`, `tests/test_cf_dns.sh`, live requirements DTV  
**Suite:** `sh tests/run.sh` → **PASS=113 FAIL=0 SKIP=0**

## Verdict

**Approve with follow-ups.** Type 0 inheritance holds. Domain vault + single-A DNS is implemented and proven offline. Remaining work is product-docs polish and live GitHub repo create (owner already chose retarget-now).

## Findings

| ID | Severity | Finding | Status |
|----|----------|---------|--------|
| R1 | major (fixed) | `out_die_code` / `cf_ip_lookup` / `cf_vault_dir` inside `$(…)` only exited the subshell | Fixed: set globals, die in the parent |
| R2 | major (fixed) | `--token-file` 0644 ignored when vault already had a token | Fixed: mode check whenever the flag is present |
| R3 | major (fixed) | `env -u HOME` inherited Type 0 getent HOME and skipped `vault_no_home` | Fixed: `CF_HOME_MISSING` at process start |
| R4 | minor | `src/cli-template` leftover would be a second ship unit | Remove in same change |
| R5 | minor | Live Cloudflare/ipinfo still ungranted in WA/WC indexes | P2 (PR 5); Core tests do not need public net |
| R6 | nit | `util_json_escape` is not used when composing `vault.json` field strings | Hex IDs + DNS labels only; accept |

## Strengths

- Help lists only routed verbs; empty argv does not call the curl stub.
- `status --force` stays read-only (`dns_multi_record`).
- Token never appears in `vault.json` or `--json vault show`.
- Isolated vault HOME is under `.ci-homes/` (not `/tmp`) so law and tests agree.

## Coverage

C-full-product: **Sufficient** for implemented surfaces (Type 0 + vault + DNS). Whitelist grants remain a policy follow-up, not a REQ gap.
