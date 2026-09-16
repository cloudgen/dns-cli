**file**: docs/requirements/requirement-shell-cli-default-interaction.md  
**Status**: Active (Version 1.7.0) Implemented  
**Area**: shell  
**Key**: `requirement-shell-cli-default-interaction`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

dns-cli **claims** a default function: a **short numbered main menu** of three **family** rows — **DNS Features** (daily DNS work), **sudoers** (grant/draft and LPU teardown), and **self-management** (local install/uninstall/where-is-me, specialized from sibling **selfmanaged** onto this local-only product). `requirement-shell-cli-zero-arguments` exists and the product is **not** online-installable (**case 3** owner of empty argv). That zero-argument file **MUST** send **interactive** empty argv (`TTY=1`) to this same numbered list. Off-TTY empty argv stays help. Routed-verb **`menu`** (alias **`main`**) **MUST** also draw the list. Family rows **MUST NOT** be live dispatcher commands.

### 1.1 Human-facing

**In one sentence:** At a real terminal, `dns-cli` (no arguments) or `dns-cli menu` shows **dns-cli**(*version*) - short description, then **1 DNS Features**, **7 sudoers**, and **8 self-management**; pick **1** for vault/ip/add/…; pick **8** to place/remove/locate this program; in a script those commands print help and do not wait.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | Open the list, pick a number | `dns-cli` or `dns-cli menu` then `1` |
| The other role | CI / pipe | `dns-cli` / `dns-cli menu` = help |
| Not this file | Install/version as **main** rows; `sudoers` / `DNS Features` / `self-management` as typed CLI commands | those stay off the board / unknown |

| Includes | Excludes |
|----------|----------|
| Top **1** family **DNS Features**; **7** family **sudoers**; **8** family **self-management**; Exit **9**; DNS submenu rows 1…10 plus Back **98** / Exit **99**; sudoers submenu Back **8** / Exit **9**; self-management submenu rows 1…5 plus Back **8** / Exit **9**; a finished listed command returns to the **top** list; header **dns-cli**(*version*) - short description; gray italic explain text; a wrong pick reprints **that same list** | `help`, setup, test-json-format, fence-test, `menu` itself; DNS / sudoer / self-management verbs on the **main** list; live `sudoers` / `dns` / `self-management` dispatcher tokens; online `self-update` / `version-check` / `self-uninstall`; treating a wrong pick as Exit; leaving the menu because a listed command finished |

| Surface | What you open | What for |
|---------|---------------|----------|
| `src/dns-cli` | Ship unit | `app_default` |
| `dns-cli` (TTY) | Empty argv | Numbered list |
| `dns-cli menu` | Command | Same numbered list |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Open the board at a prompt | Three families; **DNS Features** is **1**; **sudoers** is **7**; **self-management** is **8** | `dns-cli` or `dns-cli menu` then `1` |
| Show public IPv4 | DNS Features, then second row | `dns-cli` then `1` then `2` |
| Open grant/drafts | Family row **7**, then a number | `dns-cli` then `7` then `1` |
| Place or remove this program | Family row **8**, then a number | `dns-cli` then `8` then `1` |
| Leave the DNS list | Back to the start list | `98` |
| Leave the grant list | Back to the start list | `8` |
| Leave the self-management list | Back to the start list | `8` |
| Finish a listed job | Back at the start list | `1` then `2` (then you see 1 / 7 / 8 / 9 again) |
| Type a number that is not on this list | The same list prints again; pick again | `2` then `1` |
| Type a number that is not on the DNS list | That DNS list prints again | `1` then `11` then `98` |
| Type a number that is not on the grant list | That grant list prints again | `8` then `5` then `8` |
| Leave the menu | Exit | **9** (DNS layer **99**; sudoers **9**; **99** MAY also leave the top list) |
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

Header **MUST** print **`${APP_NAME}`**(*`${VERSION}`*) - `${SHORT_DESC}` (app-name-version-display): live Config `APP_NAME` immediately followed by parenthesized live Config `VERSION`, no space, then space-hyphen-space and live Config `SHORT_DESC` (alias of `SHORT_DESCRIPTION` / `APP_DESC`). **`APP_NAME` bold**, **`VERSION` italic**. TTY: SGR 1 / SGR 3 via `util_app_ident`. Off-TTY: plain. **MUST NOT** a bare `${APP_NAME}` on that header. **MUST NOT** freeze “numbered list of live commands” as the header suffix. Typical: `[INFO] **dns-cli**(*1.28.0*) - Cloudflare DNS CLI (vault + IPv4 A records)`.

The choice **MUST** be read in the **current shell** (`out_msg_n` then `read`). **MUST NOT** capture a `read` helper with `$()` / backticks.

1. Print a **numbered list** of three **family** rows, then **Exit**.  
2. **MUST NOT** list **setup**, **test-purpose** verbs, or **online** self-management (`self-update`, `version-check`, `self-uninstall`) on any numbered list.  
3. Command-row text **MUST** be `command: what it does`.  
4. **MUST NOT** list `help`, `menu`/`main`, the ten daily DNS verbs, the four sudoers-family verbs, or the five local self-management verbs on the **main** list (those verbs live on their submenus).  
5. Main command rows **N = 3** (three families). Family **sudoers** **MUST** be numbered **7**. Family **self-management** **MUST** be numbered **8**. Exit **MUST** be **9**. Unused integers **2–6** and **10–98** are omitted. **99** **MAY** also leave.  
6. Accept a **number** or a **listed family token**. **9** / `exit` / `quit` returns 0.  
7. **`sudoers` is not a live CLI command.** Choosing **7** or typing `sudoers` at the pick prompt **MUST** open the submenu (§2.4). `dns-cli sudoers` **MUST** remain unknown.  
7b. **`DNS Features` is not a live CLI command.** Choosing **1** or typing `dns` / `DNS Features` / `dns-features` at the pick prompt **MUST** open the DNS submenu (§2.3c). `dns-cli dns` **MUST** remain unknown.  
7c. **`self-management` is not a live CLI command.** Choosing **8** or typing `self-management` / `self-managed` / `selfmanaged` at the pick prompt **MUST** open the submenu (§2.4b). `dns-cli self-management` **MUST** remain unknown.  
8. Typing a submenu verb at the **main** pick prompt **MAY** run that handler (shortcut). After it finishes, **MUST** return to the **top** list. **MUST NOT** treat unused **numbers** 2–6 as shortcuts.  
9. Extra operands: run the matching handler, or print `Next: dns-cli <verb> …` and return. **MUST NOT** hang off-TTY.  
10. **Invalid pick (mandatory, every numbered layer):** a blank line, unused number (main **2–6** and **10–98**), or token that is not a listed choice **MUST NOT** leave that layer, **MUST NOT** be treated as Exit, and **MUST NOT** jump to another list. **MUST** warn (operator-readable: what happened + next step), **MUST** reprint **that same numbered list**, and **MUST** read another choice. A later listed number or verb **MUST** still run. EOF on `read` **MAY** return 0 (closed stdin; no hang). Off-TTY **MUST NOT** reach this loop.

Normative **main** order:

| # | Token | Label |
|---|-------|-------|
| 1 | family `DNS Features` | `DNS Features: Daily DNS work` |
| 7 | family `sudoers` | `sudoers: Grant and drafts` |
| 8 | family `self-management` | `self-management: Install, uninstall, where-is-me` |
| **9** | **Exit** | leave the menu |

Accept number or family token (`dns` / `DNS Features` / `dns-features` **MUST** open §2.3c; `sudoers` **MUST** open §2.4; `self-management` / `self-managed` / `selfmanaged` **MUST** open §2.4b). `show` **MAY** run `status` as a shortcut.

**MUST NOT** list install, uninstall, where-is-me, setup, version, about, help, test-json-format, fence-test, or `menu`/`main` itself.

Handler: `app_default` / `app_default_print_menu` / `app_default_print_row` / `app_default_run_pick` / `app_default_print_dns_menu` / `app_default_run_dns_pick` / `app_default_dns_loop` / `app_default_print_sudoers_menu` / `app_default_run_sudoers_pick` / `app_default_sudoers_loop` / `app_default_print_selfmgmt_menu` / `app_default_run_selfmgmt_pick` / `app_default_selfmgmt_loop` / `util_app_ident`.

### 2.3c DNS Features submenu

Choosing main **1** / `dns` / `DNS Features` **MUST** print a second numbered list of the ten daily DNS verbs. Submenu header **MUST** use the same `APP_NAME(VERSION)` nametag, then ` - DNS Features (daily DNS work)`. Explain text **MUST** follow the same default CLI main menu style as the main list (*italic* + light gray SGR **3** + **37** on a TTY via `app_default_print_row`). **MUST NOT** hang off-TTY (submenu exists only on the interactive menu path).

| # | Command | Label |
|---|---------|-------|
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
| **98** | **Back** | return to the main list (not a command) |
| **99** | **Exit** | leave the menu |

DNS submenu command rows **N = 10**. Exit **MUST** be **99**. **Back MUST** be **98**. Unused **11–97** are omitted. **9** on this layer **MUST** run `reject` (it is **not** Exit).

- **98** / `back` / `Back` returns to the main list (does not run a handler).  
- **99** / `exit` / `quit` returns 0 from `menu` (same as main Exit).  
- A listed number or verb runs that handler, then **MUST** return to the **top** list (same as Back). **MUST NOT** leave `menu`. **MUST NOT** stay on this DNS list. `show` **MAY** run `status`.  
- **Invalid pick** on this layer follows §2.3 item 10: unused **11–97**, a blank line, or an unknown token **MUST** warn, reprint **this** DNS list, and read again. **MUST NOT** Back, **MUST NOT** Exit, **MUST NOT** return to the main list.  
- All ten daily DNS verbs **MUST** appear here. **MUST NOT** put install/version/about/`help`/`setup`/test-purpose or the four sudoers-family verbs on this list.

### 2.4 Sudoers submenu

Choosing main **7** / `sudoers` **MUST** print a second numbered list of **all four** grouped live verbs (full sudoers-family coverage). Submenu header **MUST** use the same `APP_NAME(VERSION)` nametag, then ` - sudoers (grant and drafts)`. Explain text **MUST** follow the same default CLI main menu style as the main list (*italic* + light gray SGR **3** + **37** on a TTY via `app_default_print_row`). **MUST NOT** hang off-TTY (submenu exists only on the interactive menu path).

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
- A listed number or verb runs that handler, then **MUST** return to the **top** list (same as Back). **MUST NOT** leave `menu`. **MUST NOT** stay on this grant list.  
- **Invalid pick** on this layer follows §2.3 item 10: unused **5–7**, a blank line, or an unknown token **MUST** warn, reprint **this** grant list, and read again. **MUST NOT** Back, **MUST NOT** Exit, **MUST NOT** return to the main list.  
- All four grouped verbs **MUST** appear here. **MUST NOT** put install/version/about/`help`/`setup`/test-purpose on this list. This product **MUST NOT** list `print-sudoers-install-script` or `remove-project-sudoers` (those tokens stay unknown).

### 2.4b Self-management submenu

Choosing main **8** / `self-management` **MUST** print a second numbered list of the **local** lifecycle package (specialized from sibling **selfmanaged**: same family grouping; this product stays **local-only**). Submenu header **MUST** use the same `APP_NAME(VERSION)` nametag, then ` - self-management (place, remove, locate)`. Explain text **MUST** follow the same default CLI main menu style. **MUST NOT** hang off-TTY.

| # | Command | Label |
|---|---------|-------|
| 1 | `install` | `install: Install dns-cli (root→global, user→~/.local/bin)` |
| 2 | `uninstall` | `uninstall: Remove managed binary (confirm or --force)` |
| 3 | `where-is-me` | `where-is-me: Show running and install paths` |
| 4 | `version` | `version: Show local version` |
| 5 | `about` | `about: Show diagnostics (Type 0 + vault fields, no token)` |
| **8** | **Back** | return to the main list (not a command) |
| **9** | **Exit** | leave the menu |

Self-management command rows **N = 5**. Exit **MUST** be **9**. **Back MUST** be **8**. Unused **6–7** are omitted.

- **8** / `back` / `Back` returns to the main list (does not run a handler).  
- **9** / `exit` / `quit` returns 0 from `menu` (same as main Exit). **99** **MAY** also leave.  
- A listed number or verb runs that handler, then **MUST** return to the **top** list (same as Back). **MUST NOT** leave `menu`. **MUST NOT** stay on this self-management list.  
- **Invalid pick** on this layer follows §2.3 item 10: unused **6–7**, a blank line, or an unknown token **MUST** warn, reprint **this** list, and read again. **MUST NOT** Back, **MUST NOT** Exit, **MUST NOT** return to the main list.  
- All five local lifecycle/diagnostics verbs **MUST** appear here. **MUST NOT** list `help`, `setup`, `menu`/`main`, test-purpose, or **online** verbs (`self-install`, `self-update`, `self-uninstall`, `version-check`). Topic-owner for the verbs: `requirement-shell-local-self-management`.

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
    : "${VERSION:=1.28.0}"
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
| Family rows | `DNS Features`, `sudoers`, `self-management` — menu-only; **not** dispatched |
| Main Exit | **9** (N = 3; sudoers **7**; self-management **8**) |
| DNS submenu | Back **98**; Exit **99**; N = 10 |
| Sudoers submenu | Back **8**; Exit **9**; N = 4 (all four grant/draft/LPU verbs) |
| Self-management submenu | Back **8**; Exit **9**; N = 5 (local install/uninstall/where-is-me/version/about; no online verbs) |
| Invalid pick | Warn + reprint **that same** numbered layer; a later listed pick still runs; EOF returns 0 |
| Header | `util_app_ident` + ` - ${SHORT_DESC}` → **`${APP_NAME}`**(*`${VERSION}`*) - `${SHORT_DESC}` |
| DNS submenu header | `util_app_ident` + ` - DNS Features (daily DNS work)` |
| Sudoers submenu header | `util_app_ident` + ` - sudoers (grant and drafts)` |
| Row explain | TTY SGR 3 + SGR 37 via `app_default_print_row` |
| Handler | `app_default` (`menu` / `main` / TTY empty argv); submenu printer/loop under the same `app_default_*` family |
| Finished command | Returns to the **top** list (DNS Features, sudoers, and top-list shortcuts). Exit / EOF still leave. |
| Honesty | **Implemented.** TTY empty argv draws this menu. Off-TTY empty argv is Type N help. Header `APP_NAME(VERSION)`; main **N = 3**; DNS submenu **N = 10**; sudoers submenu **N = 4**; self-management submenu **N = 5**; Exit **9**; DNS Back **98**; sudoers/self-management Back **8**. A finished listed command returns to the top list. Invalid pick reprints the same layer (main, DNS Features, sudoers, and self-management). Sibling **selfmanaged** is a read-only architecture reference for this family grouping; this product’s live origin stays `cli-template`. |

Actor / role / subject / approver is already Active (`requirement-actor-role-subject-approver`). This menu is **not** dest yes/no review.

### 2.6 Why This Requirement Exists (CIAO)

- **Principle 2 – Intentional**: Two family rows on the start list; daily DNS work and grant/draft commands each sit one pick behind.  
- **Principle 16 – Interactive**: No hang off-TTY; TTY empty argv is this list.  
- **Principle 5 – SSOT of output**: Header through `out_info`; nametag via class-B `util_app_ident`; row explain through `app_default_print_row`.  
- **Over-protect**: `DNS Features` and `sudoers` are not live dispatcher tokens; install / version / about / `help` / setup / testers stay off every list; main Exit is **9**, not **10**; a wrong pick reprints the same layer instead of leaving.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- The start list is **three families**, not a reprint of `help`.  
- Related daily DNS commands share **DNS Features**. Related rare grant/draft commands share **sudoers**. Local lifecycle commands share **self-management**.  
- Dispatcher remains routing SSOT (`DNS Features` / `sudoers` / `self-management` are not added there).  
- Fail closed off-TTY.  
- Zero-arguments owns Type N off-TTY vs TTY menu; this file owns the list body.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Put setup, help, test-json-format, fence-test, or `menu`/`main` on the numbered main list or any submenu.  
2. Put the ten daily DNS verbs, the four sudoers-family verbs, or the five local self-management verbs on the **main** list.  
3. Drop a grouped DNS verb from the DNS Features submenu, a grouped sudoers verb from the sudoers submenu, or a grouped self-management verb from the self-management submenu.  
4. Number main Exit as **10** instead of **9**; number DNS Features Exit as **11** instead of **99**, or DNS Back as anything other than **98**; number sudoers or self-management Exit as **5** (those Exit **MUST** be **9**; Back **MUST** be **8**). Number family **self-management** as anything other than **8**, or family **sudoers** as anything other than **7**.  
5. Wire `sudoers`, `dns` / `DNS Features`, or `self-management` as a live `app_main` command. Put online `self-update` / `version-check` / `self-uninstall` on this product’s lists.  
6. Hang CI on `dns-cli` / `dns-cli menu` off-TTY, or steal TTY empty argv from this numbered list.  
7. Print a bare `${APP_NAME}` (no parenthesized `${VERSION}`, unstyled on TTY) on the main-menu or APP_NAME-led submenu header, or omit ` - ${SHORT_DESC}` on the main header.  
8. Capture the menu choice with `$()` of a function that contains `read`.  
9. Print numbered-list describe text unstyled on a TTY (it **MUST** be italic and light gray).  
10. Print the generic board title “numbered list of live commands” instead of Config `SHORT_DESC`.  
11. Leave the current numbered list because the operator typed a blank line, unused number, or unknown token — **MUST** warn, reprint **that same** layer, and read again. **MUST NOT** treat invalid as Exit, Back, or a jump to another list.  
12. Leave the menu, or stay on a submenu, because a listed command finished — **MUST** return to the **top** list after a finished listed command (same as Back). Exit / EOF still leave.

**Violating this rule is a critical CLI-surface regression.**

---

## 5. Related artifacts (versioned surface only)

| Artifact | Role |
|----------|------|
| `docs/requirements/index.md` | Registry |
| `docs/requirements/requirement-shell-cli-zero-arguments.md` | Empty argv: TTY = this menu; off-TTY = help |
| `docs/requirements/requirement-shell-cli-interface.md` | `menu` / `main` tokens (`DNS Features` / `sudoers` / `self-management` are **not** tokens) |
| `docs/requirements/requirement-shell-local-self-management.md` | Local install / uninstall / where-is-me / version / about |
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
| **TP-CLI-18** | `tests/test_cli.sh` | have (header `${APP_NAME}(${VERSION}) - ${SHORT_DESC}`; TTY bold name / italic version / SGR 3;37 explain; off-TTY menu = help; TTY `--json menu` ignores json; TTY `main`; family **DNS Features** **1** + family **sudoers** **7** + family **self-management** **8**; member verbs not on main) |
| **TP-CLI-19** | `tests/test_cli.sh` | have (TTY empty argv draws the same numbered list) |
| **TP-CLI-20** | `tests/test_cli.sh` | have (sudoers submenu Back/Exit; `sudoers` not a live command; all four grant/draft/LPU verbs) |
| **TP-CLI-21** | `tests/test_cli.sh` | have (invalid pick on main, DNS Features, and sudoers reprints that same layer; a later listed pick still runs) |
| **TP-CLI-22** | `tests/test_cli.sh` | have (DNS Features submenu Back **98** / Exit **99**; `dns` not a live command; all ten daily DNS verbs) |
| **TP-CLI-23** | `tests/test_cli.sh` | have (a finished listed command returns to the top list: DNS `ip`, sudoers `print-sudoers`, top-list shortcut) |
| **TP-CLI-24** | `tests/test_cli.sh` | have (self-management submenu Back **8** / Exit **9**; `self-management` not a live command; local five verbs; no online verbs; finished `version` returns to top) |
| **TP-CLI-14** | `tests/test_cli.sh` | have (`menu` / `main` dual mention) |
| **TP-CLI-15** | `tests/test_cli.sh` | have (`dns-cli menu` sample) |

## 6. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-09-03 | Active 1.0.0 | Case 3 numbered menu on `menu`/`main`; header **`${APP_NAME}`**(*`${VERSION}`*) |
| 2026-09-03 | Active 1.1.0 | Header **`${APP_NAME}`**(*`${VERSION}`*) - `${SHORT_DESC}`; numbered explain TTY light gray italic |
| 2026-09-03 | Active 1.2.0 | TTY empty argv uses this list; explain SGR **3;37** (default CLI main menu style) |
| 2026-09-03 | Active 1.3.0 | Daily DNS work on the main list; family **sudoers** + submenu (Back **8** / Exit **9**); `sudoers` not dispatched |
| 2026-09-13 | Active 1.4.0 | Invalid pick on every numbered layer warns, reprints **that same** list, and reads again (**TP-CLI-21**) |
| 2026-09-16 | Active 1.5.0 | Top list is family **DNS Features** **1** + family **sudoers** **8**; Exit **9**; DNS submenu Back **98** / Exit **99**; sudoers submenu unchanged (**TP-CLI-22**) |
| 2026-09-16 | Active 1.6.0 | A finished listed command returns to the **top** list (**TP-CLI-23**) |
| 2026-09-16 | Active 1.7.0 | Family **self-management** is main **8** (local install/uninstall/where-is-me/version/about); family **sudoers** moves to **7**; sibling **selfmanaged** is a read-only architecture reference (**TP-CLI-24**) |

**Last Updated**: 2026-09-16  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
