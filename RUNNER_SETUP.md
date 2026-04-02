# Running GitHub Actions Runner in Rocky Linux Container

This project includes a Dockerfile to run the GitHub Actions runner on-premises inside a Rocky Linux container. The runner will build and distribute Python venvs as configured in the CI/CD workflow.

## Prerequisites

- Docker and Docker Compose installed
- GitHub repository access (to generate runner registration token)
- Rocky Linux 9 (or compatible system for Docker)

## Getting a Runner Registration Token

1. Navigate to your GitHub repository
2. Go to **Settings** → **Actions** → **Runners** 
3. Click **New self-hosted runner**
4. Copy the registration token (starts with `AAAAAA...`)
5. Keep this token secure—it's valid for only 1 hour

## Quick Start

### 1. Clone and Navigate

```bash
git clone https://github.com/your-username/github-venv-runner.git
cd github-venv-runner
```

### 2. Create `.env` File

```bash
cat > .env << EOF
GITHUB_REPOSITORY=your-username/github-venv-runner
GITHUB_RUNNER_TOKEN=AAAAAA...your-token...
GITHUB_RUNNER_NAME=onprem-runner-1
GITHUB_RUNNER_LABELS=self-hosted,linux,python3.12,rocky
EOF
```

### 3. Build and Start the Container

```bash
docker-compose up -d
```

### 4. Verify Runner is Connected

```bash
# Check container logs
docker-compose logs -f github-runner

# Or check on GitHub: Settings → Actions → Runners (should show as "Idle")
```

## Environment Variables

### Required

- **`GITHUB_REPOSITORY`** - GitHub repository in format `owner/repo`
- **`GITHUB_RUNNER_TOKEN`** - Registration token from GitHub (valid for 1 hour)

### Optional

- **`GITHUB_RUNNER_NAME`** - Custom name for the runner (default: container hostname)
- **`GITHUB_RUNNER_GROUP`** - Runner group name (default: `Default`)
- **`GITHUB_RUNNER_LABELS`** - Comma-separated labels (default: `self-hosted,linux,python3.12,rocky`)

## Usage Examples

### Example 1: Basic Setup

```bash
export GITHUB_REPOSITORY=myorg/github-venv-runner
export GITHUB_RUNNER_TOKEN=AAAAAA...
docker-compose up -d
```

### Example 2: Multiple Runners

Create multiple `.env` files for different runner instances:

```bash
# runner1.env
GITHUB_REPOSITORY=myorg/github-venv-runner
GITHUB_RUNNER_TOKEN=AAAAAA...token1...
GITHUB_RUNNER_NAME=onprem-runner-1
GITHUB_RUNNER_LABELS=self-hosted,linux,python3.12,rocky

# runner2.env
GITHUB_REPOSITORY=myorg/github-venv-runner
GITHUB_RUNNER_TOKEN=AAAAAA...token2...
GITHUB_RUNNER_NAME=onprem-runner-2
GITHUB_RUNNER_LABELS=self-hosted,linux,python3.12,rocky

# Start multiple runners with different names
docker-compose --env-file runner1.env up -d --build
docker-compose --env-file runner2.env up -d --build
```

### Example 3: Custom Labels

Use labels to target specific runners in workflows:

```bash
GITHUB_RUNNER_LABELS=self-hosted,linux,python3.12,rocky,production
```

Then in your workflow:

```yaml
jobs:
  build:
    runs-on: [self-hosted, production]
```

## Container Details

### What's Installed

- **Base**: Rocky Linux 9
- **Python**: 3.12 (via EPEL - Extra Packages for Enterprise Linux)
- **Python Development**: Headers and devel packages for module compilation
- **Build Tools**: gcc, make, OpenSSL, zlib, libffi
- **Version Control**: Git
- **Tools**: curl, wget, tar, gzip, sudo, jq
- **GitHub Actions Runner**: v2.320.0 (latest stable version)

### Directory Structure

Inside container:

```
/home/runner/
├── actions-runner/          # Runner binary and config
├── work/                    # Job workspace (mounted volume)
└── .runner                  # Runner configuration file
```

### Volumes

- **`runner-work`** - Workspace where jobs execute (job artifacts)
- **`runner-home`** - Runner registration state (persists runner config)

## Managing the Container

### View Logs

```bash
# Real-time logs
docker-compose logs -f github-runner

# Last 100 lines
docker-compose logs --tail=100 github-runner
```

### Stop the Runner

```bash
docker-compose down
```

### Restart the Runner

```bash
docker-compose restart github-runner
```

### Update to Latest Runner Version

Edit `Dockerfile` and update the runner version number:

```dockerfile
https://github.com/actions/runner/releases/download/v2.XXX.0/actions-runner-linux-x64-2.XXX.0.tar.gz
```

Then rebuild:

```bash
docker-compose up -d --build
```

## Troubleshooting

### Runner Not Showing on GitHub

1. **Check token validity**: Token is only valid for 1 hour after generation. If expired, generate a new one.
2. **Check container logs**: `docker-compose logs github-runner`
3. **Verify environment variables**: `docker-compose config | grep GITHUB_`

### "Authentication failed" Error

- Ensure `GITHUB_RUNNER_TOKEN` is correct and not expired
- Generate a new token from Settings → Actions → Runners → New self-hosted runner

### Container Exits Immediately

```bash
# Check logs for error details
docker-compose logs github-runner

# Ensure required environment variables are set
docker-compose config
```

### Runner Accepts Job but Fails to Run Workflow

- Verify Python 3.12 is available: `docker exec github-runner python3.12 --version`
- Verify Ansible is available: `docker exec github-runner python3.12 -m ansible --version`
- Check job logs on GitHub Actions tab

## Performance Tuning

### Resource Allocation

Edit `docker-compose.yml` `deploy.resources` section:

```yaml
deploy:
  resources:
    limits:
      cpus: '4'        # Max 4 CPU cores
      memory: 4G       # Max 4GB RAM
    reservations:
      cpus: '2'        # Reserve 2 cores
      memory: 2G       # Reserve 2GB RAM
```

### Concurrent Jobs

By default, one runner accepts one job at a time. To accept multiple concurrent jobs:

1. Create multiple runner containers with different names
2. Or modify entrypoint to configure concurrent jobs (advanced)

## Docker-in-Docker (Optional)

To enable Docker commands inside workflow jobs:

Uncomment in `docker-compose.yml`:

```yaml
volumes:
  - /var/run/docker.sock:/var/run/docker.sock
```

Then test in a workflow:

```yaml
- name: Test Docker
  run: docker ps
```

## Network

The runner is connected to an internal Docker network (`github-runner`). To expose services, map ports:

```yaml
ports:
  - "8181:8181"  # If needed for monitoring
```

## Security Considerations

- **Token Storage**: Never commit `.env` file to git. Add to `.gitignore` (already configured).
- **Token Rotation**: Tokens are time-limited. Regenerate periodically.
- **Container Security**: Run with minimal privileges; runner user is non-root.
- **Secret Management**: Use GitHub Secrets for sensitive data in workflows.

## Next Steps

1. Start the container with proper environment variables
2. Verify it appears in GitHub Actions Runners settings
3. Push to `main` branch to trigger the venv build workflow
4. Monitor workflow execution on the runner
5. Download the generated `venv-py312-linux.tar.gz` from releases
