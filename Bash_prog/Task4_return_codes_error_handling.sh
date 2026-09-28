#!/usr/bin/env bash
# ------------------------------------------------------------------
# @title       Task4_return_codes_error_handling.sh
# @author      Casmir Sraha
# @index       <7363623>
# @school      Kwame Nkrumah University of Science and Technology (KNUST)
# @description Executes system health checks using return codes, custom
#              exit mapping, error redirection, and signal traps.
# @date        2026-09-28
# ------------------------------------------------------------------
# Exit codes:
#   0 = all checks passed
#   1 = missing required argument
#   2 = host unreachable
#   3 = insufficient disk space
#   4 = required file not found
#   5 = required command not found
# ------------------------------------------------------------------

# Temporary file used during execution
TEMP_FILE=$(mktemp /tmp/task4_check.XXXXXX 2>/dev/null)

# Cleanup function for trap
cleanup() {
    if [[ -f "$TEMP_FILE" ]]; then
        rm -f "$TEMP_FILE" 2>/dev/null
        echo "[CLEANUP] Temporary file '$TEMP_FILE' removed."
    fi
}
trap cleanup EXIT SIGINT SIGTERM

# Display usage instructions and exit
usage() {
    echo "Usage: $0 <hostname>"
    echo "  <hostname>  Host or IP address to ping during reachability check."
    exit 1
}

# Helper function: check exit code, log pass/fail, and exit on failure
check_status() {
    local status_code="$1"
    local check_name="$2"
    local failure_exit_code="$3"

    if [[ "$status_code" -eq 0 ]]; then
        echo "[PASS] $check_name"
    else
        echo "Error: [FAIL] $check_name (Exit code $failure_exit_code)" >&2
        exit "$failure_exit_code"
    fi
}

# 1. Argument Check
if [[ "$1" == "-h" || "$1" == "--help" || $# -ne 1 ]]; then
    usage
fi

HOST="$1"
CONFIG_FILE="/etc/passwd"
REQUIRED_CMD="curl"

echo "=========================================="
echo "    SYSTEM HEALTH & ERROR CHECKS          "
echo "=========================================="

# Check 1: Host Reachability
ping -c 1 -W 2 "$HOST" > /dev/null 2>&1
check_status $? "Host reachability test for '$HOST'" 2

# Check 2: Disk Space Check (Requires >= 10% free space)
FREE_PERCENT=$(df / | awk 'NR==2 {print 100 - $5}' | tr -d '%')
if [[ "$FREE_PERCENT" -ge 10 ]]; then
    CMD_RESULT=0
else
    CMD_RESULT=1
fi
check_status $CMD_RESULT "Disk space availability check (>= 10% free)" 3

# Check 3: File Existence and Readability
if [[ -f "$CONFIG_FILE" && -r "$CONFIG_FILE" ]]; then
    CMD_RESULT=0
else
    CMD_RESULT=1
fi
check_status $CMD_RESULT "File existence & readability test for '$CONFIG_FILE'" 4

# Check 4: Required Command Installation
command -v "$REQUIRED_CMD" > /dev/null 2>&1
check_status $? "Tool availability check for '$REQUIRED_CMD'" 5

echo "=========================================="
echo "[SUCCESS] All system checks passed successfully!"
exit 0
