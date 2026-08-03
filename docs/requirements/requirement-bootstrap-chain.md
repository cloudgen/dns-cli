**file**: docs/requirements/requirement-bootstrap-chain.md  
**Status**: Active (Version 1.0.0)  
**Area**: architecture  
**Key**: `requirement-bootstrap-chain`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

Declare the **bootstrap chain** for this product: ordered lineage, direction, architecture inheritance, and the explicit **bootstrap-trim** of online install surfaces from the parent.

**Direction is sacred:** ancestor → descendant only. Never reverse-copy this product onto the bootstrap parent.

---

## 2. Core Rules (Mandatory)

### 2.1 Direction

1. Every edge **MUST** be **ancestor → descendant** only.  
2. Plans **MUST NOT** copy this product’s ship unit onto the bootstrap parent to “share fixes.”  
3. Detected reverse-copy **MUST** be treated as critical pollution (restore parent; rebuild this product).

### 2.2 Chain declaration (this product)

| Field | Value |
|-------|--------|
| **Root / hop 0 (A)** | `selfmanaged` — external bootstrap product at `https://github.com/cloudgen/selfmanaged` |
| **Leaf / hop 1 (B)** | `folder-backup` — this workspace product |
| **Immediate origin of leaf** | `selfmanaged` |
| **Specialize mode** | **Bootstrap trim** of online self-managed / channel surfaces + **domain extend** (folder archive backup) |
| **A ship unit** | External: repo root `./selfmanaged` (not in this tree) |
| **B ship unit** | `src/folder-backup` |
| **A channel ownership** | Online `SCRIPT_URL` / companion digest (parent only) |
| **B channel ownership** | **None** — local-only install by design |
| **A domain** | none (Type 0 lifecycle bootstrap) |
| **B domain** | folder tar.gz backup + sudoers-elevated deposit (see `requirement-domain-folder-backup`) |

### 2.3 Architecture inheritance (B from A)

B **MUST** inherit A’s structural contracts where still applicable after trim:

| Layer | Inherit / replace |
|-------|-------------------|
| Runtime | POSIX `/bin/sh`, `set -u`, explicit errors |
| Output SSOT | `out_*` family |
| Modular prefixes | `out_`, `inst_`, `util_`, `app_`, `path_`, `prompt_`; domain uses dedicated prefix |
| Entry / dispatch | Single `app_main`; always call `app_main "$@"` at end |
| Global flags | `--quiet` / `--json` / `--debug` / `--force` |
| Integrity companion | **Trimmed** (no product channel digest law) |
| Online lifecycle | **Trimmed** (`version-check`, `self-update`, `self-uninstall`, Type O, `SCRIPT_URL` UX) |
| Local lifecycle | **Replace** with local `install` / `uninstall` / `where-is-me` |
| Empty argv | **Replace** Type O install-ensure → **Type N help** |

### 2.4 Keep / trim matrix (normative for this product)

| Surface | Decision | Notes for folder-backup |
|---------|----------|-------------------------|
| `out_*` output SSOT | **Keep** | Surgical only |
| Modular single-file design | **Keep** | Ship unit under `src/` |
| Global flags + `app_main` | **Keep** | Same contracts |
| Storage resolve | **Keep / adapt** | Staging for tar.gz |
| Idempotency / interactive modes | **Keep / retarget** | No remote ensure paths |
| Online channel (`SCRIPT_URL`, `REPO_*`) | **Trim** | Not install source; not help/about product UX |
| Type O empty argv | **Trim → Type N** | Empty argv = help |
| Remote `version-check` / `self-update` | **Trim** | Absent commands |
| Online remove `self-uninstall` | **Trim** | Use local **`uninstall`** |
| Companion `.sha256` product law | **Trim** | No channel integrity package |
| Local `install` / `uninstall` / `where-is-me` | **Add** | Local self-managed package |
| Domain backup + sudoers fragment | **Add** | Domain SSOT |
| Domain / out Protection Zones | **Keep spirit** | Do not “simplify away” defensive layers for style |

### 2.5 Identity retarget (B only)

| Concern | B value |
|---------|---------|
| `APP_NAME` | `folder-backup` |
| `VERSION` | `1.0.0` (product version SSOT in ship unit) |
| Primary install story | Local copy from running ship unit → `${USER_BIN}` (default `~/.local/bin`) |
| README one-liner | **No** `curl \| sh` channel claim |

### 2.6 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **A (bootstrap)** | cloudgen/selfmanaged (external reference; do not reverse-copy) |
| **B (this product)** | folder-backup |
| **Trim intent** | Remove **all** online install related features |
| **Install mode** | **local-only** (not dual-mode) |
| **Domain after specialize** | Active `requirement-domain-folder-backup` |

### 2.7 Why This Requirement Exists (CIAO)

- **Principle 2 – Intentional**: Lineage and trim are explicit.  
- **Principle 1 – Caution**: No half-live channel after trim.  
- **Principle 18 / Over-protect**: Reverse-copy is forbidden pollution.  
- **Principle 21 – Dual policies**: Complete B law; portable cores elsewhere.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution**: Matrix before delete; verify no half-live install.  
- **Intentional**: Explicit keep/trim; registry names absences.  
- **Anti-fragile**: Keep battle-tested `out_*` / modular patterns.  
- **Over-protect**: Never reverse-copy; no silent channel reintro.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Reverse-copy `folder-backup` onto `selfmanaged` or treat reverse as “cleanup.”  
2. Claim bootstrap trim while reintroducing Type O install-ensure or `SCRIPT_URL` as product UX.  
3. Leave dual-mode online+local install without an explicit dual-mode matrix and user order.  
4. Drop `out_*` / modular Protection Zones as “part of trim.”  
5. Invent a second bootstrap origin that contradicts this declaration without updating this file.

**Violating this rule is a critical bootstrap-direction regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | Hop table names A=selfmanaged, B=folder-backup, direction A→B |
| AC-2 | Keep/trim matrix matches Active registry (online package absent) |
| AC-3 | B identity retarget complete (`APP_NAME`, `VERSION`, local install) |
| AC-4 | Domain SSOT present for backup surface |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-class-software-dev` | Class gate |
| `requirement-shell-local-self-management` | Local lifecycle replacement |
| `requirement-shell-cli-zero-arguments` | Type N empty argv |
| `requirement-domain-folder-backup` | Domain extend |
| `docs/requirements/index.md` | Registry |

---

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-03 | Active | Declared A→B bootstrap trim from selfmanaged |

---

**Last Updated**: 2026-08-03  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
