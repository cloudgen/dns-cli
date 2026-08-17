# =============================================================================
# tests/test_cf_approver.sh — approver login-hook heal (offline)
# =============================================================================
# Primary REQ: requirement-dns-approver.md
# TP family: TP-CF-APR-*
# =============================================================================

# shellcheck source=helpers.sh
. "${TESTS_ROOT}/helpers.sh"

run_test_cf_approver() {
    t_header "Approver login hook heal (TP-CF-APR)"

    ci_vault_env
    _home="${HOME}"
    export CF_TEST_HEAL_RC=1
    export CF_APPROVER_USER
    CF_APPROVER_USER=$(id -un)

    rm -f "${_home}/.bashrc" "${_home}/.profile"
    sh "${SCRIPT}" version >/dev/null 2>&1
    assert_file_exists "TP-CF-APR-01 .bashrc created" "${_home}/.bashrc"
    _brc=$(cat "${_home}/.bashrc")
    assert_contains "TP-CF-APR-01 hook begin" "${_brc}" "# BEGIN dns-cli login hook"
    assert_contains "TP-CF-APR-01 hook end" "${_brc}" "# END dns-cli login hook"
    assert_contains "TP-CF-APR-01 hook sudo -n" "${_brc}" "sudo -n"
    assert_contains "TP-CF-APR-01 hook interactive" "${_brc}" "interactive"
    assert_file_exists "TP-CF-APR-02 .profile created" "${_home}/.profile"
    _prf=$(cat "${_home}/.profile")
    assert_contains "TP-CF-APR-02 sources bashrc" "${_prf}" '. "${HOME}/.bashrc"'
    assert_contains "TP-CF-APR-02 profile markers" "${_prf}" "# BEGIN dns-cli profile source-bashrc"

    printf '%s\n' "# keep-me" >"${_home}/.profile"
    sh "${SCRIPT}" version >/dev/null 2>&1
    _prf2=$(cat "${_home}/.profile")
    assert_eq "TP-CF-APR-03 existing profile kept" "# keep-me" "${_prf2}"

    _n1=$(grep -c '# BEGIN dns-cli login hook' "${_home}/.bashrc")
    sh "${SCRIPT}" version >/dev/null 2>&1
    _n2=$(grep -c '# BEGIN dns-cli login hook' "${_home}/.bashrc")
    assert_eq "TP-CF-APR-06 heal idempotent" "${_n1}" "${_n2}"

    rm -f "${_home}/.bashrc" "${_home}/.profile"
    unset CF_APPROVER_USER
    sh "${SCRIPT}" version >/dev/null 2>&1
    assert_file_missing "TP-CF-APR-04 other user no bashrc" "${_home}/.bashrc"
    assert_file_missing "TP-CF-APR-04 other user no profile" "${_home}/.profile"

    CF_APPROVER_USER=$(id -un)
    export CF_APPROVER_USER
    sh "${SCRIPT}" --json version >/dev/null 2>&1
    assert_file_missing "TP-CF-APR-05 json no bashrc" "${_home}/.bashrc"
    assert_file_missing "TP-CF-APR-05 json no profile" "${_home}/.profile"

    unset CF_TEST_HEAL_RC
    unset CF_APPROVER_USER
    ci_vault_cleanup
}
