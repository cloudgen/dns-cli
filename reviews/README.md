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

**Ship unit:** `src/dns-cli` (**VERSION 1.11.0**)  
**Suite:** `./tests/run.sh`  
**Last suite baseline:** see `reviews/test-plan.md`

**Review focus:** Type 0/1/2 + LPU `dns-adm` + inbound DNS approval + dest-owned sudoer JSON (`kind`) + dest fence catalog. Live Type 0 specify on `crms.hk` is optional (`CF_LIVE=1`). No backup/restore/sudoers-manager extras. This product **is** a sudoer-approval-submitter.
