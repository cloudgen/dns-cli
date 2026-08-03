# Report: full product — folder-backup 1.0.0

**Date:** 2026-08-03  
**Mode:** full product review (requirements + ship unit + tests)  
**Status:** open items (docs / root deposit) · **core suite green**

## Summary

Left-genesis **software-development** product **folder-backup** was reviewed against live requirements and a new isolated test suite. Architecture inheritance from **selfmanaged** with **online install trimmed** holds. Domain backup + narrow sudoers workflow matches law for non-root fail-closed deposit. Product user docs (README/SECURITY/CHANGELOG) are still absent. Root-only full deposit + next-N remain SKIP in non-root CI.

**Suite:** `./tests/run.sh` → **PASS=82 FAIL=0 SKIP=2 RESULT: OK**

## Lessons re-check

| Lesson | Result this run |
|--------|-----------------|
| L-TYPE-N-01 | PASS — empty argv is help (TP-CLI-07) |
| L-ONLINE-01 | PASS — online verbs rejected; help clean |
| L-UNIN-01 | PASS — JSON uninstall without force fails closed |
| L-DEPOSIT-01 | PASS — deposit fails without sudoers |
| L-SUDOERS-01 | PASS — no /etc write; no ALL ALL |
| L-OVERWRITE-01 | PARTIAL — naming covered; full next-N SKIP non-root |
| L-SETU-01 | PASS — env -u HOME version works |
| L-STOR-01 | PASS — effective_storage exists under isolation |

## Issues

### Issue 1 — Severity: suggestion

- **File:** product root (missing)  
- **Description:** No root `README.md` / `CHANGELOG.md` / `LICENSE.md` / `SECURITY.md` yet; operators lack install/sudoers documentation outside requirements.  
- **Suggestion:** Run software-dev housekeeping + write-readme / MIT / SECURITY skills.  
- **Lesson:** —  
- **Test:** n/a (docs)  
- **Status:** open  

### Issue 2 — Severity: suggestion

- **File:** `tests/test_domain_folder_backup.sh` TP-FOLDER-BACKUP-07/08  
- **Description:** Full deposit + next-N only run as root; CI non-root SKIPs.  
- **Suggestion:** Optional root job or injectable deposit hook for unit test; keep fail-closed path as Core.  
- **Lesson:** L-OVERWRITE-01  
- **Test:** TP-FOLDER-BACKUP-07/08  
- **Status:** open (honest skip)  

### Issue 3 — Severity: nit

- **File:** `src/folder-backup` (`path_add_shell` after install)  
- **Description:** PATH integration may emit fish/shell tips; acceptable inheritance from parent path helpers.  
- **Suggestion:** Confirm PATH helpers stay optional; no change required for Pass.  
- **Status:** open (watch)  

### Issue 4 — Severity: suggestion

- **File:** `src/folder-backup` `fb_print_sudoers`  
- **Description:** Sudoers wildcards are host-path sensitive (HOME/storage tiers). Admin must validate with `visudo -c` on target host.  
- **Suggestion:** Document in README; consider fixed deposit helper binary later if wildcards prove fragile.  
- **Lesson:** L-SUDOERS-01  
- **Status:** open  

## Strengths

- Clear local-only Type 0 package + domain four pillars in law  
- Suite isolation (temp HOME) and offline Core path  
- Fail-closed elevation without half-live online install  
- Help/about honesty (no SCRIPT_URL / CHECKSUM channel theater)

## Verdict

| Gate | Result |
|------|--------|
| Requirements inventory honest | Pass |
| Suite green (Core) | Pass |
| Lessons re-checked | Pass |
| Type 1 package elevation traps (CL full) | **n/a** (narrow deposit only; domain TP cover) |
| Product user docs complete | **Fail** (absent) |
| **Overall** | **Revise** — implement docs + optional root deposit CI; **do not Block** ship-unit core behavior |

## Next actions

1. Product README (local install + print-sudoers + backup examples)  
2. Optional: root CI job for TP-FOLDER-BACKUP-07/08  
3. Close Issue 1 via housekeeping skills  
