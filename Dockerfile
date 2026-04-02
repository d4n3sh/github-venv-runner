FROM rockylinux:9

# Install system dependencies and enable EPEL for Python 3.12
# Use --allowerasing to resolve package conflicts (curl-minimal vs curl)
RUN dnf update -y && dnf install -y --allowerasing \
    epel-release \
    git \
    curl \
    wget \
    tar \
    gzip \
    gcc \
    make \
    openssl-devel \
    zlib-devel \
    libffi-devel \
    sudo \
    jq \
    && dnf clean all

# Install Python 3.12 from EPEL
RUN dnf install -y \
    python3.12 \
    python3.12-devel \
    python3.12-pip \
    && dnf clean all

# Create runner user
RUN useradd -m runner && \
    usermod -aG wheel runner && \
    echo "runner ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/runner

# Switch to runner user
USER runner
WORKDIR /home/runner

# Download and install GitHub Actions runner
RUN mkdir -p /home/runner/actions-runner && \
    cd /home/runner/actions-runner && \
    curl -o actions-runner-linux-x64.tar.gz -L \
    https://github.com/actions/runner/releases/download/v2.415.0/actions-runner-linux-x64-2.415.0.tar.gz && \
    tar xzf ./actions-runner-linux-x64.tar.gz && \
    rm actions-runner-linux-x64.tar.gz && \
    /home/runner/actions-runner/bin/installdependencies.sh

# Copy entrypoint script
COPY --chown=runner:runner entrypoint.sh /home/runner/entrypoint.sh
RUN chmod +x /home/runner/entrypoint.sh

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8181 || exit 1

ENTRYPOINT ["/home/runner/entrypoint.sh"]
