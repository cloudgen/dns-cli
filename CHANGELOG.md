# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [1.12.0] - 2026-08-21

### Added

- Dest-owned JSON keys **`submit_app`** / **`submit_version`**: Type 0 `submit` stamps live Config `APP_NAME` / `VERSION` (overwrite on queue). Dest format-fences missing or non-string values. Dest **MUST NOT** fence if the values ≠ dest product or dest version. Dest interactive prints `queued by {app} {version}` before yes/no. Dest **MUST NOT** dest-write those keys. Sudoer generate/submit emit the same keys after sibling dest allowlists them. Law **IJF-M8** / **IJF-M9** 1.4.0. **TP-FENCE-16** · **TP-FENCE-17** · **TP-CF-REQ-17**. Ship unit **`VERSION="1.12.0"`**.

### Changed

- Incident **INC-20260821-001**: live sibling dest `/etc/sudoers.d/dns-cli-dns-adm` granted a test `.ci-homes/…/gbin/dns-cli` path. `dns-adm` login `sudo -n` of `/usr/local/bin/dns-cli interactive` failed (`a password is required`). Law already requires `commands[].path` = `/usr/local/bin/dns-cli`. Emit still copies `$GLOBAL_BIN`. This product still **MUST NOT** rewrite `/etc/sudoers.d`.
- Dest **approval fencing conditions** catalog is an independent requirement: `requirement-approval-fencing-condition`. Dest tables still print and **point**. Dest **Fence** meaning stays `requirement-incorrect-json-format`.
- Dest JSON format is **dest-owned**. Sudoer dest allowlist **MUST** treat `kind` (`type-2-switch` \| `login-hook-elev`) as a **known** key, not unexpected. File-ownership dest-writes `submit_by` **after** format; dest **MUST NOT** convert file-ownership into `kind`. Incident **INC-20260819-001**. **TP-FENCE-03** · **TP-FENCE-04** · **TP-FENCE-05** · **TP-FENCE-06** · **TP-SUDOER-JSON-21** · **TP-CF-REQ-16**. Live dest unknown-key remains **TP-FENCE-07** skip until sibling dest allowlists `kind`.

## [1.11.0] - 2026-08-21

### Added

- Type 0 **test-purpose** `fence-test`: unit test of dest fence functions against a JSON **file location** in a **local test folder** (`stdin` xor `--file PATH` xor `--dir DIR`; `--expect-match` with `--dir`). **No sudo** except wrap chmod/chown of that folder. Does **not** queue. Help lists testers apart from operational inbound. Closed dest list is still **incorrect JSON format** only. Corpus: `tests/fixtures/fence-test/{pass,match}/`. **TP-FENCE-09..15**. Sibling review: `sudoer-cli` 1.15.x.

## [1.10.0] - 2026-08-20

### Added

- Type 0 `test-json-format` dest Fence tester (`stdin` xor `--file`; no queue). Dest `interactive` moves a fence match to **declined** without asking yes/no.
- Specialized law from sibling sudoer-cli (no domain copy): `requirement-shell-script-coding`, `requirement-shell-sudo-command`, `requirement-shell-prompt`, `requirement-shell-temp-file-system`, `requirement-privilege-prevention-set`. Class residual **points**. Type 2 stays open.

## [1.9.7] - 2026-08-19

### Changed

- File-based JSON dest **login-hook `interactive`**, while taking file-ownership: dest **MUST** read original Unix file-ownership, take ownership as the corresponding LPU, review JSON format, and if the JSON is correct dest-write **`submit_by`** (human: submit by) set to that original owner. Type 0 `submit` **MUST NOT** include `submit_by`. Dest **MUST NOT** fence on dest-written `submit_by`. Term **`submit-by`**. Law: **ACT-M4** · **APR-M3** · **REQ-M9**. Mold **`LM-FILE-BASED-JSON-APPROVAL`** 1.14.0. **TP-CF-REQ-15**.
- File-based JSON approval **MUST NOT** fence dest approve on Unix owner. Dest **takes** file-ownership as the corresponding LPU. User SSOT is the JSON field, not the filename token. Dest inbound fence is **incorrect JSON format** only.
- Every requirement prints **§1.1 Human-facing**. Named dest approval-system subclasses (sudoer / nginx-conf / Cloudflare DNS) inherit fence-then-question.
- Extracted **actor / role / subject / submitter / approver** catalog. Software-dev **MUST consider** even if Approver is **None**. **TP-ARSA-01** · **TP-ARSA-02**.
- Software-dev **MUST review** dest fences and convert each dest **Fence** to an independent REQ. Dest tables still print and **point** at those REQs. This product: `requirement-incorrect-json-format`. **TP-FENCE-01** · **TP-FENCE-02**.
- **Local vaults** is the class of every existing vault (account-home). **Global vault** is relative: an ordinary login stores a token or key under an LPU dest. Law **AV-M11**. **TP-AV-08**.

## [1.9.6] - 2026-08-19

### Changed

- File-based JSON approval **user SSOT** is the **JSON username field** (`subject` / `username`), **not** the filename subject token. Dest **MUST NOT** fence when basename subject ≠ JSON field. Type 0 submit self-scope compares the JSON field to `id -un` only. Allocator **MAY** still copy the JSON field into the request-id for audit. Term **`json-username-field`**. Law: **ACT-M8** · **REQ-M9** · **SJ-M5** · **P-M13** · **L-M13**. Mold **`LM-FILE-BASED-JSON-APPROVAL`** 1.12.0. **TP-CF-REQ-14**.

## [1.9.5] - 2026-08-19

### Changed

- After any create or modify of `.bashrc` / `.zshrc` / `.profile` / Fish config, dest **MUST** align **shell-rc file ownership** to the **corresponding user** (that home’s login). Term **`shell-rc-file-ownership`**. Helper **`util_align_rc_owner`**. Law: **APR-M4** · **L-M9**. Skills **`SK-SH-SCRIPT-CODING`** §2.3.4 · **`SK-CREATE-LEAST-PRIVILEGE-SYSTEM-USER`**. Mold **`LM-PATH-AND-SHELL-SUPPORT`** 1.2.0. **TP-CF-APR-07**.

## [1.9.4] - 2026-08-19

### Changed

- **Approval system** superclass: dest **fences first**, **displays** a match in human-facing words, then asks the **approval question** only if clear. File-based JSON dest **MUST** include the **JSON format** fence. Term **`approval-system`**. Mold **`LM-APPROVAL-SYSTEM`** 1.0.0 · **`LM-FILE-BASED-JSON-APPROVAL`** 1.10.0. Law: **ACT-M4** · **ACT-M8** · **APR-M3** · **REQ-M9**. **TP-CF-REQ-13**.

## [1.9.3] - 2026-08-19

### Changed

- Login-hook **`interactive`** asks a **one-off approval question**: **yes** = approve, **no** = reject (Enter = no). No skip / quit. Term **`approval-question`**. Law: **ACT-M4** · **APR-M3**. Mold **`LM-FILE-BASED-JSON-APPROVAL`** 1.9.0 §2.8. **TP-CF-REQ-12**.

## [1.9.2] - 2026-08-19

### Changed

- Login-hook **`interactive`** (corresponding LPU **`dns-adm`**) **takes file-ownership of inbound JSON at the beginning**, then reviews. Queue move still assumes that previous ownership change. Law: **ACT-M4** · **APR-M3** · **L-M13** · **P-M13**. Mold **`LM-FILE-BASED-JSON-APPROVAL`** 1.8.0 §2.8. **TP-CF-REQ-11**.

## [1.9.1] - 2026-08-18

### Fixed

- **INC-20260818-003**: Type 1 `setup` no longer `chown`s dest-inbound `login-hook-elev` JSON to `dns-adm`. Dest **`sudoer-adm`** takes ownership. Sticky inbound (`3773`) only lets the owner (or root) unlink — handing the file to `dns-adm` blocked dest queue move.
- DNS `approve` / `reject` / `interactive` **`chown` to `dns-adm` first**, then move inbound → accepted/declined. CI stub (`CF_TEST_LPU=1`) skips live `chown`. Fail closed if production `chown` fails.

### Changed

- Law: **SJ-M5** / **L-M13** / **P-M13** / **ACT-M6** / **REQ-M9** — queue move assumes a previous ownership change to the approver; submitter/setup **MUST NOT** `chown`. Portable: **`LM-FILE-BASED-JSON-APPROVAL`** 1.5.0 §2.5a; **`LM-SUDOER-JSON-FILE`** 1.7.0 §3.0b; **`LM-THREE-LAYER-PRIVILEGE-MODEL`** 2.13.0; **`LM-LEAST-PRIVILEGE-USER`** 2.6.0. Term `approval-queue-move`. **TP-SUDOER-JSON-18** · **TP-CF-REQ-09**.

## [1.9.0] - 2026-08-18

### Added

- Inbound DNS file-based JSON approval: Type 0 **`submit`**, Type 1 **`approve` / `reject` / `interactive`**. Anyone queues a self-scoped request (`add` / `update` / `remove` / `mode`); **`dns-adm`** re-checks and moves the file. Accept applies dest via vault DNS/mode verbs. No token in the JSON.
- Type 1 **`setup`** creates the public trio `/var/dns-cli/dns-request` (`3773`) + `dns-accepted` / `dns-declined` (`0700`) and an F4 view `${LPU_HOME}/dns-request`. Type 0 **MUST NOT** `mkdir` inbound.
- Suites **TP-CF-REQ-01..08**. **TP-CF-ACTOR-01..05** now prove the routed verbs (help lists them; missing file / `--json interactive` fail closed, not unknown).

## [1.8.2] - 2026-08-18

### Added

- **Submit vs setup door** (SJ-M3 / **P-M11** / **L-M11**): who may `submit-sudoer-request` (Type 0, current login, no sudo, `type-2-switch`) vs who may `setup` (Type 1, password `sudo` / already root). Dest Type 0 self-scope **MUST NOT** apply to `setup` — that check is a blockage, not dest approval.
- Help names the door. Type 0 submit of `login-hook-elev` names both doors. Setup success says dest approval reviews the JSON.
- **TP-SUDOER-JSON-16**: dest Type 0 `self_scope` does not block setup inbound write.
- Type 2 default-vault switch (INC-20260818-001 CAPA 6 / **TP-LPU-03**): unspecified `vault` / `add` / `update` / `remove` / `status` / `show` as a non-`dns-adm` login re-execs `sudo -n -u dns-adm` of the managed global binary. If that sudo is unavailable → `lpu_required` (next: `generate-sudoer-request` then `submit-sudoer-request`, or `--vault-dir` for QA). Specify `--vault-dir` / `CF_VAULT_DIR` does **not** switch.

### Changed

- Law/mold dest split (**SJ-M4** / **P-M12** / **L-M12**): setup/account dest after approve is **`/etc/sudoers.d/dns-cli-dns-adm`**. Type 0 switch dest is **`/etc/sudoers.d/dns-cli-<user>`**. F6 is **`/etc/dns-adm/sudoers`**. Portable: **`LM-SUDOER-JSON-FILE`** 1.6.0 §3.4c; **`LM-THREE-LAYER-PRIVILEGE-MODEL`** 2.12.0; **`LM-LEAST-PRIVILEGE-USER`** 2.5.0; **`LM-FILE-BASED-JSON-APPROVAL-SUBMITTER`** 1.3.0. **TP-SUDOER-JSON-17**.
- Skills: **`SK-CREATE-SUDOERS-FILE`** S18 dest split.

## [1.8.1] - 2026-08-18

### Fixed

- Type 1 `setup` writes `login-hook-elev` JSON **into dest inbound** (dest request-id grammar). It does **not** call dest Type 0 `add-sudoer-request`. Dest approval reviews the file; dest Type 0 self-scope is a blockage, not dest approval (INC-20260818-002).
- Setup WARN on queue fail no longer says “until approved” when inbound was not written.

## [1.8.0] - 2026-08-18

### Changed

- Type 2 default vault dest is **`${SYSTEM_USER_HOME}/.local/vaults/dns-cli/`** (LPU F3 home + app child). Setup `mkdir`s that parent and child (`0700`). **MUST NOT** hardcode `/etc/dns-adm/vault/`.
- Unspecified vault I/O no longer uses the invoking user’s XDG tree. No specify + no `dns-adm` → `lpu_missing`.
- Type 0 `--vault-dir` / `CF_VAULT_DIR` remain the QA specify path (MAY be the invoking user’s `~/.local/vaults/dns-cli/`).
- Portable law: **`LM-APPLICATION-LOCAL-VAULT`** 1.2.0; F5 dest family on **`SK-CREATE-LEAST-PRIVILEGE-SYSTEM-USER`**.

### Added

- **TP-AV-07**: no specify + no LPU → `lpu_missing`.

## [1.7.0] - 2026-08-18

### Added

- Two JSON sudoer **kinds**, split by field `kind`:
  - **`type-2-switch`**: current login (example `leolio`) may run `dns-cli` as `dns-adm`. Type 0 `generate-sudoer-request` / `submit-sudoer-request`.
  - **`login-hook-elev`**: `dns-adm` may `sudo -n /usr/local/bin/dns-cli interactive`. Verb-bound; not whole-CLI-as-root.
- Type 1 **`setup`** auto-queues `login-hook-elev` when sibling `sudoer-cli` + `sudoer-adm` + inbound exist; skips when missing (setup still succeeds). Does not write `/etc/sudoers.d`.
- `generate-sudoer-request --kind type-2-switch|login-hook-elev` for the independent generate dest.
- Terminology: `sudoer-request-kind`, `type-2-switch-sudoer-request`, `login-hook-sudoer-request`, `automatic-login-hook-sudoer-submit`.
- Suites **TP-SUDOER-JSON-10..15**.

### Changed

- Type 0 `submit-sudoer-request` refuses `login-hook-elev` (that grant is setup-time only).
- JSON grant bodies always emit `kind`. Missing `kind` on a `runas=dns-adm` input is still treated as `type-2-switch`.

## [1.6.0] - 2026-08-18

### Added

- Type 0 **`generate-sudoer-request`**: write a verified JSON sudoer grant (runas `dns-adm`, path `/usr/local/bin/dns-cli`, empty args) to an invoking-user-readable dest. Does not write inbound or `/etc`.
- Type 0 **`submit-sudoer-request`**: detect sibling `sudoer-cli` + inbound; queue that JSON. Does not `mkdir` inbound or write `/etc/sudoers.d`.
- Law **`requirement-sudoer-json-file`** 1.0.0. Mold **`LM-FILE-BASED-JSON-APPROVAL-SUBMITTER`**. Three-layer mold 2.9.0 (generate/submit are not sudoers-manager extras).
- Flags `--allow-test-local`, `--add`, `--update` for the submitter path.
- Suites **TP-SUDOER-JSON-01..03/08** and **TP-PRIV-05..08**.
- Dual-mention / role-table gates: **CL-CLI-DUAL-MENTION**; **TP-CLI-14**; **TP-PRIV-09** / **TP-SUDOER-JSON-09**; **TP-CF-ACTOR-07**.
- **CI-M1a:** every verb (and every `vault` store subcommand) has a complete `dns-cli …` invocation sample on its topic-owner REQ. **TP-CLI-15**.
- Shipped `util_*` helpers have fenced `sh` examples on their topic-owner REQs (and owner law molds). Map: **`LM-MODULAR-FUNCTION-DESIGN`** §3.2.

## [1.5.0] - 2026-08-18

### Added

- Type 1 **`setup`**: create Linux user `dns-adm`, F3 home (prefer `/etc/dns-adm`), F5 vault dir `0700`, F6 dest `/etc/dns-adm/sudoers` `0440` (visudo-check; backup under `/etc/sudoer-backup/`). Re-run heals. Login-hook rc heal on the new home.
- Type 1 **`remove-lpu`**: F7 teardown (`userdel -r`); confirm or `--force`. Absent account is success no-op. Type 0 `uninstall` still does not remove the account.
- Type 0 **`print-sudoers`**: emit Table A fragment to stdout (or a user-writable path). Does **not** write dest.

### Fixed

- `install` honesty line now points at `sudo dns-cli setup` (no longer says setup is absent).

## [1.4.2] - 2026-08-18

### Fixed

- `install` / `help` stay honest: placing the CLI (including `sudo dns-cli install`) does **not** create Linux user `dns-adm`. That is Type 1 `setup` (still Gap). Incident **INC-20260818-001**.

## [1.4.1] - 2026-08-18

### Fixed

- Interactive helpers and vault confirm gates consume the `TTY` SSOT measured in `app_main` (no live `[ -t` retest inside `prompt_*`).
- Requirement Implementation Notes aligned to ship unit **1.4.1** (vault v2 / stored mode Implemented; inbound and LPU dest remain Gap).
- Dispatcher comment leftover `cf-cli` renamed to `dns-cli`.

## [1.4.0] - 2026-08-17

### Added (ship unit 1.4.0)

- Approver rc heal: when interactive and `id -un` is `dns-adm`, ensure `~/.bashrc` has the login hook; if `~/.profile` is missing, create one that sources `.bashrc`.

### Fixed

- Heal rewrites `.bashrc` via `mktemp` (not a predictable sidecar), preserves an existing rc mode, and treats the hook as present only when both BEGIN and END markers exist.

### Added (law)

- **`requirement-dns-approver`** **1.0.0**: approver is `dns-adm`; interactive hook after login; heal `.bashrc` / create `.profile`. **TP-CF-APR-01..06**. Mold **LM-ACTOR-TABLE** 1.1.0.
- **Actor table** `requirement-dns-actor-table` **1.0.1** (Gap): **anyone** may `submit`; **`dns-adm`** approves (no `dns-apr`); login-time `interactive` hook on `dns-adm`. README table + procedure. **TP-CF-ACTOR-01..06**.

## [1.3.0] - 2026-08-17

### Changed (ship unit 1.3.0)

- Product renamed **dns-cli** (`src/dns-cli`, `APP_NAME=dns-cli`). LPU name in law is **dns-adm** (default dest `/etc/dns-adm/vault/`; host create still Gap). Workspace folder may still be named `cf-cli`.
- `vault account` / `vault zone` **add** (and set/modify/input with a new `--token-file`) **probes** `_test_<UTC timestamp>` (create A `203.0.113.10`, then delete). Fail `token_probe_failed` if the token cannot write. Probe label is not stored.

### Changed (docs)

- Product `README.md` **1.2.0**: file-based JSON approval, four DNS request samples (no token field), non-round-robin vs round-robin, stay-honest Gap on submit/approve.
- Public-surface token leak review: `skill-file-leaks-check` **C5**, `skill-product-review` §2.6, commit-check / write-readme / write-review compose. Lesson **L-TOKEN-PUB-01**.

### Added (ship unit 1.2.0)

- v2 vault: `accounts/<domain-id>/` slots, `index.json`, required `user_id`, subdomain `{label, mode}`.
- `vault account` / `vault zone` **add / list / modify / remove / default / show**; list JSON is the test surface (no token).
- `vault subdomain modify` / `mode`; default **non-round-robin**; round-robin `add` appends a distinct IPv4; switch locked when `ipv4_count` ≥ 2.
- Suites **TP-CF-VAULT-18..33** and **TP-CF-MODE-01..08**.

### Added (law)

- Live Type 0 specify verify as the invoking user (`crms.hk` / `leolio`): D-M15/D-M16. Not `dns-adm`. Default suite stays offline.
- **DNS request types** `requirement-cloudflare-dns-request` **1.0.0** (Gap): exactly four inbound actions — `add`, `update`, `remove`, `mode` — with eight complete JSON examples (non-RR and RR variants).
- Glossary: `cloudflare-dns-request`, `cloudflare-dns-request-type`, `cloudflare-dns-request-basename`.
- Molds: **`LM-CLOUDFLARE-DNS-REQUEST`**, **`PM-CLOUDFLARE-DNS-REQUEST-TEST-PLAN`**, **`CL-CLOUDFLARE-DNS-REQUEST`**.

### Added (law, earlier)

- **Vault model §2.0** on `requirement-cloudflare-vault` **2.2.0**: `dns-adm` holds many domains and many Cloudflare user-ids; **1 : 1** domain↔token and domain↔`user_id`; **1 : N** domain↔subdomains.
- **Cloudflare API capability** `requirement-cloudflare-api` — Bearer token, envelope, zone GET, DNS A CRUD (PUT not PATCH).
- Glossary family: `cloudflare-api`, `cloudflare-api-envelope`, `cloudflare-api-token`, `cloudflare-api-key`, `cloudflare-zone`, `cloudflare-zone-id`, `cloudflare-account-id`, `cloudflare-user-id`, `cloudflare-dns-record`, `cloudflare-dns-record-id`.
- **Vault zone-slot CRUD** on `requirement-cloudflare-vault` **2.4.0**: `vault account` / alias `vault zone` **add / list / modify / remove**; `vault subdomain modify`; `--json` **list** is the test verification surface (no token).
- **A-record mode** `requirement-cloudflare-dns-mode` **1.0.0** (Gap): default **non-round-robin** (one IPv4 per subdomain); optional **round-robin** (many distinct IPv4 A rows); switch only when `ipv4_count` is 0 or 1; IPv4 only / no AAAA.
- Glossary family: `cloudflare-dns-mode`, `cloudflare-dns-non-round-robin-mode`, `cloudflare-dns-round-robin-mode`, `cloudflare-dns-mode-switch`, `subdomain-ipv4-count`.
- Molds: **`LM-CLOUDFLARE-DNS-MODE`**, **`PM-CLOUDFLARE-DNS-MODE-TEST-PLAN`**, **`CL-CLOUDFLARE-DNS-MODE`**.

### Changed (law — ship unit still 1.1.0)

- **LPU `dns-adm`:** new `requirement-least-privilege-user` + `requirement-three-layer-privilege-model`. Type 1 `setup` / `remove-lpu`; Type 0 `print-sudoers`; Type 2 default-vault DNS. Host create is **Gap**.
- **Multi-account vault:** each **domain-id** (apex domain name) is one Cloudflare API account with its own token; each domain-id **may** hold many subdomains (`requirement-cloudflare-vault` 2.0.0).
- Default vault dest is `/etc/dns-adm/vault/` (not the invoking user’s XDG tree). `--vault-dir` remains the QA specify path.
- Domain catalog **2.1.0** consumes mode law (no longer “always single A”). Vault **2.4.0** stores subdomain objects `{label, mode}` and requires zone-slot **add / list / modify / remove** (`vault account` / alias `vault zone`) so tests verify via **list** JSON. API **1.2.0** forbids AAAA and forbids mapping `vault zone add` to `POST /zones`. External-IPv4 **1.1.0** rejects IPv6 literals.

## [1.1.0] - 2026-08-16

### Added

- Product rename to **dns-cli** (`src/dns-cli`, `APP_NAME=dns-cli`, forge `cloudgen/dns-cli`).
- Cloudflare vault (`vault set|show|clear|subdomain`) at XDG config, 0700/0600, token file split.
- DNS verbs `add` / `update` / `remove` / `status` — one A record per FQDN; public IPv4 from ipinfo.io (`--ip` override).
- Suites **TP-CF-VAULT-01..07**, **TP-CF-DNS-01..07**, and **TP-CF-IP-01..04** (offline curl stub).
- Domain SSOT `requirement-domain-cloudflare-dns` and vault law `requirement-cloudflare-vault`.
- `ip` — print public IPv4 from ipinfo (or `--ip`) without vault or Cloudflare (QA).
- Vault suite **TP-CF-VAULT-08..17** (clear, subdomain add/list, schema, env vs set rewrite, uninstall).
- `requirement-external-ipv4` — public IPv4 lookup SSOT (`ip` verb; domain catalog consumes it).
- `requirement-application-local-vault` — declare + specify the local application vault (`--vault-dir` / `CF_VAULT_DIR`; **TP-AV-01..06**).

### Fixed

- `vault subdomain add` concatenated the last stored label (`home` + `office` → `homeoffice`) because `$(…)` strips trailing newlines.
- `vault set --zone-id` (and peer flags) now rewrite stored fields (V-M7 explicit set).
- Leftover `APP_NAME:=cli-template` defaults in install/uninstall/where-is-me/about.

### Changed

- Bootstrap chain: this tree is hop 1 (B); origin A remains cli-template.
- `out_die_code` for stable JSON error codes.

## [1.0.0] - 2026-08-13

### Added

- **cli-template** as a Type 0 template bootstrap origin (no live parent).
- Type 0 local self-managed CLI: `install`, `uninstall`, `where-is-me`, `version`, `about`, `help`.
- Empty argv **Type N** help (local-only; no curl|sh).
- Suite **TP-CLI-01..13** and **TP-LC-01..10**.
- Law: class software-dev + bootstrap-chain (this product is hop 0) + Type 0 shell family.

### Removed (not this origin’s surfaces)

- Domain verbs: `backup`, `restore`
- Sudoers-file verbs: `print-sudoers`, `print-sudoers-install-script`, `remove-project-sudoers`
- Durable `/var/backup` deposit, retention, restore dest whitelist
- `requirement-domain-folder-backup`, `requirement-folder-archive-backup*`, `requirement-three-layer-privilege-model`
- Product incidents INC-20260811-001 (sudoers grantee) and INC-20260812-001 (restore dest) — remain on sibling **folder-backup**
- Domain suite **TP-FOLDER-BACKUP-***

### Changed

- Identity SSOT: `APP_NAME=cli-template`, `REPO_NAME=cli-template`, `VERSION=1.0.0` (working names `hostmanaged` / `climanaged` dropped so this is not read as host-OS setup)
- Live parent hops **retired** — this product is hop 0; **selfmanaged** and **folder-backup** are not origins
- Ship unit path: `src/cli-template`
- About: Type 0 diagnostics only (no backup/sudoers fields)
- **No domain SSOT** and **no `setup` verb** — Type 0 template only (`version`, `install`, `about`, `help`)
- Install **locations unchanged**: local `${USER_BIN}` **and** global `${GLOBAL_BIN}` (`install --global` / root). “Local-only” still means **no online channel**, not “user-bin only.”
- Forge identity: repository-user **cloudgen**, author-email **wongcf22@gmail.com**, project-repository **cloudgen/cli-template**, product version **1.0.0**
