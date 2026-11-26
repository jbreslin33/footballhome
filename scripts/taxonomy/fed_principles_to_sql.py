#!/usr/bin/env python3
"""Federation principles sweep (JSON from the research agents) -> one migration SQL.

Usage: fed_principles_to_sql.py OUT.sql IN1.json [IN2.json ...]

Each JSON: {"slice": ..., "federations": [{"name", "country", "confederation", "status", "url", "title",
"official", "terms": [{"term", "lang", "level", "side", "canon", "new_name", "relation"}], "note"}]}

Writes:
  game_federations           every association the sweep looked at, with its status (the coverage register)
  game_sources               one source per federation that published principles (code fed-<slug>)
  game_source_principles     its terms in its own words (verified = false: web-found)
  game_common_principle_links  term -> canonical principle; canon 'new' becomes a new 'sub' common-ground row
Known sources (fa-england, knvb, ...) are not duplicated: a federation whose status is 'known' only gets its register row.
"""
import json
import re
import sys

KNOWN = {  # federation name fragment -> existing game_sources code
    'england': 'fa-england', 'netherlands': 'knvb', 'france': 'fff', 'italy': 'figc', 'spain': 'rfef',
    'germany': 'dfb', 'australia': 'football-australia', 'united states': 'ussf-d-licence', 'usa': 'ussf-d-licence',
    'japan': 'jfa', 'belgium': 'rbfa', 'canada': 'canada-soccer',
}
LEVELS = {'general', 'operational', 'fundamental', 'sub'}
SIDES = {'attack', 'defend', 'both'}
RELS = {'same', 'part_of', 'overlaps'}


def q(s):
    return 'NULL' if s is None else "'" + str(s).replace("'", "''") + "'"


def slug(s):
    return re.sub(r'[^a-z0-9]+', '-', s.lower()).strip('-')[:40]


def main():
    out, ins = sys.argv[1], sys.argv[2:]
    feds = []
    for p in ins:
        with open(p) as f:
            feds += json.load(f).get('federations', [])
    sql = []
    sql.append("""CREATE TABLE IF NOT EXISTS game_federations (
    id            serial PRIMARY KEY,
    name          text NOT NULL UNIQUE,
    country       text NOT NULL DEFAULT '',
    confederation text NOT NULL,
    principles_status text NOT NULL CHECK (principles_status IN ('found', 'known', 'not_published', 'not_searched')),
    source_id     integer REFERENCES game_sources(id),
    url           text,
    note          text NOT NULL DEFAULT ''
);""")
    sql.append("CREATE TEMP TABLE t_terms (src text, term text, lang text, lvl text, side text, canon text, rel text) ON COMMIT DROP;")
    news = {}
    rows = []
    for fe in feds:
        name = (fe.get('name') or '').strip()
        if not name:
            continue
        status = fe.get('status') or 'not_searched'
        if status not in ('found', 'known', 'not_published', 'not_searched'):
            status = 'not_searched'
        terms = [t for t in (fe.get('terms') or []) if t.get('term')]
        if status == 'found' and not terms:
            status = 'not_published'
        src = None
        low = (fe.get('country') or name).lower()
        for k, code in KNOWN.items():
            if k in low:
                src = code
        if status in ('found', 'known') and terms:
            if src is None:
                src = 'fed-' + slug(fe.get('country') or name)
                title = name + (' — ' + fe['title'] if fe.get('title') else '') + ' — principles of play'
                sql.append(f"INSERT INTO game_sources (code, kind, title, url, verified) VALUES ({q(src)}, 'federation', {q(title)}, {q(fe.get('url'))}, false) ON CONFLICT (code) DO NOTHING;")
            for t in terms:
                canon = (t.get('canon') or 'new').strip()
                if canon == 'new':
                    nn = (t.get('new_name') or t['term']).strip()
                    canon = 'x-' + slug(nn)
                    side = t.get('side') if t.get('side') in SIDES else 'both'
                    news.setdefault(canon, (nn, side, set()))[2].add(src)
                lvl = t.get('level') if t.get('level') in LEVELS else 'fundamental'
                side = t.get('side') if t.get('side') in SIDES else 'both'
                rel = t.get('relation') if t.get('relation') in RELS else 'same'
                if canon.startswith('x-'):
                    rel = 'same'   # a new common-ground row IS the term
                rows.append(f"({q(src)}, {q(t['term'][:300])}, {q((t.get('lang') or 'en')[:8])}, {q(lvl)}, {q(side)}, {q(canon)}, {q(rel)})")
        sql.append(
            "INSERT INTO game_federations (name, country, confederation, principles_status, url, note, source_id) "
            f"VALUES ({q(name)}, {q(fe.get('country') or '')}, {q(fe.get('confederation') or '')}, {q(status)}, {q(fe.get('url'))}, {q((fe.get('note') or '')[:500])}, "
            f"(SELECT id FROM game_sources WHERE code = {q(src)})) "
            "ON CONFLICT (name) DO UPDATE SET principles_status = EXCLUDED.principles_status, url = EXCLUDED.url, note = EXCLUDED.note, source_id = EXCLUDED.source_id;")
    for code, (nn, side, srcs) in sorted(news.items()):
        sql.append(f"INSERT INTO game_play_principles (code, side, level, title, aka, definition, is_not, sort_order) VALUES ({q(code)}, {q(side)}, 'sub', {q(nn[:120])}, '', {q('Named by ' + ', '.join(sorted(srcs)) + ' (federation sweep 11/26); definition owed.')}, '', 90) ON CONFLICT (code) DO NOTHING;")
    if rows:
        sql.append("INSERT INTO t_terms VALUES\n  " + ",\n  ".join(rows) + ";")
        sql.append("""INSERT INTO game_source_principles (source_id, term, lang, level, side, locator, verified)
SELECT s.id, t.term, t.lang, t.lvl, t.side, coalesce(s.url, ''), false FROM t_terms t JOIN game_sources s ON s.code = t.src
ON CONFLICT (source_id, term) DO NOTHING;""")
        sql.append("""INSERT INTO game_common_principle_links (term_id, principle_id, relation)
SELECT pt.id, p.id, t.rel FROM t_terms t JOIN game_sources s ON s.code = t.src
  JOIN game_source_principles pt ON pt.source_id = s.id AND pt.term = t.term
  JOIN game_play_principles p ON p.code = t.canon
ON CONFLICT DO NOTHING;""")
    with open(out, 'a') as f:
        f.write("\n".join(sql) + "\n")
    print(f"{len(feds)} federations, {len(rows)} terms, {len(news)} new common-ground rows -> {out}")


if __name__ == '__main__':
    main()
