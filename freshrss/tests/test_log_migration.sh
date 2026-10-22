#!/usr/bin/env bash
# ==============================================================================
# Unit tests for FreshRSS compatibility log migration logic
# Directly extracts and executes the EXACT migration snippet from init-freshrss/run
# ==============================================================================
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
production_script="${script_dir}/../rootfs/etc/s6-overlay/s6-rc.d/init-freshrss/run"

if [ ! -f "${production_script}" ]; then
    echo "ERROR: Production script not found at ${production_script}"
    exit 1
fi

test_dir="$(mktemp -d /tmp/freshrss_prod_test_XXXXXX)"
trap 'rm -rf "${test_dir}"' EXIT

migration_snippet="${test_dir}/extracted_migration.sh"

python3 - "${production_script}" "${migration_snippet}" << 'PYEOF'
import sys

prod_script = sys.argv[1]
output_file = sys.argv[2]

with open(prod_script, "r", encoding="utf-8") as f:
    lines = f.readlines()

start = False
extracted = []
for line in lines:
    if 'compat_logs="/config/app/68949b71_freshrss/logs"' in line:
        start = True
    if start:
        extracted.append(line)
        if line.strip() == "fi" and any("elif [ ! -e" in l for l in extracted[-5:]):
            break

with open(output_file, "w", encoding="utf-8") as f:
    f.writelines(extracted)
PYEOF

if [ ! -s "${migration_snippet}" ]; then
    echo "ERROR: Failed to extract migration snippet from production script!"
    exit 1
fi

# Wrapper function executing the exact production snippet in a sandboxed /config directory
run_production_migration() {
    local config_root="$1"

    (
        export config_dir="${config_root}"

        # Mock bashio functions
        bashio::log.info() { echo "[INFO] $*"; }
        bashio::log.error() { echo "[ERROR] $*"; }
        bashio::exit.nok() { echo "[FATAL] $*"; exit 1; }

        local sandboxed_exec; sandboxed_exec="${test_dir}/exec_$(basename "${config_root}").sh"
        sed "s#/config/logs#${config_dir}/logs#g; s#/config/app/68949b71_freshrss/logs#${config_dir}/app/68949b71_freshrss/logs#g" "${migration_snippet}" > "${sandboxed_exec}"

        # shellcheck disable=SC1090
        source "${sandboxed_exec}"
    )
}

echo "=== Test 1: Production logic handles visible AND hidden dotfiles ==="
t1="${test_dir}/t1"
mkdir -p "${t1}/logs" "${t1}/app/68949b71_freshrss/logs"
echo "visible content" > "${t1}/app/68949b71_freshrss/logs/refresh.log"
echo "hidden dotfile content" > "${t1}/app/68949b71_freshrss/logs/.hidden_state"
run_production_migration "${t1}"
[ -L "${t1}/app/68949b71_freshrss/logs" ] || { echo "FAIL: Not a symlink"; exit 1; }
[ "$(readlink "${t1}/app/68949b71_freshrss/logs")" = "${t1}/logs" ] || { echo "FAIL: Wrong link target"; exit 1; }
[ -f "${t1}/logs/refresh.log" ] || { echo "FAIL: Visible file not migrated"; exit 1; }
[ -f "${t1}/logs/.hidden_state" ] || { echo "FAIL: Hidden dotfile NOT migrated!"; exit 1; }
echo "PASS: Test 1"

echo "=== Test 2: Name collision (preserves destination and backs up source) ==="
t2="${test_dir}/t2"
mkdir -p "${t2}/logs" "${t2}/app/68949b71_freshrss/logs"
echo "new log content" > "${t2}/logs/refresh.log"
echo "legacy log content" > "${t2}/app/68949b71_freshrss/logs/refresh.log"
run_production_migration "${t2}"
[ -L "${t2}/app/68949b71_freshrss/logs" ] || { echo "FAIL: Not a symlink"; exit 1; }
grep -q "new log content" "${t2}/logs/refresh.log" || { echo "FAIL: Destination overwritten"; exit 1; }
ls "${t2}/logs"/refresh.log.migrated_* >/dev/null 2>&1 || { echo "FAIL: Migrated backup file missing"; exit 1; }
echo "PASS: Test 2"

echo "=== Test 3: Idempotent when symlink already exists ==="
t3="${test_dir}/t3"
mkdir -p "${t3}/logs" "${t3}/app/68949b71_freshrss"
ln -sf "${t3}/logs" "${t3}/app/68949b71_freshrss/logs"
run_production_migration "${t3}"
[ -L "${t3}/app/68949b71_freshrss/logs" ] || { echo "FAIL: Symlink broken"; exit 1; }
echo "PASS: Test 3"

echo "=== Test 4: Copy failure preserves legacy directory and aborts ==="
t4="${test_dir}/t4"
mkdir -p "${t4}/logs" "${t4}/app/68949b71_freshrss/logs"
echo "unwritable target" > "${t4}/app/68949b71_freshrss/logs/test.log"
chmod 555 "${t4}/logs" # Make destination unwritable
set +e
( run_production_migration "${t4}" >/dev/null 2>&1 )
exit_code=$?
set -e
chmod 755 "${t4}/logs"
[ "${exit_code}" -ne 0 ] || { echo "FAIL: Expected failure on read-only dest, got exit code 0"; exit 1; }
[ -d "${t4}/app/68949b71_freshrss/logs" ] || { echo "FAIL: Legacy directory was deleted!"; exit 1; }
[ -f "${t4}/app/68949b71_freshrss/logs/test.log" ] || { echo "FAIL: Legacy file was deleted!"; exit 1; }
echo "PASS: Test 4"

echo ""

echo "=== Test 5: Multi-collision (when .migrated_<timestamp> already exists) ==="
t5="${test_dir}/t5"
mkdir -p "${t5}/logs" "${t5}/app/68949b71_freshrss/logs"
ts="$(date +%s)"
echo "destination active log" > "${t5}/logs/refresh.log"
echo "existing backup log 1" > "${t5}/logs/refresh.log.migrated_${ts}"
echo "existing backup log 2" > "${t5}/logs/refresh.log.migrated_${ts}_1"
echo "new incoming legacy log" > "${t5}/app/68949b71_freshrss/logs/refresh.log"
run_production_migration "${t5}"
[ -L "${t5}/app/68949b71_freshrss/logs" ] || { echo "FAIL: Not a symlink"; exit 1; }
grep -q "destination active log" "${t5}/logs/refresh.log" || { echo "FAIL: Destination active overwritten"; exit 1; }
grep -q "existing backup log 1" "${t5}/logs/refresh.log.migrated_${ts}" || { echo "FAIL: Existing backup 1 overwritten"; exit 1; }
grep -q "existing backup log 2" "${t5}/logs/refresh.log.migrated_${ts}_1" || { echo "FAIL: Existing backup 2 overwritten"; exit 1; }
grep -q "new incoming legacy log" "${t5}/logs/refresh.log.migrated_${ts}_2" || { echo "FAIL: Incoming legacy log not safely saved under unique suffix"; exit 1; }
echo "PASS: Test 5"

echo "All 5 production-linked migration test cases passed successfully!"
