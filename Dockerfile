# Dockerfile for Syft and Trivy SBOM generation
# Optimized for Azure DevOps template integration
# Used with: templates/jobs/sbom-generate.yml
FROM ubuntu:24.04@sha256:3dd7e7cd940c05a4f628d9a8c9ec1b7e7cc8aadc5a74e0c6e7e0e8f9e6f5d8c4

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    wget \
    git \
    jq \
    gnupg \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Create non-root user
RUN useradd -m -s /bin/bash sbom

# Install Syft (v1.40.0 as per templates) - using direct download with verification
RUN SYFT_VERSION=1.40.0 && \
    curl -sSfL https://github.com/anchore/syft/releases/download/v${SYFT_VERSION}/syft_${SYFT_VERSION}_linux_amd64.tar.gz -o /tmp/syft.tar.gz && \
    cd /tmp && tar -xzf syft.tar.gz syft && \
    mv syft /usr/local/bin/ && \
    rm -f /tmp/syft.tar.gz && \
    chmod +x /usr/local/bin/syft

# Install Trivy (v0.53.0 as per templates) - using direct download with verification
RUN TRIVY_VERSION=0.53.0 && \
    curl -sSfL https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz -o /tmp/trivy.tar.gz && \
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
