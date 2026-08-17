# What to review — dns-cli

**Living checklist** (review plan). Product: **dns-cli** Cloudflare DNS CLI (Type 0/1/2 + LPU `dns-adm` in law).  
**Class:** software-development · **B = hop 1** from **A = cli-template** · **local-only** install channel.  
**Always load first:** `reviews/lessons.md`

**Last plan update:** 2026-08-17  
**Ship unit VERSION:** 1.4.0  
**Suite baseline:** see `reviews/test-plan.md`

---

## Pre-flight

| # | Check | Notes |
|---|--------|--------|
| P1 | Read `docs/requirements/index.md` | Class + architecture + shell + vault + domain DNS + LPU/three-layer |
| P2 | Confirm ship unit `src/dns-cli` | `APP_NAME` / `VERSION` hard-assign (**1.4.0**) |
| P3 | Load `reviews/lessons.md` and re-check open L-* that still apply | Skip L-SUDOERS / restore lessons as parent-only |
| P4 | Run `./tests/run.sh` | Record PASS/FAIL/SKIP in report |
| P5 | Confirm install **channel** still local-only | No SCRIPT_URL product UX |
| P6 | Confirm trimmed verbs stay unknown | backup / restore / print-sudoers-install-script |
| P7 | Public token leak (file-leaks **C5**) | No `cfut_…` / Bearer secret / `ghp_…` in README, CHANGELOG, SECURITY, `reviews/**`, requirements; request JSON samples have no `token` key |

---

## Product law surfaces

| Surface | Path | Review focus |
|---------|------|--------------|
| Class | `requirement-class-software-dev.md` | posix-sh, local-only residual |
| Bootstrap chain | `requirement-bootstrap-chain.md` | cli-template is hop 0 (no live parent) |
| Project folder | `requirement-project-folder.md` | `src/`, bins; no `/var/backup` |
| CLI interface | `requirement-shell-cli-interface.md` | Type 0/1/2 commands, flags, dispatch |
| LPU | `requirement-least-privilege-user.md` | `dns-adm` F1–F7; stay-honest Gap |
| Three-layer | `requirement-three-layer-privilege-model.md` | Tables A/B/C; setup / print-sudoers |
| Empty argv Type N | `requirement-shell-cli-zero-arguments.md` | Empty = help |
| Local self-management | `requirement-shell-local-self-management.md` | install/uninstall; mode 0755 |
| Output SSOT | `requirement-shell-output-requirements.md` | `out_*`; JSON errors |
| Modular design | `requirement-shell-modular-function-design.md` | `cf_` domain prefix |
| Application local vault | `requirement-application-local-vault.md` | default `/etc/dns-adm/vault/`; `--vault-dir` / `CF_VAULT_DIR` |
| Cloudflare vault | `requirement-cloudflare-vault.md` | zone-slot `account`/`zone` add/list/modify/remove; v2 Implemented, LPU dest Gap |
| Cloudflare API | `requirement-cloudflare-api.md` | Bearer, envelope, zone GET, DNS A CRUD; no AAAA |
| A-record mode | `requirement-cloudflare-dns-mode.md` | default non-RR; RR multi-A; switch only at ipv4_count 0/1 |
| DNS request JSON | `requirement-cloudflare-dns-request.md` | four types + examples; inbound Gap |
| External IPv4 | `requirement-external-ipv4.md` | ipinfo lookup + vault-free `ip`; IPv6 MUST NOT |
| Domain DNS | `requirement-domain-cloudflare-dns.md` | consumes mode; `ip`, add/update/status |
| Actor table | `requirement-dns-actor-table.md` | anyone submits; `dns-adm` approves; login hook; Gap |
| Approver | `requirement-dns-approver.md` | heal `.bashrc` hook; create missing `.profile` |
| Idempotency | `requirement-shell-idempotency.md` | Re-install |
| Storage | `requirement-shell-cli-storage.md` | Isolation |

**Do not review as this product’s law:** folder-archive backup, restore dest whitelist, sudoers-file emit (those remain on sibling **folder-backup**).
