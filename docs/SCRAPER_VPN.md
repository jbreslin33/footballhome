# Containerized Scraping VPN

The league sites APSL and CSL block this network's IP, so scrapes need
to go through a WireGuard tunnel. The original setup ran `wg-quick` on
the **host**, which routes *every* host packet through the VPN — that
drops inbound SSH sessions when working remotely.

This setup runs WireGuard inside a dedicated podman/docker container so
**only** scraper traffic is tunneled. SSH, the dev DB, the backend, and
the browser stay on the normal host network.

```
┌──────────────────────────────────────────────────────────────┐
│ HOST (no VPN, SSH stays alive)                               │
│                                                              │
│  make scrape-apsl ──► scripts/vpn-wrap.sh                    │
│                          │                                   │
│                          ▼                                   │
│   ┌──────────────────────────────────────────────────────┐   │
│   │ container: footballhome_scraper                      │   │
│   │   • node 20 + chromium                               │   │
│   │   • wg-quick brings up scrape-vpn at startup         │   │
│   │   • repo bind-mounted at the SAME path as host       │   │
│   │                                                      │   │
│   │   ▼ all egress goes through WireGuard                │   │
│   └────────────────────┬─────────────────────────────────┘   │
└────────────────────────┼─────────────────────────────────────┘
                         ▼
                   apslsoccer.com
```

## One-time setup

```bash
# 1. Install podman (rootless OK)
sudo apt install -y podman

# 2. Install your WireGuard config (root-owned, /etc/wireguard read-only
#    mount inside the container — no copy of the secret in the image).
sudo ./scripts/setup/setup-wireguard.sh import /path/to/provider.conf
# This creates /etc/wireguard/scrape-vpn.conf

# 3. Build + start the scraper container
make scrape-vpn-up
```

`make scrape-vpn-status` should show a different external IP for the
container than for the host.

## Daily use

The existing scrape targets work unchanged:

```bash
make scrape-apsl              # auto-routes through the container
make scrape-csl-standings
make events-apsl
```

`scripts/vpn-wrap.sh` (called by all the per-league scripts) now routes
through `scripts/scrape-vpn.sh exec`, which `podman exec`s into the
running scraper container. The container is started on first use and
stays up for fast subsequent runs (`make scrape-vpn-down` to stop it).

## Direct access

```bash
./scripts/scrape-vpn.sh shell                 # interactive bash
./scripts/scrape-vpn.sh exec curl https://api.ipify.org   # one-off
./scripts/scrape-vpn.sh logs                  # see entrypoint output
```

## Escape hatches

| Situation                        | Command                             |
| -------------------------------- | ----------------------------------- |
| Skip VPN entirely (testing)      | `NO_VPN=1 make scrape-apsl`         |
| Force the legacy host VPN        | `VPN_BACKEND=host make scrape-apsl` |
| Rebuild image after Dockerfile   | `make scrape-vpn-rebuild`           |
| Use a different WG interface     | `WG_INTERFACE=other make scrape-vpn-up` |

## Why not `--network=host`?

That would defeat the entire point — the host's routing table would be
hijacked the moment WireGuard came up.

## Why not just a SOCKS proxy in the container?

Tried that path mentally: Chrome and node-fetch and puppeteer each
handle proxies differently (env var vs CLI flag vs ProxyAgent), and
DNS-over-HTTPS in modern Chromium bypasses `HTTPS_PROXY` for name
resolution. Running the whole tool inside the netns is the only way
that's universally correct.
