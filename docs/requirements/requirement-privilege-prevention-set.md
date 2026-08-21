**file**: docs/requirements/requirement-privilege-prevention-set.md
**Status**: Active (Version 1.0.0)
**Area**: architecture
**Key**: `requirement-privilege-prevention-set`
**id**: RQ-PRIVILEGE-PREVENTION-SET
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **project Single Source of Truth** for **what this product blocks, stops, or prevents**, and for **what it must not block** after the operator has already elevated.

The Type 0 / Type 1 / Type 2 map and elev Tables A / B / C stay on `requirement-three-layer-privilege-model.md`. Least-privilege identity (F1–F7) stays on `requirement-least-privilege-user.md`. DNS dest verbs stay on dest actor / domain files. JSON sudoer **submit** stays on `requirement-sudoer-json-file.md`. This file **does not** replace those tables. It owns the **closed prevention catalog** and the **must-remain-open catalog**.

A wall that is not a §2.2 row is **not** product law.

This product **is not** a sudoers dest. Sibling `sudoer-cli` dest-approves sudoer JSON. **MUST NOT** copy sibling “Type 2 absent” or “any euid-0 host admin dest-approves DNS” rows.

### 1.1 Human-facing

**In one sentence:** After you already used password sudo for setup, this program must not invent a second lock. DNS dest review still runs **as** `dns-adm`. The catalog lists what is blocked and what must stay open.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | Create `dns-adm` after password sudo | `sudo dns-cli setup` |
| The other role | DNS dest as `dns-adm` | `dns-cli interactive` (as `dns-adm`) |
| Not this file | Dest Fence (broken JSON) | `requirement-incorrect-json-format` |

| Includes | Excludes |
|----------|----------|
| Closed block list; OPEN-ELEV / OPEN-T2 / OPEN-BOOT-ANY | Invented walls; requiring `SUDO_USER` to be `dns-adm` for **setup**; copying sibling Type 2 absence |

| Surface | What you open | What for |
|---------|---------------|----------|
| `src/dns-cli` | ship unit | authz after elev |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| First-time setup | Password sudo already decided. File checks still run. | `sudo dns-cli setup` |

---

## Design-time verification

| Gate | Artifact | Phase |
|------|----------|-------|
| Catalog present; no invented wall; Type 2 remains open | **TP-PREV-01** `tests/test_cli.sh` | Proof |

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Closed-list rule

1. A product **block** exists **only** when it has a row in §2.2.  
2. If an action is **not** listed in §2.2, the product **MUST NOT** stop it — unless this requirement is revised in the **same change** as the new block.  
3. Maintainers **MUST NOT** invent a wall that is not a §2.2 row. Invented walls include: an unpublished live-command whitelist; a Gap stub on a listed Type 1 verb after euid 0; requiring `SUDO_USER` to equal `dns-adm` on **setup**; treating CI as a create gate.  
4. §2.3 is the **must-remain-open** catalog. Closing a §2.3 row **MUST** revise this file first.  
5. Table A is **only** the F6 sudoers line. Table B is **only** what must not appear **in** the F6 fragment. Table C is **script jobs**. Those tables **MUST NOT** be reread as a live-command whitelist or denylist.  
6. **No published denylist ⇒ no extra restrict** on live tools a Type 1 job needs.

### 2.2 What this product blocks (closed catalog)

Each row is a **real** product stop. How the stop is implemented lives on the **Owner** requirement.

#### 2.2.1 Privilege actor

| ID | What is stopped | Who / when | How it stops | Owner |
|----|-----------------|------------|--------------|-------|
| **PREV-PASSWD** | Write `/etc/passwd`, `/etc/group`, `/etc/shadow`, or `/etc/gshadow` | any type | Fail closed. Create/teardown the LPU with `useradd` / `userdel` only inside Type 1 setup | LPU · three-layer |
| **PREV-SUDOERS-D** | This product writing `/etc/sudoers.d` or the main `/etc/sudoers` | Type 0 / Type 1 | Fail closed. This product is a **submitter**. Sibling dest writes grant dests. F6 dest is `/etc/dns-adm/sudoers` (not `sudoers.d`) | three-layer · sudoer-json-file |
| **PREV-T0-USER** | Create or delete the LPU (`useradd` / `userdel`) | Type 0 / ordinary login | Fail closed. Only Type 1 `setup` / `remove-lpu` | LPU · three-layer |
| **PREV-T0-QUEUE** | `mkdir` the production inbound / accepted / declined trio | Type 0 | Fail closed if the dir is missing | dest actor |
| **PREV-T1-EUID** | Type 1 `setup` / `remove-lpu` without euid 0 | any login | Fail closed; tell the operator `sudo dns-cli setup` (password sudo; **not** `sudo -n`) | three-layer |
| **PREV-DNS-APPR** | DNS `approve` / `reject` / `interactive` **not** as `dns-adm` | any other euid | Fail closed `lpu_required` / dest authz. DNS dest **is** the LPU. This is **not** sibling sudoer dest. | dest actor · three-layer |
| **PREV-T0-HOOK** | Type 0 `submit-sudoer-request` of `login-hook-elev` | Type 0 | Fail closed. That kind is Type 1 setup auto-queue | sudoer-json-file · three-layer |
| **PREV-FORCE-AUTHZ** | `--force` skipping Type 1 authz, or `--force` auto-approving in `interactive` | dest | Still fail authz; still prompt | dest actor |

#### 2.2.2 F6 fragment

| ID | What is stopped | Who / when | How it stops | Owner |
|----|-----------------|------------|--------------|-------|
| **PREV-F6-ALL** | `ALL=(ALL) ALL` or `NOPASSWD: ALL` in F6 / `print-sudoers` | emit / install | Must not emit | three-layer Table B |
| **PREV-F6-SHELL** | `/bin/sh`, `/bin/bash`, or an unrestricted shell as an F6 Cmnd | emit / install | Must not emit | three-layer Table B |
| **PREV-F6-LOCAL** | Elevate `{{USER_BIN}}/dns-cli` or an ad-hoc `/tmp` binary as production F6 | emit / install | Must not emit | three-layer |
| **PREV-F6-SCOPE** | Writes outside product-owned `/etc/dns-adm/` (F6 dest, home, queues) | Type 1 jobs | Bound dest only | three-layer · LPU |

#### 2.2.3 Identity, teardown, elev path

| ID | What is stopped | Who / when | How it stops | Owner |
|----|-----------------|------------|--------------|-------|
| **PREV-COLLIDE** | `setup` when UID, GID, or LPU name exists and is **not** this identity | Type 1 bootstrap | Exit non-zero; no partial create | LPU |
| **PREV-UNINST-F7** | Type 0 `uninstall` treated as LPU teardown | Type 0 | `uninstall` removes the **managed binary only** | LPU · local-self-management |
| **PREV-SUDO-N-BOOT** | Bootstrap / first-time `setup` documented or implemented as `sudo -n` | Type 1 bootstrap | Must not be the path. Password `sudo` or a root login. The only specified `-n` is F6 login hook **and** Type 2 switch after F6 exists | three-layer |
| **PREV-SCHEMA** | Dest-unknown JSON keys on DNS inbound | dest submit/approve | Fail closed dest Fence | incorrect-json-format |
| **PREV-EMPTY-INT** | Empty argv becoming `interactive` | any uid | Empty argv is Type N help | CLI · zero-arguments |
| **PREV-HELP** | Listing a verb in `help` that has no dispatcher arm | help | Must not list | CLI |
| **PREV-HANG** | Prompt or hang when `TTY` is not `1`; login hook hanging `scp` / CI | `interactive` / hook | Fail closed; hook skips / warns and login continues | interactive · dest |

### 2.3 What this product does **not** block (must remain open)

These rows are **product law**. Closing one is the same class of defect as adding an unlisted block.

| ID | Must stay open | After / when | Why |
|----|----------------|--------------|-----|
| **OPEN-ELEV** | Run Type 1 `setup` / `remove-lpu` the operator invoked | After password `sudo` **or** a root login (`SUDO_USER` may be **any** host admin) | That elev **is** the approval for bootstrap. **MUST NOT** require `SUDO_USER==dns-adm` for setup |
| **OPEN-BOOT-ANY** | Any host admin already euid 0 **MAY** run `setup` / `remove-lpu` | Bootstrap | `dns-adm` does not exist yet |
| **OPEN-T2** | Default-vault vault/DNS **as** `dns-adm` after a live Type 2 grant | Type 2 | This product **has** Type 2. **MUST NOT** copy sibling “Type 2 not used” |
| **OPEN-T2-SWITCH** | If euid is not `dns-adm`, re-exec `sudo -n -u dns-adm` of the **managed global** binary | Type 2 default vault | P-M4. Specified `--vault-dir` **MUST NOT** force this switch |
| **OPEN-DNS-APPR** | `dns-adm` **MAY** `approve` / `reject` / `interactive` DNS inbound | Dest as LPU | DNS dest is the LPU. File checks stay. **MUST NOT** require a second host-admin password sudo for dest review |
| **OPEN-SUDO** | The ship unit **MAY** invoke password `sudo` (outer **or** in-tool) | Mix model | “Avoid `sudo -n`” is **not** “avoid `sudo`” |
| **OPEN-USERADD** | Type 1 `setup` / `remove-lpu` **MUST** call `useradd` / `userdel` (password `sudo`) | After euid 0 | Account create is a script job, not an F6 Cmnd |
| **OPEN-TOOLS** | Type 1 **MAY** run the OS tools the job needs (`mkdir`, `chmod`, `install`, product-scoped `rm`, …) | After euid 0 | Table A is not a live-command catalog |
| **OPEN-UNLISTED** | A live tool that is **not** listed in Table A, Table B, or Table C is **not** forbidden | After euid 0 | No denylist ⇒ no extra restrict |
| **OPEN-CONFIRM** | The **only** extra gate after elev is TTY confirm or `--force` on **sensitive** undo-hard steps | After euid 0 | Confirm is not a new privilege class |
| **OPEN-NO-FLAG** | No env flag or “not enabled” die on live `useradd` / F6 / hook after euid 0 | Type 1 `setup` | Nobody published that gate |
| **OPEN-NO-CI** | Continuous integration is **not** a product gate on `useradd` | Host vs suite | A suite that cannot enter a sudo password **MUST NOT** rewrite create as forbidden |
| **OPEN-TABLE-A** | Table A stays **one** F6 line (global binary as `dns-adm`). It **MUST NOT** grow into “every binary the script may exec” | emit | Fragment ≠ live allowlist |
| **OPEN-ETC-USER** | Type 1 **MUST** put LPU home / queues / hooks under `/etc/dns-adm/` | After euid 0 | There is **no** blanket “do not write `/etc`” |
| **OPEN-DECIDE** | DNS dest `approve` / `reject` **MUST** move a regular inbound JSON after dest authz + fence | As `dns-adm` | **MUST NOT** fail because file owner ≠ subject. Dest identity is JSON `subject` |

**MUST NOT** publish **OPEN-SUDOER-APPR** (any euid-0 host admin dest-approves) for **this** DNS dest. That row is sibling dest law.

### 2.4 Sensitive is not blocked

These steps stay **allowed** after elev. The extra gate is confirm or `--force` only.

| Step | Extra gate | Still allowed after elev? |
|------|------------|---------------------------|
| Type 0 `uninstall` (managed binary only) | TTY confirm; non-interactive requires `--force` | yes |
| Type 1 `remove-lpu` / `userdel -r` | TTY confirm unless `--force` | yes |

`--force` **MUST NOT** skip §2.2 authz rows (**PREV-FORCE-AUTHZ**).

### 2.5 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **Product** | `dns-cli` |
| **Ship unit** | `src/dns-cli` |
| **LPU** | `dns-adm` |
| **F6 dest** | `/etc/dns-adm/sudoers` — `%sudo ALL=(dns-adm) NOPASSWD: /usr/local/bin/dns-cli` |
| **Usual bootstrap** | `sudo dns-cli setup` (password `sudo` OK) |
| **Type 2** | **Used** — default vault as `dns-adm` |
| **DNS dest** | `dns-adm` (not any euid-0 host admin) |
| **Sudoer dest** | Sibling `sudoer-cli` — this product **submits** only |

### 2.6 Why This Requirement Exists (Direct CIAO Alignment)

- **CIAO Principle 2 – Intentional**: The block list is written down.  
- **CIAO Principle 9 – Three Types**: Type 2 stays Type 2; Type 1 after elev is not re-gated for setup.  
- **CIAO Principle 10 – Least privilege**: Size the job **before** elev.  
- **CIAO Principle 1 / 20**: Fail closed on published rows; over-protect the **open** list.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution**: Only published rows stop an action.  
- **Intentional**: Block vs open is a pair. DNS dest ≠ sibling dest.  
- **Anti-fragile**: Password `sudo` / root login works for setup; Type 2 remains.  
- **Over-protect**: Adding a new block without revising this file is a privilege regression.

---

## 4. Protection Rule (Sacred)

**Future AI assistants or maintainers MUST NOT**:

1. Add a product block that is not a §2.2 row without revising this file in the same change.  
2. Close a §2.3 row (treat Table A as a live-command whitelist; ban in-tool password `sudo`; require `sudo -n` for `setup`; require the operator to already be `dns-adm` **for setup**).  
3. Copy sibling **PREV-T2** (Type 2 not used) onto this product.  
4. Copy sibling **OPEN-SUDOER-APPR** (any euid-0 host admin dest-approves) onto **DNS** dest.  
5. Put Table C OS tools into Table A / `print-sudoers`.  
6. Write `/etc/sudoers.d` from this product.  
7. Use `--force` to skip Type 1 authz or to auto-approve dest `interactive`.  
8. Document bootstrap as `sudo -n dns-cli setup`.

**Violating this rule is a critical privilege / invented-wall regression.**

---

## 5. Related artifacts (versioned surface only)

| Artifact | Role |
|----------|------|
| `docs/requirements/index.md` | Registry SSOT |
| `docs/requirements/requirement-three-layer-privilege-model.md` | Type map + Tables A/B/C |
| `docs/requirements/requirement-least-privilege-user.md` | F1–F7 |
| `docs/requirements/requirement-dns-actor-table.md` | DNS dest who |
| `docs/requirements/requirement-sudoer-json-file.md` | Type 0 submitter |
| `./src/dns-cli` | Ship unit |

**Last Updated**: 2026-08-20  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
