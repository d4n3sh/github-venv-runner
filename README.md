# github-venv-runner

A GitHub Actions pipeline for building and distributing Python 3.12 virtual environments with Ansible.

## Overview

This project automates the creation of isolated Python virtual environments containing Ansible and all dependencies. Built venvs are packaged as tar.gz files and automatically released on GitHub for easy distribution.

**Features:**
- Automated venv creation on push to main
- Python 3.12 with Ansible pre-installed
- Compressed tar.gz distribution via GitHub releases
- SHA256 checksum verification
- Linux-optimized builds

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
