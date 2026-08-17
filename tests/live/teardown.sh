#!/bin/sh
# Remove the probe A (if any), drop the vault slot, delete the specify dir.
# Then revoke the dashboard token yourself.
set -u
. "$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)/common.sh"
live_load_env || exit 2

if [ -d "${LIVE_VAULT}" ]; then
    if live_need_token 2>/dev/null; then
        sh "${SCRIPT}" --json --vault-dir "${LIVE_VAULT}" --domain "${CF_LIVE_DOMAIN}" \
            --subdomain "${CF_LIVE_SUBDOMAIN}" --force remove 2>/dev/null || true
        sh "${SCRIPT}" --json --vault-dir "${LIVE_VAULT}" \
            vault account remove "${CF_LIVE_DOMAIN}" --force 2>/dev/null || true
    fi
    rm -rf "${LIVE_VAULT}"
    printf '%s\n' "removed specify vault ${LIVE_VAULT}"
else
    printf '%s\n' "no specify vault at ${LIVE_VAULT}"
fi
printf '%s\n' "Revoke the temporary API token in the Cloudflare dashboard now."
