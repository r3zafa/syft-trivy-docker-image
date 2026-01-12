# Dockerfile for Syft and Trivy SBOM generation
# Optimized for Azure DevOps template integration
# Used with: templates/jobs/sbom-generate.yml
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    wget \
    git \
    jq \
    && rm -rf /var/lib/apt/lists/*

# Install Syft (v1.24.1 as per templates)
RUN curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin

# Install Trivy (v0.53.0 as per templates)
RUN wget -q https://github.com/aquasecurity/trivy/releases/download/v0.53.0/trivy_0.53.0_Linux-64bit.tar.gz && \
    tar -xzf trivy_0.53.0_Linux-64bit.tar.gz -C /usr/local/bin/ && \
    rm trivy_0.53.0_Linux-64bit.tar.gz

# Create working directories
RUN mkdir -p /sbom-output /project

# Set working directory
WORKDIR /project

# Verify installations
RUN syft --version && trivy --version

# Default command
CMD ["/bin/bash"]
