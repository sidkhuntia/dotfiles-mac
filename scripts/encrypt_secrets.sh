#!/bin/bash

# Check if a vault password file argument is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <path_to_vault_password_file>"
  echo "Example: $0 ~/.ansible-vault-pass"
  exit 1
fi

VAULT_PASSWORD_FILE="$1"
ENCRYPT_DIR="ansible/credentials"

# Check if ansible-vault is installed
if ! command -v ansible-vault &> /dev/null
then
    echo "Error: ansible-vault is not installed. Please install Ansible."
    exit 1
fi

# Check if the provided vault password file exists
if [ ! -f "$VAULT_PASSWORD_FILE" ]; then
  echo "Error: Vault password file not found: $VAULT_PASSWORD_FILE"
  exit 1
fi

echo "Starting recursive encryption of files in: $ENCRYPT_DIR"
echo "Using vault password from: $VAULT_PASSWORD_FILE"
echo "----------------------------------------------------"

# Find all files (not directories) in the specified directory and its subdirectories
find "$ENCRYPT_DIR" -type f | while read -r file_path; do
  echo "Encrypting: $file_path"
  # Use --vault-password-file to read the password from the provided file
  ansible-vault encrypt --vault-password-file "$VAULT_PASSWORD_FILE" "$file_path"
  if [ $? -eq 0 ]; then
    echo "Successfully encrypted $file_path"
  else
    echo "Failed to encrypt $file_path. Check for errors above."
  fi
  echo "----------------------------------------------------"
done

echo "Encryption process complete for all files in $ENCRYPT_DIR."