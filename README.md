# github-venv-runner

A GitHub Actions pipeline for building and distributing Python 3.12 virtual environments with Ansible, running on a Rocky Linux on-premises container.

## Overview

This project automates the creation of isolated Python virtual environments containing Ansible and all dependencies. Built venvs are packaged as tar.gz files and automatically released on GitHub for easy distribution.

**Features:**
- Automated venv creation on push to main
- Python 3.12 with Ansible pre-installed
- Compressed tar.gz distribution via GitHub releases
- SHA256 checksum verification
- Linux-optimized builds
- Rocky Linux container for on-premises self-hosted runners
- Docker Compose for easy deployment

## Quick Start: On-Premises Runner

To run the GitHub Actions runner in a Rocky Linux container:

```bash
# 1. Get a registration token from Settings → Actions → Runners → New self-hosted runner
export GITHUB_REPOSITORY=your-username/github-venv-runner
export GITHUB_RUNNER_TOKEN=AAAAAA...your-token...

# 2. Start the container
docker-compose up -d

# 3. Verify runner is connected (check GitHub Actions → Runners)
docker-compose logs -f
```

For detailed setup instructions, see [RUNNER_SETUP.md](RUNNER_SETUP.md).

## Getting Started

### Download Pre-built Venv

1. Navigate to [GitHub Releases](../../releases)
2. Download the latest `venv-py312-linux.tar.gz`
3. Verify checksum: `sha256sum -c venv-py312-linux.tar.gz.sha256`
4. Extract: `tar -xzf venv-py312-linux.tar.gz`
5. Activate: `source venv/bin/activate`

### Build Locally

```bash
python3.12 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

## About the Venv

- **Python Version**: 3.12
- **Primary Package**: Ansible
- **Platform**: Linux (x86_64)

See `requirements.txt` for complete dependency list.
