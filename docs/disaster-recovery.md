# Disaster recovery — start Football Home on a new server

Owner 2026-11-19: "we need backups so we can start on new server if needed
if this one crashes".

## What lives where

| Piece | Off-site copy | Kept up to date by |
|---|---|---|
| Code, migrations, frontend | GitHub `jbreslin33/footballhome` | `git-sync-push.timer` (user timer, every 10 min) — pushes `main` |
| Secrets (`env`, scrape VPN, APSL login) | `env.age`, `scrape-vpn.conf.age`, `apsl-credentials.conf.age` in that repo | by hand: `age -p -o env.age env` after editing `env` |
| Database (everything: people, payments, events, uploaded files, logos …) | GitHub `jbreslin33/footballhome-backups` — `daily/<date>/` last 7, `weekly/<date>/` last 4 | `backup-db.timer` (root, 3am) → `scripts/backup-db.sh` → `scripts/backup-offsite.sh` |

You need **two secrets that are not on any server** — keep both in your
password manager:

1. the **age passphrase** for `env.age` (and the other `.age` config files);
2. the **database backup key** — the whole file
   `~/.config/footballhome/backup-age-key.txt` on the old server (starts
   `# created:`, has a line `AGE-SECRET-KEY-1…`).  Without it the database
   backups cannot be opened.  Its public half is
   `scripts/backup-age-recipient.txt` (safe to share).

## Start on a new server

```bash
# 1. Code
sudo mkdir -p /srv/footballhome && sudo chown $USER /srv/footballhome
git clone https://github.com/jbreslin33/footballhome /srv/footballhome
cd /srv/footballhome

# 2. Packages, podman, nginx, secrets — prompts for the age passphrase
./setup.sh                      # unattended: AGE_PASSPHRASE='…' ./setup.sh

# 3. Containers (empty database)
make up

# 4. Database — newest daily backup
git clone --depth 1 https://github.com/jbreslin33/footballhome-backups ~/fh-restore
cd ~/fh-restore/daily/$(ls ~/fh-restore/daily | sort | tail -1)
sha256sum -c SHA256SUMS
# backup key from the password manager → ~/backup-age-key.txt (chmod 600)
cat footballhome.dump.age.part-* | age -d -i ~/backup-age-key.txt > /tmp/footballhome.dump
sudo podman cp /tmp/footballhome.dump footballhome_db:/tmp/footballhome.dump
sudo podman exec footballhome_db sh -c \
  'pg_restore -U "$POSTGRES_USER" -d "$POSTGRES_DB" --clean --if-exists --no-owner /tmp/footballhome.dump'
cd /srv/footballhome

# 5. Backend build + any migrations newer than the backup
make builder-up && make deploy
make migrate

# 6. Timers (DB backup, gcal sync, …) — systemd/*.service|timer
sudo cp systemd/*.service systemd/*.timer systemd/*.path /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now backup-db.timer gcal-sync.timer casa-insta-scores.timer \
  refresh-instagram-token.timer pyramid-chrome-sync.timer gcal-refresh.path
mkdir -p ~/.config/systemd/user
ln -sf /srv/footballhome/systemd/user/git-sync-push.{service,timer} ~/.config/systemd/user/
systemctl --user daemon-reload && systemctl --user enable --now git-sync-push.timer
loginctl enable-linger $USER

# 7. Put the backup key back where the nightly job expects it
mkdir -p ~/.config/footballhome && chmod 700 ~/.config/footballhome
mv ~/backup-age-key.txt ~/.config/footballhome/backup-age-key.txt
```

Then: point DNS (GoDaddy) at the new IP (see the home-hosting notes), get
certificates (`LE_EMAIL=… ./setup.sh --only nginx`), and open the site.
GitHub credentials for the pushes: `git config --global credential.helper store`
and one `git push` with a personal access token.

## Check the backups are working

```bash
journalctl -u backup-db -n 20 --no-pager      # last night: "Pushed off-site backup <date>"
systemctl --user list-timers | grep git-sync  # code push timer is on
journalctl --user -u git-sync-push -n 5       # "pushed N commit(s)" / DIVERGED
```

Restore test (2026-11-19): a backup was restored into a scratch database
on the old server and its row counts matched production.

## History

- Until 2026-10: the plain `.sql` dump was committed to the backups repo.
  It passed GitHub's 100 MB file limit in early October and every push
  failed silently; the last good off-site copy was 2026-09-30.  That repo
  was **public** — the encrypted rewrite (2026-11-19) replaced its history.
