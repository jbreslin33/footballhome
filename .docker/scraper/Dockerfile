# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Scraper container — node + chromium + wireguard
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#
# Runs the league scrapers in network isolation. WireGuard comes up only
# inside this container's network namespace, so the host (and SSH) is
# never affected.
#
# Image stays usable as a plain "exec into me" sandbox: it sleeps forever
# and accepts `podman exec` / `docker exec` calls.
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

FROM node:20-bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive \
    PUPPETEER_SKIP_DOWNLOAD=1 \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium \
    CHROME_BIN=/usr/bin/chromium

# WireGuard userspace tools + chromium + minimal scraping deps.
# iproute2 is needed by wg-quick. iptables is needed for wg-quick's
# default routing rules (we use legacy iptables; nftables also works).
RUN apt-get update && apt-get install -y --no-install-recommends \
        wireguard-tools \
        iproute2 \
        iptables \
        iputils-ping \
        openresolv \
        ca-certificates \
        curl \
        bash \
        procps \
        chromium \
        chromium-sandbox \
        fonts-liberation \
        libnss3 \
    && rm -rf /var/lib/apt/lists/*

# Symlinks so existing scripts that look for google-chrome[-stable] also work.
RUN ln -sf /usr/bin/chromium /usr/local/bin/google-chrome \
 && ln -sf /usr/bin/chromium /usr/local/bin/google-chrome-stable

WORKDIR /workspace

COPY entrypoint.sh /usr/local/bin/scraper-entrypoint
RUN chmod +x /usr/local/bin/scraper-entrypoint

ENTRYPOINT ["/usr/local/bin/scraper-entrypoint"]
CMD ["sleep", "infinity"]
