# Requirements index

**Product:** cli-template (POSIX `/bin/sh` local self-managed CLI — Type 0 lifecycle only)  
**Workspace state:** Specialized product law (left genesis); **software-development** class; **this product is the Type 0 bootstrap origin** (no live parent). Online / Type O, backup / restore / sudoers-file **intentionally absent**.  
**Updated:** 2026-08-13

| ID / key | Title | Area | Status | Path | Updated |
|----------|-------|------|--------|------|---------|
| requirement-class-software-dev | Software-development class law + residual stack (posix-sh, local-only); multi-vault forge push identity §2.0.5a | class | Active (1.3.0) | `requirement-class-software-dev.md` | 2026-08-13 |
| requirement-bootstrap-chain | Bootstrap origin = this product (hop 0; no live parent) | architecture | Active (4.0.0) | `requirement-bootstrap-chain.md` | 2026-08-13 |
| requirement-project-folder | Project layout (`src/`), install bins; no durable backup deposit | architecture | Active (2.0.0) | `requirement-project-folder.md` | 2026-08-13 |
| requirement-shell-cli-interface | Shell CLI interface (Type 0 commands, flags, dispatch) | shell | Active (2.0.0) | `requirement-shell-cli-interface.md` | 2026-08-13 |
| requirement-shell-cli-zero-arguments | Empty argv Type N help (local-only) | shell | Active | `requirement-shell-cli-zero-arguments.md` | 2026-08-13 |
| requirement-shell-local-self-management | Local install / uninstall / where-is-me; **mode 0755** multi-user | shell | Active (1.3.0) | `requirement-shell-local-self-management.md` | 2026-08-13 |
| requirement-shell-output-requirements | Central `out_*` output SSOT | shell | Active | `requirement-shell-output-requirements.md` | 2026-08-13 |
| requirement-shell-modular-function-design | Single-file modular prefixes (`out_`/`inst_`/`app_`); no domain prefix | shell | Active (2.0.0) | `requirement-shell-modular-function-design.md` | 2026-08-13 |
| requirement-shell-idempotency | Re-run safety for install / uninstall | shell | Active (1.1.0) | `requirement-shell-idempotency.md` | 2026-08-13 |
| requirement-shell-interactive-vs-noninteractive | Interactive vs non-interactive / confirm policy | shell | Active (1.1.0) | `requirement-shell-interactive-vs-noninteractive.md` | 2026-08-13 |
| requirement-shell-cli-storage | Scratch/cache resolve (no backup staging) | shell | Active (1.1.0) | `requirement-shell-cli-storage.md` | 2026-08-13 |

## Intentionally absent (by design — this origin)

| Surface | Status on cli-template |
|---------|------------------------|
| Online install / `SCRIPT_URL` / Type O empty-argv install-ensure | **Absent** |
| `version-check` / `self-update` / `self-uninstall` | **Absent** |
| Automatic companion `.sha256` channel integrity law | **Absent** |
| Folder archive backup / restore / retention | **Absent** |
| Domain SSOT (`requirement-domain-*`) | **Absent** — Type 0 bootstrap/template CLI; not a host-OS manager |
| Three-layer privilege / sudoers-file emit / install-script / remove-draft | **Absent** |
| Type 1 elevated deposit / restore-stage | **Absent** |

**Install mode:** **local-only** (`install` + `uninstall` + `where-is-me`). Not dual-mode.

**Rules for agents:**

1. Treat rows above as the **live product-law inventory** for cli-template.  
2. **Do not invent** additional `requirement-*.md` paths — verify on disk and add a registry row in the same change when creating one.  
3. Product source comments cite **only** these live requirement files — never templates/skills as behavioral authority.  
4. This versioned surface lists **requirement rows only** — do not dump templates / skills / terminologies / incidents path inventories here.  
5. Keep Status and Path in sync with each file’s header when status changes.  
6. **Class gate:** software-development requires exactly one Active `requirement-class-software-dev.md` (this registry includes it).  
7. **Domain SSOT:** none. This product is a **Type 0 bootstrap/template** (`version` / `install` / `about` / `help`). Do **not** add `setup` or other host-mutating verbs, and do **not** invent a hollow `requirement-domain-*` that restates Type 0.  
8. **Do not reintroduce** backup, restore, sudoers-file verbs, or online install without explicit user order and registry update.

When adding a requirement: append a row, create the file under `docs/requirements/`, keep Status in sync with the file header.
