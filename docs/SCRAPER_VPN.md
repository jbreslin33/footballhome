# Containerized Scraping VPN

The league sites APSL and CSL block this network's IP, so scrapes need
to go through a WireGuard tunnel. The original setup ran `wg-quick` on
the **host**, which routes *every* host packet through the VPN — that
drops inbound SSH sessions when working remotely.

This setup runs WireGuard inside a dedicated rootful Podman container so
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
# 1. Install podman
sudo apt install -y podman

# 2. Install your WireGuard config (root-owned, /etc/wireguard read-only
#    mount inside the container — no copy of the secret in the image).
sudo ./scripts/setup/setup-wireguard.sh import /path/to/provider.conf
# This creates /etc/wireguard/scrape-vpn.conf

# 3. Build + start the scraper container. The script uses sudo podman on
#    this host so WireGuard can set the container network namespace sysctls.
make scrape-vpn-up
```

`make scrape-vpn-status` should show a different external IP for the
container than for the host.

## Daily use

The existing scrape targets work unchanged:

```bash
make scrape-apsl              # auto-routes through the container
make scrape-csl-standings
make scrape-apsl-teams
```

`scripts/vpn-wrap.sh` (called by all the per-league scripts) routes through
`scripts/scrape-vpn.sh exec`, which runs `sudo podman exec` into the scraper
container on this host. The container is started on first use and stays up for
fast subsequent runs (`make scrape-vpn-down` to stop it).

## Direct access

```bash
./scripts/scrape-vpn.sh shell                 # interactive bash
./scripts/scrape-vpn.sh exec curl https://api.ipify.org   # one-off
./scripts/scrape-vpn.sh logs                  # see entrypoint output
```

## The backend's way out: the forward proxy

The C++ backend also needs TeamPass — the official roster print on
`#game-center` (migration 501, `backend/src/services/TeamPassRoster.cpp`)
signs in and downloads the league's roster PDF on every tap. It cannot run
inside this container, so the container runs a small forward proxy
(tinyproxy, `.docker/scraper/tinyproxy.conf`) behind the tunnel:

- The container joins the app network (`footballhome_footballhome_network`),
  so the backend reaches it as `http://footballhome_scraper:3128`
  (`TEAMPASS_PROXY_URL` overrides; `direct` = no proxy).
- The proxy relays HTTPS to `*.teampass.com` only and the port is never
  published on the host.
- The container is `--restart always`: if it is down, the roster print
  fails with "the league site did not answer".

```bash
make scrape-vpn-up        # after a rebuild, or if the container is gone
sudo podman logs footballhome_scraper | grep scraper   # "Proxy listening on :3128"
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

## Every league roster: #dual-rostering (mig 1774)

`RosterWatchSync` (backend) reads every roster we can and the
`#dual-rostering` page lists each name that is on two or more teams.

| League | Where it is read | Through the VPN? |
| ------ | ---------------- | ---------------- |
| APSL, CSL, ADASL | each team's TeamPass page (`pyramid_sources.team_page`) → `pyramid_team_people` | yes — the proxy above |
| CASA | the public roster workbooks on Google Sheets (`roster_sheet_sources`, one row per workbook) → `roster_sheet_teams` / `roster_sheet_players` | no |
| UPSL | **by paste** (mig 1777) — upsl.com answers every automated reader with a Cloudflare challenge, from the home line and the VPN alike. Each team's roster is on its team page (`premier.upsl.com/teams/<club>-<id>/`): open it, copy all, paste into the page's ➕ fold (`roster_sheet_sources.system = 'paste'`) | — |

- A sweep starts when the page opens and the last one is
  `roster_watch_policy.stale_hours` old (24); the page's 🔄 button reads
  everything again. One request at a time, `pause_ms` apart (~200 pages,
  a few minutes).
- A new CASA workbook (a new season, a new region) = one
  `roster_sheet_sources` row by migration: `tab_name` NULL when each team
  has its own tab, else the name of the one tab listing every team.
- A sheet team that is really one of the pyramid's clubs under another
  name = a `pyramid_club_aliases` row; otherwise the page counts it as a
  different club.
