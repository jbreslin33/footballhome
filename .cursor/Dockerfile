# Cursor Cloud Agent base image for Football Home.
#
# Full-stack agents need Docker-in-Docker so they can run db/backend/frontend
# the same way the production host does (prod uses Podman; cloud uses Docker —
# the Makefile auto-detects ENGINE). Do NOT COPY the project tree; Cursor
# checks out the commit into the workspace separately.
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl gnupg git sudo openssh-client \
    build-essential cmake pkg-config \
    python3 python3-pip python3-venv \
    nodejs npm \
    age expect \
    postgresql-client \
    iptables fuse-overlayfs \
    jq unzip zip \
    && rm -rf /var/lib/apt/lists/*

########################################################
# Docker (fuse-overlayfs + iptables-legacy for DinD)
########################################################
RUN install -m 0755 -d /etc/apt/keyrings && \
    curl --retry 3 --retry-delay 5 -fsSL https://download.docker.com/linux/ubuntu/gpg \
      | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    chmod a+r /etc/apt/keyrings/docker.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
      https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
      | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && \
    apt-get install -y \
      docker-ce \
      docker-ce-cli \
      containerd.io \
      docker-buildx-plugin \
      docker-compose-plugin \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/docker && \
    printf '%s\n' '{' \
    '  "storage-driver": "fuse-overlayfs"' \
    '}' > /etc/docker/daemon.json

RUN update-alternatives --set iptables /usr/sbin/iptables-legacy && \
    update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy

########################################################
# ubuntu user (passwordless sudo + docker group)
########################################################
RUN id -u ubuntu &>/dev/null || useradd -m -s /bin/bash ubuntu
RUN groupadd -f docker && usermod -aG docker ubuntu
RUN usermod -aG sudo ubuntu
RUN echo "ubuntu ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ubuntu
RUN echo "ubuntu:ubuntu" | chpasswd

USER ubuntu
WORKDIR /home/ubuntu
