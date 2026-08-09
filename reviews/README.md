# Reviews — folder-backup

Public product review surface (peer of `tests/`).

| File | Role |
|------|------|
| `what-to-review.md` | Living review plan / checklist |
| `test-plan.md` | TP-* status map |
| `requirement-test-matrix.md` | Requirement → TP families |
| `lessons.md` | Durable failure modes to re-check |
| `index.md` | Report index |
| `reports/` | Dated review run reports |

**Ship unit:** `src/folder-backup` (**VERSION 1.4.1**)  
**Suite:** `./tests/run.sh`  
**Last suite baseline:** PASS=131 FAIL=0 SKIP=0 (2026-08-09) — see `test-plan.md` and `reports/`  

**Privilege review focus (1.3+):** trust tier **S13**, project-sudoers-file, `print-sudoers-install-script`, `remove-project-sudoers` (draft only).
