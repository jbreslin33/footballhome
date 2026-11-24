#!/usr/bin/env python3
"""scripts/taxonomy/check_engine_sync.py — the engine's behaviour list and the database agree.

game/src/ai/behaviours.list (what the code has; the image build checks it against the
`// [behaviour: …]` tags) must name exactly the codes in game_engine_behaviours (what the
taxonomy knows — ⚽ Football → 🧬 Taxonomy). `make game-deploy` runs this first and stops on
a difference, so the engine cannot ship a behaviour the taxonomy has no row for, and the
taxonomy cannot keep a row for a behaviour the engine no longer has.

Exit 0 in sync, 1 out of sync, 2 the database could not be read.
"""
import os
import subprocess
import sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))


def main():
    listed = set()
    with open(os.path.join(ROOT, 'game/src/ai/behaviours.list'), encoding='utf-8') as f:
        for line in f:
            line = line.strip()
            if line and not line.startswith('#'):
                listed.add(line.split()[0])
    r = subprocess.run(['sudo', '-n', 'podman', 'exec', '-i', 'footballhome_db', 'psql', '-U', 'footballhome_user', '-d',
                        'footballhome', '-At', '-c', 'SELECT code FROM game_engine_behaviours'],
                       capture_output=True, text=True, stdin=subprocess.DEVNULL)
    if r.returncode != 0:
        sys.stderr.write('check_engine_sync: could not read game_engine_behaviours: ' + r.stderr.strip() + '\n')
        return 2
    rows = set(r.stdout.split())
    only_code, only_db = sorted(listed - rows), sorted(rows - listed)
    if only_code:
        print('In the engine, no database row (add them by migration to game_engine_behaviours):')
        for c in only_code:
            print('  ' + c)
    if only_db:
        print('In the database, not in the engine (retire the rows by migration, or restore the behaviour):')
        for c in only_db:
            print('  ' + c)
    if only_code or only_db:
        return 1
    print(f'check_engine_sync: OK ({len(listed)} behaviours in the engine and in the database)')
    return 0


if __name__ == '__main__':
    sys.exit(main())
