# =============================================================================
# tests/test_cf_approver.sh — approver login-hook heal (offline)
# =============================================================================
# Primary REQ: requirement-login-interactive-hook.md
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
    assert_contains "TP-CF-APR-01 hook production bin" "${_brc}" "sudo -n /usr/local/bin/dns-review-hooks interactive 2>/dev/null"
    assert_not_contains "TP-CF-APR-01 no old binary hook" "${_brc}" "sudo -n /usr/local/bin/dns-cli interactive;"
    assert_not_contains "TP-CF-APR-01 no per-app doorbell" "${_brc}" "dns-cli-hook"
    assert_not_contains "TP-CF-APR-01 no sibling doorbell" "${_brc}" "login-review-hook"
    _blk=$(sed -n '/^cf_approver_hook_block()/,/^}/p' "${SCRIPT}")
    assert_contains "TP-CF-APR-01 plant uses grant-path helper" "${_blk}" "lpu_login_hook_grant_path"
    assert_contains "TP-CF-APR-01 plant pins dns-review-hooks" "${_blk}" "/usr/local/bin/dns-review-hooks"
    _pathfn=$(sed -n '/^lpu_login_hook_grant_path()/,/^}/p' "${SCRIPT}")
    assert_contains "TP-CF-APR-01 grant path is dns-review-hooks" "${_pathfn}" "/usr/local/bin/dns-review-hooks"
    assert_not_contains "TP-CF-APR-01 grant path not per-app doorbell" "${_pathfn}" '${APP_NAME}-hook'
    assert_contains "TP-CF-APR-01 skip next-step" "${_brc}" "approve login-hook-elev"
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

    # TP-CF-APR-08 — old product-binary hook is rewritten to dns-review-hooks
    _old_block=$(cat <<'EOF'
# keep-operator-text
# BEGIN dns-cli login hook
if [ -z "${DNS_CLI_HOOK_RAN:-}" ]; then
    DNS_CLI_HOOK_RAN=1
    export DNS_CLI_HOOK_RAN
    if ! sudo -n /usr/local/bin/dns-cli interactive; then
        printf '%s\n' "dns-cli: login review hook skipped (sudo -n failed)" >&2
    fi
fi
# END dns-cli login hook
EOF
)
    printf '%s\n' "${_old_block}" >"${_home}/.bashrc"
    sh "${SCRIPT}" version >/dev/null 2>&1
    _rew=$(cat "${_home}/.bashrc")
    assert_contains "TP-CF-APR-08 rewrote hook path" "${_rew}" "sudo -n /usr/local/bin/dns-review-hooks interactive 2>/dev/null"
    assert_not_contains "TP-CF-APR-08 old path gone" "${_rew}" "sudo -n /usr/local/bin/dns-cli interactive;"
    assert_not_contains "TP-CF-APR-08 no per-app doorbell" "${_rew}" "dns-cli-hook"
    assert_contains "TP-CF-APR-08 skip next-step" "${_rew}" "approve login-hook-elev"
    assert_contains "TP-CF-APR-08 kept operator text" "${_rew}" "keep-operator-text"
    _n3=$(grep -c '# BEGIN dns-cli login hook' "${_home}/.bashrc")
    assert_eq "TP-CF-APR-08 no duplicate block" "1" "${_n3}"

    # TP-CF-APR-08 — old per-app dns-cli-hook is rewritten to dns-review-hooks
    _mid_block=$(cat <<'EOF'
# keep-operator-text
# BEGIN dns-cli login hook
if [ -z "${DNS_CLI_HOOK_RAN:-}" ]; then
    DNS_CLI_HOOK_RAN=1
    export DNS_CLI_HOOK_RAN
    if ! sudo -n /usr/local/bin/dns-cli-hook interactive 2>/dev/null; then
        printf '%s\n' "dns-cli: login review hook skipped (sudo -n failed). Next: as sudoer-adm, sudo sudoer-cli interactive to approve login-hook-elev." >&2
    fi
fi
# END dns-cli login hook
EOF
)
    printf '%s\n' "${_mid_block}" >"${_home}/.bashrc"
    sh "${SCRIPT}" version >/dev/null 2>&1
    _rew2=$(cat "${_home}/.bashrc")
    assert_contains "TP-CF-APR-08 rewrote per-app doorbell" "${_rew2}" "sudo -n /usr/local/bin/dns-review-hooks interactive 2>/dev/null"
    assert_not_contains "TP-CF-APR-08 per-app doorbell gone" "${_rew2}" "dns-cli-hook"
    assert_contains "TP-CF-APR-08 kept operator text after per-app rewrite" "${_rew2}" "keep-operator-text"

    # TP-CF-APR-08 — sibling login-review-hook in dns-adm rc is rewritten
    _sib_block=$(cat <<'EOF'
# keep-operator-text
# BEGIN dns-cli login hook
if [ -z "${DNS_CLI_HOOK_RAN:-}" ]; then
    DNS_CLI_HOOK_RAN=1
    export DNS_CLI_HOOK_RAN
    if ! sudo -n /usr/local/bin/login-review-hook interactive 2>/dev/null; then
        printf '%s\n' "dns-cli: login review hook skipped (sudo -n failed). Next: as sudoer-adm, sudo sudoer-cli interactive to approve login-hook-elev." >&2
    fi
fi
# END dns-cli login hook
EOF
)
    printf '%s\n' "${_sib_block}" >"${_home}/.bashrc"
    sh "${SCRIPT}" version >/dev/null 2>&1
    _rew3=$(cat "${_home}/.bashrc")
    assert_contains "TP-CF-APR-08 rewrote sibling doorbell" "${_rew3}" "sudo -n /usr/local/bin/dns-review-hooks interactive 2>/dev/null"
    assert_not_contains "TP-CF-APR-08 sibling doorbell gone" "${_rew3}" "login-review-hook"
    assert_contains "TP-CF-APR-08 kept operator text after sibling rewrite" "${_rew3}" "keep-operator-text"

    _sum1=$(cksum "${_home}/.bashrc")
    sh "${SCRIPT}" version >/dev/null 2>&1
    _sum2=$(cksum "${_home}/.bashrc")
    assert_eq "TP-CF-APR-09 already-common rc is not rewritten" "${_sum1}" "${_sum2}"

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

    _heal=$(sed -n '/^cf_approver_heal_login_rc()/,/^}/p' "${SCRIPT}")
    assert_contains "TP-CF-APR-07 heal aligns rc owner" "${_heal}" "util_align_rc_owner"
    _align=$(sed -n '/^util_align_rc_owner()/,/^}/p' "${SCRIPT}")
    assert_contains "TP-CF-APR-07 align helper chown" "${_align}" "chown"
    assert_contains "TP-CF-APR-07 corresponding user" "${_align}" "Corresponding user"

    _intfn=$(sed -n '/^cf_req_interactive()/,/^}/p' "${SCRIPT}")
    assert_contains "TP-CF-APR-09 interactive reviews old hook" "${_intfn}" "lpu_review_old_login_hook"
    _revfn=$(sed -n '/^lpu_review_old_login_hook()/,/^}/p' "${SCRIPT}")
    assert_contains "TP-CF-APR-09 review helper euid 0" "${_revfn}" 'id -u'
    assert_contains "TP-CF-APR-09 review helper heals LPU home" "${_revfn}" "lpu_heal_home_rc"
    assert_contains "TP-CF-APR-09 review helper skips test-mode" "${_revfn}" "lpu_test_mode"
    _setupfn=$(sed -n '/^lpu_setup()/,/^}/p' "${SCRIPT}")
    assert_contains "TP-CF-APR-09 setup reviews old hook" "${_setupfn}" "lpu_review_old_login_hook"

    unset CF_TEST_HEAL_RC
    unset CF_APPROVER_USER
    ci_vault_cleanup
}
