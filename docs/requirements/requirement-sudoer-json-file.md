**file**: docs/requirements/requirement-sudoer-json-file.md  
**Status**: Active (Version 1.9.0) — dest Fence row points at `requirement-incorrect-json-format`  
**Area**: architecture  
**Key**: `requirement-sudoer-json-file`  
**Optional RQ-ID**: `RQ-SUDOER-JSON-FILE`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **product Single Source of Truth** for the **JSON-type sudoer file**: the machine encoding of **two** elevation grants that share one closed schema and are split by field **`kind`**.

| Kind | Subject (`username`) | `runas` | `args` | Who queues it |
|------|----------------------|---------|--------|----------------|
| **`type-2-switch`** | Invoking login (example `leolio`) | `dns-adm` | `[]` | Type 0 `generate-sudoer-request` / `submit-sudoer-request` (self-scope) |
| **`login-hook-elev`** | LPU `dns-adm` | `root` | `["interactive"]` | Type 1 `setup` **automatically** when sibling `sudoer-cli` + `sudoer-adm` + inbound exist. Type 0 submit **MUST** refuse this kind |

They are **not** the same dest, **not** the same subject, and **MUST NOT** be collapsed. The Type 2 switch lets the current user run `sudo -u dns-adm dns-cli …`. The login-hook grant lets the rc hook run `sudo -n /usr/local/bin/dns-cli interactive`.

dns-cli **is** a **sudoer-approval-submitter**. It **is not** a sudoers-manager. Sibling dest (`sudoer-cli` / `sudoer-adm`) owns inbound, approve, and any write under `/etc/sudoers.d`. This product **MUST NOT** `mkdir` that inbound, approve, or write `/etc/sudoers.d`.

Both grants **MUST** name only the project command **`dns-cli`**. They **MUST NOT** allowlist other shell or OS tools. They **MUST NOT** grant Type 1 `setup` / `remove-lpu` (password `sudo` stays the approval) or Type 0 verbs. `login-hook-elev` **MUST** stay verb-bound to `interactive` — whole-CLI-as-root is forbidden.

This file does **not** own:

| Concern | Owner |
|---------|--------|
| Type 0/1/2 map, `print-sudoers` text, F6 dest `/etc/dns-adm/sudoers`, submit **workflow** | `requirement-three-layer-privilege-model` |
| Domain DNS catalog / inbound DNS JSON | `requirement-domain-cloudflare-dns` · `requirement-cloudflare-dns-request` |
| Dispatcher / help rows | `requirement-shell-cli-interface` |

Queued **basename** allocation remains sibling-owned. This requirement owns **command identity and JSON body shape**.

DNS inbound (`submit` a Cloudflare request) **is a different machine**. Do not mix those JSON types.

### 1.1 Human-facing

**In one sentence:** You write a **JSON grant** (switch to `dns-adm`, or the login-hook review grant). Sibling **`sudoer-cli`** approves it. dns-cli **never** writes `/etc/sudoers.d`.

| Box | Meaning | Example |
|-----|---------|---------|
| You | Generate / submit a self-scoped switch JSON | `dns-cli generate-sudoer-request` |
| Host admin | Setup queues the hook grant | `sudo dns-cli setup` |
| Sibling dest | `sudoer-adm` reviews | Not this product |

| Includes | Excludes |
|----------|----------|
| Two `kind`s + command identity `dns-cli` only | OS tools (`cp`, `mkdir`, shells) |
| Queue into sibling inbound | Writing `/etc/sudoers.d` |

| Surface | What you open | What for |
|---------|---------------|----------|
| Generated JSON | `~/.config/dns-cli/sudoer-request-*.json` | Readable without sudo |
| `dns-cli submit-sudoer-request` | Command | Queue type-2-switch |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Ask to run as `dns-adm` later | File a grant; wait for sibling approve | `dns-cli submit-sudoer-request` |

---

## 2. Core Rules / Requirements (Mandatory)

### 2.0 Role table (print sudoer file + JSON submit)

This product runs **two** Type 0 sudoer surfaces **and** one Type 1 auto-queue. The Type 2 switch shares Table A (`dns-cli` as `dns-adm`). The login-hook grant is a **different** dual (`dns-adm` as `root`, `interactive` only). They **MUST NOT** be collapsed into the DNS actor table (`requirement-dns-actor-table`).

| Surface | Verb | Artifact | Dest this product may write |
|---------|------|----------|-----------------------------|
| **Print sudoer file** | `print-sudoers` | `sudoers(5)` text (Table A / F6 dual) | stdout, or one user-writable path. **MUST NOT** write F6 dest or `/etc/sudoers.d` |
| **JSON sudoer file (Type 2 switch)** | `generate-sudoer-request` (default `kind=type-2-switch`) | closed-schema JSON, `kind=type-2-switch` | invoking-user-readable path (default `${HOME}/.config/dns-cli/sudoer-request-<user>.json`) |
| **JSON sudoer file (login hook)** | `generate-sudoer-request --kind login-hook-elev` | closed-schema JSON, `kind=login-hook-elev` | invoking-user-readable path (default `${HOME}/.config/dns-cli/sudoer-request-dns-adm-login-hook.json`) |
| **JSON submit (Type 2 switch)** | `submit-sudoer-request` | `type-2-switch` body only | none — sibling allocator writes inbound |
| **JSON auto-submit (login hook)** | Type 1 `setup` (when sibling dest exists) | `login-hook-elev` body | none — sibling allocator writes inbound |

**SJ-M1.** Product law **MUST** publish this role table. Roles **MUST NOT** be collapsed.

| Role | Who | Type | May | Must not |
|------|-----|------|-----|----------|
| **Printer** | Any login (`id -un`) | **0** | `print-sudoers` — print the sudoer **file** (Table A text) to stdout or a user-writable path | Write F6 dest `/etc/dns-adm/sudoers`; write `/etc/sudoers.d`; write `/etc/passwd`; treat CLI `--json` status as the sudoer file |
| **Generator** | Same login | **0** | `generate-sudoer-request` — write the JSON sudoer file to a dest the invoker can `cat` without sudo | Write inbound; write `/etc`; `mkdir` sibling inbound |
| **Submitter** | Same login (self-scope) | **0** | `submit-sudoer-request` — queue a **`type-2-switch`** JSON to sibling `sudoer-cli`. **No sudo.** | Submit `login-hook-elev`; submit for another login; approve; invent the queued basename; write `/etc/sudoers.d`; treat dest Type 0 self-scope as dest approval |
| **Subject (switch)** | Same person as the Type 0 submitter | — | Appear as `type-2-switch` `username` | Be another login; be `dns-adm` on a Type 0 submit |
| **Subject (hook)** | LPU `dns-adm` | — | Appear as `login-hook-elev` `username` | Be a human login |
| **Hook auto-submitter** | Host admin via `sudo dns-cli setup` | **1** | When sibling CLI + `sudoer-adm` + inbound exist, **write** `login-hook-elev` into inbound (dest request-id grammar). Missing sibling → skip (setup still succeeds). **MUST NOT** `mkdir` inbound. **MUST NOT** `chown` inbound. **MUST NOT** call dest Type 0 `add-sudoer-request` | Fail setup solely because sibling is absent; write `/etc/sudoers.d`; `chown` inbound to `dns-adm` or JSON `username`; treat this as Type 0 `submit-sudoer-request`; apply dest Type 0 self-scope (`username` == `id -un`) to setup |
| **Allocator** | Sibling `sudoer-cli` Type 0 path | **0** | Allocate basename for Type 0 `submit-sudoer-request` | Be Type 1 `setup`; apply dest Type 0 self-scope to hook auto-queue |
| **Sibling approver** | LPU **`sudoer-adm`** (not `dns-adm`) | **1** | Take ownership of inbound JSON; **then** move inbound → approved/rejected; on accept, write `/etc/sudoers.d/dns-cli-<user>` | Be invented or operated by this product |
| **F6 installer** | Host admin via `sudo dns-cli setup` | **1** | Install the **printed** sudoer file to `/etc/dns-adm/sudoers` after `visudo -c` | Write `/etc/sudoers.d` from this product |
| **Type 2 operator** | LPU **`dns-adm`** | **2** | Run the managed binary after a live grant | Approve sudoer JSON; print/submit as a dest writer |

**Account map**

| Role | Account |
|------|---------|
| Printer / generator / Type 0 submitter / switch subject | Invoking login (`id -un`) |
| Type 2 operator + hook subject | `dns-adm` |
| Sibling approver | `sudoer-adm` |
| Allocator (Type 0 submit) | Sibling `sudoer-cli` Type 0 `add-sudoer-request` |
| Inbound writer (Type 1 hook) | This product’s `setup` (dest request-id grammar) |
| F6 installer + hook auto-submitter | euid 0 / password `sudo` |
| Root session | euid 0 — may `setup` (write hook inbound as `dns-adm`); Type 0 **MUST NOT** submit a `type-2-switch` body whose `username` is someone else |

**SJ-M2.** `dns-adm` **is not** `sudoer-adm`. DNS inbound approve (`requirement-dns-actor-table`) **is not** this table.

**SJ-M3. Submit vs setup door (sacred).** Agents and operators **MUST** keep these doors apart. Dest Type 0 self-scope is **not** dest approval and **MUST NOT** be applied to `setup`.

**SJ-M4. Three dests (sacred).** JSON `username` keys the sibling dest after approve. **MUST NOT** collapse these with each other or with F6.

| Kind / dual | JSON `username` | Installed dest after sibling approve | What it allows |
|-------------|-----------------|--------------------------------------|----------------|
| **`type-2-switch`** | Invoker (`id -un`, example `leolio`) | `/etc/sudoers.d/dns-cli-<user>` (example `dns-cli-leolio`) | `sudo -n -u dns-adm /usr/local/bin/dns-cli …` |
| **`login-hook-elev`** | LPU `dns-adm` | `/etc/sudoers.d/dns-cli-dns-adm` | `sudo -n /usr/local/bin/dns-cli interactive` |
| **F6 group dual** (not JSON) | n/a — `%sudo` | `/etc/dns-adm/sudoers` (Type 1 `setup` / `print-sudoers`) | `%sudo ALL=(dns-adm) NOPASSWD: /usr/local/bin/dns-cli` |

Type 1 `setup` / account create queues **`login-hook-elev`**. After approve the dest is **`dns-cli-dns-adm`**. **MUST NOT** describe setup as writing `dns-cli-leolio`.

Type 0 `submit-sudoer-request` queues **`type-2-switch`**. After approve the dest is **`dns-cli-<invoker>`**. **MUST NOT** describe that verb as writing `dns-cli-dns-adm`.

This product **MUST NOT** write `/etc/sudoers.d`. Sibling dest write is dest Type 1. Portable: **`LM-SUDOER-JSON-FILE`** §3.4c.

**SJ-M5. Queue ownership (sacred).** Type 1 `setup` and Type 0 submit **MUST NOT** `chown` dest inbound JSON. Dest **`sudoer-adm`** takes ownership. The JSON username field is **not** file-ownership. Dest **MUST** take file-ownership when run as **`sudoer-adm`**, then move. Incident **INC-20260818-003**.

**Dest approval fencing conditions (closed).** Dest `approve` / `reject` / review **MUST** fail closed on inbound **only** for **incorrect JSON format**. Dest **MUST NOT** add extra fencing conditions. Catalog owner: `requirement-approval-fencing-condition`. Fence meaning: `requirement-incorrect-json-format`.

| Condition | Dest approve / reject / review |
|-----------|--------------------------------|
| **Incorrect JSON format** | **Fence** — fail closed. Independent REQ: `requirement-incorrect-json-format` |
| File-ownership | **MUST NOT** fence on file-ownership — take ownership as `sudoer-adm` |
| Who submitted / dest Type 0 self-scope | **MUST NOT** fence |
| JSON `username` ≠ dest LPU | **MUST NOT** fence |
| Filename subject token ≠ JSON `username` | **MUST NOT** fence — user SSOT is the JSON field |
| Dest-written `submit_by` / missing `submit_by` | **MUST NOT** fence — dest interactive writes it after format check |
| `submit_app` ≠ dest `APP_NAME` / `submit_version` ≠ dest `VERSION` | **MUST NOT** fence — Type 0 stamps live Config; sibling submitters and mixed versions are dest-legal JSON |

**Incorrect JSON format** includes: not a regular file; not one parseable JSON object; dest-owned closed-schema fail; field types/enums invalid; basename grammar fail; basename **action** ≠ JSON `action`. Dest-owned sudoer allowlist **MUST** include `kind` (`type-2-switch` \| `login-hook-elev`) as a **known** key. Dest **MUST NOT** treat dest-legal `kind` as unexpected. File-ownership dest-writes `submit_by` after format; dest **MUST NOT** convert file-ownership into `kind`. Dest **MUST NOT** take the user from the filename; user SSOT is JSON `username`. Type 0 submit self-scope and Type 1 **authz** are **not** dest inbound-file fences.

| Door | Who | How | What | Dest Type 0 `username` == `id -un` |
|------|-----|-----|------|-------------------------------------|
| **`submit-sudoer-request`** | Current login | Type 0. **No sudo.** | `type-2-switch` only. `username` = `id -un`. Dest Type 0 submit allocates inbound. | Applies (human files for self) |
| **`setup`** | Host admin | Type 1. **Password `sudo` / already root.** | Create `dns-adm`. Write `login-hook-elev` into inbound. | **MUST NOT** apply. That check is a **blockage**, not a safety net. Dest approval reviews the JSON and does **not** test who submitted. |

**When Type 0 may print / generate / submit** — all must hold:

1. Invoker is a login user.  
2. **Print:** dest is stdout or an absolute user-writable path ≠ F6 dest ≠ `/etc/sudoers.d`.  
3. **Generate:** dest is an absolute user-writable path ≠ F6 dest ≠ `/etc` ≠ inbound. Default `kind` is `type-2-switch`. `--kind login-hook-elev` writes the hook fixture only (does not queue).  
4. **Type 0 submit:** self-scope (`username` = `id -un`); body is **`kind=type-2-switch`** and matches §2.2–2.3. Sibling CLI + `sudoer-adm` + inbound exist and inbound is writable. Type 0 **MUST NOT** `mkdir` inbound. Type 0 **MUST** refuse `login-hook-elev`.  
5. **Type 1 hook auto-submit:** only from `setup`; body is **`kind=login-hook-elev`**; subject is `dns-adm`. **MUST** write inbound with dest request-id grammar. **MUST NOT** `chown` the inbound file (SJ-M5). **MUST NOT** call dest Type 0 `add-sudoer-request` / `update-sudoer-request`. Missing sibling → skip. Present sibling + unwritable inbound → skip + warn (do not `mkdir`).  
6. Type 0 submit: sibling dest allocator owns the queued basename. Type 1 setup: this product writes dest-grammar basename (SJ-M3).

**Not a print / not a Type 0 submit:** wanting `/etc/sudoers.d` written immediately; `print-sudoers` of the F6 dest path; DNS `submit`; `setup` as a Type 0 substitute for print; Type 0 on-behalf-of JSON; Type 0 submit of `login-hook-elev`.

### 2.1 What a JSON sudoer file is

1. A JSON sudoer file is a **closed-schema object** that states: who may elevate, which **product** the grant is for, add vs update, and a **commands** list.  
2. It is **not** `sudoers(5)` text. It is **not** this product’s `--json` CLI status. It is **not** a Cloudflare DNS request.  
3. Sibling approval software **MAY** convert a text dual into this JSON. Conversion **MUST NOT** invent OS-tool commands.  
4. Pretty-printed and compact JSON are the **same** grant.  
5. `print-sudoers` text (`%sudo ALL=(dns-adm) NOPASSWD: /usr/local/bin/dns-cli` → F6 dest) is a **group** dual for Type 1 `setup`. The **`type-2-switch`** JSON is the **per-user** dual queued to the sibling (`username` = invoker, `runas` = `dns-adm`). The **`login-hook-elev`** JSON is a **third** dual (`username` = `dns-adm`, `runas` = `root`, args `interactive`). Same **binary**; three dests; two JSON kinds.

### 2.2 Command identity — `dns-cli` only (sacred)

| Rule | Detail |
|------|--------|
| **Identity** | Every `commands[].path` **MUST** be `/usr/local/bin/dns-cli` |
| **Basename** | `basename(path)` **MUST** equal `dns-cli` |
| **Service** | JSON `service` **MUST** equal `dns-cli` |
| **One program** | **MUST NOT** list any other executable |
| **No local binary** | **MUST NOT** elevate `${HOME}/.local/bin/dns-cli` |
| **No OS tools** | **MUST NOT** list `cp`, `mkdir`, `install`, `chmod`, `tar`, `rm`, `ln`, `mv`, `chown`, `dd`, or shells |
| **No ALL** | **MUST NOT** use `ALL`, `NOPASSWD: ALL`, or an empty command set (empty **args** is allowed only on `type-2-switch`; empty `commands` is not) |
| **Runas (by kind)** | `type-2-switch` **MUST** be `dns-adm`. `login-hook-elev` **MUST** be `root`. **MUST NOT** be `ALL`. Whole-CLI-as-root is forbidden |

**Why empty `args` on `type-2-switch`:** Table A is the whole managed binary as `dns-adm` so `sudo -u dns-adm dns-cli --json vault …` still matches. Verb-bound `dns-cli vault` would miss global flags before the verb.

**Why verb-bound `interactive` on `login-hook-elev`:** `runas` is `root` so the hook’s `sudo -n` matches. Granting the whole CLI as root would include `setup` / `remove-lpu`. Those stay password `sudo`.

### 2.3 Closed schema (normative)

| Field | Type | Required | Rule |
|-------|------|----------|------|
| `schema_version` | integer | yes | `1` |
| `kind` | string | yes on emit | `type-2-switch` or `login-hook-elev`. Missing on input: treat as `type-2-switch` **only if** `runas` is `dns-adm` and `args` is `[]`; else fail closed |
| `purpose` | string | yes | Human; no secrets / tokens |
| `username` | string | yes | `type-2-switch`: invoking login (self-scope). `login-hook-elev`: `dns-adm`. Never `ALL` |
| `service` | string | yes | `dns-cli` |
| `action` | string | yes | `add` or `update` |
| `commands` | array | yes | Exactly one object |
| `commands[].runas` | string | yes | `type-2-switch`: `dns-adm`. `login-hook-elev`: `root` |
| `commands[].tags` | array | yes | `["NOPASSWD"]` |
| `commands[].path` | string | yes | `/usr/local/bin/dns-cli` |
| `commands[].args` | array | yes | `type-2-switch`: `[]`. `login-hook-elev`: `["interactive"]` |

**MUST NOT** include `token`, `CF_API_TOKEN`, `setup`, `remove-lpu`, `install`, or OS-tool paths. `kind` is **not** `action` and **not** a DNS request type.

### 2.4 Filename grammar (queued artifact — sibling allocator)

This product **MUST NOT** invent the dest basename. Sibling grammar (informative):

```text
sudoer-{{YYYYMMDD}}-dns-cli-{{username}}-{{action}}-{{n}}.json
```

**Worked sample (add):** `sudoer-20260818-dns-cli-alice-add-1.json`  
**Worked sample (update):** `sudoer-20260818-dns-cli-alice-update-1.json`

### 2.5 Complete sample bodies

Normative **`type-2-switch` add** JSON:

```json
{
  "schema_version": 1,
  "kind": "type-2-switch",
  "purpose": "Allow alice to run dns-cli as dns-adm.",
  "username": "alice",
  "service": "dns-cli",
  "action": "add",
  "commands": [
    {
      "runas": "dns-adm",
      "tags": ["NOPASSWD"],
      "path": "/usr/local/bin/dns-cli",
      "args": []
    }
  ]
}
```

Normative **`type-2-switch` update** JSON: same object; `"action": "update"` only.

Normative **`login-hook-elev` add** JSON:

```json
{
  "schema_version": 1,
  "kind": "login-hook-elev",
  "purpose": "Allow dns-adm login hook to run dns-cli interactive via sudo -n.",
  "username": "dns-adm",
  "service": "dns-cli",
  "action": "add",
  "commands": [
    {
      "runas": "root",
      "tags": ["NOPASSWD"],
      "path": "/usr/local/bin/dns-cli",
      "args": ["interactive"]
    }
  ]
}
```

Normative **`login-hook-elev` update** JSON: same object; `"action": "update"` only.

Equivalent **text dual** of the **per-user Type 2 switch** (sibling dest after approve — not F6):

```text
# Purpose: Allow alice to run dns-cli as dns-adm.
alice ALL=(dns-adm) NOPASSWD: /usr/local/bin/dns-cli
```

Equivalent **text dual** of the **login-hook** grant (sibling dest `/etc/sudoers.d/dns-cli-dns-adm` after approve — not F6):

```text
# Purpose: Allow dns-adm login hook to run dns-cli interactive via sudo -n.
dns-adm ALL=(root) NOPASSWD: /usr/local/bin/dns-cli interactive
```

F6 text dual (Type 1 `setup` / `print-sudoers`; **not** either JSON dest):

```text
%sudo ALL=(dns-adm) NOPASSWD: /usr/local/bin/dns-cli
```

**Withdrawn:** `"path": "/usr/bin/mkdir"` · `login-hook-elev` with `args: []` · `type-2-switch` with `runas: "root"` · `args: ["setup"]`.

### 2.6 Generate / submit honesty

1. `generate-sudoer-request` **MUST** write JSON to an invoking-user-readable dest **without** submit, inbound, or `/etc`. Default dest: `${HOME}/.config/dns-cli/sudoer-request-<user>.json` for `type-2-switch`; `${HOME}/.config/dns-cli/sudoer-request-dns-adm-login-hook.json` for `login-hook-elev`. Path operand overrides. **MUST NOT** write `/etc`, `/etc/sudoers.d`, or `/var/sudoer-cli/…`. Default `--kind` is `type-2-switch`.  
2. `submit-sudoer-request` **MUST** detect `sudoer-cli` + `sudoer-adm` + inbound; fail closed if missing (next: `sudo sudoer-cli setup`). **MUST NOT** `mkdir` inbound. **MUST** refuse `kind=login-hook-elev` and any body whose `username` ≠ `id -un`.  
3. Prefer a file from generate. No file → compact **`type-2-switch`** body for the invoker.  
4. Default action for Type 0 submit: **update** when `/etc/sudoers.d/dns-cli-<user>` exists; else **add**. `--add` / `--update` override. F6 dest `/etc/dns-adm/sudoers` **MUST NOT** count as that probe.  
5. **MUST** fail closed if an input file’s `commands` contain a forbidden path, `service` ≠ `dns-cli`, a `type-2-switch` with `runas` ≠ `dns-adm`, or a `login-hook-elev` with `runas` ≠ `root` or `args` ≠ `["interactive"]`.  
6. When inbound `${request_id}` is readable, **MUST** fail closed if `service`, `path`, `runas`, or `kind` (when present) is inconsistent.  
7. Trust-tier: production requires global managed `/usr/local/bin/dns-cli`. Otherwise `--allow-test-local` / `ALLOW_TEST_LOCAL_SUDOERS=1`.  
8. Type 1 `setup` **MUST** auto-queue `login-hook-elev` when sibling CLI + `sudoer-adm` + writable inbound exist. Action **update** when `/etc/sudoers.d/dns-cli-dns-adm` exists; else **add**. **MUST** write the JSON into inbound with dest request-id grammar (`sudoer-YYYYMMDD-dns-cli-dns-adm-<action>-<n>.json`). **MUST NOT** `chown` dest inbound (SJ-M5 — dest `sudoer-adm` takes ownership). **MUST NOT** call dest Type 0 `add-sudoer-request` / `update-sudoer-request` for this grant (SJ-M3: dest Type 0 self-scope is a **blockage**, not dest approval). Missing sibling → skip (setup succeeds). Queue fail → warn; setup still succeeds. **MUST NOT** write `/etc/sudoers.d` as a fallback. `--json` **MUST** include `login_hook_sudoer` = `submitted` \| `skipped` \| `failed`.

### 2.6a Sample invocations (CI-M1a)

```sh
dns-cli print-sudoers
dns-cli generate-sudoer-request
dns-cli generate-sudoer-request "${HOME}/.config/dns-cli/sudoer-request-alice.json"
dns-cli generate-sudoer-request --kind type-2-switch
dns-cli generate-sudoer-request --kind login-hook-elev
dns-cli generate-sudoer-request --kind login-hook-elev "${HOME}/.config/dns-cli/sudoer-request-dns-adm-login-hook.json"
dns-cli submit-sudoer-request
dns-cli submit-sudoer-request "${HOME}/.config/dns-cli/sudoer-request-alice.json"
dns-cli submit-sudoer-request --add
dns-cli submit-sudoer-request --update
sudo dns-cli setup
```

`print-sudoers` is Table A **text**. The JSON dest is generate only. `submit-sudoer-request` is **not** DNS `submit` and is **not** the login-hook auto-queue. `setup` auto-submits `login-hook-elev` only when the sibling dest exists.

### 2.7 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **`{{PRJ_NAME}}` / `APP_NAME`** | `dns-cli` |
| **`{{GLOBAL_BIN}}`** | `/usr/local/bin` |
| **Elevated path** | `/usr/local/bin/dns-cli` |
| **`{{RUNAS}}`** | `dns-adm` |
| **Allowed args** | `type-2-switch`: `[]`. `login-hook-elev`: `["interactive"]` |
| **Kinds** | `type-2-switch` · `login-hook-elev` (`--kind`) |
| **Submit verb** | `submit-sudoer-request` → `lpu_submit_sudoer_request` (`type-2-switch` only) |
| **Generate verb** | `generate-sudoer-request` → `lpu_generate_sudoer_request` |
| **Generate dest (switch)** | `${HOME}/.config/dns-cli/sudoer-request-<user>.json` |
| **Generate dest (hook)** | `${HOME}/.config/dns-cli/sudoer-request-dns-adm-login-hook.json` |
| **Hook auto-submit** | `lpu_setup` → `lpu_submit_login_hook_sudoer_request` writes inbound (not dest Type 0 `add-sudoer-request`) |
| **Approval dest** | `sudoer-cli` (env `SUDOER_CLI`) |
| **Approver** | `sudoer-adm` (env `SUDOER_ADM_USER`) |
| **Inbound** | `/var/sudoer-cli/sudoer-request` (env `SUDOER_QUEUE_INBOUND`) |
| **Sibling dest after approve (switch)** | `/etc/sudoers.d/dns-cli-<user>` — written by **sudoer-cli**, not this product |
| **Sibling dest after approve (hook)** | `/etc/sudoers.d/dns-cli-dns-adm` — written by **sudoer-cli**, not this product |
| **F6 dest** | `/etc/dns-adm/sudoers` — Type 1 `setup` group dual; not either JSON dest |
| **Privilege / workflow peer** | `requirement-three-layer-privilege-model` |
| **Ship unit** | **1.7.0** two kinds + setup auto-submit; generate + Type 0 submit since 1.6.0; `print-sudoers` file since 1.5.0 |
| **Role table** | §2.0 (this file) |

### 2.8 Why This Requirement Exists (Direct CIAO Alignment)

- **CIAO Principle 10 – Least privilege**: Grant is one managed binary as `dns-adm`, not root and not OS tools.  
- **CIAO Principle 1 – Caution**: Type 0 never writes `/etc/sudoers.d`; sibling re-validates.  
- **CIAO Principle 2 – Intentional**: `kind=type-2-switch` means “this login may run `dns-cli` as `dns-adm`.” `kind=login-hook-elev` means “`dns-adm` may `sudo -n dns-cli interactive`.”  
- **CIAO Principle 9 – Type 0 / 1 / 2**: Submit is Type 0; approve is sibling Type 1; day-to-day is Type 2.  
- **CIAO Principle 21 – Dual policies**: Placeholders in the mold; this file fills `dns-cli` / `dns-adm`.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution:** Refuse OS-tool JSON and `runas: root`.  
- **Intentional:** Submitter ≠ dest ≠ F6 dest.  
- **Anti-fragile:** Independent generate dest is the review fixture.  
- **Over-protect:** Empty argv still help; generate/submit never install dest.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Put `cp`, `mkdir`, `install`, `chmod`, `tar`, `rm`, or a shell in this JSON.  
2. Set `runas` to `root` on `type-2-switch`, grant whole-CLI-as-root on `login-hook-elev`, or grant `setup` / `remove-lpu` / Type 0 verbs.  
3. Elevate `USER_BIN/dns-cli`.  
4. Write `/etc/sudoers.d` or `mkdir` inbound from this product.  
5. Treat DNS inbound JSON (`add`/`update`/`remove`/`mode`) as this grant.  
5a. Collapse `type-2-switch` and `login-hook-elev` into one body, drop `kind`, or let Type 0 `submit-sudoer-request` queue the hook grant.  
5b. Apply dest Type 0 self-scope (`username` == `id -un`) to Type 1 `setup`, call dest Type 0 `add-sudoer-request` for `login-hook-elev`, or treat that dest check as a safety net. It is a **blockage**. Dest approval does **not** test who submitted.  
5c. Confuse **who may submit** (current login, Type 0, no sudo) with **who may setup** (host admin, Type 1, password `sudo` / already root).  
5d. Treat Type 1 `setup` dest as `/etc/sudoers.d/dns-cli-<invoker>`, or Type 0 submit dest as `/etc/sudoers.d/dns-cli-dns-adm`. Hook dest is **`dns-cli-dns-adm`**; switch dest is the **invoker**.  
5e. `chown` dest inbound JSON to `dns-adm` (or JSON `username`) from Type 1 `setup` or Type 0 submit. Dest **`sudoer-adm`** takes ownership. JSON `username` is **not** the Unix owner.  
5f. Tell dest `sudoer-cli` to fence on file-ownership (owner ≠ JSON `username`). Dest **takes** ownership as `sudoer-adm`.  
5g. Add a dest inbound fence that is not **incorrect JSON format** (who submitted, dest Type 0 self-scope, JSON `username` ≠ dest LPU).  
6. Claim generate/submit are trimmed sudoers-manager extras.  
7. Make submit, inbound, or a deleted temp the only way to obtain this JSON.  
8. Store tokens in the JSON body.  
9. Cite templates or skills as product-source authority.  
10. Drop the §2.0 role table or treat `print-sudoers` as dest install.

**Violating this rule is a critical privilege / dest-collapse regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | Every `commands[].path` is `/usr/local/bin/dns-cli` |
| AC-2 | `service` equals `dns-cli`; `type-2-switch` `runas` equals `dns-adm`; `login-hook-elev` `runas` equals `root` |
| AC-3 | `type-2-switch` `args` is `[]`; `login-hook-elev` `args` is `["interactive"]` |
| AC-4 | No OS-tool basename in `path` or `args` |
| AC-5 | Add and update samples of the **same kind** differ only by `action` |
| AC-5a | Generate writes `kind`; default is `type-2-switch` |
| AC-5b | Type 0 submit of `login-hook-elev` fails closed |
| AC-5c | `setup` writes `login-hook-elev` inbound when sibling CLI + `sudoer-adm` + inbound exist; skips when missing; does not write `/etc/sudoers.d` |
| AC-5d | `setup` still writes inbound when dest Type 0 `add-sudoer-request` would return `self_scope` (SJ-M3) |
| AC-5e | Help names the submit-vs-setup door; dest Type 0 self-scope MUST NOT apply to setup |
| AC-6 | Generate dest is invoking-user readable; suite `cat`s without sudo |
| AC-7 | Generate refuses `/etc` and sibling inbound dests |
| AC-8 | Submit of a forbidden file fails closed |
| AC-9 | Submit without dest CLI / inbound / approver fails closed (no `mkdir`) |
| AC-10 | Submit does not write `/etc/sudoers.d` |
| AC-11 | Role table present (printer / generator / submitter / switch subject / hook subject / hook auto-submitter / allocator / sibling approver / F6 installer / Type 2) |
| AC-12 | `print-sudoers` prints the sudoer file (Table A text) and does not write F6 dest |
| AC-13 | Law names three dests: `/etc/sudoers.d/dns-cli-<user>` (switch), `/etc/sudoers.d/dns-cli-dns-adm` (hook), `/etc/dns-adm/sudoers` (F6) |
| AC-14 | `setup` / Type 0 submit **MUST NOT** `chown` dest inbound (SJ-M5); dest `sudoer-adm` takes ownership |
| AC-15 | Dest approval fencing conditions closed: dest inbound fence is incorrect JSON format only (SJ-M5) |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-three-layer-privilege-model` | Workflow; Table A text; F6 dest |
| `requirement-least-privilege-user` | `dns-adm` identity |
| `requirement-shell-cli-interface` | Verb routing |
| `requirement-domain-cloudflare-dns` | Type 2 verbs after elev — not this JSON |
| `requirement-cloudflare-dns-request` | Different inbound JSON family |
| `requirement-class-software-dev` | Residual points here |
| `docs/requirements/index.md` | Registry |
| `./src/dns-cli` | Implementation under test |

---

## Design-time verification

| TP family / ID | Suite | Status | Note |
|----------------|-------|--------|------|
| **TP-SUDOER-JSON-01** | `tests/test_cf_lpu.sh` | have | path is only `/usr/local/bin/dns-cli` |
| **TP-SUDOER-JSON-02** | same | have | no mkdir/cp/tar/rm/install/chmod |
| **TP-SUDOER-JSON-03** | same | have | default generate is `type-2-switch`; runas `dns-adm`; args `[]` |
| **TP-SUDOER-JSON-10** | same | have | generate writes `kind` |
| **TP-SUDOER-JSON-11** | same | have | `--kind login-hook-elev` → username `dns-adm`, runas `root`, args `interactive` |
| **TP-SUDOER-JSON-12** | same | have | Type 0 submit of hook kind fails closed |
| **TP-SUDOER-JSON-13** | same | have | setup auto-submits hook kind when sibling stub present |
| **TP-SUDOER-JSON-16** | same | have | dest Type 0 `self_scope` does not block setup inbound write |
| **TP-SUDOER-JSON-14** | same | have | setup skips auto-submit when sibling missing |
| **TP-SUDOER-JSON-15** | same | have | law names both kinds |
| **TP-SUDOER-JSON-17** | same | have | law names switch dest ≠ hook dest ≠ F6 |
| **TP-SUDOER-JSON-18** | same | have | setup hook write does not `chown`; law names SJ-M5 |
| **TP-SUDOER-JSON-19** | same | have | dest MUST NOT fence on file-ownership |
| **TP-SUDOER-JSON-20** | same | have | dest inbound fence is incorrect JSON format only (SJ-M5 table) |
| **TP-SUDOER-JSON-21** | same | have | queued inbound keys ⊆ dest-owned allowlist (`kind` known); same assert as **TP-FENCE-05** |
| **TP-SUDOER-JSON-08** | same | have | generate dest readable without sudo |
| **TP-PRIV-05** | same | have | generate refuses `/etc` |
| **TP-PRIV-06** | same | have | submit missing dest CLI fail-closed |
| **TP-PRIV-07** | same | have | submit stub inbound; no `/etc/sudoers.d` write |
| **TP-PRIV-08** | same | have | refuse OS-tool input file |
| **TP-SUDOER-JSON-09** | same | have | §2.0 role table (printer / generator / submitter / `sudoer-adm`) |

**Matrix:** `reviews/requirement-test-matrix.md`  
**Map:** `reviews/test-plan.md`

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-19 | Active 1.9.0 | Dest Fence row points at `requirement-incorrect-json-format` |
| 2026-08-19 | Active 1.8.0 | SJ-M5 user SSOT is JSON `username`, not the filename token |
| 2026-08-18 | Active 1.7.0 | SJ-M5 dest approval fencing conditions closed: incorrect JSON format only |
| 2026-08-18 | Active 1.6.0 | SJ-M5 setup/submit MUST NOT `chown` dest inbound; dest `sudoer-adm` takes ownership (INC-20260818-003) |
| 2026-08-18 | Active 1.5.0 | SJ-M4 three dests: switch=`dns-cli-<user>`; hook=`dns-cli-dns-adm`; F6 group |
| 2026-08-18 | Active 1.4.0 | SJ-M3 submit-vs-setup door; dest Type 0 self-scope is a blockage on setup |
| 2026-08-18 | Active 1.3.0 | Two JSON kinds (`type-2-switch` vs `login-hook-elev`); setup auto-submit |
| 2026-08-18 | Active 1.2.0 | CI-M1a sample invocations for print / generate / submit |
| 2026-08-18 | Active 1.1.0 | Role table: print sudoer file + JSON generate/submit; sibling approver ≠ `dns-adm` |
| 2026-08-18 | Active 1.0.0 | JSON sudoer file + generate/submit; Type 2 `runas=dns-adm`; empty args |

---

**Last Updated**: 2026-08-18  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
