**file**: docs/requirements/requirement-shell-cli-default-interaction.md  
**Status**: Active (Version 1.2.0) Implemented  
**Area**: shell  
**Key**: `requirement-shell-cli-default-interaction`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

dns-cli **claims** a default function: a **numbered main menu** of live operational commands. `requirement-shell-cli-zero-arguments` exists and the product is **not** online-installable (**case 3** owner of empty argv). That zero-argument file **MUST** send **interactive** empty argv (`TTY=1`) to this same numbered list. Off-TTY empty argv stays help. Routed-verb **`menu`** (alias **`main`**) **MUST** also draw the list.

### 1.1 Human-facing

**In one sentence:** At a real terminal, `dns-cli` (no arguments) or `dns-cli menu` shows **dns-cli**(*version*) - short description, then numbered jobs whose explain text is light gray italics; in a script those commands print help and do not wait.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | Open the list, pick a number | `dns-cli` or `dns-cli menu` then `6` |
| The other role | CI / pipe | `dns-cli` / `dns-cli menu` = help |
| Not this file | Install/version on the list | those stay off the board |

| Includes | Excludes |
|----------|----------|
| Rows 1…14 of live work commands; Exit **99**; header **dns-cli**(*version*) - short description; gray italic explain text | `help`, install, uninstall, where-is-me, version, about, setup, test-json-format, fence-test, `menu` itself |

| Surface | What you open | What for |
|---------|---------------|----------|
| `src/dns-cli` | Ship unit | `app_default` |
| `dns-cli` (TTY) | Empty argv | Numbered list |
| `dns-cli menu` | Command | Same numbered list |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Open the board at a prompt | Header names the copy and the short description, then numbered jobs | `dns-cli` or `dns-cli menu` |
| Leave | Exit | `99` |

---

## 2. Core Rules (Mandatory)

### 2.1 Claim and case

Claimed **yes**. Specialized zero-argument requirement **exists**. Product is **non-online-installable**. This is **case 3**: empty argv **MUST** follow `requirement-shell-cli-zero-arguments` (TTY = this menu; off-TTY = Type N help). Verb **`menu` MUST** draw the same list. **`main` MUST** alias the same handler.

### 2.2 `menu` / `main`

| Mode | `--json` | MUST | MUST NOT |
|------|----------|------|----------|
| Interactive (`TTY=1`) | **Ignore** `--json` | Draw the main menu | JSON help; hang |
| Non-interactive (`TTY=0`) | Follow `--json` | `app_help` (human when `JSON=0`; JSON help when `JSON=1`); **MUST NOT** hang | Draw the menu; silent return |

`--quiet` off-TTY is still the help path (do not swallow help). Measure `TTY` in the main process; helpers consume `TTY`. Tests **MAY** inject `TTY=1`.

### 2.3 Main menu

Labels **MUST** be `command: what it does`. Look **MUST** be default CLI main menu style: header **`${APP_NAME}`**(*`${VERSION}`*) then ` - ${SHORT_DESC}`; numbered `{{explain}}` *italic* **and** light gray on a TTY via SGR **3** + **37** (`ESC[3;37m`) in `app_default_print_row`. Number and command name stay unstyled. Exit (no explain) stays unstyled. Off-TTY: the same words, no CSI.

Header **MUST** print **`${APP_NAME}`**(*`${VERSION}`*) - `${SHORT_DESC}` (app-name-version-display): live Config `APP_NAME` immediately followed by parenthesized live Config `VERSION`, no space, then space-hyphen-space and live Config `SHORT_DESC` (alias of `SHORT_DESCRIPTION` / `APP_DESC`). **`APP_NAME` bold**, **`VERSION` italic**. TTY: SGR 1 / SGR 3 via `util_app_ident`. Off-TTY: plain. **MUST NOT** a bare `${APP_NAME}` on that header. **MUST NOT** freeze “numbered list of live commands” as the header suffix. Typical: `[INFO] **dns-cli**(*1.15.0*) - Cloudflare DNS CLI (vault + IPv4 A records)`.

The choice **MUST** be read in the **current shell** (`out_msg_n` then `read`). **MUST NOT** capture a `read` helper with `$()` / backticks.

| # | Token | Label |
|---|-------|-------|
| 1 | `remove-lpu` | `remove-lpu: Remove Linux user dns-adm` |
| 2 | `print-sudoers` | `print-sudoers: Print the sudoer file (does not install dest)` |
| 3 | `generate-sudoer-request` | `generate-sudoer-request: Write a local JSON grant you can review` |
| 4 | `submit-sudoer-request` | `submit-sudoer-request: Queue a type-2-switch grant as this login` |
| 5 | `vault` | `vault: Store or inspect Cloudflare vault` |
| 6 | `ip` | `ip: Show public IPv4 (no vault)` |
| 7 | `add` | `add: Ensure one A record` |
| 8 | `update` | `update: Update existing A record` |
| 9 | `remove` | `remove: Delete managed A record` |
| 10 | `status` | `status: Show public IP and DNS A records` |
| 11 | `submit` | `submit: Queue a DNS request JSON file` |
| 12 | `approve` | `approve: Apply a waiting DNS request` |
| 13 | `reject` | `reject: Decline a waiting DNS request` |
| 14 | `interactive` | `interactive: Review waiting DNS requests one by one` |
| 99 | Exit | `Exit` (not a routed-verb) |

N = 14 → Exit **99**. Accept number or verb token (`show` **MAY** run `status`). Extra operands: run the matching handler, or print `Next: dns-cli <verb> …` and return. **MUST NOT** hang off-TTY.

**MUST NOT** list install, uninstall, where-is-me, setup, version, about, help, test-json-format, fence-test, or `menu`/`main` itself.

Handler: `app_default` / `app_default_print_menu` / `app_default_print_row` / `app_default_run_pick` / `util_app_ident`.

### 2.3a Sample invocations (CI-M1a)

```sh
dns-cli
dns-cli menu
dns-cli main
dns-cli --json menu
```

### 2.3b Example `util_app_ident` (this product)

Class B return-via-stdout. Callers pass the result into `out_info`. Live code remains `src/dns-cli`.

```sh
util_app_ident() {
    : "${APP_NAME:=dns-cli}"
    : "${VERSION:=1.17.0}"
    : "${TTY:=0}"
    : "${QUIET:=0}"
    : "${JSON:=0}"
    if [ "${TTY}" -eq 1 ] && [ "${QUIET}" -eq 0 ] && [ "${JSON}" -eq 0 ]; then
        printf '\033[1m%s\033[0m(\033[3m%s\033[0m)' "${APP_NAME}" "${VERSION}"
    else
        printf '%s(%s)' "${APP_NAME}" "${VERSION}"
    fi
}
```

### 2.4 Implementation Notes (this project)

| Item | Value |
|------|--------|
| Product | `dns-cli` |
| Claimed | yes |
| Case | **3** — empty argv follows zero-arguments (TTY = this menu; off-TTY = help); verb `menu`/`main` is the same list |
| Exit | 99 |
| Header | `util_app_ident` + ` - ${SHORT_DESC}` → **`${APP_NAME}`**(*`${VERSION}`*) - `${SHORT_DESC}` |
| Row explain | TTY SGR 3 + SGR 37 via `app_default_print_row` |
| Handler | `app_default` |

Actor / role / subject / approver is already Active (`requirement-actor-role-subject-approver`). This menu is **not** dest yes/no review.

### 2.5 Why This Requirement Exists (CIAO)

- **Principle 2 – Intentional**: Claimed menu; labels match live operational verbs.  
- **Principle 16 – Interactive**: No hang off-TTY; TTY empty argv is this list.  
- **Principle 5 – SSOT of output**: Header through `out_info`; nametag via class-B `util_app_ident`; row explain through `app_default_print_row`.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution:** Off-TTY never waits on Choice.  
- **Intentional:** Fourteen operational rows; Exit 99.  
- **Anti-fragile:** `main` aliases `menu`.  
- **Over-protect:** Lifecycle, diagnostics, and testers stay off the list.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Put install, uninstall, where-is-me, setup, version, about, help, test-json-format, fence-test, or `menu`/`main` on the numbered list.  
2. Number Exit as 15 instead of **99**.  
3. Hang CI on `dns-cli` / `dns-cli menu` off-TTY, or steal TTY empty argv from this numbered list.  
4. Print a bare `${APP_NAME}` (no parenthesized `${VERSION}`, unstyled on TTY) on the main-menu header, or omit ` - ${SHORT_DESC}`.  
5. Capture the menu choice with `$()` of a function that contains `read`.  
6. Print numbered-list describe text unstyled on a TTY (it **MUST** be italic and light gray).

**Violating this rule is a critical CLI-surface regression.**

---

## 5. Related artifacts (versioned surface only)

| Artifact | Role |
|----------|------|
| `docs/requirements/index.md` | Registry |
| `docs/requirements/requirement-shell-cli-zero-arguments.md` | Empty argv: TTY = this menu; off-TTY = help |
| `docs/requirements/requirement-shell-cli-interface.md` | `menu` / `main` tokens |
| `docs/requirements/requirement-shell-interactive-vs-noninteractive.md` | No hang |
| `docs/requirements/requirement-shell-output-requirements.md` | `out_*` + class B printf |
| `docs/requirements/requirement-actor-role-subject-approver.md` | Who-is-who (already Active) |
| `./src/dns-cli` | Ship unit |

## Design-time verification

| TP family / ID | Suite | Status |
|----------------|-------|--------|
| **TP-CLI-07** | `tests/test_cli.sh` | have (off-TTY empty argv stays help) |
| **TP-CLI-18** | `tests/test_cli.sh` | have (header `${APP_NAME}(${VERSION}) - ${SHORT_DESC}`; TTY bold name / italic version / SGR 3;37 explain; off-TTY menu = help) |
| **TP-CLI-19** | `tests/test_cli.sh` | have (TTY empty argv draws the same numbered list) |
| **TP-CLI-14** | `tests/test_cli.sh` | have (`menu` / `main` dual mention) |
| **TP-CLI-15** | `tests/test_cli.sh` | have (`dns-cli menu` sample) |

## 6. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-09-03 | Active 1.0.0 | Case 3 numbered menu on `menu`/`main`; header **`${APP_NAME}`**(*`${VERSION}`*) |
| 2026-09-03 | Active 1.1.0 | Header **`${APP_NAME}`**(*`${VERSION}`*) - `${SHORT_DESC}`; numbered explain TTY light gray italic |
| 2026-09-03 | Active 1.2.0 | TTY empty argv uses this list; explain SGR **3;37** (default CLI main menu style) |

**Last Updated**: 2026-09-03  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
