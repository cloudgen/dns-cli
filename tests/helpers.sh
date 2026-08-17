# =============================================================================
# tests/helpers.sh — shared assertions for dns-cli CI tests
# =============================================================================
# Source from test scripts (POSIX /bin/sh). Does not modify product code.
# =============================================================================

# shellcheck disable=SC2034
: "${TESTS_ROOT:=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)}"
: "${REPO_ROOT:=$(CDPATH= cd -- "${TESTS_ROOT}/.." && pwd)}"
: "${SCRIPT:=${REPO_ROOT}/src/dns-cli}"
: "${APP_NAME:=dns-cli}"
: "${PASS:=0}"
: "${FAIL:=0}"
: "${SKIP:=0}"

# Product VERSION SSOT from ship unit (keep tests free of frozen semver literals)
PRODUCT_VERSION=$(grep '^VERSION="' "${SCRIPT}" 2>/dev/null | head -n1 | cut -d'"' -f2)
: "${PRODUCT_VERSION:=unknown}"
PRODUCT_APP=$(grep '^APP_NAME="' "${SCRIPT}" 2>/dev/null | head -n1 | cut -d'"' -f2)
: "${PRODUCT_APP:=${APP_NAME}}"
APP_NAME="${PRODUCT_APP}"

# --- output ---
t_info()  { printf '  · %s\n' "$*"; }
t_pass()  { PASS=$((PASS + 1)); printf '  PASS  %s\n' "$*"; }
t_fail()  { FAIL=$((FAIL + 1)); printf '  FAIL  %s\n' "$*" >&2; }
t_skip()  { SKIP=$((SKIP + 1)); printf '  SKIP  %s\n' "$*"; }
t_header() { printf '\n== %s ==\n' "$*"; }

# --- assertions ---
assert_eq() {
    _lab="$1"; _exp="$2"; _act="$3"
    if [ "$_exp" = "$_act" ]; then
        t_pass "$_lab"
    else
        t_fail "$_lab (expected='$(_trunc "$_exp")' actual='$(_trunc "$_act")')"
    fi
}

assert_contains() {
    _lab="$1"; _hay="$2"; _ndl="$3"
    case "$_hay" in
        *"$_ndl"*) t_pass "$_lab" ;;
        *) t_fail "$_lab (missing '$(_trunc "$_ndl")' in '$(_trunc "$_hay")')" ;;
    esac
}

assert_not_contains() {
    _lab="$1"; _hay="$2"; _ndl="$3"
    case "$_hay" in
        *"$_ndl"*) t_fail "$_lab (unexpected '$(_trunc "$_ndl")')" ;;
        *) t_pass "$_lab" ;;
    esac
}

assert_exit() {
    _lab="$1"; _exp="$2"; shift 2
    "$@" >/dev/null 2>&1
    _act=$?
    assert_eq "$_lab" "$_exp" "$_act"
}

assert_file_exists() {
    _lab="$1"; _path="$2"
    if [ -e "$_path" ]; then
        t_pass "$_lab"
    else
        t_fail "$_lab (missing $_path)"
    fi
}

assert_file_missing() {
    _lab="$1"; _path="$2"
    if [ -e "$_path" ]; then
        t_fail "$_lab (still exists: $_path)"
    else
        t_pass "$_lab"
    fi
}

_trunc() {
    printf '%s' "$1" | tr '\n' ' ' | cut -c1-160
}

# Isolated HOME + USER_BIN + GLOBAL_BIN for install tests.
# GLOBAL_BIN is redirected so a host /usr/local/bin install cannot pollute
# uninstall target selection.
# Sets CI_HOME, CI_USER_BIN, CI_GLOBAL_BIN.
ci_isolated_env() {
    CI_HOME=$(mktemp -d "${TMPDIR:-/tmp}/hm-home.XXXXXX")
    CI_USER_BIN="${CI_HOME}/.local/bin"
    CI_GLOBAL_BIN="${CI_HOME}/.global-bin"
    mkdir -p "${CI_USER_BIN}" "${CI_GLOBAL_BIN}"
    export HOME="${CI_HOME}"
    export USER_BIN="${CI_USER_BIN}"
    export GLOBAL_BIN="${CI_GLOBAL_BIN}"
    # Local-only product: ensure no channel env is required
    unset SCRIPT_URL 2>/dev/null || true
    unset CHECKSUM 2>/dev/null || true
}

ci_cleanup_env() {
    if [ -n "${CI_HOME:-}" ] && [ -d "${CI_HOME}" ]; then
        rm -rf "${CI_HOME}"
        CI_HOME=
        CI_USER_BIN=
        CI_GLOBAL_BIN=
    fi
    unset GLOBAL_BIN 2>/dev/null || true
}

ci_run() {
    sh "${SCRIPT}" "$@"
}

# Vault tests must not use HOME under /tmp (default vault law fail-closed).
# Specified isolation: --vault-dir / CF_VAULT_DIR on a safe absolute tree (not /tmp).
ci_vault_env() {
    CI_VAULT_ROOT="${REPO_ROOT}/.ci-homes"
    mkdir -p "${CI_VAULT_ROOT}"
    CI_HOME=$(mktemp -d "${CI_VAULT_ROOT}/home.XXXXXX")
    CI_USER_BIN="${CI_HOME}/.local/bin"
    mkdir -p "${CI_USER_BIN}"
    export HOME="${CI_HOME}"
    export USER_BIN="${CI_USER_BIN}"
    unset XDG_CONFIG_HOME 2>/dev/null || true
    unset CF_API_TOKEN CF_ZONE_ID CF_ACCOUNT_ID CF_DOMAIN CF_SUBDOMAIN 2>/dev/null || true
    # Token-probe on vault add/set uses this stub (never public net).
    CI_STUB="${CI_HOME}/stub"
    mkdir -p "${CI_STUB}"
    export CF_STUB_DIR="${CI_STUB}"
    export CF_CURL="${TESTS_ROOT}/fixtures/cf_curl_stub.sh"
    chmod +x "${CF_CURL}" 2>/dev/null || true
    unset CF_STUB_DNS_POST_HTTP 2>/dev/null || true
}

ci_vault_cleanup() {
    if [ -n "${CI_HOME:-}" ] && [ -d "${CI_HOME}" ]; then
        rm -rf "${CI_HOME}"
        CI_HOME=
    fi
}

ci_capture() {
    _out="$1"; _err="$2"; shift 2
    if [ "$1" = "--" ]; then shift; fi
    "$@" >"$_out" 2>"$_err"
    CI_EXIT=$?
}

require_cmd() {
    if ! command -v "$1" >/dev/null 2>&1; then
        t_fail "required command missing: $1"
        return 1
    fi
    return 0
}
