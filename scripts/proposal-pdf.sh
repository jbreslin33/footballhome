#!/usr/bin/env bash
# proposal-pdf.sh — keeps a PDF of every public proposal next to its public
# page, and remakes it whenever the proposal changes (mig 1739).
#
#   https://footballhome.org/proposals/#<code>      the public page
#   https://footballhome.org/proposals/<code>.pdf   this script's output
#
# For each proposal flagged proposals.is_public it reads what the public page
# reads (GET /api/proposals/public/<code>) and hashes it.  A new hash, or a
# missing PDF, makes headless Chrome print the public page to
# frontend/proposals/<code>.pdf.  Nothing changed = nothing done, so it is
# cheap to run every minute:
#
#   * * * * * /srv/footballhome/scripts/proposal-pdf.sh   (jbreslin's crontab)
#
# A proposal that is no longer public loses its PDF.  The PDFs and the hashes
# (frontend/proposals/.pdf-state/) are generated files, not in git.
#
#   scripts/proposal-pdf.sh           remake what changed
#   scripts/proposal-pdf.sh --force   remake all of them
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/frontend/proposals"
STATE="$OUT/.pdf-state"
SITE="${PROPOSAL_PDF_SITE:-http://localhost:3000}"
FORCE="${1:-}"
mkdir -p "$STATE"

exec 9>"$STATE/.lock"
flock -n 9 || exit 0

codes="$(sudo -n podman exec footballhome_db psql -U footballhome_user -d footballhome -At \
  -c "SELECT code FROM proposals WHERE is_public AND is_active ORDER BY code" < /dev/null)" || exit 0

for code in $codes; do
  body="$(curl -fsS --max-time 20 "$SITE/api/proposals/public/$code")" || continue
  hash="$(printf '%s' "$body" | sha256sum | cut -d' ' -f1)"
  if [ "$FORCE" != "--force" ] && [ -f "$OUT/$code.pdf" ] && [ "$(cat "$STATE/$code.sha" 2>/dev/null)" = "$hash" ]; then
    continue
  fi
  tmp="$(mktemp -d)"
  if timeout 90 google-chrome --headless=new --no-sandbox --disable-gpu --user-data-dir="$tmp/profile" \
       --no-pdf-header-footer --virtual-time-budget=10000 \
       --print-to-pdf="$tmp/out.pdf" "$SITE/proposals/#$code" >/dev/null 2>&1 \
     && [ -s "$tmp/out.pdf" ]; then
    mv "$tmp/out.pdf" "$OUT/$code.pdf"
    chmod 644 "$OUT/$code.pdf"
    printf '%s' "$hash" > "$STATE/$code.sha"
    echo "$(date '+%F %T') made $code.pdf"
  else
    echo "$(date '+%F %T') FAILED $code.pdf" >&2
  fi
  rm -rf "$tmp"
done

# A proposal that stopped being public loses its PDF.
for pdf in "$OUT"/*.pdf; do
  [ -e "$pdf" ] || continue
  name="$(basename "$pdf" .pdf)"
  if ! printf '%s\n' $codes | grep -qx "$name"; then
    rm -f "$pdf" "$STATE/$name.sha"
    echo "$(date '+%F %T') removed $name.pdf"
  fi
done
