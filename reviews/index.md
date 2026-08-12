# Review reports index — folder-backup

| Date | Report | Scope | Verdict | Suite |
|------|--------|-------|---------|-------|
| 2026-08-12 | **1.6.0 retention** (daily 5 + total 30; TP-17/18; retention REQs) | `fb_apply_retention` + deposit Type 0 when writable + sudoers rm | **PASS** | PASS=166 FAIL=0 SKIP=0 |
| 2026-08-12 | **1.5.0 restore dest whitelist** (W-ETC-USER; mold/REQ/TP-16; INC-20260812-001 Closed) | `fb_refuse_restore_dest`; checklist `docs/checklists/2026-08-12-checklist-restore-dest-whitelist-w-etc-user.md` | **PASS** | PASS=156 FAIL=0 SKIP=0 |
| 2026-08-11 | **Housekeeping** (version surfaces + lessons residual) | README/SECURITY → 1.4.4; L-SUDOERS-05 renumber; L-PUSH-VAULT-01 | living | PASS=138 FAIL=0 SKIP=2 |
| 2026-08-09 | **Review plans updated** (`what-to-review.md`, `test-plan.md`, `requirement-test-matrix.md`, `lessons.md`) | Plans for 1.4.4 multi-user project-sudoers-file | living | PASS=138 FAIL=0 SKIP=2 |
| 2026-08-09 | `reports/2026-08-09-security-review-folder-backup.md` | Full security review (design + host) | **Pass (design) / Revise (host)** | F1–F8; host still test_local |
| 2026-08-09 | `reports/2026-08-09-sudoers-security-folder-backup.md` | Sudoers security (trust tiers) | **Pass (test only)** | supersedes 2026-08-03 production claim for local-only |
| 2026-08-03 | `reports/2026-08-03-product-review-initial.md` | Full product (law + ship unit + suite) | **Revise** (docs gaps; core suite green) | PASS=82 FAIL=0 SKIP=2 |
| 2026-08-03 | `reports/2026-08-03-sudoers-security-folder-backup.md` | Sudoers security (pre-emit) | **Pass (historical; superseded for production)** | local-only; see 2026-08-09 |
