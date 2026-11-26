#!/usr/bin/env python3
"""Named styles + club / federation game models (research agents' JSON) -> one migration SQL.

Usage: styles_models_to_sql.py OUT.sql [--styles styles.json] [--models club-models.json fed-models.json ...]

styles.json  {"styles":[{name, aliases, era, tied_to, definition, canon, new_code, parent, relation, profile{axis:-2..2},
                         confidence, sources[{url,title,kind}]}]}
models.json  {"models":[{name, coach|federation, club|country, era, formation, in_possession_shape, style, settings{axis:v},
                         moments{moment:{plan, principles[]}}, official, confidence, sources[{url,title,kind}]}]}

Writes (all ON CONFLICT DO NOTHING, all web-found rows verified = false):
  game_sources               one row per cited document (code web-<slug>), kind as given
  game_styles (+profiles)    new named styles; game_source_styles + game_style_links for every style's sources
  game_models                one per model: source = the coach's / federation's own game_sources row (created if missing),
                             style_id, formation_family_id; game_model_moments, game_model_principles, game_model_style_settings
  game_formation_families    a new family when a model names a shape we do not have
"""
import json
import re
import sys

KINDS = {'book', 'coach', 'club', 'federation', 'analysis', 'fh'}
AXES = {'possession', 'build-up', 'tempo', 'width', 'crossing', 'rotation', 'block-height', 'pressing', 'orientation',
        'after-loss', 'after-win'}
MOMENTS = {'in_possession', 'out_of_possession', 'to_defend', 'to_attack', 'set_piece'}
COACH_CODES = {  # existing game_sources codes for coaches / clubs
    'guardiola': 'guardiola', 'klopp': 'klopp', 'sacchi': 'sacchi', 'bielsa': 'bielsa', 'cruyff': 'cruyff', 'rangnick': 'rangnick',
    'simeone': 'simeone', 'gasperini': 'gasperini', 'zeman': 'zeman', 'pochettino': 'pochettino', 'hasenhuttl': 'hasenhuttl',
    'hasenhüttl': 'hasenhuttl', 'de zerbi': 'de-zerbi', 'schmidt': 'schmidt', 'herrera': 'catenaccio', 'rocco': 'catenaccio',
}
FED_CODES = {'england': 'fa-england', 'netherlands': 'knvb', 'australia': 'football-australia', 'spain': 'rfef', 'poland': 'pzpn',
             'united states': 'us-soccer-u17', 'usa': 'us-soccer-u17', 'japan': 'jfa', 'france': 'fff', 'italy': 'figc',
             'germany': 'dfb', 'belgium': 'rbfa', 'canada': 'canada-soccer'}


def q(s):
    return 'NULL' if s is None else "'" + str(s).replace("'", "''") + "'"


def slug(s, n=50):
    s = (s or '').lower()
    s = s.replace('ü', 'u').replace('ö', 'o').replace('é', 'e').replace('á', 'a').replace('í', 'i').replace('ó', 'o').replace('ñ', 'n').replace('ã', 'a')
    return re.sub(r'[^a-z0-9]+', '-', s).strip('-')[:n]


class Out:
    def __init__(self):
        self.sql = []
        self.sources = {}

    def source(self, src):
        url = (src.get('url') or '').strip()
        title = (src.get('title') or url or 'untitled').strip()
        kind = src.get('kind') if src.get('kind') in KINDS else 'analysis'
        code = 'web-' + slug(re.sub(r'^https?://(www\.)?', '', url) or title, 60)
        if code not in self.sources:
            self.sources[code] = True
            self.sql.append(f"INSERT INTO game_sources (code, kind, title, url, verified) VALUES ({q(code)}, {q(kind)}, {q(title[:300])}, {q(url or None)}, false) ON CONFLICT (code) DO NOTHING;")
        return code

    def owner_source(self, code, kind, title):
        if code not in self.sources:
            self.sources[code] = True
            self.sql.append(f"INSERT INTO game_sources (code, kind, title, url, verified) VALUES ({q(code)}, {q(kind)}, {q(title[:300])}, NULL, false) ON CONFLICT (code) DO NOTHING;")
        return code


STYLE_SAME = {  # the two research agents named the same style differently: one code each
    'angeball': 'ange-ball', 'system-football': 'systematic-football', 'jogo-bonito': 'futebol-arte',
    'sarri-ball': 'sarriball', 'bait-the-press': 'press-baiting',
}


def style_code(v):
    v = (v or '').strip()
    if not v:
        return None, False
    new = v.startswith('new:')
    c = slug(v[4:] if new else v)
    return STYLE_SAME.get(c, c), new


def main():
    out_path = sys.argv[1]
    args = sys.argv[2:]
    styles_files, model_files, mode = [], [], None
    for a in args:
        if a == '--styles':
            mode = 's'
        elif a == '--models':
            mode = 'm'
        elif mode == 's':
            styles_files.append(a)
        else:
            model_files.append(a)
    o = Out()
    S = o.sql
    S.append("-- the duplicate one-off from two sweeps: switch of play = switch play")
    S.append("""UPDATE game_common_principle_links l SET principle_id = (SELECT id FROM game_play_principles WHERE code = 'x-switch-play')
 WHERE principle_id = (SELECT id FROM game_play_principles WHERE code = 'x-switch-of-play')
   AND NOT EXISTS (SELECT 1 FROM game_common_principle_links k WHERE k.term_id = l.term_id AND k.principle_id = (SELECT id FROM game_play_principles WHERE code = 'x-switch-play'));
DELETE FROM game_common_principle_links WHERE principle_id = (SELECT id FROM game_play_principles WHERE code = 'x-switch-of-play');
DELETE FROM game_play_principles WHERE code = 'x-switch-of-play';""")
    n_st = n_new_st = n_m = 0
    # ── named styles ──
    for f in styles_files:
        for st in json.load(open(f)).get('styles', []):
            name = (st.get('name') or '').strip()
            if not name:
                continue
            n_st += 1
            canon = (st.get('canon') or 'new').strip()
            if canon == 'new':
                canon = slug(st.get('new_code') or name)
                n_new_st += 1
                S.append(f"INSERT INTO game_styles (code, title, aka, era, definition, sort_order) VALUES ({q(canon)}, {q(name[:120])}, {q((st.get('aliases') or '')[:300])}, {q((st.get('era') or '')[:60])}, {q(((st.get('definition') or '') + (' (' + st['tied_to'] + ')' if st.get('tied_to') else ''))[:800])}, 200) ON CONFLICT (code) DO NOTHING;")
                for ax, v in (st.get('profile') or {}).items():
                    if ax in AXES and isinstance(v, int) and -2 <= v <= 2 and v != 0:
                        S.append(f"INSERT INTO game_style_profiles (style_id, dimension_id, value) SELECT s.id, d.id, {v} FROM game_styles s, game_style_dimensions d WHERE s.code = {q(canon)} AND d.code = {q(ax)} ON CONFLICT DO NOTHING;")
            else:
                canon = slug(canon)
            parent = st.get('parent')
            if parent:
                S.append(f"UPDATE game_styles c SET parent_id = p.id FROM game_styles p WHERE c.code = {q(canon)} AND p.code = {q(slug(parent))} AND c.parent_id IS NULL AND c.id <> p.id;")
            rel = st.get('relation') if st.get('relation') in ('same', 'part_of', 'overlaps') else 'same'
            if st.get('canon') == 'new':
                rel = 'same'
            for src in (st.get('sources') or [])[:3]:
                code = o.source(src)
                ctx = (st.get('tied_to') or 'named style')[:200]
                S.append(f"INSERT INTO game_source_styles (source_id, name, context, locator, verified) SELECT id, {q(name[:200])}, {q(ctx)}, coalesce(url, ''), false FROM game_sources WHERE code = {q(code)} ON CONFLICT (source_id, name, context) DO NOTHING;")
                S.append(f"""INSERT INTO game_style_links (entry_id, style_id, relation)
SELECT e.id, g.id, {q(rel)} FROM game_source_styles e JOIN game_sources s ON s.id = e.source_id, game_styles g
 WHERE s.code = {q(code)} AND e.name = {q(name[:200])} AND e.context = {q(ctx)} AND g.code = {q(canon)} ON CONFLICT DO NOTHING;""")
    # ── game models ──
    for f in model_files:
        for m in json.load(open(f)).get('models', []):
            name = (m.get('name') or '').strip()
            if not name:
                continue
            n_m += 1
            is_fed = bool(m.get('federation'))
            kind = 'federation' if is_fed else ('team' if m.get('kind') == 'national' else 'club')
            if is_fed:
                key = (m.get('country') or m.get('federation') or '').lower()
                owner = next((c for k, c in FED_CODES.items() if k in key), None) or o.owner_source('fed-' + slug(m.get('country') or m.get('federation')), 'federation', (m.get('federation') or name) + ' — game model')
            else:
                coach = (m.get('coach') or '').lower()
                owner = next((c for k, c in COACH_CODES.items() if k in coach), None) or o.owner_source('coach-' + slug(m.get('coach') or name), 'coach', (m.get('coach') or name))
            sty, sty_new = style_code(m.get('style'))
            if sty and sty_new:
                S.append(f"INSERT INTO game_styles (code, title, definition, sort_order) VALUES ({q(sty)}, {q(sty.replace('-', ' ').capitalize())}, {q('Named by ' + name + ' (game-model research 11/26); definition owed.')}, 210) ON CONFLICT (code) DO NOTHING;")
            fam = (m.get('formation') or '').strip() or None
            if fam and fam.startswith('new:'):
                fam = fam[4:].strip()
                digits = re.findall(r'\d', fam)
                back = int(digits[0]) if digits and 2 <= int(digits[0]) <= 5 else 4
                S.append(f"INSERT INTO game_formation_families (code, title, back, phase, definition, sort_order) VALUES ({q(fam)}, {q(fam)}, {back}, 'base', {q('Named by ' + name + ' (game-model research 11/26).')}, 400) ON CONFLICT (code) DO NOTHING;")
            plan_note = ' · '.join(filter(None, [m.get('club') or m.get('country') or '', ('in possession ' + m['in_possession_shape']) if m.get('in_possession_shape') else '']))
            S.append(f"""INSERT INTO game_models (name, kind, note, sort_order, era, source_id, style_id, formation_family_id, verified)
SELECT {q(name[:200])}, {q(kind)}, {q(plan_note[:500])}, {50 if is_fed else 60}, {q((m.get('era') or '')[:60])},
       (SELECT id FROM game_sources WHERE code = {q(owner)}), (SELECT id FROM game_styles WHERE code = {q(sty)}),
       (SELECT id FROM game_formation_families WHERE code = {q(fam)}), false
ON CONFLICT (name) DO NOTHING;""")
            cites = []
            for src in (m.get('sources') or [])[:3]:
                code = o.source(src)
                cites.append(src.get('url') or src.get('title') or '')
            cite = ' · '.join(c for c in cites if c)[:900]
            for ax, v in (m.get('settings') or {}).items():
                if ax in AXES and isinstance(v, int) and -2 <= v <= 2 and v != 0:
                    S.append(f"INSERT INTO game_model_style_settings (model_id, dimension_id, value) SELECT gm.id, d.id, {v} FROM game_models gm, game_style_dimensions d WHERE gm.name = {q(name[:200])} AND d.code = {q(ax)} ON CONFLICT DO NOTHING;")
            for mo, body in (m.get('moments') or {}).items():
                if mo not in MOMENTS or not isinstance(body, dict):
                    continue
                if body.get('plan'):
                    S.append(f"INSERT INTO game_model_moments (model_id, moment, plan, citation) SELECT id, {q(mo)}, {q(body['plan'][:800])}, {q(cite)} FROM game_models WHERE name = {q(name[:200])} ON CONFLICT DO NOTHING;")
                for i, pc in enumerate((body.get('principles') or [])[:4]):
                    S.append(f"INSERT INTO game_model_principles (model_id, principle_id, moment, emphasis, own_words) SELECT gm.id, p.id, {q(mo)}, {3 if i == 0 else 2}, '' FROM game_models gm, game_play_principles p WHERE gm.name = {q(name[:200])} AND p.code = {q(pc)} ON CONFLICT DO NOTHING;")
            # the model's style is also a source naming that style
            if sty:
                ctx = name[:200]
                for src in (m.get('sources') or [])[:1]:
                    code = o.source(src)
                    S.append(f"INSERT INTO game_source_styles (source_id, name, context, locator, verified) SELECT id, {q(sty)}, {q(ctx)}, coalesce(url, ''), false FROM game_sources WHERE code = {q(code)} ON CONFLICT (source_id, name, context) DO NOTHING;")
                    S.append(f"""INSERT INTO game_style_links (entry_id, style_id, relation)
SELECT e.id, g.id, 'same' FROM game_source_styles e JOIN game_sources s ON s.id = e.source_id, game_styles g
 WHERE s.code = {q(code)} AND e.name = {q(sty)} AND e.context = {q(ctx)} AND g.code = {q(sty)} ON CONFLICT DO NOTHING;""")
    with open(out_path, 'a') as fh:
        fh.write("\n".join(x for x in S if x) + "\n")
    print(f"{n_st} style entries ({n_new_st} new styles), {n_m} game models, {len(o.sources)} sources -> {out_path}")


if __name__ == '__main__':
    main()
