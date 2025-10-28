#!/bin/bash
# .github/scripts/run_cortex_scan.sh

set -euo pipefail

echo "--- DEBUGGING: VERIFYING ENVIRONMENT VARIABLES ---"
echo "CORTEX_API_KEY_ID is: ${CORTEX_API_KEY_ID:-<unset>}"
echo "CORTEX_API_URL is: ${CORTEX_API_URL:-<unset>}"
echo "GITHUB_WORKSPACE is: ${GITHUB_WORKSPACE:-<unset>}"
echo "GITHUB_REPOSITORY is: ${GITHUB_REPOSITORY:-<unset>}"
echo "--------------------------------------------------"

# Ensure trailing slash on API URL
if [[ "$CORTEX_API_URL" != */ ]]; then
  CORTEX_API_URL="${CORTEX_API_URL}/"
fi

# Verify required variables
if [ -z "$CORTEX_API_URL" ] || [ -z "$CORTEX_API_KEY" ] || [ -z "$CORTEX_API_KEY_ID" ]; then
  echo "Error: One or more required environment variables (CORTEX_API_URL, CORTEX_API_KEY, CORTEX_API_KEY_ID) are not set."
  exit 1
fi

echo "Running Cortex CLI Code Scan..."
echo "DEBUG: api-base-url is '$CORTEX_API_URL'"

# Execute the Cortex CLI scan
./cortexcli code scan \
  --api-base-url "$CORTEX_API_URL" \
  --api-key "$CORTEX_API_KEY" \
  --api-key-id "$CORTEX_API_KEY_ID" \
  --directory "$GITHUB_WORKSPACE" \
  --repo-id "$GITHUB_REPOSITORY" \
  --branch "$GITHUB_REF_NAME" \
  --source "GITHUB_ACTIONS" \
  --create-repo-if-missing

echo "Cortex CLI Code Scan completed successfully."
