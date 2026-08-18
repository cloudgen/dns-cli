**file**: docs/requirements/requirement-dns-actor-table.md  
**Status**: Active (Version 1.1.0) — submit / approve / reject / `interactive` **Implemented** (1.9.0); sudoer roles stay off this table  
**Area**: architecture  
**Key**: `requirement-dns-actor-table`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **Single Source of Truth** for the **dns-cli actor table**: who may **submit** a DNS request JSON file, who may **approve** or reject it, and the **login-time interactive review** procedure (hook after TTY login).

The **machine** (folder = state, JSON = proposal, four request types) is owned with `requirement-domain-cloudflare-dns` and `requirement-cloudflare-dns-request`. This file owns **who** and the **approval procedure**. Privilege Types are `requirement-three-layer-privilege-model`. Type 2 vault operator identity is `requirement-least-privilege-user` (`dns-adm`).

This is **not** a second `requirement-domain-*`. It is **not** the sudoer print/submit role table (`requirement-sudoer-json-file` §2.0 / `requirement-three-layer-privilege-model` §2.1a). DNS `submit` ≠ `submit-sudoer-request`. Approver `dns-adm` ≠ sibling `sudoer-adm`.

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Actor table

**ACT-M1.** Product law and the product README **MUST** publish this actor table. Roles **MUST NOT** be collapsed.

| Role | Who | Type | May | Must not |
|------|-----|------|-----|----------|
| **Submitter** | **Anyone** — any login (`id -un`; example `alice`) | **0** | `submit` a self-scoped JSON file into inbound | Submit for another identity; approve/reject (unless this login is `dns-adm` using Type 1 verbs); write Cloudflare dest; choose the dest basename; hold or print the API token |
| **Subject** | Same person as the submitter | — | Appear in basename `subject` and JSON `subject` | Be another login |
| **Approver** | LPU **`dns-adm`** | **1** (after F6, or euid 0) | Re-check JSON + name; **move** inbound → accepted/declined; on accept, apply dest (`add` / `update` / `remove` / `mode`) | Invent a second approver account; store the token in the request |
| **Allocator** | `dns-cli` Type 0 `submit` path | **0** | Allocate `YYYYMMDD-<subject>-<action>-<n>.json` | Trust `--name` / caller dest basename |
| **Root session** | euid 0 | **1** | Same Type 1 verbs as `dns-adm` | Submit a body whose subject is someone else |

**ACT-M2.** **`dns-adm` is the approver.** The same LPU is Type 2 for default-vault DNS and Type 1 for approve / `interactive`. **MUST NOT** invent a second account (`dns-apr` or similar).

**ACT-M3.** The API token **MUST** stay in the vault (0600 file). Request JSON **MUST NOT** include a `token` key (`requirement-cloudflare-dns-request`).

**ACT-M3a.** This table **MUST NOT** absorb printer / generator / `submit-sudoer-request` / `sudoer-adm`. Those roles stay on `requirement-sudoer-json-file` §2.0.

### 2.2 Account map

| Role | Account |
|------|---------|
| Submitter / subject | **Anyone** — any ordinary login (`id -un`) |
| Approver | `dns-adm` |
| Type 2 operator | `dns-adm` (same account; different command Type) |
| Root session | euid 0 |

### 2.3 When a normal user may submit

Type 0 `submit` is allowed **only when all** hold:

1. Invoker is **any** login user (including `dns-adm`).  
2. **Self-scope:** basename `subject`, JSON `subject`, file owner, and `id -un` are the same person. On-behalf-of → fail closed.  
3. Body `action` is one of `add` / `update` / `remove` / `mode` (`requirement-cloudflare-dns-request`).  
4. Inbound exists and is writable. Type 0 **MUST NOT** `mkdir` production inbound.  
5. Allocator owns the basename.  
6. No `token` / IPv6 / unknown keys.

**Not a submit:** a change for a colleague; wanting Cloudflare written immediately; `approve` as a normal user; `status` / `show` / `ip`; `vault account add`.

### 2.4 Verify at submit and again at approve

| Check | Rule |
|-------|------|
| Closed schema | `schema_version` 1; unknown keys fail |
| Identity match | Basename fields win; JSON `subject` / `action` must match |
| Self-scope | Subject = invoker at submit; owner still matches at approve |
| Payload | IPv4 fields per `requirement-cloudflare-dns-request` + `requirement-external-ipv4` |
| Token | Body **MUST NOT** contain a token |
| Dest | Accept maps to DNS `add` / `update` / `remove` / `vault subdomain mode` using the **vault** token. **MUST NOT** write `/etc/passwd` or `/etc/sudoers.d` |
| Re-validate | Approve **re-runs** these checks |

CLI `--json` is status only. It is **not** the request file.

### 2.5 Approval procedure (interactive hook after login)

**ACT-M4.** When implemented, TTY login as **`dns-adm`** **MUST** start review **once** per session via an rc hook. Empty argv of `dns-cli` **MUST** remain help.

Procedure:

1. `dns-adm` logs in on a keyboard TTY (SSH/console).  
2. Interactive rc (`.bashrc` only unless `.profile` exists and does **not** source `.bashrc`) runs the snippet in §2.6.  
3. Guards pass → `sudo -n /usr/local/bin/dns-cli interactive` (global binary only). The live grant is **`login-hook-elev`** (sibling dest after approve), **not** the Type 0 `type-2-switch` JSON and **not** F6 `%sudo ALL=(dns-adm)`.  
4. `interactive` lists inbound JSON, one file at a time: show purpose + body; prompt **accept** / **decline** / **skip** / **quit**.  
5. Accept / decline **MUST** re-run §2.4, then **move** the file (accepted / declined). Accept also applies the dest DNS/mode verb.  
6. Empty inbound → exit 0; login continues to a shell.  
7. `scp` / `SSH_ORIGINAL_COMMAND` / no TTY → hook **does nothing**.  
8. `sudo -n` fail → warning; login **continues**.  
9. `--force` **MUST NOT** auto-accept. `--json` / non-TTY `interactive` → fail closed.

**ACT-M5.** `submit` / `approve` / `reject` / `interactive` **MUST NOT** appear in `help` until `app_main` routes them. Until then they **MUST** fail as unknown (fail closed).

### 2.5a Sample invocations (CI-M1a)

These verbs are **Implemented** on ship unit **1.9.0**. They are **not** `submit-sudoer-request`.

```sh
dns-cli submit
dns-cli submit /home/alice/.config/dns-cli/dns-request.json
dns-cli approve
dns-cli reject
dns-cli interactive
sudo -n /usr/local/bin/dns-cli interactive
```

`submit` is Type 0 self-scope. `approve` / `reject` / `interactive` are Type 1 as `dns-adm` (or euid 0). Empty argv remains help.

### 2.6 Complete login-hook snippet (normative sample)

Markers: `# BEGIN dns-cli login hook` … `# END dns-cli login hook`. Session guard **MUST** be set **before** `sudo -n`.

```sh
# BEGIN dns-cli login hook
if [ -z "${DNS_CLI_HOOK_RAN:-}" ] \
    && [ -n "${PS1:-}" ] \
    && [ -t 0 ] && [ -t 1 ] \
    && case "$-" in *i*) true ;; *) false ;; esac \
    && [ "$(id -un)" = "dns-adm" ] \
    && [ -z "${SSH_ORIGINAL_COMMAND:-}" ]; then
    DNS_CLI_HOOK_RAN=1
    export DNS_CLI_HOOK_RAN
    if ! sudo -n /usr/local/bin/dns-cli interactive; then
        printf '%s\n' "dns-cli: login review hook skipped (sudo -n failed)" >&2
    fi
fi
# END dns-cli login hook
```

F7 **MUST** strip this block from whichever rc files contain it.

### 2.7 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **Product** | `dns-cli` |
| **Ship unit** | `src/dns-cli` **1.9.0** — rc heal + submit / approve / reject / `interactive` **Implemented** |
| **Inbound** | `/var/dns-cli/dns-request` (`3773`); archives `dns-accepted` / `dns-declined` (`0700`); F4 `${LPU_HOME}/dns-request` |
| **Submitter** | **Anyone** — any login (`id -un`; example `alice`) |
| **Approver** | `dns-adm` |
| **Type 2 operator** | `dns-adm` (same leaf) |
| **Review verb** | `interactive` |
| **Hook variable** | `DNS_CLI_HOOK_RAN` |
| **Inbound create** | Type 1 `setup` creates the trio; Type 0 does not `mkdir` |
| **Dest** | Cloudflare A / mode apply via vault — not `/etc/<subject>/dns` |
| **Proof** | **TP-CF-ACTOR-01..07** · **TP-CF-REQ-01..08** |

### 2.8 Why This Requirement Exists (Direct CIAO Alignment)

- **CIAO Principle 1 – Caution**: Hostile inbound; re-validate at approve; no token in the file.  
- **CIAO Principle 2 – Intentional**: Named actors; login hook is explicit `interactive`, not empty argv.  
- **CIAO Principle 9 – Three types**: Type 0 submit / Type 1 approve.  
- **CIAO Principle 10 – Least privilege**: One LPU `dns-adm` approves; any login may submit; token stays in the vault.  
- **CIAO Principle 16 – Interactive**: Hook skips scp/CI; `sudo -n` never blocks login.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution:** Do not trust inbound inodes; skip non-TTY.  
- **Intentional:** One table for who; one hook for when.  
- **Anti-fragile:** `sudo -n` fail does not lock the approver out.  
- **Over-protect:** Help does not advertise unrouted verbs.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Invent a second approver account (`dns-apr` or similar). `dns-adm` **is** the approver.  
2. Restrict submit to a special submitter login — **anyone** may submit (self-scope).  
3. Claim submit / approve / interactive **Implemented** while `app_main` does not route them.  
4. Hijack empty argv as review.  
5. Hang `scp` / CI on the hook.  
6. Put a token in the actor table, hook snippet, or request JSON.  
7. Register this file as `requirement-domain-*`.

**Violating this rule is a critical privilege / stay-honest regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-ACT1 | Actor table present in this file **and** product README |
| AC-ACT2 | `dns-adm` is the only approver; anyone may submit |
| AC-ACT3 | Complete hook snippet present |
| AC-ACT4 | Routed `submit` / `approve` / `reject` / `interactive` are not unknown |
| AC-ACT5 | Help lists those verbs now that they are routed |
| AC-ACT6 | Empty argv is help |
| AC-ACT7 | Stay-honest: rc heal + review loop **Implemented** on 1.9.0 |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-dns-approver` | Hook heal / `.bashrc` / `.profile` create |
| `requirement-domain-cloudflare-dns` | Consumes this table; names the machine |
| `requirement-cloudflare-dns-request` | Request JSON types |
| `requirement-three-layer-privilege-model` | Type 0 submit / Type 1 approve; sudoer print/submit role table is §2.1a there |
| `requirement-sudoer-json-file` | Sibling sudoer JSON roles — not this table |
| `requirement-least-privilege-user` | `dns-adm` is Type 2, not LPA |
| `requirement-shell-cli-interface` | Dispatch; help honesty |
| `requirement-shell-cli-zero-arguments` | Empty argv = help |
| `requirement-shell-interactive-vs-noninteractive` | TTY / `--json` fail closed |
| `docs/requirements/index.md` | Registry |

---

## Design-time verification

| TP family / ID | Suite | Status | Note |
|----------------|-------|--------|------|
| **TP-CF-ACTOR-01** | `tests/test_cli.sh` | have | `submit` routed; no file fails closed |
| **TP-CF-ACTOR-02** | `tests/test_cli.sh` | have | `approve` routed |
| **TP-CF-ACTOR-03** | `tests/test_cli.sh` | have | `reject` routed |
| **TP-CF-ACTOR-04** | `tests/test_cli.sh` | have | `interactive` routed; `--json` fail closed |
| **TP-CF-ACTOR-05** | `tests/test_cli.sh` | have | help lists those verbs |
| **TP-CF-ACTOR-06** | `tests/test_cli.sh` | have | empty argv is help (peer TP-CLI-07) |
| **TP-CF-ACTOR-07** | `tests/test_cli.sh` | have | MUST NOT absorb printer / `submit-sudoer-request` / `sudoer-adm` |

**Map:** `reviews/test-plan.md`

---

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-18 | Active 1.1.0 | submit / approve / reject / interactive Implemented (1.9.0) |
| 2026-08-18 | Active 1.0.3 | CI-M1a sample invocations for submit / approve / reject / interactive |
| 2026-08-18 | Active 1.0.2 | Point at sudoer print/submit role table; do not merge |
| 2026-08-17 | Active 1.0.1 | Approver is `dns-adm`; anyone may submit; no `dns-apr` |
| 2026-08-17 | Active 1.0.0 | Actor table + login hook law; ship unit Gap |

---

**Last Updated**: 2026-08-17  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
