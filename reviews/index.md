# Review reports index — dns-cli

**Current ship (living):** `src/dns-cli` **1.28.0** — TTY main menu top list is family **DNS Features** **1** + family **sudoers** **7** + family **self-management** **8** (Exit **9**); a finished listed command returns to that top list; DNS submenu Back **98** / Exit **99**; login doorbell `/usr/local/bin/dns-review-hooks` (heal rewrites old `dns-cli`, `dns-cli-hook`, and `login-review-hook`); TTY main menu invalid pick reprints the same numbered layer (main + DNS Features + sudoers); inbound DNS `submit` / `approve` / `reject` / `interactive` **Implemented**; login-hook `interactive` shows the waiting body as YAML and keeps the latest duplicate inbound per dest; dest fence catalog `requirement-approval-fencing-condition`; dest Fence `requirement-incorrect-json-format`; hyphenated login in DNS request names; Type 0 **test-purpose** `fence-test`; independent login-hook REQ (`requirement-login-interactive-hook`). Historical rows below keep the verdict they had on that date.

| Date | Report | Scope | Verdict | Suite |
|------|--------|-------|---------|-------|
| 2026-09-13 | filled `docs/checklists/2026-09-13-checklist-dns-review-hooks.md` | Doorbell `dns-review-hooks`; old `dns-cli` / `dns-cli-hook` / `login-review-hook` heal | **Pass** — law 1.2.0 + **TP-CF-APR-08** · **09** | **TP-CF-APR-01..09** |
| 2026-09-13 | filled `docs/checklists/2026-09-13-*-menu-invalid-retry.md` | Invalid pick reprints the same numbered menu layer | **Pass** — law 1.4.0 + **TP-CLI-21** | **TP-CLI-21** |
| 2026-09-08 | `reports/2026-09-08-review-login-hook-sibling.md` | Login hook vs sibling `sudoer-cli`; live `sudo -n` fail | **Revise** — grant is sibling dest `login-hook-elev`; skip next-step + `interactive` rc review in 1.23.0 | **TP-CF-APR-09** |
| 2026-09-06 | `reports/2026-09-06-review-human-readability-coverage.md` | README human readability / requirements coverage / checklists / tests | **Pass** after follow-ups | **TP-CF-REQ-18** · **TP-CLI-18** TTY `--json` / `main` |
| 2026-09-03 | `reports/2026-09-03-review-sudoers-submenu-coverage.md` | Family **sudoers** submenu coverage / README voice / TP alignment | **Pass** after follow-ups | **TP-CLI-18** · **TP-CLI-20** have; **TP-CF-REQ** hyphenated-login FAILs pre-existing |
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
