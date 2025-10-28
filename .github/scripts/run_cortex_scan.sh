#!/bin/bash
# .github/scripts/run_cortex_scan.sh

# Exit immediately if a command exits with a non-zero status.
set -e

# Check for required environment variables
if [ -z "$CORTEX_API_URL" ] || [ -z "$CORTEX_API_KEY" ] || [ -z "$CORTEX_API_KEY_ID" ]; then
  echo "Error: One or more required environment variables (CORTEX_API_URL, CORTEX_API_KEY, CORTEX_API_KEY_ID) are not set."
  exit 1
fi

echo "Running Cortex CLI Code Scan..."

# Execute the code scan command, passing all arguments directly.
./cortexcli code scan \
  --api-base-url "https://api-pcscortexcloud.xdr.us.paloaltonetworks.com/" \
  --api-key "$CORTEX_API_KEY" \
  --api-key-id "$CORTEX_API_KEY_ID" \
  --directory "$GITHUB_WORKSPACE" \
  --repo-id "$GITHUB_REPOSITORY" \
  --branch "$GITHUB_REF_NAME" \
  --source "GITHUB_ACTIONS" \
  --create-repo-if-missing

echo "Cortex CLI Code Scan completed successfully."
