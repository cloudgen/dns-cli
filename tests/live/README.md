# Live Type 0 verify — `crms.hk` as the invoking user

**Not** `dns-adm`. **Not** `./tests/run.sh` (that suite stays offline).

Law: `requirement-domain-cloudflare-dns` D-M15 / D-M16.

## 1. Create a temporary API token (dashboard)

1. Cloudflare → **My Profile** → **API Tokens** → **Create Token**.
2. Template **Edit zone DNS** (Zone → DNS → **Edit**).
3. Zone Resources: **Include** → **Specific zone** → **crms.hk**.
4. Copy the token **once** into a 0600 file (never commit, never argv):

```sh
umask 077
printf '%s' 'PASTE_TOKEN_HERE' > tests/live/token
chmod 0600 tests/live/token
```

5. Copy zone id, account id, and user id (dashboard overview / URL, or run `discover.sh` after the token file exists).

## 2. Fill env

```sh
cp tests/live/env.example tests/live/.env
# edit tests/live/.env — set CF_LIVE_TOKEN_FILE to an *absolute* path
# e.g. /home/leolio/prjs/cf-cli/tests/live/token
```

## 3. Seed, verify, teardown (as `leolio`)

```sh
# optional: print zone_id / account_id / user_id (never prints the token)
sh tests/live/discover.sh

sh tests/live/seed.sh
CF_LIVE=1 sh tests/test_cf_live.sh
sh tests/live/teardown.sh
```

Then **revoke** the token in the Cloudflare dashboard.

Probe label defaults to `dns-cli-tmp` (not `@` / `www`).
