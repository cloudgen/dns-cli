# Report: JSON sudoer submitter — dns-cli 1.6.0

**Date:** 2026-08-18  
**Mode:** product-gap / missing requirement  
**Status:** closed on ship unit 1.6.0 (sibling approve dest still not this product)  
**Ship unit:** `src/dns-cli` `VERSION=1.6.0`  
**Suite:** `sh tests/run.sh` **PASS=344 FAIL=0 SKIP=0**  
**Lessons:** L-SUDOER-SUBMIT-01 (new) · L-TRIM-01 (narrowed)

## Summary

dns-cli can now **generate** and **submit** a file-based JSON sudoer grant (Type 0 compose with sibling `sudoer-cli`). That capability was missing from product law and the ship unit. The gap was not “we forgot sudoers entirely” — `print-sudoers` and Type 1 `setup` already existed. It was a **role collapse**: hop-1 trim and reviews treated every sudoers surface as folder-backup / sudoers-manager extras, while file-based JSON approval was specialized only as the **DNS inbound** machine.

## Why the requirement was missing

Five independent mistakes stacked. Any one would have been enough to keep the row out of the registry.

### 1. The law mold specialized the wrong dest

`LM-FILE-BASED-JSON-APPROVAL` said: specialize into the one Active **domain SSOT** (the approval **dest**). dns-cli did that for Cloudflare DNS request JSON (`requirement-cloudflare-dns-request`). Reviewers then treated “file-based JSON approval” as **covered**.

The missing dest is different: dns-cli is a **sudoer-approval-submitter** toward sibling `sudoer-cli`. There was **no** `LM-FILE-BASED-JSON-APPROVAL-SUBMITTER` mold, so agents had no specialize-out target for that role.

### 2. The three-layer mold in this tree was stale (2.6.0)

folder-backup’s copy is **2.8.0**: independent generate dest, `generate-sudoer-request`, `submit-sudoer-request`, AC-18. dns-cli’s copy stopped at dest `/etc/{{username}}/{{service}}` and never gained §2.3.2a / §2.3.3c / §2.3.3d. Specializing three-layer here could not invent generate/submit because the mold did not name them.

### 3. Hop-1 trim classified “sudoers” as parent extras

Bootstrap from cli-template **intentionally absent**-listed sudoers-manager extras (`print-sudoers-install-script`, `remove-project-sudoers`) and backup/restore. Agents and reviews widened that to “all sudoers emit stays on folder-backup.” `what-to-review.md` said explicitly: do not review sudoers-file emit.

Generate/submit are **not** those extras. The mold now says so (2.9.0 protection rule 18).

### 4. `print-sudoers` was added later as text F6 only

1.5.0 added Type 0 **text** emit + Type 1 `setup` writing `/etc/dns-adm/sudoers`. That is the **group** F6 dest (`%sudo ALL=(dns-adm)`). It is **not** a JSON grant, **not** sibling inbound, and **not** loaded by sudo unless an admin `@include`s it (product-gap Issue 4). Adding print-sudoers looked like “sudoers is done.”

### 5. `LM-SUDOER-JSON-FILE` looked like folder-backup only

The mold hardcoded `runas: root` and `args: ["backup"]` / `["restore"]`. A Type 2 product (runas `dns-adm`, empty args so `--json vault` still matches) could not specialize it without appearing to violate the mold. The mold is now **1.3.0** with `{{RUNAS}}` and Type 2 empty-args.

## What this product is / is not

| Role | dns-cli |
|------|---------|
| Sudoers-manager / approval dest | **No** |
| Sudoer-approval-submitter | **Yes** (1.6.0) |
| DNS inbound approval dest | Law named; ship **Gap** |
| F6 dest writer | Type 1 `setup` → `/etc/dns-adm/sudoers` (not `/etc/sudoers.d`) |

Sibling `sudoer-cli` / `sudoer-adm` still approve and, if they choose, write `/etc/sudoers.d/dns-cli-<user>`. This product **MUST NOT** do that.

## Grant shape (Implemented)

```json
{
  "schema_version": 1,
  "purpose": "Allow <user> to run dns-cli as dns-adm.",
  "username": "<user>",
  "service": "dns-cli",
  "action": "add",
  "commands": [
    {"runas": "dns-adm", "tags": ["NOPASSWD"], "path": "/usr/local/bin/dns-cli", "args": []}
  ]
}
```

Empty `args` matches Table A (whole managed binary as `dns-adm`). Verb-bound `dns-cli vault` would miss `dns-cli --json vault`. Whole-CLI-as-**root** remains forbidden. `setup` / `remove-lpu` stay password `sudo`.

## Issues

None open on the submitter path after 1.6.0. Remaining product gaps (not this change): Type 2 default-vault switch (Issue 2 on the 1.5.0 gap report); unspecified vault dest (Issue 1); DNS inbound `submit` / `approve` / `interactive`.

## Proof

| Family | Result |
|--------|--------|
| TP-SUDOER-JSON-01..03, 08 | have |
| TP-PRIV-05..08 | have |
| Full suite | PASS=344 FAIL=0 SKIP=0 |
