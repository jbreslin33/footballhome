#!/bin/bash
# Keep GitHub in step with the server (owner 2026-11-19: "we need to be in
# synce with github in case server goes down").  Every commit on main here
# is pushed to origin within minutes — by systemd/user/git-sync-push.timer.
#
# Only commits travel; uncommitted work stays on this disk.  Never forces:
# if GitHub has commits this server lacks (diverged), it logs and stops so
# a human merges.  Logs to the journal: journalctl --user -u git-sync-push
set -u
REPO=/srv/footballhome
cd "$REPO" || exit 1
# One at a time (a slow push must not overlap the next tick).
exec 9>/tmp/footballhome-git-sync.lock
flock -n 9 || { echo "another sync is running"; exit 0; }

branch=$(git symbolic-ref --short HEAD 2>/dev/null)
if [ "$branch" != "main" ]; then echo "on '$branch', not main — skipped"; exit 0; fi
git fetch -q origin main || { echo "fetch failed (network?)"; exit 1; }
ahead=$(git rev-list --count origin/main..main)
behind=$(git rev-list --count main..origin/main)
if [ "$ahead" -eq 0 ]; then
  [ "$behind" -gt 0 ] && echo "GitHub is $behind ahead of the server — nothing pushed (pull when convenient)"
  exit 0
fi
if [ "$behind" -gt 0 ]; then
  echo "DIVERGED: server $ahead ahead, GitHub $behind ahead — not pushing; merge by hand" >&2
  exit 1
fi
git push -q origin main && echo "pushed $ahead commit(s) → origin/main $(git rev-parse --short main)"
