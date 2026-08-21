**file**: docs/requirements/requirement-class-software-dev.md  
**Status**: Active (Version 1.10.0) — dest Fences ship Type 0 test-purpose `fence-test` (local test folder)  
**Area**: class  
**Key**: `requirement-class-software-dev`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

Declare this workspace as a **software-development** project class and hold the **residual collection** of software-engineering stack facts **not already owned** by more specific Active peer requirements: primary language, toolchain policy, package/test tooling, and runtime OS family.

This file is **class law + residual SSOT**, not a second copy of Type 0 lifecycle, output, or storage tables (those stay on peer requirements).

### 1.1 Human-facing

**In one sentence:** This file says dns-cli is a **software product** and keeps leftover stack facts (language, toolchain) that no other requirement owns.

| Box | Meaning | Example |
|-----|---------|---------|
| You | Read class + residual stack | POSIX `/bin/sh`, `python3` for JSON |
| A more specific file | Owns the real rule once it exists | `requirement-shell-cli-interface` owns the command list |
| Not this file | Day-to-day install, vault, or DNS verbs | `dns-cli add` |

| Includes | Excludes |
|----------|----------|
| Project class = software-development | Server-maintenance class file |
| Residual language / toolchain until a peer owns them | Full help catalog |
| MUST consider who dest-approves (or write None) | Inventing an approver |
| MUST review dest fences and extract each Fence | Leaving a dest Fence as only a table cell |

| Surface | What you open | What for |
|---------|---------------|----------|
| `docs/requirements/requirement-class-software-dev.md` | This file | Class + residual |
| `src/dns-cli` | Ship unit | What language the product actually is |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Ask what kind of project this is | Software you install and run, not a host-admin playbook | `dns-cli about` |

---

## 2. Core Rules (Mandatory)

### 2.0 Project class membership

1. **MUST** treat this workspace as **software-development** (shippable software), not genesis-template and not server-maintenance.  
2. **MUST** use basename **`requirement-class-software-dev.md`** as the sole Active class-law file for this class.  
3. **MUST NOT** register an Active `requirement-class-server-maintenance.md` while class is software-development.  
4. **MUST** retain portable harness knowledge; specialized product knowledge lives in this and peer `requirement-*.md` files.  
5. **MUST** apply software-development SSOT/gate posture when claimed (identity, ship unit, precommit when git is used — as applicable).  
5a. When git is used on a **multi-vault host**, **MUST** treat forge push identity as **product repository-user SSOT** (Config `REPO_USER` / project-repository owner), not ambient default SSH face: agents **MUST** run precommit / SSH-profile gates (pre-git report; vault bind via activate or one-shot identity for push). Host vault basenames are **not** product law.  
6. **MUST NOT** invent hollow product docs solely to look specialized; collect real values or defer explicitly.

### 2.1 Residual collection principle (SSOT hygiene)

7. **MUST** treat this file as the **default home** for software-stack facts **not owned** by another Active requirement.  
8. **MUST NOT** duplicate full normative tables that already live in a more specific Active requirement. Prefer a **one-line pointer** to the peer requirement key.  
9. When a new specialized requirement **takes ownership** of a topic previously only listed here, **MUST** update this file in the **same change**: remove or shrink the residual entry and point to the new owner.  
10. **MUST NOT** leave contradictory stack facts across this file and peer requirements.

### 2.2 Programming language(s)

11. **MUST** declare at least one **primary programming language** for the ship unit.  
12. **SHOULD** list secondary languages only when they are real product law.  
13. **MUST** state whether the product is primarily: interpreted, compiled, polyglot, or package-multi-language.  
14. **MUST NOT** freeze a marketing product name as if it were the language name.

### 2.3 Compilers, interpreters, and toolchains

15. **MUST** declare the **target toolchain class** used to build or run the product.  
16. **MUST** state version policy as one of: unconstrained · minimum version · range · pinned.  
17. **SHOULD** record whether cross-compilation is in scope.  
18. **MUST** fail closed in CI/docs claims: do not claim “supports all compilers” without tests or explicit unconstrained policy.

### 2.4 Project / package / build tools

19. **MUST** declare the **primary project or package tool** used for dependencies and builds.  
20. **MUST** declare how dependencies are resolved when the ecosystem supports lockfiles.  
21. **SHOULD** name the test runner and linter/formatter **classes** when they are project law.  
22. **MUST NOT** require a secret token or private registry password in this file.

### 2.5 Runtime and platform (residual)

23. **MUST** declare the intended **primary runtime/OS family** when not fully owned by another architecture requirement.  
24. **SHOULD** declare minimum CPU/arch support only when it is real product law.  
25. **MUST** separate **developer machine** toolchain requirements from **end-user runtime** requirements when they differ.

### 2.6 No-hardcode / dual policy (class file)

26. **MUST NOT** hard-code a single product/app brand, one org’s production hostname, or personal owner identity as universal core law.  
27. **MUST** put live product name, repo slug, and concrete stack choices in **Implementation Notes** after collection — complete when Status is Active.  
28. **MUST NOT** store secrets, PATs, or toy credentials in this file.

### 2.8 Actor / role / subject / approver (consider)

29. Every software-development project **MUST** consider an **actor / role / subject / approver** requirement — **even if there is no dest approver**.  
30. **MUST** either publish Active `requirement-actor-role-subject-approver` (product stem allowed) that prints the five-column table (Submitter immediately before Approver), **or** record in this residual: **considered — no dest approver and no approval subject**.  
31. **MUST NOT** skip the consider. **MUST NOT** invent an approver so the table looks complete.  
32. A dest-specific actor table **MAY** exist when dest review is Implemented. That file does **not** replace this consider.

### 2.9 Dest fence conditions (review and convert)

33. Every software-development project **MUST review** whether any dest fencing conditions exist.  
34. Each dest **Fence** row **MUST** be an independent Active requirement (product stem allowed). Dest fence tables **MUST** still print the closed catalog and **point** at those REQs.  
35. Dest **MUST NOT** fence rows stay on dest tables only — they are **not** independent fence requirements.  
36. If none: record in this residual **considered — no dest fence conditions**.  
37. **MUST NOT** skip the review. **MUST NOT** invent a dest fence so the set looks complete.  
38. Dest **approval fencing conditions** (the closed catalog) **MUST** be Active `requirement-approval-fencing-condition` (product stem allowed) while dest review or dest submit exists. Dest tables still print. This catalog REQ is **not** a dest Fence.  
39. When dest has any dest **Fence**, the product **MUST** ship Type 0 **`fence-test`** as a **test-purpose** verb: **unit test** of dest fence functions against a JSON **file location** in a **local test folder**. **MUST NOT** require `sudo` to run. The only allowed in-tool elev is wrapping **chmod** / **chown** of that folder (check before sudo). **MUST NOT** sudo otherwise. **MUST NOT** queue, dest-write, `setup`, or `approve`. Dest review / queue / host install **MUST NOT** count as that tester. Help **MUST** list test-purpose verbs **apart** from **operational** verbs. Dual mention: CLI-interface REQ **and** dest catalog / domain SSOT. This product: `fence-test --file tests/fixtures/fence-test/pass/20260821-alice-add-1.json`. Per-row testers **MAY** also exist (`test-json-format`) and are also test-purpose. Privilege Type 0 does **not** mean “unit test.”

### 2.10 Coding-style related requirement (MUST have)

40. This software-development product **MUST** have an Active coding-style related requirement matching the primary language.  
41. **Intention:** without that REQ, agents bring portable learned lessons **raw** and treat them as this product’s law. That REQ is the **specialize-in home** (adopt, point, or refuse).  
42. This product: Active `requirement-shell-script-coding` (POSIX `/bin/sh`). This class file **points**; it does **not** keep the writing-style body.  
43. **MUST NOT** skip. Honest residual **none** is **not** valid.

### 2.11 In-tool sudo / chmod wrappers

44. This ship unit invokes sudo inside the script. Active `requirement-shell-sudo-command` **MUST** own the sudo-wrapping function, check before sudo, and the chmod example.  
45. Coding-style **points** at that file. This class file **points**. **MUST NOT** keep wrapper bodies only on the coding-style REQ.

### 2.7 Implementation Notes (this project)

| Field | Value (dns-cli) |
|-------|---------------------|
| **Project display name** | `dns-cli` |
| **Project class** | software-development |
| **Class requirement basename** | `requirement-class-software-dev.md` |
| **Primary language(s)** | `posix-sh` (`/bin/sh`) |
| **Language role** | primary only — single-file shell ship unit under `src/` |
| **Execution model** | **interpreted** — no compile step |
| **Toolchain / interpreter** | POSIX `/bin/sh` (dash/bash-as-sh compatible subset); no compiler |
| **JSON extract tools (runtime residual)** | `python3` **or** `jq` (exactly one required at run time for domain JSON; not a second language) |
| **External HTTPS client** | `curl` (ipinfo.io + Cloudflare API; grants are whitelist surface, not this file) |
| **Toolchain version policy** | **unconstrained** among POSIX sh implementations that pass product tests when present |
| **Cross-compile in scope?** | no |
| **Primary project/package tool** | **none** — no language module system; ship unit is the source |
| **Lockfile policy** | not used |
| **Test runner** | POSIX shell suite under `tests/` when present (`tests/run.sh` pattern) |
| **Linter/formatter** | none as project law (shellcheck optional for maintainers) |
| **Primary runtime / OS family** | POSIX Linux (and compatible UNIX where `/bin/sh` + `mktemp` + `date` exist) |
| **Architectures supported** | any arch with POSIX sh and the external tools the script invokes |
| **Git surface** | used when product is published; forge target `cloudgen/dns-cli` (repo may be created after identity retarget) |
| **Ship unit / install** | `src/dns-cli` → `${USER_BIN}/dns-cli` (default `~/.local/bin/dns-cli`); **local-only** |
| **Product version SSOT** | `VERSION="1.9.7"` hard-assign in `src/dns-cli` |
| **Bootstrap origin** | **A = `cli-template`** (hop 0, sibling origin). **This product is B = `dns-cli` (hop 1).** |

**Residual ownership table:**

| Topic | Owner | Notes |
|-------|-------|--------|
| Project class membership | **this file** | Fixed |
| Primary language + toolchain policy | **this file** | posix-sh, unconstrained |
| Package/build tool + lockfile | **this file** | none / not used |
| Bootstrap lineage / keep-trim | `requirement-bootstrap-chain` | this product is hop 1; origin A = cli-template |
| Project layout / ship path | `requirement-project-folder` | `src/` + bin targets; vault pointer only |
| Type 0 CLI surface / flags / dispatch | `requirement-shell-cli-interface` | Do not duplicate |
| Empty argv Type N help | `requirement-shell-cli-zero-arguments` | Local-only |
| Local self-managed lifecycle | `requirement-shell-local-self-management` | install / uninstall / where-is-me |
| Output SSOT (`out_*`) | `requirement-shell-output-requirements` | Do not duplicate |
| Scratch/cache storage resolve | `requirement-shell-cli-storage` | Do not duplicate |
| Idempotency / re-run safety | `requirement-shell-idempotency` | Do not duplicate |
| Interactive vs non-interactive | `requirement-shell-interactive-vs-noninteractive` | Do not duplicate |
| Modular prefixes / single-file layout | `requirement-shell-modular-function-design` | Do not duplicate |
| Actor / role / subject / approver consider | `requirement-actor-role-subject-approver` | MUST consider even if no approver; dest who stays on `requirement-dns-actor-table` |
| Dest fence catalog | `requirement-approval-fencing-condition` | Closed dest refuse list; dest tables still print |
| Dest fence conditions review | `requirement-incorrect-json-format` | Converted dest **Fence** row; dest tables still print the catalog; Type 0 `test-json-format`; list tester `fence-test` |
| Coding-style related REQ | `requirement-shell-script-coding` | **MUST**; specialize-in home for portable POSIX writing lessons; residual **points** |
| In-tool sudo / chmod wrappers | `requirement-shell-sudo-command` | Sudo-wrapping function; check before sudo; chmod example |
| Prompt helper bodies | `requirement-shell-prompt` | `prompt_yes_no` / `prompt_ask`; mode policy stays interactive REQ |
| Scratch leaves | `requirement-shell-temp-file-system` | `mktemp`; no `$$` names; storage root stays storage REQ |
| What is blocked vs must stay open | `requirement-privilege-prevention-set` | Closed prevention catalog; do not invent walls; Type 2 remains open |
| Privilege / LPU / Type 0/1/2 | `requirement-least-privilege-user` + `requirement-three-layer-privilege-model` | `dns-adm`; dest `/etc/dns-adm/sudoers`; backups **MUST** use `/etc/sudoer-backup/` and **MUST NOT** land under `/etc/sudoers.d/` |
| JSON sudoer file / Type 0 generate+submit | `requirement-sudoer-json-file` | Two kinds: `type-2-switch` (Type 0 submit) and `login-hook-elev` (setup auto-queue); `print-sudoers` is three-layer + this file’s peer; this product **MUST NOT** write `/etc/sudoers.d` |
| Sudoers-manager extras (`print-sudoers-install-script`, `remove-project-sudoers`) | **intentionally absent** | Not this product’s domain. Generate/submit are **not** extras. |
| Folder archive backup / restore / retention | **intentionally absent** | Not this product’s domain (sibling folder-backup) |
| Domain surface (DNS catalog) | `requirement-domain-cloudflare-dns` | **current domain SSOT** — four pillars; consumes API law |
| Cloudflare API (HTTPS / envelope / DNS CRUD) | `requirement-cloudflare-api` | capability law; **not** a second domain catalog |
| External / public IPv4 lookup | `requirement-external-ipv4` | capability law; **not** a second domain catalog |
| Application local vault (path + specify) | `requirement-application-local-vault` | default `${SYSTEM_USER_HOME}/.local/vaults/dns-cli/` + `--vault-dir` / `CF_VAULT_DIR` |
| Cloudflare vault (schema/token/verbs) | `requirement-cloudflare-vault` | multi-account; domain-id = apex; consumes local-vault path |
| Online install / remote self-management / companion checksum | **intentionally absent** | Local-only channel |

---

## 3. Why This Requirement Exists (Direct CIAO Alignment)

- **CIAO Principle 2 – Intentional**: Class and stack choices are explicit, not assumed from folder names.  
- **CIAO Principle 5 – SSOT**: Residual stack facts have one home until specialized requirements take ownership.  
- **CIAO Principle 1 – Caution**: Toolchain policies are declared; agents do not invent compilers or online install.  
- **CIAO Principle 21 – Dual Policies**: Portable core; filled Implementation Notes.  
- **CIAO Principle 4 (O) + Principle 20**: Protection Rule against dual stack SSOTs and wrong-class pollution.

---

## 4. Design Principles (CIAO / CIAO-Lite)

- **Caution**: Assume toolchain and package tools are missing until declared and verified.  
- **Intentional**: Residual collection is deliberate — not a dump of every possible tool.  
- **Anti-fragile**: Unconstrained POSIX sh policy survives multi-env runs when tests pass.  
- **Over-protect**: Protection rule prevents dual stack SSOTs and genesis/class confusion.

---

## 5. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Delete this file while the workspace remains **software-development** with other Active product requirements.  
2. Rename the specialized basename away from `requirement-class-software-dev.md` without an explicit class-model change.  
3. Hard-code secrets, personal owner identity, or production host FQDNs into core rules as universal law.  
4. Duplicate full peer requirement bodies into this residual section.  
5. Leave Implementation Notes as hollow stubs when Status claims Active.  
6. Reintroduce Active **online-install** / remote **self-update** / **self-uninstall** / channel **checksum** law without explicit user order (product is **local-only** by design).  
7. Treat this file as server-maintenance allowlist law, or register an Active server-maintenance class file in parallel.  
8. Invent a second primary language SSOT that contradicts peer modular/CLI requirements.  
9. Skip the actor / role / subject / approver consider, or invent an approver so the table looks complete.  
10. Skip dest-fence review, leave a dest **Fence** as only a table cell, invent a dest fence, leave dest Fences without Type 0 `fence-test`, treat `sudo` / a sudoers fragment / the waiting folder as that tester, group testers with operational verbs in help, or `sudo` on a tester except wrapping chmod/chown of the local test folder.  
11. Leave dest **approval fencing conditions** as only terminology or dest-table cells while dest review exists.  
12. Skip the coding-style related REQ, leave writing style only as residual “when present”, or treat coding skills as product law.  
13. Skip `requirement-shell-sudo-command` while the ship unit has in-tool sudo, or keep wrapper bodies only on the coding-style REQ.  
14. Copy sibling Type 2 absence or “any euid-0 host admin dest-approves DNS” into this product’s prevention catalog.

**Violating any of these is considered a critical regression.**

---

## 6. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | Active registered `requirement-class-software-dev.md` matches software-development class |
| AC-2 | Primary language + toolchain policy + package tool declared in Implementation Notes (complete) |
| AC-3 | Residual ownership table honest: no silent dual SSOT with peer REQs |
| AC-4 | Core rules remain free of frozen secret/host hardcodes |
| AC-5 | No class file conflict with `requirement-class-server-maintenance` |
| AC-6 | Ship unit identity (posix-sh single-file, local install) consistent with peer shell REQs |
| AC-7 | Online install package **absent** from Active registry by design |
| AC-8 | Actor / role / subject / approver considered (Active catalog REQ or residual **None**) |
| AC-9 | Dest fence conditions reviewed (independent REQ per **Fence**, or residual **none**); dest Fences ship Type 0 **test-purpose** `fence-test` (local test folder; help listed apart from operational) |
| AC-10 | Dest fence catalog is Active `requirement-approval-fencing-condition` while dest review exists (or residual **none**) |
| AC-11 | Active `requirement-shell-script-coding` (specialize-in home; residual points) |
| AC-12 | Active `requirement-shell-sudo-command` while in-tool sudo exists |
| AC-13 | JSON-format dest Fence names Type 0 `test-json-format` |
| AC-14 | Dest Fences ship Type 0 **test-purpose** `fence-test` (`--file` / `--dir`; local test folder; testers listed apart from operational) |

---

## 7. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-bootstrap-chain` | This product is hop 1; origin A = cli-template |
| `requirement-domain-cloudflare-dns` | Domain SSOT |
| `requirement-cloudflare-vault` | Vault law |
| `requirement-cloudflare-api` | HTTPS API capability |
| `requirement-least-privilege-user` | `dns-adm` F1–F7 |
| `requirement-three-layer-privilege-model` | Type map + Tables A/B/C |
| `requirement-project-folder` | Layout and install locations |
| `requirement-actor-role-subject-approver` | Actor / role / subject / approver catalog (consider even if no approver) |
| `requirement-approval-fencing-condition` | Dest fence catalog (closed dest refuse list) |
| `requirement-incorrect-json-format` | Independent dest **Fence** REQ (this product’s dest refuse reason); Type 0 `test-json-format`; list tester `fence-test` |
| `requirement-shell-script-coding` | POSIX writing-style specialize-in home |
| `requirement-shell-sudo-command` | In-tool sudo wrappers |
| `requirement-shell-prompt` | `prompt_*` bodies |
| `requirement-shell-temp-file-system` | Scratch leaves |
| `requirement-privilege-prevention-set` | Closed prevention catalog |
| `requirement-shell-cli-interface` | Command surface, flags, dispatch |
| `requirement-shell-cli-zero-arguments` | Type N empty argv |
| `requirement-shell-local-self-management` | Local install lifecycle |
| `requirement-shell-output-requirements` | `out_*` SSOT |
| `requirement-shell-cli-storage` | Scratch/cache resolve |
| `requirement-shell-idempotency` | Re-run safety |
| `requirement-shell-interactive-vs-noninteractive` | Mode policy |
| `requirement-shell-modular-function-design` | Prefixes / single-file modularity |
| `docs/requirements/index.md` | Registry SSOT |

---

## 8. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-03 | Active | Specialized class law for folder-backup (left genesis; bootstrap trim from selfmanaged) |
| 2026-08-13 | Active 1.1.0 | Retarget to cli-template; drop domain/privilege residual owners |
| 2026-08-13 | Active 1.2.0 | Bootstrap origin = selfmanaged; folder-backup hop retired (no longer maintain bootstrap from it) |
| 2026-08-13 | Active 1.3.0 | This product is hop 0; selfmanaged is not origin |
| 2026-08-21 | Active 1.10.0 | Dest Fences ship Type 0 **test-purpose** `fence-test` (local test folder; help listed apart from operational) |
| 2026-08-20 | Active 1.9.1 | Coding-style MUST have; in-tool sudo residual points; prevention-set / prompt / temp peers |
| 2026-08-19 | Active 1.8.0 | Dest fence catalog is an independent REQ; dest-owned `kind` is format allowlist not a dest fence |
| 2026-08-19 | Active 1.7.0 | MUST review dest fence conditions; each Fence row is an independent REQ |
| 2026-08-19 | Active 1.6.0 | MUST consider actor / role / subject / approver even if no dest approver |
| 2026-08-17 | Active 1.5.0 | Privilege residual → LPU + three-layer (`dns-adm`) |
| 2026-08-16 | Active 1.4.0 | Specialize B = dns-cli; domain + vault residual owners; curl + python3/jq |

---

**Last Updated**: 2026-08-21  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
