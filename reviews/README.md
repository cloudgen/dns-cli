# Reviews — dns-cli

Public product review surface (peer of `tests/`).

| File | Role |
|------|------|
| `what-to-review.md` | Living review plan / checklist |
| `test-plan.md` | TP-* status map |
| `requirement-test-matrix.md` | Requirement → TP families |
| `lessons.md` | Durable failure modes to re-check |
| `index.md` | Report index |
| `reports/` | Dated review run reports |

**Ship unit:** `src/dns-cli` (**VERSION 1.2.0**)  
**Suite:** `./tests/run.sh`  
**Last suite baseline:** PASS=240 FAIL=0 SKIP=0 (2026-08-17)

**Review focus:** Type 0 local lifecycle + Cloudflare vault v2 + A-record mode + `ip`; live Type 0 specify on `crms.hk` is optional (`CF_LIVE=1`). No backup/restore/sudoers-file surface.
