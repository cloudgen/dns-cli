# Review reports index — dns-cli

**Current ship (living):** `src/dns-cli` **1.11.0** — inbound DNS `submit` / `approve` / `reject` / `interactive` **Implemented**; dest fence catalog `requirement-approval-fencing-condition`; dest Fence `requirement-incorrect-json-format`; Type 0 **test-purpose** `fence-test`. Historical rows below keep the verdict they had on that date.

| Date | Report | Scope | Verdict | Suite |
|------|--------|-------|---------|-------|
| 2026-08-19 | `reports/2026-08-19-review-dest-kind-schema.md` | Dest-owned JSON / `kind` fence (INC-20260819-001) | **Revise** — this-product allowlist proven; live dest 1.8.1 still refuses `kind` | PASS=619 FAIL=0 SKIP=1 |
| 2026-08-18 | `reports/2026-08-18-review-sudoer-json-submitter.md` | Missing JSON sudoer submitter (file-based JSON type) | **Pass** — generate/submit Implemented 1.6.0; DNS inbound still Gap | PASS=344 FAIL=0 |
| 2026-08-18 | `reports/2026-08-18-review-product-gap.md` | Product gap INC-20260818-001 (create path vs dest/switch) | **Revise** — setup Implemented 1.5.0; dest/switch/host-run open | PASS=317; host `dns-adm` absent |
| 2026-08-18 | `reports/2026-08-18-review-requirement-coverage.md` | C-full-product requirement sufficient check | Sufficient with Gaps | law vs `src/dns-cli` 1.4.0 |
| 2026-08-17 | `reports/2026-08-17-review-local-1.2.0.md` | local uncommitted ship unit 1.2.0 | Approve with follow-ups | PASS=235 FAIL=0 |
| 2026-08-17 | `reports/2026-08-17-review-live-token-crms-hk.md` | live Type 0 token on `crms.hk` | Pass after `zone:dns:edit` | live PASS=9 |
| 2026-08-17 | `reports/2026-08-17-review-live-crms-hk.md` | earlier live Type 0 as `leolio` | Pass (then revoke) | live PASS=8 |
| 2026-08-17 | `reports/2026-08-17-review-vault-zone-crud.md` | vault zone-slot CRUD + mode | Pass with Gaps | PASS=235 FAIL=0 |
| 2026-08-17 | `reports/2026-08-17-review-dns-cli-vault-dns-ip.md` | vault + DNS + `ip` + suites | Approve with follow-ups | PASS=163 FAIL=0 SKIP=0 |
| 2026-08-16 | `reports/2026-08-16-review-dns-cli-ship-unit.md` | ship unit + vault/DNS first land | Approve with follow-ups | PASS=113 FAIL=0 SKIP=0 |
| 2026-08-13 | Bootstrap origin (pre-specialize) | hop 0 template history | living | see `tests/run.sh` |

Related products **selfmanaged** and **folder-backup** keep their own reviews. They are **not** this product’s law, origin, or evidence.
