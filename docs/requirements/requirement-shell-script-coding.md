**file**: docs/requirements/requirement-shell-script-coding.md
**Status**: Active (Version 1.1.0 — aligned to POSIX shell coding mold; own-or-point)
**Area**: shell
**Key**: `requirement-shell-script-coding`
**id**: RQ-SHELL-SCRIPT-CODING
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **specialize-in home** for how the dns-cli POSIX `/bin/sh` ship unit is written.

**Intention:** without this file, agents bring portable learned lessons **raw** and treat them as this product’s law. With this file, those lessons are **adopted here**, **pointed** at a peer requirement that already owns the slice, or **refused**.

**Core intention (adopted):** produce a script that is portable across dash / bash-as-sh / BusyBox, safe to re-run, explicit (no hidden `set -e` exits), heavily documented, and maintainable. This product is **local-only** — **refuse** `curl | sh` empty-argv install-ensure as writing law.

This file is **not** a second copy of output, prefix, TTY-measure, prompt-body, temp-leaf, or sudo-wrapper tables.

### 1.1 Human-facing

**In one sentence:** How this program is written lives here so agents do not paste portable style into `src/dns-cli` as if it were already law.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | One POSIX script | `src/dns-cli` |
| The other role | Peer files own slices | `out_*` on the output requirement |
| Not this file | Dest JSON fences, DNS verbs | `requirement-incorrect-json-format` |

| Includes | Excludes |
|----------|----------|
| Shebang; function header template; SSOT of constants/args; quote vars; `.` not `source`; `command -v`; no `set -e`; `set -u` **adopted**; `/dev/tty` openability; rc `chown` after `mv`; check before sudo (**points**) | Duplicating `out_*` printers, prefix catalogs, TTY-measure tables, `prompt_*` bodies, `mktemp` samples, `util_sudo` / `util_chmod` bodies |

| Surface | What you open | What for |
|---------|---------------|----------|
| `src/dns-cli` | ship unit | the code this style governs |
| `docs/requirements/index.md` | registry | this row + peers |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Change a helper | Follow this file and the peers it points at. Do not import a portable lesson that this product did not adopt. | (edit `src/dns-cli`) |

---

## Design-time verification

| Gate | Artifact | Phase |
|------|----------|-------|
| Style / writing law | **n/a** — review-time; no unique TP family | Design |
| Syntax | **TP-CLI-01** (`sh -n`) | Proof |
| Nounset / HOME-before-path | **TP-CLI-11** (`env -u HOME`) | Proof |
| TTY measure outside functions | **TP-ELEV-07** family when Type 1 TTY is in suite; else review-time | Proof |

---

## 2. Core Rules (Mandatory)

### 2.0 Specialize-in home (sacred)

1. **MUST** treat this file as the product home for portable POSIX writing lessons.  
2. **MUST NOT** apply a portable coding lesson as product law unless this file **adopts** it or a **pointed peer** already owns it.  
3. **MUST NOT** skip this file and treat a coding skill as product law.  
4. When a new lesson is learned in a portable mold and this product should keep it, **MUST** specialize it **here** (or move ownership to the correct peer) in the **same change**.  
5. **MUST NOT** duplicate full normative tables that live on peer requirements.

### 2.0a Pointed peers (do not duplicate)

| Slice | Owner | This file |
|-------|-------|-----------|
| `out_*` printer, JSON/quiet, operator `Next:` | `requirement-shell-output-requirements` | Point only |
| Function prefixes (`out_`, `inst_`, `app_`, `cf_`, `lpu_`, `prompt_*`, …) | `requirement-shell-modular-function-design` | Point only |
| Interactive vs non-interactive; `[ -t` **outside** functions | `requirement-shell-interactive-vs-noninteractive` | Point only |
| `prompt_yes_no` / `prompt_ask` bodies | `requirement-shell-prompt` | Point only |
| Scratch leaves (`mktemp`; no `$$` names) | `requirement-shell-temp-file-system` | Point only |
| Re-run install/uninstall | `requirement-shell-idempotency` | Point only |
| In-tool sudo / chmod wrappers | `requirement-shell-sudo-command` | Point only |
| Login-hook rc dest owner (`dns-adm`) | `requirement-least-privilege-user` (L-M9) · `requirement-dns-approver` | Point dest who; **adopt** write rules in §2.10 |

### 2.1 Interpreter and portability

6. **MUST** use `#!/bin/sh` on the ship unit.  
7. **MUST** stay in the POSIX `/bin/sh` subset that product tests pass (dash / bash-as-sh / BusyBox).  
8. **MUST NOT** add bashisms as default style: arrays, `[[ ]]`, process substitution `<(…)`, here-strings.  
9. **MUST** quote expansions: `"${VAR}"`.  
10. **MUST** prefer `.` over `source` when sourcing.  
11. **MUST** use `command -v` instead of `which`.  
12. Path handling **SHOULD** stay POSIX. Git Bash on Windows is **not** a claimed runtime for this product (Implementation Notes).

### 2.2 Function naming (point + residual)

13. Every new function **MUST** use a defined prefix. Full catalog: `requirement-shell-modular-function-design`.  
14. Names **MUST** be `snake_case` after the prefix.  
15. **MUST NOT** use bare function names `install`, `main`, `helper`, `about`, `help`. User-facing **commands** may stay short words.  
16. **MUST NOT** put domain ops under `app_*`. Domain prefix on this product is `cf_` (Cloudflare) and `lpu_` (account / sudoer submit). **MUST NOT** invent `hm_*` / `fb_*`.

### 2.3 Function structure template (adopted)

Every non-trivial function **MUST** follow this header + defaults shape:

```sh
# =============================================================================
# function_name() - Short one-line purpose
# =============================================================================
#
# GENERAL PURPOSE:
# Clear one-paragraph explanation of what this function does and why it exists.
#
# CIAO PRINCIPLES APPLIED:
# - Caution (Principle 1): ...
# - Intentional (Principle 2): ...
# - Anti-fragile (Principle 3): ...
# - Over-protect (Principle 4 / CIAO-Lite O · Principle 20): ...
#
# !!! DO NOT MODIFY OR SIMPLIFY THIS FUNCTION !!!
#
# Lessons Learned (CIAO Reflection):
# [Date]: [Short note when fixing regressions]
#
# Last reviewed: YYYY-MM-DD
# =============================================================================

function_name() {
    : "${VAR1:=default}"
    : "${VAR2:=default}"
    # main logic
}
```

17. The full header comment block **MUST** be present on non-trivial helpers.  
18. Critical helpers **MUST** keep `!!! DO NOT MODIFY OR SIMPLIFY THIS FUNCTION !!!`.  
19. Safe variable defaults using `: "${VAR:=default}"` **MUST** appear at the top of the function body for every live variable.  
20. The CIAO PRINCIPLES APPLIED section **SHOULD** be filled meaningfully.  
21. **MUST NOT** strip headers or Protection Zones to “clean up” working code.  
22. New or modified control flow **MUST** use explicit `if` / `then` / `else` / `fi`. **MUST NOT** use `command \|\| { … }` or `command && { … }` except already-stable one-liners inside Protection Zones.  
23. **MUST NOT** rewrite a working function for style, cleanliness, or modernization. Touch it for a bug, a requirement violation, or an explicit redesign.  
24. Nested `case` **SHOULD** stay flat; extract a named helper instead of cascading cases.  
25. When an error occurs, provide context and perform reasonable cleanup before returning or exiting (via `out_*` / `out_die_code`).

### 2.4 Product-source citation

26. Product-source `ALIGNMENT` / “see” comments **MUST** cite only live `docs/requirements/requirement-*.md` rows registered in `index.md`.  
27. **MUST NOT** paste template or skill basenames into the ship unit as behavioral authority.  
28. **MUST NOT** invent or leave stale `requirement-*.md` names in source headers. Incident IDs in lessons comments are allowed.

### 2.5 SSOT of values, input, output

29. Important constants, defaults, and Config **MUST** have one source (script top / Config block). **MUST NOT** hardcode the same value in many places.  
30. Command-line arguments, environment, and interactive input **MUST** be parsed in one place (`app_main` flag loop). After parse, helpers **MUST** consume internal variables only.  
31. All user-facing and machine-readable output **MUST** go through `out_*`. **MUST NOT** use raw `echo` / `printf` for product messages outside approved output helpers. Full printer law: `requirement-shell-output-requirements`.

### 2.6 Nounset and `set -e` (this product)

32. **MUST NOT** use global `set -e` or `set -eu`. Errors **MUST** be explicit (`out_die` / `out_die_code` / return codes).  
33. **Adopted (this product, against the portable mold default):** the ship unit **MUST** run with `set -u`.  
34. Under `set -u`, every bare expansion on a live path **MUST** have a prior default or arity check.  
35. **MUST** default `HOME` (or the approved substitute) **before** any `${HOME}/…` path.  
36. **MUST NOT** hide nounset abort by discarding stderr on external `.` / `source`.

### 2.7 Elevation writing (TTY / `sudo -n`)

TTY **measure** stays on `requirement-shell-interactive-vs-noninteractive`. Sudo **wrappers** stay on `requirement-shell-sudo-command`. This section owns **how agents write** elev examples.

37. Interactive capability **MUST** be measured in the main process, outside functions. Helpers **MUST consume `TTY`**. **MUST NOT** bury `[ -t 0 ]` / `[ -t 1 ]` in string-returning helpers that are only called via `$(…)`.  
38. **MUST NOT** treat `/dev/tty` **existence** as interactive. Require a successful open, e.g. `( : </dev/tty ) 2>/dev/null`, before password-sudo mode.  
39. **MUST NOT** use `[ -t 0 ]` inside `$(helper)` as the **sole** gate for interactive password sudo.  
40. Prefer a **direct** setter that assigns a mode variable over `mode=$(detect)` when detect needs live TTY policy.  
41. **MUST NOT** paste `sudo -n` into the ship unit, help, or examples unless a live privilege requirement **names** the NOPASSWD grant or login hook. First-time `setup` uses password `sudo` or an already-root session.  
42. Help **MUST** show `sudo dns-cli setup`, not `sudo -n dns-cli setup`.  
43. Password sudo **SHOULD** bind the prompt to the controlling terminal (`sudo … </dev/tty`) when stdin may be redirected.  
44. JSON / non-interactive paths **MUST NOT** hang on password prompts; fail closed.  
45. Table A is F6 / `print-sudoers` only. Table C (`useradd` / `userdel`) is in-tool password `sudo`, **not** a sudoers Cmnd. **MUST NOT** write “ship unit MUST NOT invoke `sudo`” as default law.  
46. Named `-n` exceptions on this product: login-hook `sudo -n … interactive` (F6 text); Type 2 `sudo -n -u dns-adm` of the managed global binary (`requirement-three-layer-privilege-model` P-M4).

```sh
# Measure in main (app_main). Existence of /dev/tty is NOT enough.
TTY=0
[ -t 0 ] && [ -t 1 ] && TTY=1
if [ "${TTY}" -eq 0 ] && [ -c /dev/tty ] 2>/dev/null && ( : </dev/tty ) 2>/dev/null; then
    TTY=1
fi
```

### 2.8 Check before sudo (point)

47. In-tool sudo **MUST** use the sudo-wrapping function and check before sudo. **chmod example:** `[ -O path ]` then no `sudo chmod` on match.  
48. **Owner:** `requirement-shell-sudo-command` (`util_sudo` / `util_chmod`). This file **points**; it does **not** keep the wrapper bodies.  
49. **MUST NOT** probe with `sudo ls` / `sudo stat`.

### 2.9 User-owned shell rc (writing)

Dest **who** (owner must be `dns-adm`) stays on `requirement-least-privilege-user` L-M9 / `requirement-dns-approver`. This section owns **how** the rewrite is coded.

50. When Type 1 `setup` / heal creates or rewrites another login’s `.profile` / `.bashrc` (including `mktemp`+`mv`):  
    - Owner **MUST** be the corresponding user, not the elevated invoker.  
    - Mode **MUST** be readable by that user (typical `0644`). **MUST NOT** leave `0600` `root:root`.  
    - After `mktemp`+`mv`, **MUST `chown` again** — `mv` keeps the temp’s owner.  
    - When `getent passwd` succeeds, `chown` failure is **fatal**. **MUST NOT** `chown … \|\| true`.  
    - **MUST NOT** overwrite an existing `.profile` body. Heal owner/mode only.  
    - **MUST NOT** write another login’s rc.

```sh
chmod 0644 "${_rc}" || return 1
if getent passwd "${_user}" >/dev/null 2>&1; then
    chown "${_user}:${_group}" "${_rc}" || return 1
fi
```

### 2.10 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **Ship unit** | `src/dns-cli` |
| **Primary language** | posix-sh (`#!/bin/sh`) |
| **Global `set -e`** | **Forbidden** — explicit `out_die` (Implemented) |
| **Global `set -u`** | **Adopted** — `set -u` at script top; HOME before paths (Implemented) |
| **Linter / formatter as law** | **none** — `shellcheck` optional for maintainers |
| **Domain prefixes** | `cf_` / `lpu_` (owned on the modular requirement) |
| **Git Bash / Windows** | **Not** a claimed runtime |
| **Online `curl\|sh` / Type O empty-argv** | **Refused** — local-only |
| **Adopted portable lessons** | POSIX shebang; function header template; Protection Zones; explicit `if`; respect working code; live-requirement ALIGNMENT; SSOT of Config/args; quote vars; `.` not `source`; `command -v`; `/dev/tty` openability; rc `chown` after `mv`; check before sudo + sudo-wrapping (bodies on `requirement-shell-sudo-command`) |
| **Refused portable lessons** | Mold default “MUST NOT `set -u`”; online-install / `curl\|sh`; treating `sudo -n` as default elev; Type 2 absence (this product **has** Type 2); “ship unit MUST NOT invoke sudo” |

**Mold-section map (this specialization):**

| Portable mold topic | This product |
|---------------------|--------------|
| Prefix catalog | Point — modular-function-design |
| Function structure / headers | **Adopt** §2.3 |
| Output printers | Point — output-requirements |
| Args parse SSOT | **Adopt** §2.5 (`app_main`) |
| `.` / `command -v` / quote / no bashisms | **Adopt** §2.1 |
| No `set -e` | **Adopt** §2.6 |
| No `set -u` (mold default) | **Refuse** — this product **uses** `set -u` |
| TTY measure / no-retest | Point — interactive REQ; writing residual §2.7 |
| `sudo -n` unless specified | **Adopt** §2.7 |
| Wrapper bodies / `[ -O ]` chmod | Point — sudo-command |
| Rc owner after `mv` | **Adopt** writing §2.9; dest who on LPU / approver |
| `curl \| sh` harsh-install | **Refuse** |

### 2.11 Why This Requirement Exists (Direct CIAO Alignment)

- **CIAO Principle 2 – Intentional**: Writing style is chosen here, not assumed from a portable skill.  
- **CIAO Principle 5 – SSOT**: One home for specialized writing lessons; peers keep their slices.  
- **CIAO Principle 16**: TTY measured outside functions; helpers consume `TTY`.  
- **CIAO Principle 20 / CIAO-Lite O**: Protection Zones and “do not rewrite working code” stay product law.  
- **CIAO Principle 21 – Dual Policies**: Portable lessons stay in molds; this file is complete product law.  
- **CIAO Principle 10 / 22**: Check before sudo. Example: do not `sudo chmod` when this login already owns the path.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution**: Assume a missing coding-style file means portable lessons will leak in raw.  
- **Intentional**: Adopt, point, or refuse — never silent import.  
- **Anti-fragile**: POSIX subset + `set -u` + respect working code survive harsh hosts and later agents.  
- **Over-protect**: This file exists so the next agent cannot treat a coding skill as dns-cli law.

---

## 4. Protection Rule (Sacred)

**Future AI assistants or maintainers MUST NOT**:

1. Delete this file while the workspace remains software-development with a POSIX ship unit.  
2. Apply a portable writing lesson as product law without adopting it here or pointing at the owning peer.  
3. Duplicate full `out_*`, prefix, TTY-measure, prompt, temp, or sudo-wrapper tables into this file.  
4. Rewrite working functions for style.  
5. Cite templates or skills as ship-unit ALIGNMENT.  
6. Paste `sudo -n` as default elev, or write first-time `setup` as `sudo -n dns-cli setup`.  
7. Change the shebang away from `#!/bin/sh` without an explicit product-language change.  
8. Treat “linter none” as permission to skip this requirement.  
9. Keep sudo-wrapping / check-before-sudo bodies here instead of `requirement-shell-sudo-command`.  
10. Probe with `sudo ls` / `sudo stat` to decide whether to sudo.  
11. Introduce `set -e` / `set -eu`, or remove `set -u` without an explicit product-language change.  
12. Use `source` instead of `.`, or `which` instead of `command -v`.  
13. Use `[ -t 0 ]` / `[ -t 1 ]` **inside functions** (especially under `$(…)`) as the sole gate for interactive sudo or prompt policy.  
14. Leave rewritten `.bashrc` / `.profile` owned by the elevated invoker, or swallow `chown` with `\|\| true` when the account exists.  
15. Put Table C tools (`useradd`, `userdel`) into `print-sudoers`.  
16. Write “ship unit MUST NOT invoke `sudo`” as default law.

**Violating any of these is a critical regression.**

---

## 5. Related artifacts (versioned surface only)

| Artifact | Role |
|----------|------|
| `docs/requirements/index.md` | Registry SSOT |
| `docs/requirements/requirement-class-software-dev.md` | Class residual **points** here |
| `docs/requirements/requirement-shell-sudo-command.md` | Wrapper bodies |
| `docs/requirements/requirement-shell-prompt.md` | Prompt bodies |
| `docs/requirements/requirement-shell-temp-file-system.md` | Scratch leaves |
| `docs/requirements/requirement-shell-modular-function-design.md` | Prefixes |
| `docs/requirements/requirement-shell-interactive-vs-noninteractive.md` | TTY measure |
| `docs/requirements/requirement-shell-output-requirements.md` | `out_*` |
| `docs/requirements/requirement-least-privilege-user.md` | Rc dest owner |
| `./src/dns-cli` | Ship unit |

## 6. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-20 | Active 1.1.0 | Aligned to POSIX shell coding mold: function structure, SSOT of args, `.`/`command -v`, `set -e` ban, `set -u` adopted, `/dev/tty` open, rc `chown`, elev writing; peers still own printers/prefixes/TTY/prompt/temp/sudo bodies |
| 2026-08-20 | Active 1.0.0 | Initial specialize-in home (thin own-or-point) |

**Last Updated**: 2026-08-20  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
