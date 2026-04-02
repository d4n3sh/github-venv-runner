# Copilot Instructions for github-venv-runner

## Project Overview

**github-venv-runner** is a GitHub Actions pipeline designed to build and manage Python virtual environments. This is a reference implementation for CI/CD workflows that need to manage isolated Python dependencies at scale.

## Architecture

### Key Components

- **GitHub Actions Workflows**: YAML-based pipelines defined in `.github/workflows/`
- **GitHub-Hosted Runners**: Uses Ubuntu-latest runners for safe, secure builds
- **Python Virtual Environment Management**: Creates isolated venv instances with specific dependency sets
- **Artifact Management**: Venv artifacts compressed as tar.gz and distributed via GitHub releases

### Development Flow

1. Workflows trigger on events (push to main, manual dispatch)
2. Jobs execute on GitHub-hosted Ubuntu runners
3. Python 3.12 environments are provisioned dynamically
4. Dependencies are installed and isolated within venv
5. Venv is compressed into tar.gz for distribution
6. Artifacts are uploaded as GitHub release assets with checksums

## Build, Test & Verification Commands

```bash
# Validate workflow syntax
python -m py_compile *.py  # if Python scripts are added

# Test venv creation and packaging locally
python3.12 -m venv test_env
source test_env/bin/activate
pip install --upgrade pip

# Package venv into tar.gz
tar --exclude='.git' -czf venv-py312-linux.tar.gz test_env/

# Verify tar.gz contents
tar -tzf venv-py312-linux.tar.gz | head -20

# Extract tar.gz for testing
tar -xzf venv-py312-linux.tar.gz

# Validate workflow files (requires gh cli)
gh workflow list
gh workflow run build-venv --ref main
```

## Naming & File Structure Conventions

### Workflows

- **Workflow files** (`.github/workflows/`): Use kebab-case, descriptive names
  - `build-venv.yml` - main venv building pipeline
  - `test-venv.yml` - validation/testing of built environments
  - `upload-artifacts.yml` - artifact distribution

### Python Code

- **Module/script naming**: Use snake_case
- **Functions/classes**: PEP 8 conventions (CapitalCase for classes, snake_case for functions)
- **Virtual environment directories**: Never commit `venv/`, `.venv/`, or similar—always in `.gitignore`

### Directory Structure

```
.github/
  workflows/
    build-venv.yml
  copilot-instructions.md
requirements.txt  # Base dependencies (Ansible)
README.md
LICENSE
```

## Key Conventions

### Workflow Design

- **Trigger**: Push to main branch (can be extended with manual dispatch, schedule)
- **Runner**: GitHub-hosted Ubuntu runner (ubuntu-latest) for security
- **Fail fast**: Use conditional steps and early validation
- **Artifact retention**: Set appropriate retention policies for built venv artifacts
- **Logging**: Log venv creation steps for debugging
- **Secrets**: If managing credentials, use GitHub Secrets—never hardcode in workflows

### Venv Distribution & Packaging

- **Tar.gz naming**: Use descriptive names: `venv-py{version}-{platform}.tar.gz` (e.g., `venv-py312-linux.tar.gz`)
- **Compression strategy**: Use `tar -czf` with `--exclude` flags to skip unnecessary directories (`.git`, `__pycache__`, `.pyc` files, tests)
- **Size optimization**: Consider excluding development dependencies or docs from packaged venv to reduce file size
- **Artifact upload**: Upload tar.gz files as GitHub release assets for distribution
- **Extraction instructions**: Document where users should extract the tar.gz and any post-extraction steps
- **Checksum verification**: Generate and publish SHA256 checksums alongside tar.gz files for integrity verification

## Important Notes

- **Python compatibility**: Test with all Python versions the project needs to support
- **Artifact size**: Venv tar.gz files can be 100MB–1GB+ depending on dependencies—monitor storage and bandwidth
- **Platform-specific venvs**: Linux builds produce venvs compatible with Linux systems
- **GitHub-hosted runners**: Provide safe, isolated execution for public repositories
- **Distribution channels**: Plan how packaged venvs will be distributed—GitHub releases, artifact repository, S3, etc.
