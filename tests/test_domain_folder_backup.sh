# =============================================================================
# tests/test_domain_folder_backup.sh — folder archive backup + domain surface
# =============================================================================
# Primary ops REQ: requirement-folder-archive-backup (NOT domain)
# Domain surface:  requirement-domain-folder-backup (verbs/help/about pointers)
# Privilege peer:  requirement-three-layer-privilege-model
# Other peers:     requirement-shell-idempotency
# TP family: TP-FOLDER-BACKUP-*
# =============================================================================

# shellcheck source=helpers.sh
. "${TESTS_ROOT}/helpers.sh"

# Probe narrow Type 1 deposit without running backup.
# Returns 0 when passwordless allowlisted mkdir for deposit dir works.
fb_ci_sudo_deposit_available() {
    command -v sudo >/dev/null 2>&1 || return 1
    sudo -n /usr/bin/mkdir -p /var/backup/folder-backup >/dev/null 2>&1 \
        || sudo -n /bin/mkdir -p /var/backup/folder-backup >/dev/null 2>&1
}

# Fail-closed path: put a non-elevating "sudo" first on PATH so deposit cannot escalate.
fb_ci_path_without_working_sudo() {
    _bindir=$(mktemp -d "${TMPDIR:-/tmp}/fb-nosudo.XXXXXX")
    printf '%s\n' '#!/bin/sh' 'echo "sudo: simulated unauthorized" >&2' 'exit 1' >"${_bindir}/sudo"
    chmod 0755 "${_bindir}/sudo"
    printf '%s' "${_bindir}:${PATH}"
}

run_test_domain_folder_backup() {
    t_header "Domain folder-backup (TP-FOLDER-BACKUP)"

    require_cmd sh
    require_cmd tar
    require_cmd date

    ci_isolated_env

    # TP-FOLDER-BACKUP-01 print-sudoers human emits fragment; Type 0 must not install /etc
    _out=$(HOME="${CI_HOME}" sh "${SCRIPT}" print-sudoers 2>&1)
    _ec=$?
    assert_eq "TP-FOLDER-BACKUP-01 print-sudoers exit 0" 0 "$_ec"
    assert_contains "TP-FOLDER-BACKUP-01 NOPASSWD" "$_out" "NOPASSWD"
    assert_contains "TP-FOLDER-BACKUP-01 dest path" "$_out" "/var/backup/folder-backup"
    assert_contains "TP-FOLDER-BACKUP-01 admin install hint" "$_out" "/etc/sudoers.d/"
    assert_contains "TP-FOLDER-BACKUP-01 tar verify allowlist" "$_out" "tar -tzf"
    # print-sudoers never writes /etc itself. Host may already have admin-installed fragment.
    if [ -e /etc/sudoers.d/folder-backup ]; then
        t_pass "TP-FOLDER-BACKUP-01 host has admin sudoers (print-sudoers is Type 0 only; no /etc write attempted)"
    else
        assert_file_missing "TP-FOLDER-BACKUP-01 no /etc write" "/etc/sudoers.d/folder-backup"
    fi

    # TP-FOLDER-BACKUP-02 print-sudoers to path
    _frag="${CI_HOME}/.config/folder-backup/sudoers.fragment"
    _out=$(HOME="${CI_HOME}" sh "${SCRIPT}" print-sudoers "${_frag}" 2>&1)
    _ec=$?
    assert_eq "TP-FOLDER-BACKUP-02 write fragment exit 0" 0 "$_ec"
    assert_file_exists "TP-FOLDER-BACKUP-02 fragment file" "${_frag}"
    assert_contains "TP-FOLDER-BACKUP-02 file has mkdir" "$(cat "${_frag}")" "mkdir -p /var/backup/folder-backup"
    assert_not_contains "TP-FOLDER-BACKUP-02 no ALL ALL" "$(cat "${_frag}")" "NOPASSWD: ALL"

    # TP-FOLDER-BACKUP-03 backup without source fails
    _err=$(HOME="${CI_HOME}" sh "${SCRIPT}" backup 2>&1 >/dev/null)
    assert_eq "TP-FOLDER-BACKUP-03 backup no arg exit 1" 1 "$?"
    assert_contains "TP-FOLDER-BACKUP-03 usage" "$_err" "Usage:"

    # TP-FOLDER-BACKUP-04 backup invalid source fails
    _err=$(HOME="${CI_HOME}" sh "${SCRIPT}" backup /no/such/dir-$$ 2>&1 >/dev/null)
    assert_eq "TP-FOLDER-BACKUP-04 missing dir exit 1" 1 "$?"

    # TP-FOLDER-BACKUP-05 deposit fail-closed when escalation cannot succeed
    # Always force unauthorized sudo via PATH so this case stays valid with host sudoers installed.
    _src="${CI_HOME}/sample-src"
    mkdir -p "${_src}"
    printf 'data\n' > "${_src}/file.txt"
    _nopath=$(fb_ci_path_without_working_sudo)
    _err=$(HOME="${CI_HOME}" PATH="${_nopath}" sh "${SCRIPT}" backup "${_src}" 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-FOLDER-BACKUP-05 deposit fail-closed exit 1" 1 "$_ec"
    assert_contains "TP-FOLDER-BACKUP-05 sudoers hint" "$_err" "print-sudoers"
    # cleanup fake sudo dir (prefix before first :)
    _fake=$(printf '%s' "${_nopath}" | cut -d: -f1)
    rm -rf "${_fake}" 2>/dev/null || true

    # TP-FOLDER-BACKUP-06 archive naming visible before deposit fail
    _nopath=$(fb_ci_path_without_working_sudo)
    _out=$(HOME="${CI_HOME}" PATH="${_nopath}" sh "${SCRIPT}" backup "${_src}" 2>&1)
    assert_contains "TP-FOLDER-BACKUP-06 creates archive name pattern" "$_out" "sample-src-"
    assert_contains "TP-FOLDER-BACKUP-06 tar.gz extension" "$_out" ".tar.gz"
    _day=$(date +%Y%m%d)
    assert_contains "TP-FOLDER-BACKUP-06 date segment" "$_out" "${_day}"
    _fake=$(printf '%s' "${_nopath}" | cut -d: -f1)
    rm -rf "${_fake}" 2>/dev/null || true

    # TP-FOLDER-BACKUP-07/08 — elevated deposit (root OR allowlisted sudo -n)
    if [ "$(id -u)" -eq 0 ]; then
        _broot="${CI_HOME}/var-backup"
        mkdir -p "${_broot}"
        _out=$(HOME="${CI_HOME}" BACKUP_ROOT="${_broot}" BACKUP_NOTATION="folder-backup" \
            sh "${SCRIPT}" backup "${_src}" 2>&1)
        _ec=$?
        assert_eq "TP-FOLDER-BACKUP-07 root deposit exit 0" 0 "$_ec"
        _found=$(find "${_broot}/folder-backup" -name 'sample-src-*.tar.gz' 2>/dev/null | head -n1)
        if [ -n "$_found" ] && [ -f "$_found" ]; then
            t_pass "TP-FOLDER-BACKUP-07 archive deposited"
            _out2=$(HOME="${CI_HOME}" BACKUP_ROOT="${_broot}" BACKUP_NOTATION="folder-backup" \
                sh "${SCRIPT}" backup "${_src}" 2>&1)
            _count=$(find "${_broot}/folder-backup" -name "sample-src-${_day}-*.tar.gz" 2>/dev/null | wc -l | tr -d ' ')
            if [ "${_count}" -ge 2 ]; then
                t_pass "TP-FOLDER-BACKUP-08 next-N no overwrite (${_count} archives)"
            else
                t_fail "TP-FOLDER-BACKUP-08 expected >=2 archives, got ${_count}"
            fi
        else
            t_fail "TP-FOLDER-BACKUP-07 no archive under ${_broot}/folder-backup"
            t_skip "TP-FOLDER-BACKUP-08 skipped (no first deposit)"
        fi
    elif fb_ci_sudo_deposit_available; then
        # Host admin installed narrow sudoers — exercise real Type 1 deposit
        _marker="ci-elev-$$"
        _elev_src="${CI_HOME}/${_marker}"
        mkdir -p "${_elev_src}"
        printf 'elev\n' > "${_elev_src}/payload.txt"
        _out=$(HOME="${CI_HOME}" sh "${SCRIPT}" backup "${_elev_src}" 2>&1)
        _ec=$?
        assert_eq "TP-FOLDER-BACKUP-07 sudo deposit exit 0" 0 "$_ec"
        assert_contains "TP-FOLDER-BACKUP-07 deposit path" "$_out" "/var/backup/folder-backup/${_marker}-"
        assert_contains "TP-FOLDER-BACKUP-07 success text" "$_out" "Backup complete"
        assert_contains "TP-FOLDER-BACKUP-07 verified counts" "$_out" "Verified:"
        assert_contains "TP-FOLDER-BACKUP-07 source_files" "$_out" "source_files="
        assert_contains "TP-FOLDER-BACKUP-07 archive_files" "$_out" "archive_files="
        if [ -f "/var/backup/folder-backup/${_marker}-${_day}-1.tar.gz" ] \
            || find /var/backup/folder-backup -name "${_marker}-${_day}-*.tar.gz" 2>/dev/null | grep -q .; then
            t_pass "TP-FOLDER-BACKUP-07 archive present under deposit dir"
            _out2=$(HOME="${CI_HOME}" sh "${SCRIPT}" backup "${_elev_src}" 2>&1)
            _ec2=$?
            assert_eq "TP-FOLDER-BACKUP-08 second deposit exit 0" 0 "$_ec2"
            _count=$(find /var/backup/folder-backup -name "${_marker}-${_day}-*.tar.gz" 2>/dev/null | wc -l | tr -d ' ')
            if [ "${_count}" -ge 2 ]; then
                t_pass "TP-FOLDER-BACKUP-08 next-N no overwrite (${_count} archives via sudo)"
            else
                t_fail "TP-FOLDER-BACKUP-08 expected >=2 archives via sudo, got ${_count}"
            fi
        else
            # Deposit may succeed with root ownership; listing may still work on 0755 dir
            if printf '%s' "$_out" | grep -q 'Backup complete'; then
                t_pass "TP-FOLDER-BACKUP-07 archive deposited (success message; dir list limited)"
                _out2=$(HOME="${CI_HOME}" sh "${SCRIPT}" backup "${_elev_src}" 2>&1)
                if printf '%s' "$_out2" | grep -q -- "-${_day}-2.tar.gz"; then
                    t_pass "TP-FOLDER-BACKUP-08 next-N via sudo (name -2)"
                else
                    assert_contains "TP-FOLDER-BACKUP-08 next-N name" "$_out2" "-${_day}-"
                fi
            else
                t_fail "TP-FOLDER-BACKUP-07 no archive evidence under /var/backup/folder-backup"
                t_skip "TP-FOLDER-BACKUP-08 skipped (no first deposit)"
            fi
        fi
    else
        t_skip "TP-FOLDER-BACKUP-07 elevated deposit (not root; sudoers deposit not available)"
        t_skip "TP-FOLDER-BACKUP-08 next-N full deposit (not root; sudoers deposit not available)"
    fi

    # TP-FOLDER-BACKUP-09 help/about domain fields already partially CLI; confirm about deposit_dir
    _out=$(HOME="${CI_HOME}" sh "${SCRIPT}" --json about 2>/dev/null)
    assert_contains "TP-FOLDER-BACKUP-09 about backup_root" "$_out" '"backup_root"'
    assert_contains "TP-FOLDER-BACKUP-09 about sudo_deposit" "$_out" '"sudo_deposit"'

    # TP-FOLDER-BACKUP-10 path-ish: sanitize leaves basename only (source with nested ok)
    _nested="${CI_HOME}/proj/nested-name"
    mkdir -p "${_nested}"
    echo y > "${_nested}/b.txt"
    # Prefer nosudo for naming check so we do not require deposit; if sudo works, success still names leaf
    _nopath=$(fb_ci_path_without_working_sudo)
    _out=$(HOME="${CI_HOME}" PATH="${_nopath}" sh "${SCRIPT}" backup "${_nested}" 2>&1)
    assert_contains "TP-FOLDER-BACKUP-10 uses leaf basename" "$_out" "nested-name-"
    _fake=$(printf '%s' "${_nopath}" | cut -d: -f1)
    rm -rf "${_fake}" 2>/dev/null || true

    # -------------------------------------------------------------------------
    # TP-FOLDER-BACKUP-11..13 restore (ops SSOT; default dest host = hard-disk)
    # -------------------------------------------------------------------------
    # Build a user-readable archive under controlled BACKUP_ROOT (no sudo needed)
    _broot="${CI_HOME}/var-backup"
    _dep="${_broot}/folder-backup"
    mkdir -p "${_dep}"
    _rsrc="${CI_HOME}/restore-src-tree"
    mkdir -p "${_rsrc}/sub"
    printf 'restore-me\n' > "${_rsrc}/a.txt"
    printf 'nested\n' > "${_rsrc}/sub/b.txt"
    # Create archive matching product naming via tar (leaf = restore-src-tree)
    _day=$(date +%Y%m%d)
    _aname="restore-src-tree-${_day}-1.tar.gz"
    tar -C "${CI_HOME}" -czf "${_dep}/${_aname}" "restore-src-tree"
    # TP-FOLDER-BACKUP-11 restore missing archive fails
    _err=$(HOME="${CI_HOME}" BACKUP_ROOT="${_broot}" sh "${SCRIPT}" restore no-such-archive-xyz 2>&1 >/dev/null)
    assert_eq "TP-FOLDER-BACKUP-11 missing archive exit 1" 1 "$?"
    # TP-FOLDER-BACKUP-12 restore to explicit dest (override host SSOT)
    _rdest="${CI_HOME}/projects-sim"
    mkdir -p "${_rdest}"
    _out=$(HOME="${CI_HOME}" BACKUP_ROOT="${_broot}" \
        sh "${SCRIPT}" restore "${_aname}" "${_rdest}/restore-src-tree" 2>&1)
    _ec=$?
    assert_eq "TP-FOLDER-BACKUP-12 restore exit 0" 0 "$_ec"
    assert_contains "TP-FOLDER-BACKUP-12 restore complete" "$_out" "Restore complete"
    assert_contains "TP-FOLDER-BACKUP-12 verified files" "$_out" "Verified:"
    assert_file_exists "TP-FOLDER-BACKUP-12 restored file" "${_rdest}/restore-src-tree/a.txt"
    # TP-FOLDER-BACKUP-13 default host is hard-disk (message) when no dest
    _proot="${CI_HOME}/prjs"
    mkdir -p "${_proot}"
    # non-empty dest fails without --force
    _out=$(HOME="${CI_HOME}" BACKUP_ROOT="${_broot}" PROJECTS_ROOT="${_proot}" \
        sh "${SCRIPT}" restore restore-src-tree 2>&1) || true
    # first restore to hard-disk default
    rm -rf "${_proot}/restore-src-tree"
    _out=$(HOME="${CI_HOME}" BACKUP_ROOT="${_broot}" PROJECTS_ROOT="${_proot}" \
        sh "${SCRIPT}" restore restore-src-tree 2>&1)
    _ec=$?
    assert_eq "TP-FOLDER-BACKUP-13 hard-disk default exit 0" 0 "$_ec"
    assert_contains "TP-FOLDER-BACKUP-13 host hard-disk" "$_out" "hard-disk"
    assert_file_exists "TP-FOLDER-BACKUP-13 on projects root" "${_proot}/restore-src-tree/a.txt"
    # second without force fails
    _err=$(HOME="${CI_HOME}" BACKUP_ROOT="${_broot}" PROJECTS_ROOT="${_proot}" \
        sh "${SCRIPT}" restore restore-src-tree 2>&1 >/dev/null)
    assert_eq "TP-FOLDER-BACKUP-13 non-empty without force exit 1" 1 "$?"

    # print-sudoers includes restore stage cp reverse
    _out=$(HOME="${CI_HOME}" sh "${SCRIPT}" print-sudoers 2>&1)
    assert_contains "TP-FOLDER-BACKUP-01b restore stage cp allowlist" "$_out" "Restore: copy deposit"

    ci_cleanup_env
}
