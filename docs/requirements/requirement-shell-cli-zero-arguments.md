**file**: docs/requirements/requirement-shell-cli-zero-arguments.md  
**Status**: Active (Version 1.1.0)  
**Area**: shell  
**Key**: `requirement-shell-cli-zero-arguments`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **project Single Source of Truth** for **zero-argument (empty argv) dispatcher behavior** of the dns-cli POSIX shell CLI.

### 1.0 Product type

| Field | Value for dns-cli |
|-------|-------------------------|
| **Empty-argv type** | **Type N — Non-online-install** |
| **Rationale** | Product is **local-only**; no `curl \| sh` channel. Off-TTY empty argv shows **help**. Interactive empty argv (`TTY=1`) shows the **numbered main menu** (same handler as `menu` / `main`). Empty argv **MUST NOT** install-ensure |

Type O (online-install empty-argv = install-ensure) does **not** apply.

### 1.1 Human-facing

**In one sentence:** At a keyboard, `dns-cli` with **no arguments** opens the **numbered list of jobs**; in a script the same command still prints **help** — it does **not** install, and it does **not** start a review.

| Box | Meaning | Example |
|-----|---------|---------|
| You (TTY) | Type the program name alone | `dns-cli` → numbered list |
| Script / pipe | Same command, no keyboard | `dns-cli` → help |
| Not this | First-time copy of the binary | `dns-cli self-install` |

| Includes | Excludes |
|----------|----------|
| TTY empty argv → main menu | Empty argv → install |
| Off-TTY empty argv → help | Empty argv → `interactive` review |
| No network on empty argv | Login review hijacking no-args |

| Surface | What you open | What for |
|---------|---------------|----------|
| Terminal | `dns-cli` | Numbered list (`app_default`) |
| Script | `dns-cli` | Help |
| `dns-cli help` | Explicit help | Usage text |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Sit at a prompt and type the name | You see the numbered jobs | `dns-cli` |
| Run it in CI | You see usage, not a wait | `dns-cli` |

---

## 2. Core Rules (Mandatory)

### 2.1 Single meaning of empty argv

1. When **argv is empty** (`$# -eq 0` at entry to `app_main`):
   - **Interactive** (`TTY=1`): the dispatcher **MUST** route to the numbered main menu (`app_default`) — same handler as `dns-cli menu`. Topic-owner of the list: `requirement-shell-cli-default-interaction`.
   - **Non-interactive** (`TTY=0`): the dispatcher **MUST** route to **`help`** / usage (`app_help`). **MUST NOT** prompt.
2. Empty argv **MUST NOT** perform install or any state-changing ensure.  
3. Explicit `dns-cli help` remains a valid full-usage path (same content family as off-TTY empty argv).  
4. Explicit `dns-cli self-install` (alias `install`) remains the only first-time local install path (plus documented force refresh). Copy `$0` when it is this script; **MUST NOT** download.  
5. Script entry **MUST** always call `app_main "$@"` (no basename product-name gate that blocks dispatch).  
6. Empty argv **MUST NOT** call Cloudflare, ipinfo, or mutate the vault. Drawing the numbered list **MUST NOT** network.

### 2.2 Normative matrix

| Invocation | Behavior |
|------------|----------|
| `dns-cli` (no args, `TTY=1`) | Numbered main menu; exit 0 after Exit / a pick |
| `dns-cli` (no args, `TTY=0`) | Show help; exit 0; **MUST NOT** hang |
| `dns-cli help` | Show help; exit 0 |
| `dns-cli self-install` | Local place (copy this file; no download). Alias `install`. |
| Flags only (e.g. `--json` with no command) | **MUST** still resolve to help (or fail with clear usage if product chooses fail-closed) — default: **help** after flag parse with no command token |

### 2.2a Sample invocations (CI-M1a)

```sh
dns-cli
dns-cli help
dns-cli --json help
```

Off-TTY empty argv **MUST** match `help` (Type N). TTY empty argv **MUST** match `dns-cli menu`. **MUST NOT** install, call Cloudflare, or look up ipinfo.

### 2.3 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **Product** | `dns-cli` |
| **Type** | **Type N** |
| **Default COMMAND** | Off-TTY `help`; TTY `app_default` |
| **Contrast Type O** | Type O install-ensure is **not** this origin’s empty-argv law |

### 2.4 Why This Requirement Exists (CIAO)

- **Principle 2 – Intentional**: Empty argv meaning is explicit and not left as “whatever the parent did.”  
- **Principle 1 – Caution**: Avoid surprise install on bare invocation for an ops CLI.  
- **Principle 16 – Interactive**: Off-TTY help is the safe automation default; TTY empty argv is the numbered list.

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
3. Make bare invocation run domain `backup`, `add`, `update`, `remove`, or `vault set` without a numbered pick.  
4. Hang CI / off-TTY empty argv on a Choice prompt.  
5. Steal TTY empty argv back to help-only while this product claims a default function.

**Violating this rule is a critical dispatcher regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | Off-TTY empty argv shows help and does not install; TTY empty argv shows the numbered main menu and does not install |
| AC-2 | Type N is the declared empty-argv type |
| AC-3 | `self-install` (alias `install`) remains an explicit command |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-shell-cli-interface` | Dispatcher command table |
| `requirement-shell-cli-default-interaction` | Numbered list on TTY empty argv and on `menu`/`main` |
| `requirement-shell-local-self-management` | Explicit install |
| `requirement-bootstrap-chain` | Trim of Type O from parent |
| `docs/requirements/index.md` | Registry |

---

## Design-time verification

| TP family / ID | Suite | Status |
|----------------|-------|--------|
| **TP-CLI-07** | `tests/test_cli.sh` | have (off-TTY empty argv is help) |
| **TP-CLI-19** | `tests/test_cli.sh` | have (TTY empty argv is the numbered main menu) |

**Matrix:** `reviews/requirement-test-matrix.md`  
**Map:** `reviews/test-plan.md`

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-03 | Active | Type N for local-only folder-backup |
| 2026-08-16 | Active | dns-cli identity; empty argv must not mutate DNS/vault |
| 2026-09-03 | Active 1.1.0 | TTY empty argv = numbered main menu; off-TTY stays Type N help |

---

**Last Updated**: 2026-09-17  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
