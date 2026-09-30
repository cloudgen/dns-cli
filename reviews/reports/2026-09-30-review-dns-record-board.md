# Review — numbered live A records

**Date:** 2026-09-30  
**Product:** dns-cli  
**Law:** `requirement-domain-cloudflare-dns` **2.10.0** (D-M17) and `requirement-shell-cli-default-interaction` **1.10.0**  
**Ship unit:** `src/dns-cli` **1.38.0**

## What was already here

Menu **1** numbered DNS **commands** (**11–19** and **101**). `status` printed one name and the first A record. It stayed read-only. A vault with several names required `--subdomain` and exited. Saving a zone token already created and deleted a temporary `_test_<UTC>` A record at documentation address `203.0.113.10`.

## What this release adds

Typed `records` and menu **102** list each stored name's live A records as `1.`, `2.`, and so on. A name with no A record is still a row. Those numbers are data. They are not command-tree children, so the DNS command list does not restart at **1**.

On a keyboard, a row number then accepts `add`, `update`, or `remove`. Round-robin remove deletes that row's address. More than one A on a non-round-robin name warns and stays on the list (`dns-cli add --force` remains the repair). `test-api` runs the same create-then-delete probe. `0` ends `records` and returns to the front board. `status` and `show` still do not mutate DNS.

Off-TTY `records` and `--json records` print the rows and do not read a choice.

## Proof

**TP-CF-REC-01..09** in `tests/test_cf_dns.sh`. **TP-CLI-22** checks the **102** command row. **TP-CLI-14** and **TP-CLI-15** include `records`.

`sh tests/run.sh` on 2026-09-30: **PASS=1017 FAIL=0 SKIP=2** (the two skips are the existing live-dest cases).
