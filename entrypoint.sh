#!/bin/bash
set -e

# Exit if required environment variables are not set
if [ -z "$GITHUB_REPOSITORY" ] || [ -z "$GITHUB_RUNNER_TOKEN" ]; then
    echo "Error: GITHUB_REPOSITORY and GITHUB_RUNNER_TOKEN environment variables must be set"
    echo "Usage: docker run -e GITHUB_REPOSITORY=owner/repo -e GITHUB_RUNNER_TOKEN=xxx <image>"
    exit 1
fi

cd /home/runner/actions-runner

# Set runner name (use hostname or provided name)
RUNNER_NAME="${GITHUB_RUNNER_NAME:-$(hostname)}"

# Configure runner (non-interactive)
echo "Configuring GitHub Actions runner..."
./config.sh \
    --url "https://github.com/${GITHUB_REPOSITORY}" \
    --token "${GITHUB_RUNNER_TOKEN}" \
    --name "${RUNNER_NAME}" \
    --runnergroup "${GITHUB_RUNNER_GROUP:-Default}" \
    --labels "${GITHUB_RUNNER_LABELS:-self-hosted,linux,python3.12,rocky}" \
    --work /home/runner/work \
    --unattended \
    --replace

echo "Starting GitHub Actions runner..."
exec ./run.sh
