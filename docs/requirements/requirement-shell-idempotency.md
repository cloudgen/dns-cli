**file**: docs/requirements/requirement-shell-idempotency.md  
**Status**: Active (Version 1.1.0)  
**Area**: shell  
**Key**: `requirement-shell-idempotency`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **project Single Source of Truth** for **idempotency (re-run safety)** of state-changing operations in the cli-template POSIX shell CLI.

**Informal formula:** for ensure-style operation *f* and system state *x*, **f(f(x)) ≈ f(x)** for the **desired outcome** (logs and timestamps may differ).

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 What must be idempotent

Every **state-changing** shell operation that **ensures** a desired configuration **MUST**:

1. **Detect** whether the desired state already holds.  
2. **Skip or no-op** unsafe work when it does.  
3. **Succeed** when already achieved — **MUST NOT** fail solely because state “already exists.”  
4. **Avoid duplicates** (binary installs, PATH lines).  
5. **Leave the system consistent** on every run (including partial prior installs).  
6. **Communicate** clearly when already done in human mode; respect quiet/json via output SSOT.

### 2.2 What a second run must not do

| Forbidden when desired state already holds | Prefer |
|--------------------------------------------|--------|
| Fail solely because state exists | Success + “already installed / nothing to uninstall” |
| Create duplicate managed binaries | Existence check first |
| Overwrite a correct install without force | No-op unless force |
| Leave half-applied worse state | Atomic steps; cleanup temps; fail loud |

### 2.3 Force override

Force policy (`--force` / `FORCE=1`) **MAY** re-apply ensure steps that would otherwise no-op **only** when documented. Force **MUST NOT** silently skip path validation.

### 2.4 Implementation Notes — command matrix (this project)

| Command / path | Desired state | Re-run when already good | Force / special |
|----------------|---------------|--------------------------|-----------------|
| `install` | Managed binary present at privilege-correct path | Success no-op (mode heal still runs) | `--force` replaces from running ship unit |
| `uninstall` | Managed binary absent | Success no-op | `--force` skips confirm |
| `where-is-me` / `version` / `about` / `help` | Read-only | Always safe | N/A |

### 2.5 Why This Requirement Exists (CIAO)

- **Principle 1 – Caution**: Re-runs must not corrupt installs.  
- **Principle 3 – Anti-fragile**: Safe to re-invoke.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- Detect → ensure → success-if-done for lifecycle.  
- Fail closed on permission and path errors (idempotency ≠ never error).

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Make `install` fail when already installed (force off).  
2. Treat idempotency as permission to ignore validation failures.  
3. Remove atomic install/stage patterns for “speed.”  
4. Reintroduce archive next-N overwrite rules as if backup were still product law.

**Violating this rule is a critical re-run safety regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | Second `install` without force is success no-op |
| AC-2 | Second `uninstall` when absent is success no-op |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-shell-local-self-management` | Install/uninstall ensure |
| `requirement-shell-cli-interface` | Force flag wiring |
| `docs/requirements/index.md` | Registry |

---

## Design-time verification

| TP family / ID | Suite | Status |
|----------------|-------|--------|
| **TP-LC-03,07** | `tests/test_local_lifecycle.sh` | have |

**Matrix:** `reviews/requirement-test-matrix.md`  
**Map:** `reviews/test-plan.md`

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-03 | Active 1.0.0 | folder-backup lifecycle + archive numbering |
| 2026-08-13 | Active 1.1.0 | cli-template: lifecycle only |

---

**Last Updated**: 2026-08-13  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
