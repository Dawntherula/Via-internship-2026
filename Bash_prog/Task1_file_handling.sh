#!/usr/bin/env bash
# ------------------------------------------------------------------
# @title       Task1_file_handling.sh
# @author      Casmir Sraha
# @index       <7363623>
# @school      Kwame Nkrumah University of Science and Technology (KNUST)
# @description Creates a directory, manages a text file within it,
#              handles backups, and performs deletion with validation.
# @date        2026-09-28
# ------------------------------------------------------------------

# Display usage information and exit
usage() {
    echo "Usage: $0 <target-directory>"
    echo "  <target-directory>  Path to the directory where file operations will occur."
    exit 1
}

# Check for help flag or incorrect argument count
if [[ "$1" == "-h" || "$1" == "--help" || $# -ne 1 ]]; then
    usage
fi

TARGET_DIR="$1"
FILE_NAME="sample.txt"
FILE_PATH="${TARGET_DIR}/${FILE_NAME}"
BAK_PATH="${FILE_PATH}.bak"

# 1. Directory creation check
if [[ -d "$TARGET_DIR" ]]; then
    echo "[INFO] Directory '$TARGET_DIR' already exists."
else
    mkdir -p "$TARGET_DIR" 2>/dev/null
    if [[ $? -eq 0 ]]; then
        echo "[SUCCESS] Directory '$TARGET_DIR' created successfully."
    else
        echo "Error: Failed to create directory '$TARGET_DIR'. Check permissions." >&2
        exit 1
    fi
fi

# 2. Create file and write initial content
echo "Initial line of content." > "$FILE_PATH" 2>/dev/null
if [[ $? -eq 0 ]]; then
    echo "[SUCCESS] Created file '$FILE_PATH' and wrote initial content."
else
    echo "Error: Failed to write to file '$FILE_PATH'." >&2
    exit 1
fi

# 3. Append additional content
echo "Appended second line of content." >> "$FILE_PATH" 2>/dev/null
if [[ $? -eq 0 ]]; then
    echo "[SUCCESS] Appended content to '$FILE_PATH'."
else
    echo "Error: Failed to append content to '$FILE_PATH'." >&2
    exit 1
fi

# 4. Read and display contents
echo "--- Displaying file contents ---"
cat "$FILE_PATH"
if [[ $? -ne 0 ]]; then
    echo "Error: Failed to read file '$FILE_PATH'." >&2
    exit 1
fi
echo "--------------------------------"

# 5. Copy file to a .bak version
cp "$FILE_PATH" "$BAK_PATH" 2>/dev/null
if [[ $? -eq 0 ]]; then
    echo "[SUCCESS] Copied '$FILE_PATH' to '$BAK_PATH'."
else
    echo "Error: Failed to create backup file '$BAK_PATH'." >&2
    exit 1
fi

# 6. Check existence and delete original file
if [[ -f "$FILE_PATH" ]]; then
    echo "[CONFIRMATION] File '$FILE_PATH' exists. Proceeding with deletion..."
    rm "$FILE_PATH" 2>/dev/null
    if [[ $? -eq 0 ]]; then
        echo "[SUCCESS] Original file '$FILE_PATH' deleted."
    else
        echo "Error: Failed to delete file '$FILE_PATH'." >&2
        exit 1
    fi
else
    echo "Error: File '$FILE_PATH' does not exist for deletion." >&2
    exit 1
fi

exit 0
