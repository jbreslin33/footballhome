#!/usr/bin/env python3
"""scripts/taxonomy/export_engine_index.py — the engine's C++ as the Taxonomy page reads it.

⚽ Football → 🧬 Taxonomy (#football-taxonomy) shows, beside every concept's database row,
the engine behaviour that plays it and the C++ class behind that behaviour, with links up
the parent chain and the source itself (owner 11/24: "the taxonomy page should show the db
entry and the c++ class should be viewable with hyperlink to parent classes"). The backend
image holds no engine source, so this script copies what the page needs into the database:

  game_engine_sources     every file of game/src/{ai,core,server,teach} and shared/tactics,
                          whole, with the commit it was read at
  game_engine_classes     every class / struct in them: file, first and last line, parent,
                          the comment block above it
  game_engine_behaviours  .symbol / .class_name — where each behaviour's file:line sits now
                          (the enclosing Class::method), so the page links it to its class

Re-run after engine changes (it replaces the first two tables and re-anchors the third):

  python3 scripts/taxonomy/export_engine_index.py | sudo podman exec -i footballhome_db \\
      psql -U footballhome_user -d footballhome -v ON_ERROR_STOP=1 -1

Reads only; prints SQL on stdout. No third-party modules.
"""
import os
import re
import subprocess
import sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))
DIRS = ['game/src/ai', 'game/src/core', 'game/src/server', 'game/src/teach', 'shared/tactics']
CLASS_RE = re.compile(r'^\s*(class|struct)\s+(\w+)(?:\s+final)?\s*(?::\s*(?:public|protected|private)?\s*([\w:]+(?:<[^>{]*>)?))?\s*\{')
FUNC_RE = re.compile(r'^[\w:<>,&\*\s~]*?\b(\w+)::(~?\w+)\s*\([^;]*$')


def q(s):
    return 'NULL' if s is None else "'" + str(s).replace("'", "''") + "'"


def strip(line):
    """The line without string / char literals and // comments, for brace counting."""
    line = re.sub(r'"(?:\\.|[^"\\])*"', '""', line)
    line = re.sub(r"'(?:\\.|[^'\\])'", "''", line)
    return line.split('//', 1)[0]


def block_end(lines, start):
    """1-based last line of the brace block that opens on line `start` (1-based)."""
    depth, seen = 0, False
    for i in range(start - 1, len(lines)):
        for ch in strip(lines[i]):
            if ch == '{':
                depth += 1
                seen = True
            elif ch == '}':
                depth -= 1
                if seen and depth == 0:
                    return i + 1
    return len(lines)


def doc_above(lines, start):
    out, i = [], start - 2
    while i >= 0 and lines[i].strip().startswith('//'):
        out.append(lines[i].strip()[2:].strip())
        i -= 1
    return '\n'.join(reversed(out)) or None


def main():
    commit = subprocess.run(['git', '-C', ROOT, 'rev-parse', '--short', 'HEAD'], capture_output=True, text=True).stdout.strip()
    files, classes, funcs = {}, [], {}
    for d in DIRS:
        for name in sorted(os.listdir(os.path.join(ROOT, d))):
            if not name.endswith(('.hpp', '.cpp')):
                continue
            rel = d + '/' + name
            with open(os.path.join(ROOT, rel), encoding='utf-8') as f:
                body = f.read()
            lines = body.split('\n')
            files[rel] = (body, len(lines))
            funcs[rel] = []
            for n, line in enumerate(lines, 1):
                m = CLASS_RE.match(line)
                if m and not line.strip().endswith(';'):
                    parent = m.group(3).split('::')[-1].split('<')[0] if m.group(3) else None
                    classes.append((m.group(2), rel, n, block_end(lines, n), parent, doc_above(lines, n), m.group(1)))
                    continue
                if line[:1] not in (' ', '\t', '/', '#', '}', '') :
                    f2 = FUNC_RE.match(line)
                    if f2:
                        funcs[rel].append((n, f2.group(1), f2.group(2)))

    # `using PlayerState = State<PlayerAgent, PlayerCtx>;` — a parent named by its alias is the template behind it.
    alias = {}
    for rel, (body, _) in files.items():
        for m in re.finditer(r'^\s*using\s+(\w+)\s*=\s*(\w+)\s*<', body, re.M):
            alias[m.group(1)] = m.group(2)
    classes = [(n, r, a, b, alias.get(p, p), d, k) for (n, r, a, b, p, d, k) in classes]
    known = {c[0] for c in classes}
    print('DELETE FROM game_engine_classes;')
    print('DELETE FROM game_engine_sources;')
    for rel, (body, n) in files.items():
        print(f'INSERT INTO game_engine_sources (file, commit, line_count, body) VALUES ({q(rel)}, {q(commit)}, {n}, {q(body)});')
    seen = set()
    for name, rel, a, b, parent, doc, kind in classes:
        if (name, rel) in seen:
            continue
        seen.add((name, rel))
        print('INSERT INTO game_engine_classes (name, file, line_start, line_end, parent, doc, kind) VALUES '
              f'({q(name)}, {q(rel)}, {a}, {b}, {q(parent if parent in known else None)}, {q(doc)}, {q(kind)});')

    # Re-anchor the behaviours: file:line → the class body it is in, else the Class::method above it.
    rows = subprocess.run(['sudo', '-n', 'podman', 'exec', '-i', 'footballhome_db', 'psql', '-U', 'footballhome_user', '-d',
                           'footballhome', '-At', '-F', '|', '-c', 'SELECT code, file, line FROM game_engine_behaviours'],
                          capture_output=True, text=True, stdin=subprocess.DEVNULL).stdout
    for row in rows.splitlines():
        code, rel, line = row.split('|')
        rel, line = ('game/src/' + rel if not rel.startswith(('game/', 'shared/')) else rel), int(line)
        cls = [c for c in classes if c[1] == rel and c[2] <= line <= c[3]]
        symbol, cname = None, None
        if cls:
            cname = min(cls, key=lambda c: c[3] - c[2])[0]   # the innermost
            symbol = cname
        else:
            above = [f for f in funcs.get(rel, []) if f[0] <= line]
            if above:
                _, owner, method = above[-1]
                symbol = owner + '::' + method
                cname = owner if owner in known else None
        print(f'UPDATE game_engine_behaviours SET symbol = {q(symbol)}, class_name = {q(cname)}, file = {q(rel)} WHERE code = {q(code)};')
    sys.stderr.write(f'{len(files)} files, {len(seen)} classes at {commit}\n')


if __name__ == '__main__':
    main()
