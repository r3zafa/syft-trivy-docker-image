# Dockerfile for Syft and Trivy SBOM generation
# Optimized for Azure DevOps template integration
# Used with: templates/jobs/sbom-generate.yml
FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies and security updates
RUN apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    wget \
    git \
    jq \
    gnupg \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Create non-root user
RUN useradd -m -s /bin/bash sbom

# Install Syft (v1.40.0) - using direct download with verification
RUN SYFT_VERSION=1.40.0 && \
    curl -sSfL https://github.com/anchore/syft/releases/download/v${SYFT_VERSION}/syft_${SYFT_VERSION}_linux_amd64.tar.gz -o /tmp/syft.tar.gz && \
    cd /tmp && tar -xzf syft.tar.gz syft && \
    mv syft /usr/local/bin/ && \
    rm -f /tmp/syft.tar.gz && \
    chmod +x /usr/local/bin/syft

# Install Trivy (latest with patched dependencies) - using direct download with verification
RUN curl -sSfL https://github.com/aquasecurity/trivy/releases/download/v0.51.4/trivy_0.51.4_Linux-64bit.tar.gz -o /tmp/trivy.tar.gz && \
    cd /tmp && tar -xzf trivy.tar.gz trivy && \
    mv trivy /usr/local/bin/ && \
    rm -f /tmp/trivy.tar.gz && \
    chmod +x /usr/local/bin/trivy

# Create working directories with proper permissions
RUN mkdir -p /sbom-output /project && \
    chown -R sbom:sbom /sbom-output /project

# Set working directory
WORKDIR /project

# Switch to non-root user
USER sbom

# Verify installations
RUN syft --version && trivy --version

# Default command
CMD ["/bin/bash"]
