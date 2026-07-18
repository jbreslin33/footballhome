# Runtime Config

This directory holds small runtime configuration files that are mounted into
containers or installed onto the host.

## Tracked Files

- `ad-targeting-zips.json`: ZIP allowlists used by
  `scripts/apply-zip-allowlist.js` for Meta ad targeting.
- `nginx-footballhome.conf`: canonical host nginx site config installed by
  `scripts/setup/setup-nginx.sh`.

## Ignored Local Files

- `*.p12` and `*.pem`: LeagueApps API key material. `env` sets
  `LEAGUEAPPS_API_PRIVATE_KEY=<id>`, `scripts/setup/setup-env.sh` converts
  `config/<id>.p12` to `config/<id>.pem`, and backend containers mount this
  directory read-only at `/app/config` so `LeagueAppsService` can sign JWTs.

Do not commit plaintext private keys, certificates, or other local credentials
from this directory. Encrypted secret bundles belong in the repo root only when
they are intentionally tracked, such as `env.age`.