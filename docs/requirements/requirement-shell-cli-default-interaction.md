**file**: docs/requirements/requirement-shell-cli-default-interaction.md  
**Status**: Active (Version 1.3.0) Implemented  
**Area**: shell  
**Key**: `requirement-shell-cli-default-interaction`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

dns-cli **claims** a default function: a **short numbered main menu** of daily **DNS work**, with sudoer grant/draft and LPU teardown behind one **family** row. `requirement-shell-cli-zero-arguments` exists and the product is **not** online-installable (**case 3** owner of empty argv). That zero-argument file **MUST** send **interactive** empty argv (`TTY=1`) to this same numbered list. Off-TTY empty argv stays help. Routed-verb **`menu`** (alias **`main`**) **MUST** also draw the list. The family row **MUST NOT** be a live dispatcher command.

### 1.1 Human-facing

**In one sentence:** At a real terminal, `dns-cli` (no arguments) or `dns-cli menu` shows **dns-cli**(*version*) - short description, then numbered daily DNS jobs plus **sudoers**; pick **sudoers** for grant/drafts; in a script those commands print help and do not wait.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | Open the list, pick a number | `dns-cli` or `dns-cli menu` then `2` |
| The other role | CI / pipe | `dns-cli` / `dns-cli menu` = help |
| Not this file | Install/version on the list; `sudoers` as a typed CLI command | those stay off the board / unknown |

| Includes | Excludes |
|----------|----------|
| Daily DNS rows 1…10; family **sudoers** **11**; Exit **99**; header **dns-cli**(*version*) - short description; gray italic explain text; sudoers submenu Back **8** / Exit **9** | `help`, install, uninstall, where-is-me, version, about, setup, test-json-format, fence-test, `menu` itself; sudoer verbs on the **main** list; a live `sudoers` dispatcher token |

| Surface | What you open | What for |
|---------|---------------|----------|
| `src/dns-cli` | Ship unit | `app_default` |
| `dns-cli` (TTY) | Empty argv | Numbered list |
| `dns-cli menu` | Command | Same numbered list |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Open the board at a prompt | Daily DNS work; **vault** is **1**; **sudoers** is **11** | `dns-cli` or `dns-cli menu` then `1` |
| Show public IPv4 | Second row | `dns-cli` then `2` |
| Open grant/drafts | Family row **11**, then a number | `dns-cli` then `11` then `1` |
| Leave the grant list | Back to the start list | `8` |
| Leave the menu | Exit | `99` (submenu **9** also leaves) |
| Install the program | Not on this list | `dns-cli install` |
| Run `menu` in a script | Help screen, no pick | `dns-cli menu </dev/null` |

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

Header **MUST** print **`${APP_NAME}`**(*`${VERSION}`*) - `${SHORT_DESC}` (app-name-version-display): live Config `APP_NAME` immediately followed by parenthesized live Config `VERSION`, no space, then space-hyphen-space and live Config `SHORT_DESC` (alias of `SHORT_DESCRIPTION` / `APP_DESC`). **`APP_NAME` bold**, **`VERSION` italic**. TTY: SGR 1 / SGR 3 via `util_app_ident`. Off-TTY: plain. **MUST NOT** a bare `${APP_NAME}` on that header. **MUST NOT** freeze “numbered list of live commands” as the header suffix. Typical: `[INFO] **dns-cli**(*1.22.0*) - Cloudflare DNS CLI (vault + IPv4 A records)`.

The choice **MUST** be read in the **current shell** (`out_msg_n` then `read`). **MUST NOT** capture a `read` helper with `$()` / backticks.

1. Print a **numbered list** of **daily DNS work** plus one **family** row, then **Exit**.  
2. **MUST NOT** list **install / setup**, **self-managed** commands (`install`, `uninstall`, `where-is-me`), **diagnostics** (`version`, `about`), or **test-purpose** verbs.  
3. Command-row text **MUST** be `command: what it does`.  
4. **MUST NOT** list `help`, `menu`/`main`, or the four sudoers-family verbs on the **main** list (those verbs live on the submenu).  
5. Main command rows **N = 11** (ten verbs + one family). Exit **MUST** be **99**. Unused integers **12–98** are omitted.  
6. Accept a **number** or a **listed verb**. **99** / `exit` / `quit` returns 0.  
7. **`sudoers` is not a live CLI command.** Choosing **11** or typing `sudoers` at the pick prompt **MUST** open the submenu (§2.4). `dns-cli sudoers` **MUST** remain unknown.  
8. Typing a submenu verb at the **main** pick prompt **MAY** run that handler (shortcut).  
9. Extra operands: run the matching handler, or print `Next: dns-cli <verb> …` and return. **MUST NOT** hang off-TTY.

Normative **main** order:

| # | Token | Label |
|---|-------|-------|
| 1 | `vault` | `vault: Store or inspect Cloudflare vault` |
| 2 | `ip` | `ip: Show public IPv4 (no vault)` |
| 3 | `add` | `add: Ensure one A record` |
| 4 | `update` | `update: Update existing A record` |
| 5 | `remove` | `remove: Delete managed A record` |
| 6 | `status` | `status: Show public IP and DNS A records` |
| 7 | `submit` | `submit: Queue a DNS request JSON file` |
| 8 | `approve` | `approve: Apply a waiting DNS request` |
| 9 | `reject` | `reject: Decline a waiting DNS request` |
| 10 | `interactive` | `interactive: Review waiting DNS requests one by one` |
| 11 | family `sudoers` | `sudoers: Grant and drafts` |
| **99** | **Exit** | leave the menu |

Accept number or verb token (`show` **MAY** run `status`).

**MUST NOT** list install, uninstall, where-is-me, setup, version, about, help, test-json-format, fence-test, or `menu`/`main` itself.

Handler: `app_default` / `app_default_print_menu` / `app_default_print_row` / `app_default_run_pick` / `app_default_print_sudoers_menu` / `app_default_run_sudoers_pick` / `app_default_sudoers_loop` / `util_app_ident`.

### 2.4 Sudoers submenu

Choosing main **11** / `sudoers` **MUST** print a second numbered list of the grouped live verbs. Submenu header **MUST** use the same `APP_NAME(VERSION)` nametag, then ` - sudoers (grant and drafts)`. Explain text **MUST** follow the same default CLI main menu style as the main list (*italic* + light gray SGR **3** + **37** on a TTY via `app_default_print_row`). **MUST NOT** hang off-TTY (submenu exists only on the interactive menu path).

| # | Command | Label |
|---|---------|-------|
| 1 | `generate-sudoer-request` | `generate-sudoer-request: Write a local JSON grant you can review` |
| 2 | `submit-sudoer-request` | `submit-sudoer-request: Queue a type-2-switch grant as this login` |
| 3 | `print-sudoers` | `print-sudoers: Print the sudoer file (does not install dest)` |
| 4 | `remove-lpu` | `remove-lpu: Remove Linux user dns-adm` |
| **8** | **Back** | return to the main list (not a command) |
| **9** | **Exit** | leave the menu |

Submenu command rows **N = 4**. Exit **MUST** be **9**. **Back MUST** be **8**. Unused **5–7** are omitted.

- **8** / `back` / `Back` returns to the main list (does not run a handler).  
- **9** / `exit` / `quit` returns 0 from `menu` (same as main Exit). **99** **MAY** also leave.  
- A listed number or verb runs that handler, then returns 0 from `menu` (one command, then done).  
- All four grouped verbs **MUST** appear here. **MUST NOT** put install/version/about/`help`/`setup`/test-purpose on this list. This product **MUST NOT** list `print-sudoers-install-script` or `remove-project-sudoers` (those tokens stay unknown).

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
    : "${VERSION:=1.22.0}"
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

### 2.5 Implementation Notes (this project)

| Item | Value |
|------|--------|
| Product | `dns-cli` |
| Claimed | yes |
| Case | **3** — empty argv follows zero-arguments (TTY = this menu; off-TTY = help); verb `menu`/`main` is the same list |
| Family row | `sudoers` — menu-only; **not** dispatched |
| Main Exit | **99** (N = 11) |
| Submenu | Back **8**; Exit **9**; N = 4 |
| Header | `util_app_ident` + ` - ${SHORT_DESC}` → **`${APP_NAME}`**(*`${VERSION}`*) - `${SHORT_DESC}` |
| Submenu header | `util_app_ident` + ` - sudoers (grant and drafts)` |
| Row explain | TTY SGR 3 + SGR 37 via `app_default_print_row` |
| Handler | `app_default` (`menu` / `main` / TTY empty argv); submenu printer/loop under the same `app_default_*` family |
| Honesty | **Implemented.** TTY empty argv draws this menu. Off-TTY empty argv is Type N help. Header `APP_NAME(VERSION)`; main **N = 11**; submenu **N = 4**; Exit **99**; Back **8**. |

Actor / role / subject / approver is already Active (`requirement-actor-role-subject-approver`). This menu is **not** dest yes/no review.

### 2.6 Why This Requirement Exists (CIAO)

- **Principle 2 – Intentional**: Daily DNS work is the start list; grant/draft commands are one extra pick.  
- **Principle 16 – Interactive**: No hang off-TTY; TTY empty argv is this list.  
- **Principle 5 – SSOT of output**: Header through `out_info`; nametag via class-B `util_app_ident`; row explain through `app_default_print_row`.  
- **Over-protect**: `sudoers` is not a live dispatcher token; install / version / about / `help` / setup / testers stay off both lists; main Exit is **99**, not **12**.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- The start list is **daily work**, not a reprint of `help`.  
- Related rare commands share one family row.  
- Dispatcher remains routing SSOT (`sudoers` is not added there).  
- Fail closed off-TTY.  
- Zero-arguments owns Type N off-TTY vs TTY menu; this file owns the list body.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Put install, uninstall, where-is-me, setup, version, about, help, test-json-format, fence-test, or `menu`/`main` on the numbered main list or the sudoers submenu.  
2. Put the four sudoers-family verbs (`generate-sudoer-request`, `submit-sudoer-request`, `print-sudoers`, `remove-lpu`) on the **main** list.  
3. Drop a grouped sudoers verb from the submenu.  
4. Number main Exit as **12** instead of **99**, or submenu Exit as **5** (submenu Exit **MUST** be **9**; Back **MUST** be **8**).  
5. Wire `sudoers` as a live `app_main` command.  
6. Hang CI on `dns-cli` / `dns-cli menu` off-TTY, or steal TTY empty argv from this numbered list.  
7. Print a bare `${APP_NAME}` (no parenthesized `${VERSION}`, unstyled on TTY) on the main-menu or APP_NAME-led submenu header, or omit ` - ${SHORT_DESC}` on the main header.  
8. Capture the menu choice with `$()` of a function that contains `read`.  
9. Print numbered-list describe text unstyled on a TTY (it **MUST** be italic and light gray).  
10. Print the generic board title “numbered list of live commands” instead of Config `SHORT_DESC`.

**Violating this rule is a critical CLI-surface regression.**

---

## 5. Related artifacts (versioned surface only)

| Artifact | Role |
|----------|------|
| `docs/requirements/index.md` | Registry |
| `docs/requirements/requirement-shell-cli-zero-arguments.md` | Empty argv: TTY = this menu; off-TTY = help |
| `docs/requirements/requirement-shell-cli-interface.md` | `menu` / `main` tokens (`sudoers` is **not** a token) |
| `docs/requirements/requirement-shell-interactive-vs-noninteractive.md` | No hang |
| `docs/requirements/requirement-shell-output-requirements.md` | `out_*` + class B printf |
| `docs/requirements/requirement-actor-role-subject-approver.md` | Who-is-who (already Active) |
| `docs/requirements/requirement-three-layer-privilege-model.md` | `print-sudoers` / `remove-lpu` topic-owner |
| `docs/requirements/requirement-sudoer-json-file.md` | generate/submit JSON grant |
| `./src/dns-cli` | Ship unit |

## Design-time verification

| TP family / ID | Suite | Status |
|----------------|-------|--------|
| **TP-CLI-07** | `tests/test_cli.sh` | have (off-TTY empty argv stays help) |
| **TP-CLI-18** | `tests/test_cli.sh` | have (header `${APP_NAME}(${VERSION}) - ${SHORT_DESC}`; TTY bold name / italic version / SGR 3;37 explain; off-TTY menu = help; TTY `--json menu` ignores json; TTY `main`; family row; sudoer verbs not on main) |
| **TP-CLI-19** | `tests/test_cli.sh` | have (TTY empty argv draws the same numbered list) |
| **TP-CLI-20** | `tests/test_cli.sh` | have (sudoers submenu Back/Exit; `sudoers` not a live command) |
| **TP-CLI-14** | `tests/test_cli.sh` | have (`menu` / `main` dual mention) |
| **TP-CLI-15** | `tests/test_cli.sh` | have (`dns-cli menu` sample) |

## 6. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-09-03 | Active 1.0.0 | Case 3 numbered menu on `menu`/`main`; header **`${APP_NAME}`**(*`${VERSION}`*) |
| 2026-09-03 | Active 1.1.0 | Header **`${APP_NAME}`**(*`${VERSION}`*) - `${SHORT_DESC}`; numbered explain TTY light gray italic |
| 2026-09-03 | Active 1.2.0 | TTY empty argv uses this list; explain SGR **3;37** (default CLI main menu style) |
| 2026-09-03 | Active 1.3.0 | Daily DNS work on the main list; family **sudoers** + submenu (Back **8** / Exit **9**); `sudoers` not dispatched |

**Last Updated**: 2026-09-03  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
