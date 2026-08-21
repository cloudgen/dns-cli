**file**: docs/requirements/requirement-shell-sudo-command.md
**Status**: Active (Version 1.0.0 – sudo-wrapping function; check before sudo; chmod example)
**Area**: shell
**Key**: `requirement-shell-sudo-command`
**id**: RQ-SHELL-SUDO-COMMAND
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **project Single Source of Truth** for **in-tool sudo**: the sudo-wrapping function, check before sudo, and the chmod example.

**Type map** stays on `requirement-three-layer-privilege-model`. **Writing-style home** stays on `requirement-shell-script-coding` (points here). Outer operator elev (`sudo dns-cli setup`) is **not** this file. Type 2 re-exec `sudo -n -u dns-adm` of the managed global binary stays on three-layer (NOPASSWD grant) — **MUST NOT** become this wrapper’s default.

### 1.1 Human-facing

**In one sentence:** The program calls sudo only through one helper. That helper checks without sudo first. If you already own the file, it does not sudo chmod.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | Mode on a file you own | `util_chmod 0640 request.json` |
| The other role | Already-root setup | `util_sudo useradd …` |
| Not this file | Outer password sudo of the CLI | `sudo dns-cli setup` |

| Includes | Excludes |
|----------|----------|
| `util_sudo`; `util_chmod`; check before sudo | Raw `sudo chmod`; default `sudo -n` inside the wrapper; dest queue owner as a fence |

| Surface | What you open | What for |
|---------|---------------|----------|
| `src/dns-cli` | ship unit | wrappers |
| `dns-cli help` | command | still shows outer `sudo … setup` |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Install as yourself | chmod of your copy does not sudo. | `sh src/dns-cli install` |

---

## Design-time verification

| Gate | Artifact | Phase |
|------|----------|-------|
| Wrappers exist; no raw `sudo chmod`; `sudo "$@"` only in `util_sudo`; owner probe skips sudo | **TP-SUDO-01..07** `tests/test_cli.sh` | Proof |

---

## 2. Core Rules (Mandatory)

### 2.1 Ownership

| Helper | Role |
|--------|------|
| `util_sudo` | **Sudo-wrapping function** — the only in-tool `sudo` call site for password sudo / already-root script jobs |
| `util_chmod` | chmod example: check before sudo via `[ -O path ]`, then `chmod` or `util_sudo chmod` |

1. In-tool `sudo` for Table C jobs **MUST** go through `util_sudo`.  
2. chmod that sets a product mode **MUST** go through `util_chmod`.  
3. **MUST NOT** write raw `sudo chmod` or a second `sudo "$@"` for those jobs.  
4. **MUST NOT** default to `sudo -n` inside the wrapper. F6 login-hook `-n` stays hook text. Type 2 `sudo -n -u dns-adm` of the **managed global** binary stays on `requirement-three-layer-privilege-model` (P-M4).

### 2.2 Check before sudo

1. **Before sudo**, probe **without** sudo.  
2. If this login already can, **MUST NOT** sudo.  
3. **Generic probe (util_sudo):** `id -u` = 0 → run `"$@"` without sudo.  
4. **chmod example (util_chmod):** `[ -O path ]` → `chmod` without sudo. Else `util_sudo chmod`. If the path is missing, return nonzero (caller dies or `|| true`).  
5. **MUST NOT** probe with `sudo ls` / `sudo stat`.

### 2.3 Sufficient samples (normative shape)

```sh
util_sudo() {
    : "${HOME:=/tmp}"
    if [ "$(id -u 2>/dev/null || echo 1)" -eq 0 ]; then
        "$@"
        return $?
    fi
    if ! command -v sudo >/dev/null 2>&1; then
        return 1
    fi
    sudo "$@"
}

util_chmod() {
    _mode="${1:-}"
    _path="${2:-}"
    [ -n "${_mode}" ] && [ -n "${_path}" ] || return 1
    [ -e "${_path}" ] || return 1
    if [ -O "${_path}" ]; then
        chmod "${_mode}" "${_path}"
        return $?
    fi
    util_sudo chmod "${_mode}" "${_path}"
}
```

### 2.4 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **Sudo-wrapping function** | `util_sudo` — **Gap** (ship still uses raw `exec sudo` / `sudo -n -u` at Type 1/2 sites; wrappers not yet the only call site) |
| **chmod helper** | `util_chmod MODE PATH` — **Gap** (inline `chmod` / `mktemp` modes remain) |
| **Outer elev** | Help still shows `sudo dns-cli setup` (not this wrapper) |
| **Named `-n` exceptions** | Login-hook `sudo -n … interactive` (F6 text); Type 2 `sudo -n -u dns-adm` of `${GLOBAL_BIN}/dns-cli` (P-M4) |

### 2.5 Why This Requirement Exists (Direct CIAO Alignment)

- **CIAO Principle 10**: Do not sudo when this login already can.  
- **CIAO Principle 5**: One sudo call site for password/script jobs.  
- **CIAO Principle 22**: chmod example uses the wrapper.  
- **CIAO Principle 20**: Do not scatter raw `sudo chmod`.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution**: Probe without sudo.  
- **Intentional**: Wrapper is the SSOT for password sudo.  
- **Anti-fragile**: Nested sudo after outer `sudo setup` does not prompt again.  
- **Over-protect**: chmod cannot skip the owner probe.

---

## 4. Protection Rule (Sacred)

**Future AI assistants or maintainers MUST NOT**:

1. Add a second in-tool `sudo` call site beside `util_sudo` for Table C jobs.  
2. Write `sudo chmod` outside `util_chmod`.  
3. Skip check before sudo inside the wrapper.  
4. Default the wrapper to `sudo -n`.  
5. Probe owner with `sudo ls` / `sudo stat`.  
6. Treat outer `sudo dns-cli setup` as this wrapper.  
7. Fold Type 2 `sudo -n -u dns-adm` into this wrapper as the default.

**Violating any of these is a critical regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | Active registered `requirement-shell-sudo-command.md` |
| AC-2 | Complete samples present (not a one-liner) |
| AC-3 | Coding-style and class residual **point** here |
| AC-4 | Type 2 `-n -u` remains three-layer, not this wrapper’s default |
| AC-5 | **TP-SUDO-01..07** **todo** until wrappers are shipped |

---

## 6. Related artifacts (versioned surface only)

| Artifact | Role |
|----------|------|
| `docs/requirements/index.md` | Registry SSOT |
| `docs/requirements/requirement-shell-script-coding.md` | Points here |
| `docs/requirements/requirement-three-layer-privilege-model.md` | Type map + Type 2 `-n` |
| `./src/dns-cli` | Ship unit |

**Last Updated**: 2026-08-20  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
