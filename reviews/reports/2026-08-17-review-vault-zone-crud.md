# Review — vault zone-slot CRUD (ship unit 1.2.0)

**Date:** 2026-08-17  
**Scope:** `src/cf-cli` v2 vault + A-record mode; `tests/test_cf_vault.sh`; `tests/test_cf_dns.sh`  
**Suite:** `./tests/run.sh` PASS=235 FAIL=0 SKIP=0

## Summary

v2 vault is Implemented on `src/cf-cli` **1.2.0**: `accounts/<domain-id>/`, required `user_id`, `vault account`/`vault zone` add/list/modify/remove, `vault subdomain` add/list/modify/remove/mode. List JSON is the verification surface (token never printed). Default mode is non-round-robin; round-robin add/status and switch lock are wired. LPU default dest `/etc/cf-adm/vault/` and Type 1 `setup` remain Gap.

## Issues found and fixed this pass

1. **List JSON used default `json.dumps` spacing** so tests looking for `"domain_id":"x"` missed `"domain_id": "x"`. Fixed compact separators.  
2. **`vault set` after schema_version=99 could not repair** (load died; later `_cf_vault_seed` no-op). Soft-load on set now rewrites the slot.  
3. **Round-robin `update`/`remove`** still treated N>1 as `dns_multi_record`. Now `update` needs `--from`; `remove` needs `--ip`.

## Remaining (honest Gap / todo)

- TP-CF-MODE-06 / 09 / 10 not asserted (switch back at count 0/1; force-is-not-switch; empty argv).  
- Default vault path is still XDG when `cf-adm` is absent (AV-M1 / TP-AV-07).  
- Type 2 run-as-`cf-adm` not implemented.

## Verdict

Pass for the requested vault CRUD + list verification, with the fixes above. Do not claim LPU dest or Type 1 setup Implemented.
