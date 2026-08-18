**file**: docs/requirements/requirement-shell-cli-zero-arguments.md  
**Status**: Active (Version 1.0.0)  
**Area**: shell  
**Key**: `requirement-shell-cli-zero-arguments`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **project Single Source of Truth** for **zero-argument (empty argv) dispatcher behavior** of the dns-cli POSIX shell CLI.

### 1.0 Product type

| Field | Value for dns-cli |
|-------|-------------------------|
| **Empty-argv type** | **Type N — Non-online-install** |
| **Rationale** | Product is **local-only**; no `curl \| sh` channel; empty argv shows **help**, not install-ensure |

Type O (online-install empty-argv = install-ensure) does **not** apply.

---

## 2. Core Rules (Mandatory)

### 2.1 Single meaning of empty argv

1. When **argv is empty** (`$# -eq 0` at entry to `app_main`), the dispatcher **MUST** route to **`help`** / usage (`app_help`).  
2. Empty argv **MUST NOT** perform install or any state-changing ensure.  
3. Explicit `dns-cli help` remains a valid full-usage path (same content family as empty argv).  
4. Explicit `dns-cli install` remains the only first-time local install path (plus documented force refresh).  
6. Empty argv **MUST NOT** call Cloudflare, ipinfo, or mutate the vault.  
5. Script entry **MUST** always call `app_main "$@"` (no basename product-name gate that blocks dispatch).

### 2.2 Normative matrix

| Invocation | Behavior |
|------------|----------|
| `dns-cli` (no args) | Show help; exit 0 |
| `dns-cli help` | Show help; exit 0 |
| `dns-cli install` | Local install ensure |
| Flags only (e.g. `--json` with no command) | **MUST** still resolve to help (or fail with clear usage if product chooses fail-closed) — default: **help** after flag parse with no command token |

### 2.2a Sample invocations (CI-M1a)

```sh
dns-cli
dns-cli help
dns-cli --json help
```

Empty argv **MUST** match `help` (Type N). **MUST NOT** install, call Cloudflare, or look up ipinfo.

### 2.3 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **Product** | `dns-cli` |
| **Type** | **Type N** |
| **Default COMMAND** | `help` |
| **Contrast Type O** | Type O install-ensure is **not** this origin’s empty-argv law |

### 2.4 Why This Requirement Exists (CIAO)

- **Principle 2 – Intentional**: Empty argv meaning is explicit and not left as “whatever the parent did.”  
- **Principle 1 – Caution**: Avoid surprise install on bare invocation for an ops CLI.  
- **Principle 16 – Interactive**: Help is the safe human default for local tools.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution**: No silent ensure on empty argv.  
- **Intentional**: Type N declared in law.  
- **Anti-fragile**: Help works offline.  
- **Over-protect**: Do not reintroduce Type O without reclassifying product install mode.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Change empty argv to install-ensure while the product remains local-only.  
2. Copy Type O empty-argv law wholesale without updating this file and install mode.  
3. Make bare invocation run domain `backup`, `add`, `update`, `remove`, or `vault set`.

**Violating this rule is a critical dispatcher regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | Empty argv shows help and does not install |
| AC-2 | Type N is the declared empty-argv type |
| AC-3 | `install` remains an explicit command |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-shell-cli-interface` | Dispatcher command table |
| `requirement-shell-local-self-management` | Explicit install |
| `requirement-bootstrap-chain` | Trim of Type O from parent |
| `docs/requirements/index.md` | Registry |

---

## Design-time verification

| TP family / ID | Suite | Status |
|----------------|-------|--------|
| **TP-CLI-07** | `tests/test_cli.sh` | have |

**Matrix:** `reviews/requirement-test-matrix.md`  
**Map:** `reviews/test-plan.md`

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-03 | Active | Type N for local-only folder-backup |
| 2026-08-16 | Active | dns-cli identity; empty argv must not mutate DNS/vault |

---

**Last Updated**: 2026-08-16  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
