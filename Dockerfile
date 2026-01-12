# Multi-stage Dockerfile for Syft and Trivy SBOM generation
FROM alpine:3.18 as base

# Set working directory
WORKDIR /app

# Install required dependencies
RUN apk add --no-cache \
    curl \
    wget \
    git \
    ca-certificates \
    tar \
    gzip \
    bash

# Install Syft
RUN curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin

# Install Trivy
RUN wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | apt-key add - 2>/dev/null || \
    curl -sSfL https://aquasecurity.github.io/trivy-repo/deb/public.key | apt-key add - 2>/dev/null || \
    (curl -sSfL https://github.com/aquasecurity/trivy/releases/download/v0.48.0/trivy_0.48.0_Linux-64bit.tar.gz | \
    tar -xzf - -C /usr/local/bin/)

# Alternative: Direct installation from GitHub releases
RUN wget -q https://github.com/aquasecurity/trivy/releases/download/v0.48.0/trivy_0.48.0_Linux-64bit.tar.gz && \
    tar -xzf trivy_0.48.0_Linux-64bit.tar.gz -C /usr/local/bin/ && \
    rm trivy_0.48.0_Linux-64bit.tar.gz

# Verify installations
RUN syft --version && trivy --version

# Create output directory for SBOMs
RUN mkdir -p /sbom-output

# Default command
CMD ["/bin/bash"]
