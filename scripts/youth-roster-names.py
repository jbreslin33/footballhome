#!/usr/bin/env python3
# Read the player names off the locked youth roster PDFs (club_file
# sources, mig 592) into official_roster_names, so the #teams Roster pill
# can show the OFFICIAL list and the ✂ cut flag (mig 868).
#
# By hand, after a new roster PDF goes on #files and its source row is
# pointed at it. The board has no re-pull for these, so nothing else
# touches the names. Emits SQL on stdout: each file's names replace that
# source's names, a file that parses to nothing is skipped and leaves its
# names alone. Alias rows (official_roster_aliases) survive a re-run; add
# one for a league misspelling the match trigger misses. Names go through
# the pipe into the DB and never land in git, per the contacts-in-DB-only
# rule.
#
# Run (needs pdftotext):
#   python3 scripts/youth-roster-names.py \
#   | sudo podman exec -i footballhome_db \
#     psql -U footballhome_user -d footballhome -v ON_ERROR_STOP=1

import base64
import os
import re
import subprocess
import sys

ENGINE = os.environ.get('ENGINE', 'sudo podman').split()
PSQL = ENGINE + ['exec', '-i', 'footballhome_db', 'psql', '-U', 'footballhome_user', '-d', 'footballhome', '-At']

# "1  Last, First  [jersey]  12345678  2016  P ..." — coaches have no birth year.
PLAYER_ROW = re.compile(r'^\s*\d+\s+(\S[^,]*,\s*\S.*?)\s{2,}(?:\d{1,3}\s+)?\d{7,}\s+\d{4}\s')


def query(sql):
    return subprocess.run(PSQL, input=sql, capture_output=True, text=True, check=True).stdout


def names_in(pdf):
    text = subprocess.run(['pdftotext', '-layout', '-', '-'], input=pdf, capture_output=True, check=True).stdout
    names = []
    for line in text.decode().splitlines():
        m = PLAYER_ROW.match(line)
        if m:
            last, first = [part.strip() for part in m.group(1).split(',', 1)]
            names.append(f'{first} {last}')
    return names


def quoted(s):
    return "'" + s.replace("'", "''") + "'"


print('BEGIN;')
for row in query("SELECT id, external_team_id FROM official_roster_sources WHERE is_active AND system = 'club_file' ORDER BY id").splitlines():
    source_id, file_id = row.split('|')
    b64 = query(f"SELECT encode(bytes, 'base64') FROM club_files WHERE id = {int(file_id)}")
    names = names_in(base64.b64decode(b64))
    print(f'source {source_id} (club_files {file_id}): {len(names)} names', file=sys.stderr)
    if not names:
        continue
    print(f'DELETE FROM official_roster_names WHERE source_id = {int(source_id)};')
    for i, name in enumerate(names):
        print(f'INSERT INTO official_roster_names (source_id, full_name, sort_order) VALUES ({int(source_id)}, {quoted(name)}, {i});')
print('COMMIT;')
