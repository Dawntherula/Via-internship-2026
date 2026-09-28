#!/usr/bin/env bash
# ------------------------------------------------------------------
# @title       Task5_crud_app.sh
# @author      Casmir Sraha
# @index       <7363623>
# @school      Kwame Nkrumah University of Science and Technology (KNUST)
# @description Interactive menu-driven Phonebook CRUD application storing
#              records in a CSV file with automatic backups and input validation.
# @date        2026-09-28
# ------------------------------------------------------------------

DATA_FILE="phonebook.csv"
BACKUP_FILE="phonebook.csv.bak"

# Display usage information and exit
usage() {
    echo "Usage: $0 [-h|--help]"
    echo "  Runs an interactive terminal-based Phonebook CRUD application."
    echo "  Data is stored locally in '$DATA_FILE'."
    exit 0
}

# Check for help arguments
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    usage
fi

# Ensure data file exists with header
init_db() {
    if [[ ! -f "$DATA_FILE" ]]; then
        echo "ID,Name,Phone,Email" > "$DATA_FILE"
    fi
}

# Create backup before destructive operations
backup_db() {
    if [[ -f "$DATA_FILE" ]]; then
        cp "$DATA_FILE" "$BACKUP_FILE"
    fi
}

# 1. CREATE: Add a new phonebook entry
create_record() {
    echo "--- Add New Contact ---"
    
    # Generate auto-incrementing ID
    local max_id
    max_id=$(awk -F',' 'NR>1 {if($1>m) m=$1} END {print m+0}' "$DATA_FILE")
    local new_id=$((max_id + 1))

    # Read and validate Name
    read -rp "Enter Name: " name
    if [[ -z "$name" ]]; then
        echo "Error: Name cannot be empty!" >&2
        return 1
    fi

    # Read and validate Phone Number
    read -rp "Enter Phone Number: " phone
    if [[ -z "$phone" ]]; then
        echo "Error: Phone number cannot be empty!" >&2
        return 1
    fi

    # Read and validate Email
    read -rp "Enter Email: " email
    if [[ -z "$email" ]]; then
        echo "Error: Email cannot be empty!" >&2
        return 1
    fi

    # Append to CSV
    echo "${new_id},${name},${phone},${email}" >> "$DATA_FILE"
    echo "[SUCCESS] Contact added successfully with ID $new_id!"
}

# 2. READ: View all records
read_records() {
    echo "--- Phonebook Contacts ---"
    if [[ $(wc -l < "$DATA_FILE") -le 1 ]]; then
        echo "No contacts found in phonebook."
        return 0
    fi

    echo "--------------------------------------------------------"
    printf "%-5s | %-20s | %-15s | %-20s\n" "ID" "Name" "Phone" "Email"
    echo "--------------------------------------------------------"
    awk -F',' 'NR>1 {printf "%-5s | %-20s | %-15s | %-20s\n", $1, $2, $3, $4}' "$DATA_FILE"
    echo "--------------------------------------------------------"
}

# 3. SEARCH: Find record by ID or Name
search_records() {
    echo "--- Search Contact ---"
    read -rp "Enter ID or Name to search: " term
    if [[ -z "$term" ]]; then
        echo "Error: Search term cannot be empty!" >&2
        return 1
    fi

    local matches
    matches=$(awk -F',' -v t="$term" 'NR>1 && (tolower($1) == tolower(t) || tolower($2) ~ tolower(t))' "$DATA_FILE")

    if [[ -z "$matches" ]]; then
        echo "Record not found matching '$term'."
    else
        echo "--------------------------------------------------------"
        printf "%-5s | %-20s | %-15s | %-20s\n" "ID" "Name" "Phone" "Email"
        echo "--------------------------------------------------------"
        echo "$matches" | awk -F',' '{printf "%-5s | %-20s | %-15s | %-20s\n", $1, $2, $3, $4}'
        echo "--------------------------------------------------------"
    fi
}

# 4. UPDATE: Modify existing record
update_record() {
    echo "--- Update Contact ---"
    read -rp "Enter ID of contact to update: " target_id
    if [[ -z "$target_id" ]]; then
        echo "Error: ID cannot be empty!" >&2
        return 1
    fi

    # Verify ID exists
    if ! awk -F',' -v id="$target_id" 'NR>1 {if ($1 == id) found=1} END {exit !found}' "$DATA_FILE"; then
        echo "Record not found for ID '$target_id'."
        return 1
    fi

    # Read updated fields
    read -rp "Enter New Name: " new_name
    read -rp "Enter New Phone Number: " new_phone
    read -rp "Enter New Email: " new_email

    if [[ -z "$new_name" || -z "$new_phone" || -z "$new_email" ]]; then
        echo "Error: All fields are required for updating!" >&2
        return 1
    fi

    # Backup data file before update
    backup_db

    # Perform in-place update using temporary file
    local tmp_file
    tmp_file=$(mktemp)
    awk -F',' -v id="$target_id" -v name="$new_name" -v phone="$new_phone" -v email="$new_email" \
        'BEGIN {OFS=","} {if (NR>1 && $1 == id) print id, name, phone, email; else print $0}' "$DATA_FILE" > "$tmp_file"
    mv "$tmp_file" "$DATA_FILE"

    echo "[SUCCESS] Contact ID $target_id updated successfully! Backup created."
}

# 5. DELETE: Remove record by ID
delete_record() {
    echo "--- Delete Contact ---"
    read -rp "Enter ID of contact to delete: " target_id
    if [[ -z "$target_id" ]]; then
        echo "Error: ID cannot be empty!" >&2
        return 1
    fi

    # Verify ID exists
    if ! awk -F',' -v id="$target_id" 'NR>1 {if ($1 == id) found=1} END {exit !found}' "$DATA_FILE"; then
        echo "Record not found for ID '$target_id'."
        return 1
    fi

    # Confirmation step
    read -rp "Are you sure you want to delete contact ID $target_id? (y/N): " confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        echo "Deletion cancelled."
        return 0
    fi

    # Backup data file before delete
    backup_db

    # Perform delete using temporary file
    local tmp_file
    tmp_file=$(mktemp)
    awk -F',' -v id="$target_id" 'BEGIN {OFS=","} {if ($1 != id) print $0}' "$DATA_FILE" > "$tmp_file"
    mv "$tmp_file" "$DATA_FILE"

    echo "[SUCCESS] Contact ID $target_id deleted! Backup created."
}

# Main event loop
init_db

while true; do
    echo ""
    echo "=========================================="
    echo "        PHONEBOOK MANAGEMENT SYSTEM       "
    echo "=========================================="
    echo "1) Add Contact (Create)"
    echo "2) List All Contacts (Read)"
    echo "3) Search Contact"
    echo "4) Update Contact"
    echo "5) Delete Contact"
    echo "6) Exit"
    echo "=========================================="
    read -rp "Select an option [1-6]: " choice

    case "$choice" in
        1) create_record ;;
        2) read_records ;;
        3) search_records ;;
        4) update_record ;;
        5) delete_record ;;
        6)
            echo "Exiting application. Goodbye!"
            exit 0
            ;;
        *)
            echo "Invalid option '$choice'. Please select between 1 and 6."
            ;;
    esac
done
