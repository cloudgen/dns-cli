# What to review — cli-template

**Living checklist** (review plan). Product: **cli-template** local self-managed Type 0 CLI.  
**Class:** software-development · **no** domain SSOT · **local-only** install channel.  
**Always load first:** `reviews/lessons.md`

**Last plan update:** 2026-08-13  
**Ship unit VERSION:** 1.0.0  
**Suite baseline:** see `reviews/test-plan.md`

---

## Pre-flight

| # | Check | Notes |
|---|--------|--------|
| P1 | Read `docs/requirements/index.md` | Class + architecture + shell; no domain / three-layer |
| P2 | Confirm ship unit `src/cli-template` | `APP_NAME` / `VERSION` hard-assign (**1.0.0**) |
| P3 | Load `reviews/lessons.md` and re-check open L-* that still apply | Skip L-SUDOERS / restore lessons as parent-only |
| P4 | Run `./tests/run.sh` | Record PASS/FAIL/SKIP in report |
| P5 | Confirm install **channel** still local-only | No SCRIPT_URL product UX |
| P6 | Confirm trimmed verbs stay unknown | backup / restore / print-sudoers |

---

## Product law surfaces

| Surface | Path | Review focus |
|---------|------|--------------|
| Class | `requirement-class-software-dev.md` | posix-sh, local-only residual |
| Bootstrap chain | `requirement-bootstrap-chain.md` | cli-template is hop 0 (no live parent) |
| Project folder | `requirement-project-folder.md` | `src/`, bins; no `/var/backup` |
| CLI interface | `requirement-shell-cli-interface.md` | Type 0 commands, flags, dispatch |
| Empty argv Type N | `requirement-shell-cli-zero-arguments.md` | Empty = help |
| Local self-management | `requirement-shell-local-self-management.md` | install/uninstall; mode 0755 |
| Output SSOT | `requirement-shell-output-requirements.md` | `out_*`; JSON errors |
| Modular design | `requirement-shell-modular-function-design.md` | no domain prefix |
| Idempotency | `requirement-shell-idempotency.md` | Re-install |
| Storage | `requirement-shell-cli-storage.md` | Isolation |

**Do not review as this product’s law:** folder-archive backup, restore dest whitelist, sudoers-file emit (those remain on sibling **folder-backup**).
