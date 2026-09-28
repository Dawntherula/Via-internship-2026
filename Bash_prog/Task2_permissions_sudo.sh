#!/usr/bin/env bash
# ------------------------------------------------------------------
# @title       Task2_permissions_sudo.sh
# @author      Casmir Sraha
# @index       <7363623>
# @school      Kwame Nkrumah University of Science and Technology (KNUST)
# @description Inspects file permissions, demonstrates numeric/symbolic
#              chmod changes, and conditionally attempts chown if run as root.
# @date        2026-09-28
# ------------------------------------------------------------------

# Display usage information and exit
usage() {
    echo "Usage: $0 <file-path>"
    echo "  <file-path>  Path to the file whose permissions will be inspected and altered."
    exit 1
}

# Helper function to print symbolic and numeric permissions
print_permissions() {
    local target="$1"
    local symbolic
    local numeric

    # Using stat for cross-platform portability on Linux
    symbolic=$(stat -c "%A" "$target" 2>/dev/null)
    numeric=$(stat -c "%a" "$target" 2>/dev/null)

    if [[ $? -eq 0 ]]; then
        echo "   -> Symbolic: $symbolic"
        echo "   -> Numeric:  $numeric"
    else
        echo "Error: Failed to retrieve permissions for '$target'." >&2
        return 1
    fi
}

# Check for help flag or missing arguments
if [[ "$1" == "-h" || "$1" == "--help" || $# -ne 1 ]]; then
    usage
fi

TARGET_FILE="$1"

# Validate that the file exists
if [[ ! -e "$TARGET_FILE" ]]; then
    echo "Error: Target file '$TARGET_FILE' does not exist." >&2
    exit 1
fi

echo "=== Initial File Permissions ==="
print_permissions "$TARGET_FILE"
if [[ $? -ne 0 ]]; then
    exit 1
fi

echo -e "\n=== Step 1: Applying Numeric Permission Change (chmod 644) ==="
chmod 644 "$TARGET_FILE" 2>/dev/null
if [[ $? -eq 0 ]]; then
    echo "[SUCCESS] Changed permissions to 644."
else
    echo "Error: Failed to set permissions to 644 on '$TARGET_FILE'." >&2
    exit 1
fi

echo -e "\n=== Step 2: Applying Symbolic Permission Change (chmod u+x) ==="
chmod u+x "$TARGET_FILE" 2>/dev/null
if [[ $? -eq 0 ]]; then
    echo "[SUCCESS] Added user execute permission (u+x)."
else
    echo "Error: Failed to set user execute permission on '$TARGET_FILE'." >&2
    exit 1
fi

echo -e "\n=== Step 3: Root Privilege Check & chown Attempt ==="
# Check effective user ID (0 indicates root)
if [[ $(id -u) -eq 0 ]]; then
    echo "[INFO] Executing as root. Attempting chown operation..."
    
    # Get current file owner to safely re-assign ownership to itself
    CURRENT_USER=$(stat -c "%U" "$TARGET_FILE")
    chown "$CURRENT_USER" "$TARGET_FILE" 2>/dev/null
    
    if [[ $? -eq 0 ]]; then
        echo "[SUCCESS] Ownership re-assigned/verified for user '$CURRENT_USER'."
    else
        echo "Error: 'chown' operation failed." >&2
        exit 1
    fi
else
    echo "[NOTICE] Skipping 'chown' step: Script is not running as root (id -u != 0)."
    echo "         To test ownership changes, rerun with 'sudo $0 $TARGET_FILE'."
fi

echo -e "\n=== Final File Permissions ==="
print_permissions "$TARGET_FILE"
if [[ $? -ne 0 ]]; then
    exit 1
fi

exit 0
