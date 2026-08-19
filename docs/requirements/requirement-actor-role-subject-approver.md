**file**: docs/requirements/requirement-actor-role-subject-approver.md  
**Status**: Active (Version 1.1.0) — Submitter column before Approver (anyone / the actor itself / None)  
**Area**: architecture  
**Key**: `requirement-actor-role-subject-approver`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **actor / role / subject / submitter / approver** catalog for `dns-cli`. It names who acts, in what role, for whom, who submitted, and who dest-approves. Submitter is **anyone**, **the actor itself**, or **None**. **None** is a valid Approver fill.

Every software-development project **MUST** consider this requirement type even if dest review does not exist. Dest who and dest login review stay on `requirement-dns-actor-table`. Privilege Types stay on `requirement-three-layer-privilege-model`. Sibling sudoer dest stays on `requirement-sudoer-json-file`.

This file is **not** a dest fence table and **not** a second domain SSOT.

### 1.1 Human-facing

**In one sentence:** Write down **who** runs each kind of command, **for whom**, **who submitted**, and **who dest-approves** — write **None** when nobody dest-submits or dest-approves.

| Box | Meaning | Example |
|-----|---------|---------|
| You | Day-to-day login | `dns-cli help` — no dest approver |
| Dest approver | Reviews a waiting DNS file | `dns-adm` via `dns-cli interactive` |
| Not this file | Dest fence list or login-hook snippet | `requirement-dns-actor-table` |

| Includes | Excludes |
|----------|----------|
| Five-column catalog (Submitter before Approver) | Inventing `nginx-adm` dest here |
| Honest **None** | Skipping because dest review is absent |

| Surface | What you open | What for |
|---------|---------------|----------|
| `dns-cli help` | Commands with no dest | Approver = None |
| `dns-cli submit ./req.json` | DNS dest request | Approver = `dns-adm` |
| `dns-cli submit-sudoer-request` | Sibling dest | Approver = `sudoer-adm` |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Ask who dest-approves a DNS file | Only `dns-adm` dest-reviews that JSON | `dns-cli interactive` |
| Ask who dest-approves nginx conf | **None here** — dest product is not this tree | (no dest verb) |
| Run help as yourself | No dest subject and no dest approver | `dns-cli help` |

---

## 2. Core Rules / Requirements (Mandatory)

**ARSA-M1.** This catalog **MUST** stay Active while the workspace is software-development and dest review **or** dest submit exists. A software-development project **without** dest review **MUST** still consider this type (this file **or** class residual **considered — no dest approver and no approval subject**).

**ARSA-M2.** Approver **MAY** be **None**. Subject **MAY** be **None**. Submitter **MAY** be **None**. **MUST** write **None** when dest review, dest submit, or a dest subject does not exist. **MUST NOT** invent an approver.

**ARSA-M2a.** Submitter **MUST** sit **immediately before** Approver. Closed fills: **anyone** (dest reviews inbound from any login) · **the actor itself** (this actor is the dest submitter) · **None** (this row is not a dest-submit path).

**ARSA-M3.** Product law **MUST** print this table:

| Actor | Role | Subject | Submitter | Approver |
|-------|------|---------|-----------|----------|
| Any ordinary login (`id -un`) | Day-to-day user | **None** | **None** | **None** — `help` / `version` / `about` / `install` / `uninstall` / `where-is-me` / `ip` / `print-sudoers` do not dest-review |
| Any ordinary login | DNS request submitter | Cloudflare DNS request JSON `subject` (self) | **the actor itself** | `dns-adm` |
| Any ordinary login | Sudoer-grant submitter | Sudoer JSON `username` (self) | **the actor itself** | `sudoer-adm` (sibling dest — this product **MUST NOT** dest-approve or write `/etc/sudoers.d`) |
| `dns-adm` | DNS dest approver and default-vault operator | Same DNS request JSON `subject` | **anyone** | `dns-adm` (`approve` / `reject` / `interactive`) |
| Root session | Host setup | **None** as dest subject | **None** | **None** as dest review — `setup` is password `sudo` / already root, not dest approve |
| `nginx-adm` | Nginx dest approver (peer dest) | nginx-conf | **None here** | **None here** — dest product is not in this tree |

**ARSA-M4.** Dest who, dest fence, queue move, and login-hook procedure **MUST** stay on `requirement-dns-actor-table` (and dest peers). This catalog **MUST NOT** absorb those tables.

**ARSA-M5.** When Subject is a dest request, user identity is the JSON field (`subject` on DNS; `username` on sudoer), **not** the filename token.

**ARSA-M6.** `dns-adm` dest-approves **DNS** inbound only. `sudoer-adm` dest-approves **sudoer** inbound only. **MUST NOT** collapse those dests.

### 2.1 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **Product** | `dns-cli` |
| **Class consider** | Published this file (not residual None) |
| **DNS dest approver** | `dns-adm` — Implemented |
| **Sudoer dest approver** | `sudoer-adm` — sibling dest; this product submits only |
| **Nginx dest approver** | **None here** |
| **Day-to-day dest approver** | **None** |
| **Dest who / procedure** | `requirement-dns-actor-table` |
| **Proof** | **TP-ARSA-01** · **TP-ARSA-02** |

### 2.2 Why This Requirement Exists (Direct CIAO Alignment)

- **CIAO Principle 2 – Intentional**: Who acts and who dest-approves is written, including **None**.  
- **CIAO Principle 5 – SSOT**: One catalog; dest procedure stays on the dest actor table.  
- **CIAO Principle 1 – Caution**: Do not invent an approver.  
- **CIAO Principle 10 – Least privilege**: Dest approver is a named dedicated account when dest exists.  
- **CIAO Principle 21 – Dual policies**: Portable consider; filled table for this product.

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution**: Missing dest review is **None**, not a hidden dest.  
- **Intentional**: Five columns (Submitter before Approver); every live verb family has a row.  
- **Anti-fragile**: Class consider survives products that never dest-approve.  
- **Over-protect**: Protection Rule forbids skip and invented `*-adm`.

## 4. Protection Rule (Sacred)

**Future AI assistants or maintainers MUST NOT**:

1. Delete this consider while the workspace remains software-development without moving it to class residual **considered — no dest approver**.  
2. Invent `nginx-adm` dest verbs on this product.  
3. Treat `dns-adm` as the sudoer dest approver, or `sudoer-adm` as the DNS dest approver.  
4. Absorb dest fence / login-hook law into this catalog.  
5. Take the user from a filename token.

## 5. Related artifacts (versioned surface only)

| Artifact | Role |
|----------|------|
| `docs/requirements/index.md` | Registry SSOT |
| `docs/requirements/requirement-class-software-dev.md` | Class MUST consider |
| `docs/requirements/requirement-dns-actor-table.md` | DNS dest who / procedure |
| `docs/requirements/requirement-dns-approver.md` | DNS dest login-hook heal |
| `docs/requirements/requirement-sudoer-json-file.md` | Sibling dest submitter roles |
| `docs/requirements/requirement-three-layer-privilege-model.md` | Privilege Types |
| `docs/requirements/requirement-least-privilege-user.md` | `dns-adm` account |
| `./src/dns-cli` | Ship unit |

## Design-time verification

| TP family / ID | Suite | Status | Note |
|----------------|-------|--------|------|
| **TP-ARSA-01** | `tests/test_cli.sh` | have | class MUST consider even if no approver |
| **TP-ARSA-02** | `tests/test_cli.sh` | have | catalog table prints Actor / Role / Subject / Submitter / Approver and None |

**Map:** `reviews/test-plan.md`

---

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-19 | Active 1.1.0 | Submitter column immediately before Approver (anyone / the actor itself / None) |
| 2026-08-19 | Active 1.0.0 | Extracted catalog; software-dev MUST consider; None is valid |

---

**Last Updated**: 2026-08-19  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
