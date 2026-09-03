# Product review: dns-cli (sudoers family submenu — coverage, tests, README)

**Date:** 2026-09-03  
**Reviewer:** council Review role  
**Product:** dns-cli `VERSION=1.18.0`  
**Ship unit:** `src/dns-cli`  
**Scope:** requirement coverage + human readability of `requirement-shell-cli-default-interaction` §1.1 and README Description; test-plan / matrix / checklist alignment for family **sudoers**  
**Method:** disk read + local diff + bundled reviewer subagent + CLI surface tests  
**Baseline:** **TP-CLI-18** · **TP-CLI-19** · **TP-CLI-20** have. Full suite PASS=730 FAIL=18 SKIP=1 before follow-up test honesty. The 18 FAILs are TP-CF-REQ basename parse when the invoking login contains hyphens (unchanged).

## Summary

Claim **C-feature** (TTY main menu family **sudoers**): daily DNS work on the start list, grant/draft/LPU verbs on a submenu, `sudoers` not dispatched. MUST tables match `app_default*` and `app_main`. Requirement §1.1 is people-first. README Description was a Type 0/1/2 catalog (finding); rewritten this pass. TP-CLI-20 labels sampled the submenu; Back/Exit uniqueness and pick-`sudoers` were tightened this pass.

## Strengths

| Area | Notes |
|------|--------|
| Family row | `sudoers` is menu-only; `dns-cli sudoers` stays unknown |
| Main list | vault is **1**; grant verbs off the main list; Exit **99** |
| Submenu | generate / submit / print-sudoers / remove-lpu; Back **8**; Exit **9** |
| Dual mention | `menu` / `main` still CLI + topic-owner; family token is not a routed verb |
| REQ §1.1 | One sentence, boxes, includes/excludes, practice — no Type-only lead |

## Findings

### DNS-CLI-TEST-02 — Severity: P2 (medium)
- **Area:** tests  
- **Status:** fixed (this review)  
- **Location:** `tests/test_cli.sh` TP-CLI-20  
- **Description:** Combined-stdout `11. sudoers:` could not prove Back returned to main; Exit 9 only checked process exit 0. Typed `sudoers` at the pick prompt was untested.  
- **Impact:** A Back-as-Exit or Exit-as-Back regression could still pass.  
- **Suggestion:** Count `1. vault:` twice after `11` then `8` then `99`; once after `11` then `9`; send literal `sudoers` then Back.  
- **Cross-ref:** `requirement-shell-cli-default-interaction` §2.3 item 7 · §2.4  

### DNS-CLI-DOC-02 — Severity: P2 (medium)
- **Area:** README voice  
- **Status:** fixed (this review) — also closes DNS-CLI-DOC-01  
- **Location:** `README.md` Description / Features  
- **Description:** Description led with Type 0/1/2 as the only explanation. Features led a bullet with **Type N**.  
- **Impact:** Operators could not tell who types what from the first paragraph.  
- **Suggestion:** People/folder/next-step Description; three boxes; Features “No arguments”.  

### DNS-CLI-HELP-01 — Severity: P3 (low)
- **Area:** help  
- **Status:** fixed (this review)  
- **Location:** `src/dns-cli` `app_help` menu row  
- **Description:** Help called the list “live commands” while family `sudoers` is not a dispatcher token.  
- **Impact:** Operators could try `dns-cli sudoers` after reading help.  
- **Suggestion:** Daily DNS work plus family sudoers; not a typed command.  

### DNS-CLI-PLAN-01 — Severity: P3 (low)
- **Area:** test plan / matrix  
- **Status:** fixed (this review)  
- **Location:** `reviews/test-plan.md` · `reviews/requirement-test-matrix.md` · `reviews/what-to-review.md`  
- **Description:** Headers still said product VERSION 1.11.0; empty-argv row still “Empty = help”; default-interaction surface missing from what-to-review.  
- **Impact:** Coverage maps lagged the 1.18.0 submenu.  
- **Suggestion:** Bump VERSION/date; add TP-CLI-20; TTY empty argv = menu.  

## Non-findings (explicitly OK)

| Check | Result |
|-------|--------|
| Registry vs disk | 32 files; match; no orphans; no ghosts |
| Class gate | software-development; Active `requirement-class-software-dev` |
| Family token not dispatched | Pass (TP-CLI-20) |
| Dual mention `menu`/`main` | Pass (TP-CLI-14/15); `sudoers` is not a routed verb |
| Empty argv | Off-TTY help; TTY menu (TP-CLI-07 · TP-CLI-19) |
| Git-surface | No skill/template paths in versioned REQs |
| Choice capture | Current-shell `read` |
| README §4.3 demo | After install; markdown nametag; Exit 99; no install/version/about/testers |

## Requirement sufficient check (claim-scoped)

### Claim
- ID: **C-feature**
- Text: TTY numbered main menu groups sudoer-related choices behind family **sudoers**, matching grok-cli’s arrangement, without adding a live `sudoers` command.

### SSOT preflight
- Identity: aligned (`APP_NAME=dns-cli`, `VERSION=1.18.0`, `REPO_USER=cloudgen`)

### Ownership matrix

| Surface | Class | Owner | Status |
|---------|-------|-------|--------|
| `menu` / `main` / TTY empty argv list | lifecycle | `requirement-shell-cli-default-interaction` + CLI-interface | ok |
| Family row `sudoers` (not dispatched) | menu-only | `requirement-shell-cli-default-interaction` | ok |
| `generate-sudoer-request` / `submit-sudoer-request` | lifecycle | `requirement-sudoer-json-file` + three-layer | ok |
| `print-sudoers` / `remove-lpu` | lifecycle / Type 1 | three-layer + LPU | ok |
| Daily DNS verbs | domain | `requirement-domain-cloudflare-dns` + actor table | ok |

### Dual mention (Step 3h)
- In scope: yes  
- Every routed verb on CLI REQ + topic-owner: yes (`sudoers` is not routed)  
- Topic-owner samples: yes (`dns-cli menu` / `dns-cli main`)

### Human-intro standard
- Default-interaction §1.1: yes  
- README Description (after this pass): yes  

### Verdict
- **Sufficient** for C-feature after follow-ups in this turn.

## Priority remediation order

1. Tighten **TP-CLI-20** (Back count, Exit 9 uniqueness, pick `sudoers`) — **done**.  
2. Rewrite README Description / Features Type N lead — **done**.  
3. Help `menu` line — **done**.  
4. Align test-plan / matrix / what-to-review — **done**.

## Related

| Artifact | Role |
|----------|------|
| `docs/requirements/requirement-shell-cli-default-interaction.md` | Product law 1.3.0 |
| `reviews/test-plan.md` | TP map |
| `reviews/requirement-test-matrix.md` | REQ ↔ TP |

**Written by:** council Review role  
**Review status:** Findings from this pass closed
