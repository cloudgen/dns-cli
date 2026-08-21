# Tests — dns-cli

## Run

```sh
./tests/run.sh
# or
sh tests/run.sh
```

Exit **0** when all assertions pass; **1** on failure; **2** if ship unit missing.

## Layout

| File | Focus | TP families |
|------|--------|-------------|
| `run.sh` | Entrypoint | — |
| `helpers.sh` | Asserts + isolated HOME | — |
| `test_cli.sh` | CLI surface, Type N empty argv, offline reject, trimmed-verb reject, **dual mention**, actor-table split, dest fence catalog, **fence-test**, dest-owned `submit_app` | **TP-CLI-*** · **TP-CF-ACTOR-*** · **TP-FENCE-01..04** · **TP-FENCE-08..17** |
| `fixtures/fence-test/` | Local corpus for Type 0 `fence-test` (`pass/` / `match/`) | **TP-FENCE-09..14** |
| `test_local_lifecycle.sh` | install / uninstall / where-is-me | **TP-LC-*** |
| `test_cf_vault.sh` | Vault 0700/0600, HOME fail-closed, last-label, redaction, **`--vault-dir` specify** | **TP-CF-VAULT-*** · **TP-AV-*** |
| `test_cf_dns.sh` | Single A, add-implies-update, `--force`, stubbed curl | **TP-CF-DNS-*** · **TP-CF-MODE-*** |
| `test_cf_ip.sh` | Vault-free public IPv4 display | **TP-CF-IP-*** |
| `test_cf_lpu.sh` | `setup` / `remove-lpu` / `print-sudoers` / generate+submit JSON sudoer + dest-owned queued allowlist (stub `CF_TEST_LPU=1`) | **TP-LPU-*** · **TP-PRIV-*** · **TP-SUDOER-JSON-*** · **TP-FENCE-05** · **TP-FENCE-07** |
| `test_cf_request.sh` | DNS inbound `submit` / `approve` / `reject` + closed schema; DNS dest rejects sudoer `kind`; Type 0 stamps `submit_app` / `submit_version` | **TP-CF-REQ-*** · **TP-FENCE-06** |
| `test_cf_live.sh` | Optional live `crms.hk` as invoking user (not `dns-adm`) | **TP-CF-LIVE-*** |
| `live/` | Seed / discover / teardown for Type 0 specify vault | — |
| `fixtures/cf_curl_stub.sh` | Offline Cloudflare/ipinfo stand-in | — |

## Isolation

- Temp `HOME` + `USER_BIN` + redirected `GLOBAL_BIN` for install tests  
- **No** public network on `./tests/run.sh`  
- **No** write to `/etc` or `/var/backup`  
- Live `crms.hk` verify is **opt-in**: `CF_LIVE=1 sh tests/test_cf_live.sh` as `leolio` with `--vault-dir` (see `tests/live/README.md`). Never `dns-adm`.

## Ship unit under test

`src/dns-cli`

## Maps

Product TP map: `reviews/test-plan.md`  
RTM: `reviews/requirement-test-matrix.md`
