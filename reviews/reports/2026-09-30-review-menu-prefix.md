# Review — main menu prefix numbers

**Date:** 2026-09-30  
**Product:** dns-cli  
**Reference (read-only):** sibling sshd-cli `requirement-shell-cli-default-interaction` **1.14.0**  
**Law:** `requirement-shell-cli-default-interaction` **1.9.0**  
**Ship unit:** `src/dns-cli` **1.37.0**

## What was already here

The top list already had the three families: **1 DNS Features**, **7 sudoers**, **8 self-management**, and **9** Exit. Side lists restarted at **1**. DNS Back was **98** and Exit **99**. Sudoers and self-management used Back **8** and Exit **9**.

## What the sibling card adds

Child numbers keep the parent prefix. A side list uses **0** Back and does not print Exit. **9** on a side list is a wrong pick. Self-management keeps the shared slots **82** version, **83** about, and **87** self-install. Online **81** / **84** / **85** / **86** stay off a local-only product. Sudoers shared words stay **71** / **72** / **73**. This product does not list sshd-cli’s **74** / **75**.

## Specialization kept

- Case 3: a terminal with no command opens this menu. A script prints help.
- No language board (**6**). No second domain family (**2**).
- **76** `remove-lpu`, **88** `uninstall`, **89** `where-is-me`, and **101** `interactive` are this product’s extra rows.
- A blank line still reprints the same list.
- Typed `exit` / `99` still leaves from a side list. Those words are not rows.

## Proof

**TP-CLI-18** through **TP-CLI-24** in `tests/test_cli.sh`.

`sh tests/run.sh` on 2026-09-30: **PASS=985 FAIL=0 SKIP=2** (the two skips are the existing live-dest cases).
