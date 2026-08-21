# fence-test corpus

**Test-purpose** corpus: prove dest fence functions against a JSON **file location** in this **local test folder**. **No sudo** except wrap chmod/chown of this folder. **No sudoers file.** Does **not** queue.

This dest's closed list is **incorrect JSON format** only (DNS dest). Per-row tester: `test-json-format`. List tester: `fence-test`.

One file:

```sh
sh src/dns-cli fence-test --file tests/fixtures/fence-test/pass/20260821-alice-add-1.json
```

A folder of cases:

```sh
sh src/dns-cli fence-test --dir tests/fixtures/fence-test/pass
sh src/dns-cli fence-test --dir tests/fixtures/fence-test/match --expect-match
```

| Folder | Meaning |
|--------|---------|
| `pass/` | Every dest fence must **clear** (dest-legal DNS request JSON). |
| `match/` | Every file must **match** a dest fence (not an object, unknown key, secret key). |

Regular `*.json` only. No symlinks. Do **not** add `expect_fence` keys to the body (unknown key is itself this dest Fence).
