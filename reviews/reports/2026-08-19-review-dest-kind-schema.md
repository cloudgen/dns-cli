# Report: dest-owned JSON / `kind` fence — dns-cli 1.9.7

**Date:** 2026-08-19  
**Mode:** product review (dest fence catalog + dest-owned sudoer allowlist + INC-20260819-001)  
**Status:** open items (live dest still refuses `kind`)  
**Ship unit:** `src/dns-cli` `VERSION=1.9.7`  
**Suite:** `sh tests/run.sh` **PASS=619 FAIL=0 SKIP=1**  
**Lessons re-checked:** L-KIND-SCHEMA-01 · L-FENCE-REQ-01 · L-HOOK-QUEUE-01 · L-QUEUE-CHOWN-01 · L-SUDOER-SUBMIT-01 · L-ROLE-TABLE-01 · L-LPU-MISSING-01

## Summary

This product now **owns** dest JSON format law: sudoer dest **MUST** treat dest-legal `kind` as a known key, and file-ownership dest-writes `submit_by` after format — it is not `kind`. The dest fence catalog is an independent REQ. Queued sudoer bodies match that dest-owned allowlist. DNS dest rejects `kind`. Live sibling dest **sudoer-cli 1.8.1** still fences unexpected `kind` (INC-20260819-001). That is dest fail-closed doing its job. The hook grant stays unapprovable until dest allowlists `kind` **or** this product omits `kind` from the queued body.

Verdict: **Revise** — law and this-product suites are aligned; live dest schema is not.

## Scope

- Dest fence catalog `requirement-approval-fencing-condition`  
- Dest Fence `requirement-incorrect-json-format` 1.1.0 (dest-owned allowlist)  
- Submitter emit vs dest inbound (`requirement-sudoer-json-file`)  
- DNS dest fence on this ship unit (`cf_req_dest_fence`)  
- Test plan / matrix / what-to-review lock-in after INC-20260819-001  
- Not: dest sibling source rewrite; not `/etc/sudoers.d` apply; not dest Type 0 re-submit of `login-hook-elev`

## Lessons re-check

| Lesson | This turn |
|--------|-----------|
| L-KIND-SCHEMA-01 | Holds. Law dest-owns `kind`. Emit contract now **TP-FENCE-05**. Live dest still 1.8.1. |
| L-FENCE-REQ-01 | Holds. Catalog REQ + Fence REQ; dest tables point. |
| L-HOOK-QUEUE-01 | Holds. Setup writes inbound; dest Type 0 is still the wrong door. |
| L-QUEUE-CHOWN-01 | Holds. Setup does not `chown`; waiting file in the incident was `root:root`. |
| L-SUDOER-SUBMIT-01 | Holds. This product is submitter, not dest. |
| L-ROLE-TABLE-01 | Holds. DNS actor table does not absorb printer/submitter. |

## Strengths

| Area | Notes |
|------|--------|
| Dest catalog | Closed dest refuse list is its own REQ; MUST NOT rows stay non-fences |
| Dest-owned allowlist | IJF-M7..M10 name dest keys; `kind` known on sudoer dest; not on DNS dest |
| Queued-body proof | **TP-FENCE-05** / **TP-SUDOER-JSON-21** extract keys; not emit-only `"kind"` grep |
| DNS dest fence | **TP-FENCE-06** / **TP-CF-REQ-16** fail closed with unknown-key + no yes/no |
| Honesty | **TP-FENCE-07** skip; stub dest `cp` is not dest accept |
| Suite | PASS=619 FAIL=0 SKIP=1 |

## Issues

### Issue 1 -- Severity: bug
- File: dest sibling `/usr/local/bin/sudoer-cli` **1.8.1** (`sr_dest_fence_unknown_keys`); this product still queues `kind`
- Description: Live dest closed allowlist is `schema_version`, `purpose`, `username`, `service`, `action`, `commands`. Waiting `login-hook-elev` includes `kind`. Dest fenced incorrect JSON format and did not ask yes/no. This product's law now dest-owns `kind`. Dest 1.8.1 does not.
- Suggestion: Dest allowlist `kind` **xor** this product omit `kind` from the queued inbound body. Do not approve the waiting file. Do not dest Type 0 `add-sudoer-request` this hook JSON.
- Lesson: L-KIND-SCHEMA-01
- Test: **TP-FENCE-07** (skip until sibling dest matches)
- Status: **open** — INC-20260819-001 CAPA 4
- Cross-ref: `docs/incidents/incident-20260819-001-dest-rejects-kind-field.md`

### Issue 2 -- Severity: suggestion
- File: `reviews/test-plan.md` **TP-FENCE-01..04** / `tests/test_cli.sh`
- Description: Catalog and Fence **have** rows still include law-document greps. Those prove the REQ exists. They do not prove dest accept. This turn added **TP-FENCE-05/06** so the gap is no longer the only proof.
- Suggestion: Keep 01–04 as law-presence. Do not treat them as dest compatibility.
- Lesson: L-KIND-SCHEMA-01
- Test: **TP-FENCE-05** · **TP-FENCE-06**
- Status: **closed** on this turn (emit contract added; law greps stay labeled honestly)

### Issue 3 -- Severity: nit
- File: `docs/requirements/requirement-cloudflare-dns-request.md` Design-time verification
- Description: **TP-CF-REQ-01..07** DTV rows still say `tests/test_cf_dns.sh` / **todo** while the suite and product test-plan mark them **have** on `tests/test_cf_request.sh`.
- Suggestion: Retarget those DTV rows to `test_cf_request.sh` **have**.
- Test: TP-CF-REQ-01..07
- Status: **open** (stale DTV only; not a suite miss)

## Non-findings (explicitly OK)

| Check | Result |
|-------|--------|
| Dest Fence is incorrect JSON format only | dest tables + catalog + IJF REQ; **TP-FENCE-02/03** |
| File-ownership is not a dest Fence and is not `kind` | AFC-M6 · IJF-M10 · **TP-FENCE-03/04** |
| Setup does not `chown` dest inbound | **TP-SUDOER-JSON-18** |
| Type 0 submit refuses `login-hook-elev` | **TP-SUDOER-JSON-12** |
| DNS dest unknown key + no yes/no | **TP-FENCE-06** operator-readable: names unknown key; dest will not ask yes/no |
| Type 1 `setup` without root/sudo | **TP-PRIV-03** fail closed |
| Dual mention / role tables | **TP-CLI-14** · **TP-PRIV-09** · **TP-SUDOER-JSON-09** · **TP-CF-ACTOR-07** |
| Token leak in this review | no token values |
| Stub dest `cp` treated as dest accept | no; **TP-FENCE-07** skip |

## Operator-readable dest Fence (CL-OPERATOR-READABLE-ERROR)

| Path | E1–E7 |
|------|--------|
| This product DNS dest `cf_req_dest_fence` / `cf_req_explain_fence` | Names unknown key; dest will not ask yes/no; next is fix JSON and submit again. **Pass** on this ship unit. |
| Live dest 1.8.1 format fail | Names field `kind`; dest will not ask yes/no. Next-step `sudoer-cli add-sudoer-request` is the **002** wrong door for `login-hook-elev`. Dest UX; not this ship unit. |

## Test-plan deltas

| TP-ID | Was | Now |
|-------|-----|-----|
| TP-FENCE-03 / TP-FENCE-04 | have (law grep) | have (law grep; still not dest accept) |
| **TP-FENCE-05** | — | **have** queued keys ⊆ dest-owned allowlist |
| **TP-FENCE-06** / **TP-CF-REQ-16** | — | **have** DNS dest rejects `kind` |
| **TP-SUDOER-JSON-21** | — | **have** same assert as TP-FENCE-05 |
| **TP-FENCE-07** | — | **skip** live dest unknown-key |

## Priority remediation order

1. Dest sudoer-cli allowlist `kind`, **or** this product stop queuing `kind` (Issue 1 / CAPA 4).  
2. Keep **TP-FENCE-07** skip until that match is real. Do not mark it **have** on stub dest.  
3. Retarget stale TP-CF-REQ-01..07 DTV rows (Issue 3).

## Related

| Artifact | Role |
|----------|------|
| `docs/incidents/incident-20260819-001-dest-rejects-kind-field.md` | Incident |
| `docs/requirements/requirement-approval-fencing-condition.md` | Dest catalog |
| `docs/requirements/requirement-incorrect-json-format.md` | Dest Fence meaning |
| `reviews/test-plan.md` | TP map |
| `reviews/lessons.md` | L-KIND-SCHEMA-01 |

**Written by:** product-review (this session)  
**Review status:** Findings open (Issue 1, Issue 3)
