# Copilot Instructions for github-venv-runner

## Project Overview

**github-venv-runner** is a GitHub Actions pipeline designed to build and manage Python virtual environments on on-premises GitHub Actions runners. This is a reference implementation for CI/CD workflows that need to manage isolated Python dependencies at scale.

## Architecture

### Key Components

- **GitHub Actions Workflows**: YAML-based pipelines defined in `.github/workflows/`
- **On-Premises Runner**: Uses self-hosted GitHub Actions runners rather than GitHub-hosted runners
- **Python Virtual Environment Management**: Creates isolated venv instances with specific dependency sets
- **Artifact Management**: Likely produces distributable venv artifacts or reports

### Development Flow

1. Workflows trigger on events (push, pull_request, schedule)
2. Jobs execute on the on-premises runner
3. Python environments are provisioned dynamically
4. Dependencies are installed and isolated within venv
5. Venv is compressed into tar.gz for distribution
6. Packaged artifacts are uploaded and made available for download

## Build, Test & Verification Commands

Once implemented, typical commands will be:

```bash
# Validate workflow syntax
python -m py_compile *.py  # if Python scripts are added

# Test venv creation and packaging locally
python -m venv test_env
source test_env/bin/activate  # or test_env\Scripts\activate on Windows
pip install --upgrade pip

# Package venv into tar.gz
tar --exclude='.git' -czf venv-py311-linux.tar.gz test_env/

# Verify tar.gz contents
tar -tzf venv-py311-linux.tar.gz | head -20

# Extract tar.gz for testing
tar -xzf venv-py311-linux.tar.gz

# Validate workflow files (requires act or gh cli)
gh workflow list
gh workflow run <workflow-name> --ref main
```

Add these as you develop the project structure.

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
    test-venv.yml
  copilot-instructions.md
scripts/
  build-env.py     # Helper scripts for venv management
  setup.sh         # Setup for on-premises runner
docs/
  CONTRIBUTING.md
requirements.txt  # Base dependencies for the project itself
README.md
LICENSE
```

## Key Conventions

### On-Premises Runner Specifics

- **Runner labels**: Use self-hosted runners with clear labels (e.g., `self-hosted`, `linux`, `python-builder`)
- **Environment setup**: Document any pre-requisites the runner must have (Python versions, OS, disk space)
- **Timeout settings**: Adjust job timeouts appropriately—on-prem runners may be slower
- **Resource constraints**: Consider memory/CPU limits when building large environments

### Virtual Environment Best Practices

- **One venv per build**: Each workflow job should create isolated environments
- **Explicit Python versions**: Specify `python-version` in setup-python action or environment
- **Dependency pinning**: Use `requirements.txt` with pinned versions for reproducibility
- **Cleanup**: Ensure workflows clean up temporary venvs to avoid disk space issues

### Workflow Design

- **Fail fast**: Use conditional steps and early validation
- **Artifact retention**: Set appropriate retention policies for built venv artifacts
- **Logging**: Log venv creation steps for debugging runner issues
- **Secrets**: If managing credentials, use GitHub Secrets—never hardcode in workflows

### Venv Distribution & Packaging

- **Tar.gz naming**: Use descriptive names: `venv-py{version}-{platform}.tar.gz` (e.g., `venv-py311-linux.tar.gz`, `venv-py310-windows.tar.gz`)
- **Compression strategy**: Use `tar -czf` with `--exclude` flags to skip unnecessary directories (`.git`, `__pycache__`, `.pyc` files, tests)
- **Size optimization**: Consider excluding development dependencies or docs from packaged venv to reduce file size
- **Artifact upload**: Upload tar.gz files as GitHub Actions artifacts or release assets for distribution
- **Extraction instructions**: Document where users should extract the tar.gz and any post-extraction steps (e.g., updating shebangs on macOS/Linux)
- **Cross-platform paths**: Be aware of path differences—venv activation scripts differ between Unix (`bin/`) and Windows (`Scripts/`)
- **Checksum verification**: Generate and publish SHA256 checksums alongside tar.gz files for integrity verification

## Important Notes

- **Runner availability**: Confirm on-premises runner is online before testing workflows locally
- **Python compatibility**: Test with all Python versions the project needs to support
- **Artifact size**: Venv tar.gz files can be 100MB–1GB+ depending on dependencies—monitor storage and bandwidth
- **Parallel jobs**: Consider runner resource limits when defining concurrent jobs
- **Platform-specific venvs**: Build separate tar.gz files for each platform (Linux, macOS, Windows) since venv internals are platform-dependent
- **Tarball portability**: Venvs extracted from tar.gz to different absolute paths may need adjustments—consider using relative paths or post-extraction scripts
- **Distribution channels**: Plan how packaged venvs will be distributed—GitHub releases, artifact repository, S3, etc.
