#!/bin/bash
# .github/scripts/run_cortex_scan.sh

set -euo pipefail

echo "--- DEBUGGING: VERIFYING ENVIRONMENT VARIABLES ---"
echo "CORTEX_API_KEY_ID is: ${CORTEX_API_KEY_ID:-<unset>}"
echo "CORTEX_API_URL (raw) is: '${CORTEX_API_URL:-<unset>}'"
echo "GITHUB_WORKSPACE is: ${GITHUB_WORKSPACE:-<unset>}"
echo "GITHUB_REPOSITORY is: ${GITHUB_REPOSITORY:-<unset>}"
echo "--------------------------------------------------"

# Function to strip whitespace/newlines and ensure trailing slash
sanitize_url() {
  local url="$1"
  # Remove leading/trailing whitespace and newlines
  url="$(echo -n "$url" | tr -d '[:space:]')"
  # Add trailing slash if missing
  [[ "$url" != */ ]] && url="${url}/"
  echo "$url"
}

CORTEX_API_URL="$(sanitize_url "$CORTEX_API_URL")"

echo "DEBUG: sanitized api-base-url is '$CORTEX_API_URL'"

# Validate required envs
if [ -z "$CORTEX_API_URL" ] || [ -z "$CORTEX_API_KEY" ] || [ -z "$CORTEX_API_KEY_ID" ]; then
  echo "Error: One or more required environment variables (CORTEX_API_URL, CORTEX_API_KEY, CORTEX_API_KEY_ID) are not set."
  exit 1
fi

# Verify the binary exists
if [ ! -x "./cortexcli" ]; then
  echo "Error: cortexcli binary not found or not executable."
  ls -la
  exit 1
fi

echo "Running Cortex CLI Code Scan..."
echo "DEBUG (final): ./cortexcli code scan --api-base-url '$CORTEX_API_URL'"

# Run the Cortex CLI scan
echo "Trying Cortex CLI Code Scan (standard flag order)..."

if ! ./cortexcli code scan \
  --api-base-url "$CORTEX_API_URL" \
  --api-key "$CORTEX_API_KEY" \
  --api-key-id "$CORTEX_API_KEY_ID" \
  --directory "$GITHUB_WORKSPACE" \
  --repo-id "$GITHUB_REPOSITORY" \
  --branch "$GITHUB_REF_NAME" \
  --source "GITHUB_ACTIONS" \
  --create-repo-if-missing; then

  echo "Standard flag order failed — retrying with global flags before subcommand..."
  
  ./cortexcli \
    --api-base-url "$CORTEX_API_URL" \
    --api-key "$CORTEX_API_KEY" \
    --api-key-id "$CORTEX_API_KEY_ID" \
    code scan \
    --directory "$GITHUB_WORKSPACE" \
    --repo-id "$GITHUB_REPOSITORY" \
    --branch "$GITHUB_REF_NAME" \
    --source "GITHUB_ACTIONS" \
    --create-repo-if-missing || {
      echo "Both formats failed."
      exit 2
    }
fi

echo "Cortex CLI Code Scan completed successfully."
