# Copilot Instructions for github-venv-runner

## Project Overview

**github-venv-runner** is a GitHub Actions pipeline designed to build and manage Python virtual environments on on-premises GitHub Actions runners. This is a reference implementation for CI/CD workflows that need to manage isolated Python dependencies at scale.

## Architecture

### Key Components

- **GitHub Actions Workflows**: YAML-based pipelines defined in `.github/workflows/`
- **On-Premises Runner**: Runs inside Rocky Linux 9 Docker container via Docker Compose
- **Python Virtual Environment Management**: Creates isolated venv instances with specific dependency sets
- **Container Infrastructure**: Dockerfile and docker-compose.yml for self-hosted runner deployment
- **Artifact Management**: Venv artifacts compressed as tar.gz and distributed via GitHub releases

### Development Flow

1. On-premises runner started in Rocky Linux container (docker-compose up)
2. Container registers with GitHub (requires registration token)
3. Workflows trigger on events (push to main, manual dispatch)
4. Jobs execute on the containerized on-premises runner
5. Python 3.12 environments are provisioned dynamically
6. Dependencies installed within isolated venv
7. Venv is compressed into tar.gz for distribution
8. Artifacts uploaded as GitHub release assets with checksums

### Deployment Architecture

```
GitHub Repository
    ↓
   [Push to main / Manual trigger]
    ↓
GitHub Actions Webhook
    ↓
On-Premises Docker Container (Rocky Linux 9)
    ├─ GitHub Actions Runner v2.415.0
    ├─ Python 3.12 + Ansible
    ├─ Build Tools (gcc, make, etc.)
    └─ 2-4 CPU cores, 2-4GB RAM (configurable)
    ↓
[Creates venv, Compresses tar.gz, Generates checksum]
    ↓
GitHub Release Assets
    ├─ venv-py312-linux.tar.gz
    └─ venv-py312-linux.tar.gz.sha256
```

## Build, Test & Verification Commands

### Container Setup

```bash
# Build and start the runner container
docker-compose up -d

# View container logs
docker-compose logs -f github-runner

# Verify Python 3.12 and Ansible in container
docker exec github-runner python3.12 --version
docker exec github-runner python3.12 -m ansible --version

# Stop the container
docker-compose down
```

### Local Development (without container)

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

# Validate workflow files (requires act or gh cli)
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
scripts/
  build-env.py     # Helper scripts for venv management
  setup.sh         # Setup for on-premises runner
docs/
  CONTRIBUTING.md
  RUNNER_SETUP.md  # Rocky Linux container deployment guide
Dockerfile        # Rocky Linux 9 with GitHub Actions runner
docker-compose.yml # Container orchestration
requirements.txt  # Base dependencies for the project itself
README.md
LICENSE
```

## Key Conventions

### On-Premises Runner Specifics (Docker Container)

- **Container image**: Rocky Linux 9 with GitHub Actions Runner v2.415.0 pre-installed
- **Runner registration**: Use `GITHUB_RUNNER_TOKEN` from repo Settings → Actions → Runners
- **Environment variables**: Configure runner name, group, and labels via environment variables
- **Storage**: Runner work directory mounted as named volume (`runner-work`)
- **Networking**: Container isolated on internal Docker network
- **Resource limits**: Configure CPU and memory limits in docker-compose.yml
- **Container lifecycle**: Use `docker-compose up/down` for managing runner
- **Logging**: Monitor with `docker-compose logs -f github-runner`
- **Persistence**: Runner registration state persists in `runner-home` volume even after container restart

### Container Deployment

- **Dockerfile**: Builds Rocky Linux 9 image with Python 3.12, Ansible dependencies, and GitHub Actions runner
- **docker-compose.yml**: Defines service configuration, volumes, networking, resource limits
- **entrypoint.sh**: Automates runner registration and startup (requires environment variables)
- **Setup**: See `RUNNER_SETUP.md` for detailed deployment instructions
- **Multiple runners**: Deploy multiple container instances for parallel job execution

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
