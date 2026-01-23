# Dockerfile for Syft and Trivy SBOM generation
# Optimized for Azure DevOps template integration
# Used with: templates/jobs/sbom-generate.yml
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
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

# Install Trivy (v0.68.2 - latest available as of Jan 2026)
# Known CVEs in upstream Go dependencies (awaiting fix in Trivy v0.69.0+):
#   - CVE-2025-66564 (7.5 High): github.com/sigstore/timestamp-authority v1.2.2
#   - CVE-2026-22703 (5.5 Medium): github.com/sigstore/cosign/v2 v2.2.4
# These are compiled into Trivy binary - no fix available until upstream updates
RUN curl -sSfL https://github.com/aquasecurity/trivy/releases/download/v0.68.2/trivy_0.68.2_Linux-64bit.tar.gz -o /tmp/trivy.tar.gz && \
    cd /tmp && tar -xzf trivy.tar.gz trivy && \
    mv trivy /usr/local/bin/ && \
    rm -f /tmp/trivy.tar.gz && \
    chmod +x /usr/local/bin/trivy


# Copy utility scripts into the image and set permissions
COPY scripts /usr/local/bin/scripts
RUN chmod +x /usr/local/bin/scripts/*.sh \
    && mkdir -p /sbom-output /project \
    && chown -R sbom:sbom /sbom-output /project



# Add scripts directory to PATH for easy access in Azure Pipelines
ENV PATH="/usr/local/bin/scripts:$PATH"

# Set working directory
WORKDIR /project


# Verify installations (run as root during build)
RUN syft --version && trivy --version


# NOTE: Do not set USER here - Azure DevOps container jobs require root access
# during container initialization to create the pipeline user.
# Azure DevOps will handle user switching appropriately.


# Default command
CMD ["/bin/bash"]
