**file**: docs/requirements/requirement-dns-approver.md  
**Status**: Active (Version 1.10.0) — approver identity only; login-hook plant is independent  
**Area**: architecture  
**Key**: `requirement-dns-approver`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **Single Source of Truth** for the **dns-cli approver identity**: **`dns-adm`**. Only that account dest-approves inbound DNS request JSON. There is **no** second approver account.

**Anyone** may submit (`requirement-dns-actor-table`). Login-hook plant, rc heal, old-hook rewrite, and the soft link **`/usr/local/bin/${APP_NAME}-hook`** are **`requirement-login-interactive-hook`**. Dest review loop (keep-latest, take-ownership, fence, YAML, yes/no) stays on `requirement-dns-actor-table`. LPU F1–F7 stay on `requirement-least-privilege-user`.

### 1.1 Human-facing

**In one sentence:** Only **`dns-adm`** dest-approves waiting DNS files; the login hook that starts that review lives on `requirement-login-interactive-hook`.

| Box | Meaning | Example |
|-----|---------|---------|
| Approver | `dns-adm` dest-reviews inbound DNS JSON | `dns-cli approve` / `interactive` |
| This file | Who dest-approves | One account; no `dns-apr` |
| Not this | Hook plant / `-hook` soft link / old-hook rewrite | `requirement-login-interactive-hook` |

| Includes | Excludes |
|----------|----------|
| Approver identity `dns-adm` | Second approver account |
| Pointer to the independent login-hook REQ | Owning `.bashrc` snippet, heal, or `/usr/local/bin/dns-cli-hook` |

| Surface | What you open | What for |
|---------|---------------|----------|
| `dns-cli interactive` | Command | Dest review as `dns-adm` |
| `requirement-login-interactive-hook` | Peer law | Soft link + heal |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Approve as `dns-adm` | Re-check JSON, take ownership, move | `dns-cli approve` |

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Approver identity

**APR-M1.** The approver **MUST** be **`dns-adm`**. **MUST NOT** invent `dns-apr` or another leaf.

**APR-M2.** Approval-subject is Cloudflare DNS request JSON (`add` / `update` / `remove` / `mode`). Dest on accept is a vault DNS/mode apply — not `/etc/passwd` or `/etc/sudoers.d`.

### 2.2 Login-time review (pointer)

**APR-M3.** After a **TTY login** as `dns-adm`, dest review **MUST** start through the independent login-hook REQ (`requirement-login-interactive-hook`): once-per-session `sudo -n /usr/local/bin/dns-cli-hook interactive`. Empty argv of `dns-cli` **MUST** remain help. Dest review after launch (keep-latest, take-ownership, fence, YAML, one-off yes/no) **MUST** follow `requirement-dns-actor-table` ACT-M4 / ACT-M6. This file **MUST NOT** own the snippet, the `-hook` soft link, or old-hook rewrite.

The hook’s `sudo -n` needs a live grant **`login-hook-elev`** (`requirement-sudoer-json-file`). Rc heal **MUST NOT** be treated as that grant.

### 2.2a Sample invocations (CI-M1a)

```sh
dns-cli interactive
sudo -n /usr/local/bin/dns-cli-hook interactive
```

`interactive` is Type 1 as `dns-adm`. Empty argv remains help. Hook plant + heal: `requirement-login-interactive-hook`. Dest loop: `requirement-dns-actor-table`.

### 2.3 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **Product** | `dns-cli` |
| **Approver** | `dns-adm` |
| **Review verb** | `interactive` (**Implemented** 1.21.0 — YAML body display, keep-latest duplicate inbound, then fence, then yes/no) |
| **Login-hook plant** | `requirement-login-interactive-hook` (snippet, heal, `/usr/local/bin/dns-cli-hook`) |
| **Proof** | **TP-CF-APR-01..08** (hook REQ) · **TP-CF-REQ-19** · **TP-CF-REQ-20** |

### 2.4 Why This Requirement Exists (Direct CIAO Alignment)

- **CIAO Principle 10 – Least privilege**: One dedicated approver account.  
- **CIAO Principle 2 – Intentional**: Approver identity is this file; hook plant is a peer.  
- **CIAO Principle 5 – SSOT**: Do not fold the `-hook` soft link back into this identity file.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution:** Do not invent a second approver account.  
- **Intentional:** Identity here; hook plant on the independent REQ.  
- **Anti-fragile:** Dest review loop stays on the actor table.  
- **Over-protect:** Do not absorb `/usr/local/bin/${APP_NAME}-hook` back into this file.

---

## 4. Protection Rule (Sacred)

**MUST NOT**:

1. Invent a second approver account.  
2. Absorb login-hook plant, rc heal, old-hook rewrite, or `/usr/local/bin/${APP_NAME}-hook` back into this file.  
3. Hijack empty argv as `interactive`.  
4. Put a token in dest review or this identity file.

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-APR1 | Approver is `dns-adm`; no second account |
| AC-APR2 | Login-hook plant / heal / `-hook` soft link live on `requirement-login-interactive-hook` |
| AC-APR3 | Dest review loop (keep-latest, ownership, fence, YAML, yes/no) lives on `requirement-dns-actor-table` |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-login-interactive-hook` | Snippet, rc heal, old-hook rewrite, `/usr/local/bin/${APP_NAME}-hook` |
| `requirement-dns-actor-table` | Actor table + dest review loop |
| `requirement-least-privilege-user` | `dns-adm` F1–F7 |
| `requirement-domain-cloudflare-dns` | Named machine |
| `requirement-three-layer-privilege-model` | Type 1 approve after F6 |
| `requirement-shell-interactive-vs-noninteractive` | TTY / `--json` |
| `docs/requirements/index.md` | Registry |

---

## Design-time verification

| TP family / ID | Suite | Status | Note |
|----------------|-------|--------|------|
| **TP-CF-APR-01..08** | `tests/test_cf_approver.sh` | have | Hook plant / heal — primary owner `requirement-login-interactive-hook` |
| **TP-CF-REQ-19** | test_cf_request | have | Duplicate inbound same dest: keep latest; older superseded → declined |
| **TP-CF-REQ-20** | test_cf_request | have | Login-hook `interactive` shows the waiting body as YAML |

**Map:** `reviews/test-plan.md`

---

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-09-08 | Active 1.10.0 | Approver identity only. Login-hook plant / `/usr/local/bin/${APP_NAME}-hook` / old-hook rewrite moved to `requirement-login-interactive-hook`. |
| 2026-09-06 | Active 1.9.0 | Login-hook `interactive` shows a clear waiting body as **YAML**. **TP-CF-REQ-20**. |
| 2026-09-06 | Active 1.8.0 | Interactive / login-hook review keeps the **latest** inbound file per dest (`domain_id`+`subdomain`); older duplicates superseded → declined. **TP-CF-REQ-19**. |
| 2026-09-03 | Active 1.7.0 | Login hook runs `/usr/local/bin/dns-cli-hook`; setup creates the alias when missing; heal rewrites the old binary path |
| 2026-08-19 | Active 1.6.0 | APR-M3 interactive records original file-ownership, then dest-writes `submit_by` if format is clear |
| 2026-08-19 | Active 1.5.0 | APR-M4 rc heal aligns ownership to corresponding user (shell-rc-file-ownership) |
| 2026-08-19 | Active 1.4.0 | Fence first; human-facing match; then one-off yes/no (approval-system) |
| 2026-08-19 | Active 1.3.0 | Approval question is one-off yes/no (yes=approve, no=reject); term `approval-question` |
| 2026-08-19 | Active 1.2.0 | Login-hook `interactive` takes inbound file-ownership as `dns-adm` **at the beginning** |
| 2026-08-17 | Active 1.0.0 | Approver = `dns-adm`; interactive rc heal; create `.profile` if missing |

---

**Last Updated**: 2026-09-08  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
