**file**: docs/requirements/requirement-bootstrap-chain.md  
**Status**: Active (Version 5.2.0)  
**Area**: architecture  
**Key**: `requirement-bootstrap-chain`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

Declare the **bootstrap chain** for this product: **B = `dns-cli` (hop 1)**, specialized from **A = `cli-template` (hop 0)**. Direction **A → B only**.

**This product does not point to selfmanaged or folder-backup as origin.** Those names are retired hops / related products only. Historical copy sources stay in status history.

**Direction is sacred:** specialize from A onto this tree only. Never reverse-copy this product onto a remaining `cli-template` origin tree.

---

## 2. Core Rules (Mandatory)

### 2.1 Direction

1. This product **is** hop 1 (`dns-cli`). Immediate parent / origin **A** is **`cli-template`** (hop 0).  
2. Every edge **MUST** be **A → B only**.  
3. Plans **MUST NOT** copy this ship unit onto a `cli-template` origin tree to “share fixes.”  
4. Detected reverse-copy **MUST** be treated as critical pollution (restore A; rebuild B).  
5. Agents **MUST NOT** treat `selfmanaged` or `folder-backup` as this product’s live origin.

### 2.2 Chain declaration (this product)

| Field | Value |
|-------|--------|
| **Root / hop 0 (origin A)** | `cli-template` — Type 0 template; not this tree after specialize |
| **Immediate origin** | `cli-template` |
| **Leaf / this product (B)** | `dns-cli` (hop 1) |
| **Specialize mode** | Inherit Type 0 architecture; retarget identity; **domain present** (Cloudflare vault + DNS) |
| **This ship unit (target)** | `src/dns-cli` |
| **This ship unit (live)** | `src/dns-cli` |
| **This channel ownership** | **None** — local-only install by design |
| **This domain** | **present** — `requirement-domain-cloudflare-dns` (DNS) + `requirement-cloudflare-vault` (multi-account vault) + `requirement-cloudflare-dns-mode` (A-record mode; not a second domain catalog). LPU `dns-adm` is host identity for the default vault. |
| **Retired names (not live hops)** | `selfmanaged`, `folder-backup` — related products / historical copy sources. **Do not** name them as origin. |

### 2.3 Architecture contracts (this origin owns)

These are **this product’s** structural contracts. Descendants inherit them. They are **not** “inherited from selfmanaged” as live law.

| Layer | This origin |
|-------|-------------|
| Runtime | POSIX `/bin/sh`, `set -u`, explicit errors |
| Output SSOT | `out_*` family |
| Modular prefixes | `out_`, `inst_`, `util_`, `app_`, `path_`, `prompt_`, **`cf_`**, **`lpu_`** |
| Domain prefix | **`cf_`** (`cf_vault_*`, `cf_dns_*`, `cf_ip_*`, `cf_api_*`, `cf_json_*`) |
| Entry / dispatch | Single `app_main`; always call `app_main "$@"` at end |
| Global flags | `--quiet` / `--json` / `--debug` / `--force` / `--global` |
| Integrity companion | **Absent** (no product channel digest law) |
| Online lifecycle | **Absent** (`version-check`, `self-update`, `self-uninstall`, Type O, `SCRIPT_URL` UX) |
| Local lifecycle | **Present** — `install` / `uninstall` / `where-is-me` |
| Empty argv | **Type N** help (not Type O install-ensure) |
| Backup / restore | **Absent** — never this product’s domain |
| Sudoers-manager extras | **Absent** (`print-sudoers-install-script`, `remove-project-sudoers`) |
| LPU / Type 1 `setup` / Type 0 `print-sudoers` / generate+submit JSON sudoer | **Present** — `requirement-least-privilege-user` + `requirement-three-layer-privilege-model` + `requirement-sudoer-json-file` (Implemented 1.5.0 / 1.6.0) |

### 2.4 Surface matrix (normative for this product)

| Surface | Decision | Notes for dns-cli |
|---------|----------|------------------|
| `out_*` output SSOT | **Keep** | Inherited from A |
| Modular single-file design | **Keep** | Ship unit under `src/` |
| Global flags + `app_main` | **Keep** | Plus domain flags owned by domain SSOT |
| Storage resolve | **Keep** | Scratch only; vault is separate law |
| Idempotency / interactive modes | **Keep** | Lifecycle + domain matrix rows |
| Online channel | **Absent** | Not install source; not help/about product UX |
| Type O empty argv | **Absent** | Empty argv = Type N help |
| Domain backup + restore | **Absent** | Not this product’s domain |
| Sudoers-manager extras (install-script / remove-draft) | **Absent** | Not this product’s domain |
| Type 0 `print-sudoers` + Type 1 `setup` / `remove-lpu` | **Add on B** | LPU `dns-adm` — Implemented 1.5.0 |
| Type 0 `generate-sudoer-request` / `submit-sudoer-request` | **Add on B** | JSON sudoer submitter — Implemented 1.6.0 |
| Local `install` / `uninstall` / `where-is-me` | **Keep** | Local self-managed package |
| Cloudflare vault + DNS | **Add on B** | Multi-account vault + DNS — v2 zone-slot **Implemented** on 1.4.0; LPU default dest Gap |
| Domain / out Protection Zones | **Keep spirit** | Do not simplify `out_*` |

### 2.5 Identity (this origin)

| Concern | Value |
|---------|---------|
| `APP_NAME` | `dns-cli` (live Config `APP_NAME="dns-cli"` — Implemented) |
| `VERSION` | `1.4.1` (live Config `VERSION="1.4.1"`) |
| Primary install story | Local copy from running ship unit → `${USER_BIN}` (default `~/.local/bin`) |
| README one-liner | **No** `curl \| sh` channel claim |

### 2.6 Implementation Notes (this product)

| Item | Value |
|------|--------|
| **Product** | `dns-cli` |
| **Workspace** | `/home/leolio/prjs/dns-cli` |
| **Role** | Specialized hop 1 from `cli-template`. Not a child of selfmanaged or folder-backup. |
| **Related (not origin)** | `selfmanaged`, `folder-backup` — do not overwrite; do not maintain this product from them |

### 2.7 Why This Requirement Exists (CIAO)

- **Principle 2 – Intentional**: This product is B; A is named `cli-template`.  
- **Principle 4 / 20 – Over-protect**: Reverse-copy onto A is a critical pollution class.  
- **Principle 21 – Dual policies**: Identity lives in Implementation Notes and ship-unit Config.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution:** Do not invent backup/restore or online install. Host `setup` exists only to create `dns-adm`.  
- **Intentional:** Type 0 inherited; domain + LPU added on B only.  
- **Anti-fragile:** Origin A stays intact; this tree is B.  
- **Over-protect:** Online/backup stay absent; LPU dest is not `/etc/sudoers.d`.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Name `selfmanaged` or `folder-backup` as this product’s live origin or immediate parent.  
2. Reverse-copy this product onto a `cli-template` origin tree.  
3. Reintroduce `backup`, `restore`, or sudoers-manager extras (`print-sudoers-install-script`, `remove-project-sudoers`) without a new user order.  
4. Leave domain surface promised without an Active `requirement-domain-*` (or claim Implemented while code is Gap).  
5. Reintroduce online install / Type O / `SCRIPT_URL` UX without explicit user order.  
6. Drop Type 0 lifecycle while claiming this product inherits Type 0 from A.  
7. Claim this product is hop 0 / the Type 0 origin.

**Violating this rule is a critical bootstrap-direction regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | Chain names **cli-template** as hop 0 / origin A and **dns-cli** as hop 1 / B |
| AC-2 | Target ship unit is `src/dns-cli` (live) |
| AC-3 | Help does not list backup / restore / print-sudoers-install-script |
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
| `requirement-domain-cloudflare-dns` | Domain SSOT on B |
| `requirement-cloudflare-vault` | Vault law on B |
| `requirement-cloudflare-dns-mode` | A-record mode on B (not a second domain catalog) |
| `requirement-least-privilege-user` | `dns-adm` on B |
| `requirement-three-layer-privilege-model` | Type map on B |
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
| 2026-08-18 | Active 5.2.0 | setup / print-sudoers Implemented; generate/submit JSON sudoer Present |
| 2026-08-17 | Active 5.1.0 | LPU `dns-adm` + Type 1 setup on B; backup/restore still absent |
| 2026-08-16 | Active 5.0.0 | This workspace is B = dns-cli hop 1; A = cli-template; domain present |

---

**Last Updated**: 2026-08-18  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
