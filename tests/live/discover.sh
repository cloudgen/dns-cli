#!/bin/sh
# Print zone_id, account_id, user_id for CF_LIVE_DOMAIN using the temp token.
# Never prints the token. Type 0 — invoking user. Does not need cf-adm.
set -u
. "$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)/common.sh"
live_load_env || exit 2
live_need_token || exit 2

_hdr=$(mktemp "${TMPDIR:-/tmp}/cf-live-hdr.XXXXXX")
chmod 0600 "${_hdr}"
{
    printf 'header = "Authorization: Bearer %s"\n' "$(tr -d '\n\r' <"${CF_LIVE_TOKEN_FILE}")"
    printf 'header = "Accept: application/json"\n'
} >"${_hdr}"
_body=$(mktemp "${TMPDIR:-/tmp}/cf-live-body.XXXXXX")
chmod 0600 "${_body}"
_cleanup() { rm -f "${_hdr}" "${_body}"; }
trap _cleanup EXIT INT TERM

_code=$(curl --config "${_hdr}" -sS --connect-timeout 5 --max-time 15 \
    -o "${_body}" -w '%{http_code}' \
    "https://api.cloudflare.com/client/v4/zones?name=${CF_LIVE_DOMAIN}") || _code=000
if [ "${_code}" != "200" ]; then
    printf '%s\n' "zone lookup HTTP ${_code}" >&2
    exit 1
fi
python3 -c '
import json,sys
with open(sys.argv[1], encoding="utf-8") as fh:
    data=json.load(fh)
if not data.get("success"):
    raise SystemExit("zone lookup success=false")
res=data.get("result") or []
if not res:
    raise SystemExit("no zone named %s" % sys.argv[2])
z=res[0]
print("CF_LIVE_DOMAIN=%s" % sys.argv[2])
print("CF_LIVE_ZONE_ID=%s" % z.get("id",""))
print("CF_LIVE_ACCOUNT_ID=%s" % ((z.get("account") or {}).get("id","")))
' "${_body}" "${CF_LIVE_DOMAIN}" || exit 1

_code=$(curl --config "${_hdr}" -sS --connect-timeout 5 --max-time 15 \
    -o "${_body}" -w '%{http_code}' \
    "https://api.cloudflare.com/client/v4/user") || _code=000
if [ "${_code}" != "200" ]; then
    printf '%s\n' "user lookup HTTP ${_code} (token may lack User Read; set CF_LIVE_USER_ID by hand)" >&2
    exit 0
fi
python3 -c '
import json,sys
with open(sys.argv[1], encoding="utf-8") as fh:
    data=json.load(fh)
if not data.get("success"):
    raise SystemExit(0)
u=(data.get("result") or {})
print("CF_LIVE_USER_ID=%s" % u.get("id",""))
' "${_body}"
