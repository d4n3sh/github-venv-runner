# Contributing to github-venv-runner

## Development Environment Setup

### Prerequisites

- Python 3.12
- Git
- GitHub CLI (optional, for testing workflows locally)

### Local Testing

1. **Clone and navigate to the repository:**
   ```bash
   git clone git@github.com:d4n3sh/github-venv-runner.git
   cd github-venv-runner
   ```

2. **Create a local virtual environment:**
   ```bash
   python3.12 -m venv venv
   source venv/bin/activate
   pip install -r requirements.txt
   ```

3. **Verify Ansible installation:**
   ```bash
   ansible --version
   pip list
   ```

### Testing Venv Packaging

To verify the packaging process works correctly:

```bash
# Create test venv
python3.12 -m venv test_venv
source test_venv/bin/activate
pip install -r requirements.txt

# Package it (same process as CI)
tar --exclude='test_venv/.git' \
    --exclude='test_venv/__pycache__' \
    --exclude='test_venv/**/*.pyc' \
    --exclude='test_venv/**/*.pyo' \
    -czf venv-py312-linux.tar.gz test_venv/

# Verify size and contents
ls -lh venv-py312-linux.tar.gz
tar -tzf venv-py312-linux.tar.gz | head -20

# Test extraction
mkdir test_extract
tar -xzf venv-py312-linux.tar.gz -C test_extract
source test_extract/test_venv/bin/activate
ansible --version

# Clean up
rm -rf test_venv test_extract venv-py312-linux.tar.gz
```

## Modifying Dependencies

To add or update dependencies:

1. Update `requirements.txt` with new/updated package versions
2. Test locally by creating a fresh venv:
   ```bash
   python3.12 -m venv venv
   source venv/bin/activate
   pip install -r requirements.txt
   ```
3. Verify all packages work together
4. Commit and push—the CI workflow will automatically create a release

## Workflow Testing

To test the GitHub Actions workflow locally (requires `act`):

```bash
# Install act (https://github.com/nektos/act)
# Then run:
act push -b
```

## Release Process

Releases are created automatically when changes are pushed to `main`. The workflow:

1. Creates a fresh Python 3.12 venv
2. Installs dependencies from `requirements.txt`
3. Packages the venv as tar.gz
4. Creates a GitHub release with:
   - Release notes
   - tar.gz file
   - SHA256 checksum

No manual release creation is needed.

## Troubleshooting

### Venv extraction fails on different distros
Some Linux distros may require system packages. Ensure the target system has Python 3.12 development libraries:
```bash
# Ubuntu/Debian
sudo apt-get install python3.12-dev python3.12-venv

# RHEL/CentOS
sudo yum install python312-devel python312-pip
```

### Ansible module import errors after extraction
This may indicate a corrupted tar.gz or incompatible system. Verify checksum:
```bash
sha256sum -c venv-py312-linux.tar.gz.sha256
```

### Large tar.gz file size
The venv with Ansible and all dependencies typically ranges 200-400MB. This is expected.
