#!/bin/sh
# Offline curl stand-in for TP-CF-DNS. Never touches the public network.
# State dir: $CF_STUB_DIR (required).
set -u
: "${CF_STUB_DIR:?CF_STUB_DIR required}"
: "${CF_STUB_IPINFO_CODE:=200}"
: "${CF_STUB_ZONE_NAME:=example.test}"
: "${CF_STUB_ACCOUNT_ID:=aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa}"
: "${CF_STUB_ZONE_ID:=bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb}"

mkdir -p "${CF_STUB_DIR}"
_rec="${CF_STUB_DIR}/records.json"
if [ ! -f "${_rec}" ]; then
    printf '%s\n' '[]' >"${_rec}"
fi

_out=""
_url=""
_method="GET"
_datafile=""
while [ $# -gt 0 ]; do
    case "$1" in
        -o)
            shift
            _out="${1:-}"
            ;;
        -w)
            shift
            ;;
        -X)
            shift
            _method="${1:-GET}"
            ;;
        --data-binary)
            shift
            _datafile="${1:-}"
            _datafile="${_datafile#@}"
            ;;
        --config|-sS|--connect-timeout|--max-time|-H)
            if [ "$1" = "--connect-timeout" ] || [ "$1" = "--max-time" ] || [ "$1" = "-H" ]; then
                shift
            fi
            ;;
        http://*|https://*)
            _url="$1"
            ;;
    esac
    shift
done

_http=200
_body=""

if printf '%s' "${_url}" | grep -q 'ipinfo.io'; then
    if [ "${CF_STUB_IPINFO_CODE}" != "200" ]; then
        _http="${CF_STUB_IPINFO_CODE}"
        _body='{"error":"quota"}'
    else
        _body='{"ip":"203.0.113.10","city":"Test"}'
    fi
elif printf '%s' "${_url}" | grep -q '/dns_records'; then
    _name=$(printf '%s' "${_url}" | sed -n 's/.*name=\([^&]*\).*/\1/p')
    case "${_method}" in
        GET)
            _body=$(CF_STUB_NAME="${_name}" python3 -c '
import json,os,sys
path=sys.argv[1]
name=os.environ.get("CF_STUB_NAME","")
with open(path, encoding="utf-8") as fh:
    recs=json.load(fh)
matched=[r for r in recs if r.get("name")==name]
print(json.dumps({"success":True,"result":matched}))
' "${_rec}")
            ;;
        POST)
            if [ -n "${CF_STUB_DNS_POST_HTTP:-}" ] && [ "${CF_STUB_DNS_POST_HTTP}" != "200" ]; then
                _http="${CF_STUB_DNS_POST_HTTP}"
                _body='{"success":false,"errors":[{"code":10000,"message":"Authentication error"}]}'
            else
            _payload="{}"
            if [ -n "${_datafile}" ] && [ -f "${_datafile}" ]; then
                _payload=$(cat "${_datafile}")
            fi
            _body=$(printf '%s' "${_payload}" | python3 -c '
import json,sys,uuid
payload=json.load(sys.stdin)
path=sys.argv[1]
rec={
  "id": uuid.uuid4().hex[:32],
  "type": payload.get("type","A"),
  "name": payload.get("name",""),
  "content": payload.get("content",""),
  "ttl": payload.get("ttl",300),
  "proxied": payload.get("proxied", False),
}
with open(path, encoding="utf-8") as fh:
    recs=json.load(fh)
recs.append(rec)
with open(path,"w",encoding="utf-8") as fh:
    json.dump(recs, fh)
print(json.dumps({"success":True,"result":rec}))
' "${_rec}")
            fi
            ;;
        PUT)
            _rid=$(printf '%s' "${_url}" | sed -n 's#.*/dns_records/\([0-9a-f]*\).*#\1#p')
            _payload="{}"
            if [ -n "${_datafile}" ] && [ -f "${_datafile}" ]; then
                _payload=$(cat "${_datafile}")
            fi
            _body=$(printf '%s' "${_payload}" | python3 -c '
import json,sys
payload=json.load(sys.stdin)
path=sys.argv[1]
rid=sys.argv[2]
with open(path, encoding="utf-8") as fh:
    recs=json.load(fh)
out=None
for rec in recs:
    if rec.get("id")==rid:
        rec.update({k:payload[k] for k in payload})
        out=rec
        break
with open(path,"w",encoding="utf-8") as fh:
    json.dump(recs, fh)
print(json.dumps({"success":True,"result":out or {}}))
' "${_rec}" "${_rid}")
            ;;
        DELETE)
            _rid=$(printf '%s' "${_url}" | sed -n 's#.*/dns_records/\([0-9a-f]*\).*#\1#p')
            python3 -c '
import json,sys
path=sys.argv[1]
rid=sys.argv[2]
with open(path, encoding="utf-8") as fh:
    recs=json.load(fh)
recs=[r for r in recs if r.get("id")!=rid]
with open(path,"w",encoding="utf-8") as fh:
    json.dump(recs, fh)
print(json.dumps({"success":True}))
' "${_rec}" "${_rid}" >/dev/null
            _body='{"success":true}'
            ;;
    esac
elif printf '%s' "${_url}" | grep -q '/zones/'; then
    _body=$(printf '{"success":true,"result":{"id":"%s","name":"%s","account":{"id":"%s","name":"test"}}}' \
        "${CF_STUB_ZONE_ID}" "${CF_STUB_ZONE_NAME}" "${CF_STUB_ACCOUNT_ID}")
else
    _http=404
    _body='{"success":false}'
fi

if [ -n "${_out}" ]; then
    printf '%s' "${_body}" >"${_out}"
else
    printf '%s' "${_body}"
fi
printf '%s' "${_http}"
echo "STUB ${_method} ${_url}" >>"${CF_STUB_DIR}/calls.log"
exit 0
