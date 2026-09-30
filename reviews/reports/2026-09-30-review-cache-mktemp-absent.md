# Review: cache requirement against sibling safe-rm

**Date:** 2026-09-30  
**Product:** dns-cli `VERSION=1.36.0`  
**Ship unit:** `src/dns-cli`  
**Scope:** Cache folder law (`requirement-shell-cli-storage`) compared with sibling `safe-rm` storage **1.1.1**. Read-only on safe-rm. Writes stay in dns-cli.  
**Method:** Read both storage requirements and both `util_mktemp` bodies. Added the missing maker-absent rule and ran `sh tests/run.sh`.

## Summary

dns-cli already had the per-login, per-process cache folder (storage **1.6.0**, ship unit **1.35.0**). safe-rm **1.1.1** adds the next rule: `mktemp` is not installed on every OS. When it is missing, or it cannot create the leaf, scratch is still created under that cache folder. A file is mode `0600`. A directory is mode `0700`, because a directory at `0600` exists and cannot be searched.

That rule is now dns-cli storage **1.7.0**. The leaf requirement (`requirement-shell-temp-file-system` **1.2.0**) points at the same helpers so the two files do not disagree.

## What was already in place

| Check | Result |
|-------|--------|
| Linux preferred `/dev/shm/cache/cache-${APP_NAME}-${login}-$$` | Already law and code |
| Git Bash and Mac chains, silent skipped tier, leaf mode `0700` | Already law and code |
| Persistency `${HOME}/.local/dns-cli` | Unchanged |
| About labels Cache folder used / preferred / 1st / 2nd | Unchanged |

## What safe-rm had that dns-cli did not

| Gap | Now |
|-----|-----|
| `util_mktemp` called `mktemp` without checking the program exists | `util_mktemp_bin` checks first. `DNS_CLI_MKTEMP_BIN` (including empty) is the test stand-in |
| A missing maker fell through to bare `mktemp`, which is a `/tmp` dump or a command-not-found | File is `${APP_NAME}.${suffix}.${token}` under the cache folder, mode `0600`, not a `$$` name |
| No scratch-directory mode rule | `util_mktemp_dir` sets mode `0700` and requires the directory to be searchable before return |
| Storage law had no section titled **Under command line for normal user only** | Added. Cache stays this login. No `sudo` to “fix” a missing tier. No exec from the cache folder on Termux |

## Non-findings

| Check | Result |
|-------|--------|
| Silent sibling write | safe-rm was read only |
| Cache chain replaced | No. The 1.6.0 chain is unchanged |
| Vault temps moved into the cache folder | No. Vault rewrites still use `mktemp` in the vault directory |

## Proof

**TP-CLI-28** in `tests/test_cli.sh`: mktemp name under the cache leaf; refuse a `$$` file-name template; absent maker writes mode `0600`; `util_mktemp_dir` under umask `0177` is mode `0700` and searchable.

`sh tests/run.sh` on 2026-09-30: **PASS=984 FAIL=0 SKIP=2** (the two skips are the existing live-dest cases, not this change).

**Review status:** Closed on ship unit 1.36.0 for this gap.
