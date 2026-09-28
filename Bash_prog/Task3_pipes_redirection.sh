#!/usr/bin/env bash
# ------------------------------------------------------------------
# @title       Task3_pipes_redirection.sh
# @author      Casmir Sraha
# @index       <7363623>
# @school      Kwame Nkrumah University of Science and Technology (KNUST)
# @description Generates a self-contained log file and uses text processing
#              pipelines to compute summary statistics, outputting to results.txt.
# @date        2026-09-28
# ------------------------------------------------------------------

# Display usage information and exit
usage() {
    echo "Usage: $0"
    echo "  This script takes no arguments. It generates sample logs and computes analytics."
    exit 1
}

# Check for help flag or unexpected arguments
if [[ "$1" == "-h" || "$1" == "--help" || $# -gt 0 ]]; then
    usage
fi

LOG_FILE="sample_app.log"
RESULTS_FILE="results.txt"
ERROR_LOG="errors.log"

# Clear old log/error files if present
> "$RESULTS_FILE"
> "$ERROR_LOG"

# 1. Generate self-contained fake log data (50+ lines) using a heredoc
cat << 'EOF' > "$LOG_FILE" 2>> "$ERROR_LOG"
2026-09-11 10:03:21 INFO 192.168.1.10 User login successful
2026-09-11 10:03:45 ERROR 192.168.1.23 Connection timeout
2026-09-11 10:04:02 WARN 192.168.1.10 Disk usage above 80%
2026-09-11 10:05:12 INFO 192.168.1.15 Password changed successfully
2026-09-11 10:06:00 ERROR 192.168.1.10 Database query failed
2026-09-11 10:06:45 INFO 192.168.1.42 User logout
2026-09-11 10:07:11 WARN 192.168.1.23 High CPU usage detected
2026-09-11 10:08:30 ERROR 192.168.1.10 Unauthorized access attempt
2026-09-11 10:09:01 INFO 192.168.1.88 File downloaded successfully
2026-09-11 10:10:15 INFO 192.168.1.10 User login successful
2026-09-11 10:11:00 ERROR 192.168.1.55 Network interface down
2026-09-11 10:12:05 WARN 192.168.1.15 Memory threshold reached
2026-09-11 10:13:22 INFO 192.168.1.10 Session refreshed
2026-09-11 10:14:10 ERROR 192.168.1.23 Connection reset by peer
2026-09-11 10:15:00 INFO 192.168.1.42 API call executed
2026-09-11 10:16:30 WARN 192.168.1.10 High memory usage
2026-09-11 10:17:12 INFO 192.168.1.10 User login successful
2026-09-11 10:18:05 ERROR 192.168.1.99 SSL certificate expired
2026-09-11 10:19:40 INFO 192.168.1.15 Profile updated
2026-09-11 10:20:11 WARN 192.168.1.23 Slow response time
2026-09-11 10:21:00 ERROR 192.168.1.10 Failed authentication
2026-09-11 10:22:15 INFO 192.168.1.88 User logout
2026-09-11 10:23:05 INFO 192.168.1.10 User login successful
2026-09-11 10:24:50 WARN 192.168.1.55 Bandwidth limit reached
2026-09-11 10:25:30 ERROR 192.168.1.23 Service unavailable
2026-09-11 10:26:12 INFO 192.168.1.42 Data backup started
2026-09-11 10:27:00 WARN 192.168.1.10 High disk I/O
2026-09-11 10:28:15 ERROR 192.168.1.10 Database connection lost
2026-09-11 10:29:40 INFO 192.168.1.15 Password reset requested
2026-09-11 10:30:00 INFO 192.168.1.10 User login successful
2026-09-11 10:31:22 WARN 192.168.1.23 Latency spike observed
2026-09-11 10:32:10 ERROR 192.168.1.88 File permission denied
2026-09-11 10:33:05 INFO 192.168.1.42 Settings updated
2026-09-11 10:34:50 ERROR 192.168.1.10 Out of memory error
2026-09-11 10:35:12 WARN 192.168.1.15 Storage space low
2026-09-11 10:36:00 INFO 192.168.1.10 User login successful
2026-09-11 10:37:25 ERROR 192.168.1.23 Internal server error
2026-09-11 10:38:10 WARN 192.168.1.99 Unusual traffic detected
2026-09-11 10:39:00 INFO 192.168.1.42 User logout
2026-09-11 10:40:15 ERROR 192.168.1.10 Cache sync failure
2026-09-11 10:41:30 INFO 192.168.1.15 User login successful
2026-09-11 10:42:05 WARN 192.168.1.10 High CPU temperature
2026-09-11 10:43:00 ERROR 192.168.1.23 Connection refused
2026-09-11 10:44:12 INFO 192.168.1.88 Scheduled job started
2026-09-11 10:45:50 WARN 192.168.1.55 Queue size growing
2026-09-11 10:46:10 ERROR 192.168.1.10 Critical service failure
2026-09-11 10:47:00 INFO 192.168.1.10 User login successful
2026-09-11 10:48:22 WARN 192.168.1.23 Packet loss detected
2026-09-11 10:49:15 ERROR 192.168.1.42 Disk write error
2026-09-11 10:50:00 INFO 192.168.1.15 Maintenance completed
EOF

# Check log file creation success
if [[ $? -ne 0 || ! -s "$LOG_FILE" ]]; then
    echo "Error: Failed to create log file '$LOG_FILE'." >&2
    exit 1
fi

# Build summary report and write output to results.txt (>) while saving error output to errors.log (2>>)
{
    echo "=========================================="
    echo "        LOG ANALYSIS REPORT              "
    echo "=========================================="
    echo ""

    # 1. Total number of log lines
    TOTAL_LINES=$(wc -l < "$LOG_FILE")
    echo "1. TOTAL LOG LINES: $TOTAL_LINES"
    echo ""

    # 2. Count of lines per log level (INFO, WARN, ERROR)
    echo "2. COUNT OF LINES PER LOG LEVEL:"
    INFO_COUNT=$(grep -c " INFO " "$LOG_FILE")
    WARN_COUNT=$(grep -c " WARN " "$LOG_FILE")
    ERROR_COUNT=$(grep -c " ERROR " "$LOG_FILE")
    echo "   - INFO : $INFO_COUNT"
    echo "   - WARN : $WARN_COUNT"
    echo "   - ERROR: $ERROR_COUNT"
    echo ""

    # 3. Top 3 most frequent IP addresses
    echo "3. TOP 3 MOST FREQUENT IP ADDRESSES:"
    awk '{print $4}' "$LOG_FILE" | sort | uniq -c | sort -nr | head -n 3 | awk '{print "   - IP: " $2 " (" $1 " occurrences)"}'
    echo ""

    # 4. All ERROR lines only
    echo "4. ALL ERROR LINES ONLY:"
    grep " ERROR " "$LOG_FILE"
    echo ""
    echo "=========================================="
} > "$RESULTS_FILE" 2>> "$ERROR_LOG"

# Verify report creation
if [[ $? -eq 0 ]]; then
    echo "[SUCCESS] Log processing complete. Summary report saved to '$RESULTS_FILE'."
    echo ""
    echo "--- Displaying '$RESULTS_FILE' ---"
    cat "$RESULTS_FILE"
else
    echo "Error: Failed during text processing pipelines. Check '$ERROR_LOG'." >&2
    exit 1
fi

exit 0
