# Tests — cli-template

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
| `test_cli.sh` | CLI surface, Type N empty argv, offline reject, trimmed-verb reject | **TP-CLI-*** |
| `test_local_lifecycle.sh` | install / uninstall / where-is-me | **TP-LC-*** |

## Isolation

- Temp `HOME` + `USER_BIN` + redirected `GLOBAL_BIN` for install tests  
- **No** public network  
- **No** write to `/etc` or `/var/backup`

## Ship unit under test

`src/cli-template`

## Maps

Product TP map: `reviews/test-plan.md`  
RTM: `reviews/requirement-test-matrix.md`
