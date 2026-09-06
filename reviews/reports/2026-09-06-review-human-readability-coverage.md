# Report: human-readability-coverage — dns-cli 1.19.0

**Date:** 2026-09-06
**Mode:** full product docs + coverage + tests (implement follow-ups)
**Status:** closed

## Summary

README Features and actor table now lead with who types what. Dest basename parse accepts hyphenated POSIX logins. Requirement session-login leaks and stale Gap/DTV rows were corrected. Core suite follow-ups: **TP-CF-REQ-18**, **TP-CLI-18** TTY `--json menu` / `main`.

## Issues
### Issue 1 -- Severity: bug
- File: src/dns-cli:5530
- Description: Basename parser used `cut -f2/-f3` so hyphenated logins failed dest format.
- Suggestion: Date left, action+n right; **TP-CF-REQ-18**.
- Lesson: L-TOKEN-PUB-01 family (public-surface honesty) plus dest grammar
- Test: TP-CF-REQ-18
- Status: closed

### Issue 2 -- Severity: suggestion
- File: README.md:Features
- Description: Features dumped dest-law changelog; actor table froze `leolio`.
- Suggestion: People/folder bullets; documentation example `alice`.
- Test: TP-CLI-16 (REQ voice); README review
- Status: closed

### Issue 3 -- Severity: nit
- File: src/dns-cli:app_default
- Description: Invalid-choice warn said “Type 1-11”.
- Suggestion: “Enter 1-11”.
- Test: TP-CLI-20 invalid pick
- Status: closed
