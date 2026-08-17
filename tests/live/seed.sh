#!/bin/sh
# Seed a Type 0 specify vault for CF_LIVE_DOMAIN as the invoking user (leolio).
# Does not create or require cf-adm.
set -u
. "$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)/common.sh"
live_load_env || exit 2
live_need_token || exit 2
if [ -z "${CF_LIVE_ZONE_ID:-}" ] || [ -z "${CF_LIVE_ACCOUNT_ID:-}" ] || [ -z "${CF_LIVE_USER_ID:-}" ]; then
    printf '%s\n' "Set CF_LIVE_ZONE_ID, CF_LIVE_ACCOUNT_ID, CF_LIVE_USER_ID (see discover.sh)" >&2
    exit 2
fi
umask 077
mkdir -p "${LIVE_VAULT}"
chmod 0700 "${LIVE_VAULT}"
sh "${SCRIPT}" --json --vault-dir "${LIVE_VAULT}" vault account add "${CF_LIVE_DOMAIN}" \
    --user-id "${CF_LIVE_USER_ID}" \
    --zone-id "${CF_LIVE_ZONE_ID}" \
    --account-id "${CF_LIVE_ACCOUNT_ID}" \
    --subdomain "${CF_LIVE_SUBDOMAIN}" \
    --token-file "${CF_LIVE_TOKEN_FILE}"
printf '%s\n' "seeded ${CF_LIVE_DOMAIN} in ${LIVE_VAULT} as $(id -un) (not cf-adm)"
