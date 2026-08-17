# Shared live-path helpers. Source from tests/live/*.sh and test_cf_live.sh.
# Does not print secrets.

live_load_env() {
    if [ -n "${REPO_ROOT:-}" ]; then
        LIVE_REPO="${REPO_ROOT}"
    else
        _s=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
        if [ -f "${_s}/../src/dns-cli" ]; then
            LIVE_REPO=$(CDPATH= cd -- "${_s}/.." && pwd)
        elif [ -f "${_s}/../../src/dns-cli" ]; then
            LIVE_REPO=$(CDPATH= cd -- "${_s}/../.." && pwd)
        else
            printf '%s\n' "Cannot find src/dns-cli from $0" >&2
            return 1
        fi
    fi
    if [ -f "${LIVE_REPO}/tests/live/.env" ]; then
        # shellcheck disable=SC1091
        . "${LIVE_REPO}/tests/live/.env"
    fi
    : "${CF_LIVE_DOMAIN:=crms.hk}"
    : "${CF_LIVE_SUBDOMAIN:=cf-cli-tmp}"
    : "${SCRIPT:=${LIVE_REPO}/src/dns-cli}"
    if [ -n "${CF_LIVE_VAULT_DIR:-}" ]; then
        LIVE_VAULT="${CF_LIVE_VAULT_DIR}"
    else
        LIVE_VAULT="${LIVE_REPO}/.live-vault"
    fi
}

live_need_token() {
    if [ -z "${CF_LIVE_TOKEN_FILE:-}" ] || [ ! -f "${CF_LIVE_TOKEN_FILE}" ]; then
        printf '%s\n' "CF_LIVE_TOKEN_FILE missing or not a file" >&2
        return 1
    fi
    _m=$(stat -c '%a' "${CF_LIVE_TOKEN_FILE}" 2>/dev/null || echo "")
    if [ "${_m}" != "600" ]; then
        printf '%s\n' "CF_LIVE_TOKEN_FILE must be mode 0600 (is ${_m})" >&2
        return 1
    fi
    return 0
}

live_cli() {
    sh "${SCRIPT}" --vault-dir "${LIVE_VAULT}" --domain "${CF_LIVE_DOMAIN}" "$@"
}
