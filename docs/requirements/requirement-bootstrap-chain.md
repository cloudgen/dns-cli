**file**: docs/requirements/requirement-bootstrap-chain.md  
**Status**: Active (Version 4.0.0)  
**Area**: architecture  
**Key**: `requirement-bootstrap-chain`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

Declare the **bootstrap chain** for this product: this workspace **is** the Type 0 bootstrap origin (root hop). There is **no live parent**. Future products specialize **from** this origin (A = `cli-template` → B = descendant).

**This product does not point to selfmanaged or folder-backup as origin.** Those names are retired hops / related products only. Historical copy sources stay in status history.

**Direction is sacred:** when a descendant exists, ancestor → descendant only. Never reverse-copy a descendant onto this origin.

---

## 2. Core Rules (Mandatory)

### 2.1 Direction

1. This product **is** hop 0 (bootstrap origin). It has **no** immediate parent.  
2. Every future edge **MUST** be **this origin → descendant** only.  
3. Plans **MUST NOT** copy a descendant ship unit onto `src/cli-template` to “share fixes.”  
4. Detected reverse-copy **MUST** be treated as critical pollution (restore this origin; rebuild the descendant).  
5. Agents **MUST NOT** treat `selfmanaged` or `folder-backup` as this product’s live origin, nor run “maintain bootstrap from …” those products as standing work.

### 2.2 Chain declaration (this product)

| Field | Value |
|-------|--------|
| **Root / hop 0 (this product)** | `cli-template` — Type 0 template; bootstrap origin for future specialize |
| **Immediate origin** | **None** — this product is the origin |
| **Leaf** | `cli-template` (until a descendant is specialized from this tree) |
| **Specialize mode (as origin)** | Type 0 local-only template; **no domain**; descendants inherit architecture and retarget identity |
| **This ship unit** | `src/cli-template` |
| **This channel ownership** | **None** — local-only install by design |
| **This domain** | **none** — Type 0 bootstrap/template (`version`, `install`, `about`, `help`). **Not** a host-OS setup product. |
| **Retired names (not live hops)** | `selfmanaged`, `folder-backup` — related products / historical copy sources. **Do not** name them as origin. |

### 2.3 Architecture contracts (this origin owns)

These are **this product’s** structural contracts. Descendants inherit them. They are **not** “inherited from selfmanaged” as live law.

| Layer | This origin |
|-------|-------------|
| Runtime | POSIX `/bin/sh`, `set -u`, explicit errors |
| Output SSOT | `out_*` family |
| Modular prefixes | `out_`, `inst_`, `util_`, `app_`, `path_`, `prompt_` |
| Domain prefix | **None** — do not invent a host prefix until a descendant has domain |
| Entry / dispatch | Single `app_main`; always call `app_main "$@"` at end |
| Global flags | `--quiet` / `--json` / `--debug` / `--force` / `--global` |
| Integrity companion | **Absent** (no product channel digest law) |
| Online lifecycle | **Absent** (`version-check`, `self-update`, `self-uninstall`, Type O, `SCRIPT_URL` UX) |
| Local lifecycle | **Present** — `install` / `uninstall` / `where-is-me` |
| Empty argv | **Type N** help (not Type O install-ensure) |
| Backup / restore / sudoers emit | **Absent** — never this product’s domain |

### 2.4 Surface matrix (normative for this product)

| Surface | Decision | Notes for cli-template |
|---------|----------|------------------------|
| `out_*` output SSOT | **Keep** | This origin’s family |
| Modular single-file design | **Keep** | Ship unit under `src/` |
| Global flags + `app_main` | **Keep** | Same contracts; no domain flags |
| Storage resolve | **Keep** | Scratch only |
| Idempotency / interactive modes | **Keep** | Lifecycle only |
| Online channel | **Absent** | Not install source; not help/about product UX |
| Type O empty argv | **Absent** | Empty argv = Type N help |
| Domain backup + restore | **Absent** | Not this product’s domain |
| Sudoers print / install-script / remove-draft | **Absent** | Not this product’s domain |
| Local `install` / `uninstall` / `where-is-me` | **Keep** | Local self-managed package |
| Domain / out Protection Zones | **Keep spirit** | Do not simplify `out_*` |

### 2.5 Identity (this origin)

| Concern | Value |
|---------|---------|
| `APP_NAME` | `cli-template` |
| `VERSION` | `1.0.0` (product version SSOT in ship unit) |
| Primary install story | Local copy from running ship unit → `${USER_BIN}` (default `~/.local/bin`) |
| README one-liner | **No** `curl \| sh` channel claim |

### 2.6 Implementation Notes (this product)

| Item | Value |
|------|--------|
| **Product** | `cli-template` |
| **Workspace** | `/home/leolio/prjs/cli-template` |
| **Role** | Bootstrap origin (hop 0). Not a child of selfmanaged or folder-backup. |
| **Related (not origin)** | `selfmanaged`, `folder-backup` — do not overwrite; do not maintain this product from them |

### 2.7 Why This Requirement Exists (CIAO)

- **Principle 2 – Intentional**: This product is the origin. Parent hops are not implied.  
- **Principle 4 / 20 – Over-protect**: Reverse-copy onto this origin is a critical pollution class.  
- **Principle 21 – Dual policies**: Identity lives in Implementation Notes and ship-unit Config.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution:** Do not invent host `setup` or other OS-mutating verbs to fill the product name.  
- **Intentional:** Type 0 bootstrap/template origin only. Domain SSOT stays absent.  
- **Anti-fragile:** This origin stays intact so descendants can specialize from it.  
- **Over-protect:** Registry lists online and domain surfaces as absent by design.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Name `selfmanaged` or `folder-backup` as this product’s live origin or immediate parent.  
2. Reverse-copy a descendant onto `src/cli-template`.  
3. Reintroduce `backup`, `restore`, or sudoers-file verbs without new Active requirements and explicit user order.  
4. Create a hollow Active `requirement-domain-*` while there is no domain surface.  
5. Reintroduce online install / Type O / `SCRIPT_URL` UX without explicit user order.  
6. Drop Type 0 lifecycle while claiming this product is the Type 0 template origin.  
7. Re-add a live parent hop without explicit user order.

**Violating this rule is a critical bootstrap-direction regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | Chain names **cli-template** as hop 0 / origin; no live parent |
| AC-2 | Ship unit is `src/cli-template` |
| AC-3 | Help does not list backup / restore / print-sudoers |
| AC-4 | Unknown domain verbs fail closed |
| AC-5 | Empty argv is Type N help |
| AC-6 | Product maps and class law do **not** name selfmanaged or folder-backup as origin |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-class-software-dev` | Class gate |
| `requirement-shell-cli-interface` | Type 0 verb catalog |
| `requirement-shell-local-self-management` | Local install package |
| `docs/requirements/index.md` | Registry |

---

## Design-time verification

| TP family / ID | Suite | Status | Note |
|----------------|-------|--------|------|
| **TP-CLI-04,10,13** | `tests/test_cli.sh` | have | no online verbs; backup/restore/sudoers unknown |
| **TP-CLI-07** | `tests/test_cli.sh` | have | Type N empty argv |

**Matrix:** `reviews/requirement-test-matrix.md`  
**Map:** `reviews/test-plan.md`

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-03 | Active 1.0.0 | folder-backup: selfmanaged → folder-backup (trim online) |
| 2026-08-13 | Active 2.0.0 | specialize hop; trim backup/restore/sudoers; identity **cli-template** (not host-OS setup) |
| 2026-08-13 | Active 3.0.0 | Retired live hop folder-backup; briefly named selfmanaged → cli-template |
| 2026-08-13 | Active 4.0.0 | **This product is hop 0.** No live parent. selfmanaged and folder-backup are not origins. |

---

**Last Updated**: 2026-08-13  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
