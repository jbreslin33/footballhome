-- 827 (2026-10-29) — #apsl: promotion and relegation as data.
--
-- Owner 2026-10-29: "so db wise an apsl conference cannot promote currently
-- because we have no connected league above. but it can relegate. thing is
-- some relegate to multiple feeders. so it needs to be one to many right?
-- we need this all in db!!"
--
-- 1. pyramid_flows (mig 823) becomes pyramid_links: ONE row per link
--    between an upper level (a conference, or a table) and a lower table,
--    carrying teams BOTH ways — promotes (up the link) and relegates (down
--    it).  A conference with four links below relegates one-to-many; a
--    table linked to two conferences (North Jersey Liga 1) promotes
--    one-to-many.  No link above = nothing to promote into (every APSL
--    conference today).
-- 2. pyramid_zone_kinds: what a zone IS — label, colour, and which way its
--    teams move (up / down / NULL = stays: APSL's playoff spots go to the
--    national playoffs, not to another table).  The page reads colours and
--    meaning from here; a kind a feed introduces is added with its own
--    label and colour, moving nowhere until a row says otherwise.
-- 3. pyramid_zone_moves: where each zone's teams go — up-zones along the
--    table's links up, down-zones along every link down.

-- ── Links ──────────────────────────────────────────────────────────────
ALTER TABLE pyramid_flows RENAME TO pyramid_links;
ALTER SEQUENCE IF EXISTS pyramid_flows_id_seq RENAME TO pyramid_links_id_seq;
ALTER TABLE pyramid_links RENAME COLUMN from_source_id    TO lower_source_id;
ALTER TABLE pyramid_links RENAME COLUMN from_division     TO lower_division;
ALTER TABLE pyramid_links RENAME COLUMN to_competition_id TO upper_competition_id;
ALTER TABLE pyramid_links RENAME COLUMN to_source_id      TO upper_source_id;
ALTER TABLE pyramid_links RENAME COLUMN to_division       TO upper_division;
ALTER TABLE pyramid_links ADD COLUMN IF NOT EXISTS promotes  boolean NOT NULL DEFAULT true;
ALTER TABLE pyramid_links ADD COLUMN IF NOT EXISTS relegates boolean NOT NULL DEFAULT true;

-- ── Zone kinds ─────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS pyramid_zone_kinds (
    code       text PRIMARY KEY,
    label      text NOT NULL,
    moves      text CHECK (moves IN ('up', 'down')),
    color      text NOT NULL,
    sort_order integer NOT NULL DEFAULT 0
);
INSERT INTO pyramid_zone_kinds (code, label, moves, color, sort_order) VALUES
    ('playoff',                'Playoff',                NULL,   '#22c55e', 10),
    ('promotion',              'Promotion',              'up',   '#16a34a', 20),
    ('promotion_playoff',      'Promotion playoff',      'up',   '#86efac', 30),
    ('relegation_playoff',     'Relegation playoff',     'down', '#f87171', 40),
    ('relegation',             'Relegation',             'down', '#dc2626', 50),
    ('conditional_relegation', 'Conditional relegation', 'down', '#b91c1c', 60)
ON CONFLICT (code) DO NOTHING;
INSERT INTO pyramid_zone_kinds (code, label, color, sort_order)
SELECT DISTINCT z.kind, z.label, '#94a3b8', 90 FROM pyramid_division_zones z
ON CONFLICT (code) DO NOTHING;
ALTER TABLE pyramid_division_zones
  ADD CONSTRAINT pyramid_division_zones_kind_fkey FOREIGN KEY (kind) REFERENCES pyramid_zone_kinds(code);

-- ── Where each zone's teams go ─────────────────────────────────────────
CREATE OR REPLACE VIEW pyramid_zone_moves AS
    -- Up: a table's up-zone goes up each of its links that promotes.
    SELECT z.division_id, z.kind, z.from_pos, z.to_pos, l.id AS link_id, 'up'::text AS direction,
           l.upper_competition_id AS to_competition_id, ud.id AS to_division_id
      FROM pyramid_division_zones z
      JOIN pyramid_zone_kinds k ON k.code = z.kind AND k.moves = 'up'
      JOIN pyramid_divisions d ON d.id = z.division_id AND d.removed_at IS NULL
      JOIN pyramid_links l ON l.promotes AND l.lower_source_id = d.source_id AND l.lower_division = d.name
      LEFT JOIN pyramid_divisions ud ON ud.removed_at IS NULL
                                    AND ud.source_id = l.upper_source_id AND ud.name = l.upper_division
     WHERE l.upper_competition_id IS NOT NULL OR ud.id IS NOT NULL
    UNION ALL
    -- Down: a table's down-zone goes down EVERY link that relegates from
    -- it — links into the table itself, or into its whole conference.
    SELECT z.division_id, z.kind, z.from_pos, z.to_pos, l.id, 'down',
           NULL::integer, ld.id
      FROM pyramid_division_zones z
      JOIN pyramid_zone_kinds k ON k.code = z.kind AND k.moves = 'down'
      JOIN pyramid_divisions d ON d.id = z.division_id AND d.removed_at IS NULL
      JOIN pyramid_links l ON l.relegates
                          AND ((l.upper_source_id = d.source_id AND l.upper_division = d.name)
                               OR l.upper_competition_id = d.competition_id)
      JOIN pyramid_divisions ld ON ld.removed_at IS NULL
                               AND ld.source_id = l.lower_source_id AND ld.name = l.lower_division;

-- ── Loader: a zone kind a feed introduces is recorded, not dropped ─────
CREATE OR REPLACE FUNCTION fh_pyramid_load(p_source_id integer, p_divisions jsonb) RETURNS integer
LANGUAGE plpgsql AS $$
DECLARE
  src     pyramid_sources%ROWTYPE;
  d       jsonb;
  t       jsonb;
  z       jsonb;
  v_comp  integer;
  v_div   integer;
  v_club  integer;
  v_key   text;
  v_cname text;
  v_explicit boolean;
  v_teams integer;
  v_seen  timestamptz := clock_timestamp();
BEGIN
  SELECT * INTO src FROM pyramid_sources WHERE id = p_source_id;
  IF NOT FOUND THEN RAISE EXCEPTION 'pyramid source % not found', p_source_id; END IF;

  IF src.season_prefix IS NOT NULL THEN
    SELECT coalesce(jsonb_agg(x || jsonb_build_object('name', btrim(substr(x->>'name', length(src.season_prefix) + 1)))), '[]'::jsonb)
      INTO p_divisions
      FROM jsonb_array_elements(coalesce(p_divisions, '[]'::jsonb)) x
     WHERE starts_with(x->>'name', src.season_prefix);
  END IF;

  SELECT count(*) INTO v_teams
    FROM jsonb_array_elements(coalesce(p_divisions, '[]'::jsonb)) x,
         jsonb_array_elements(coalesce(x->'teams', '[]'::jsonb)) y;
  IF v_teams = 0 THEN
    RAISE EXCEPTION 'pyramid source %: the read found no teams — previous tables kept', p_source_id;
  END IF;

  FOR d IN SELECT * FROM jsonb_array_elements(p_divisions) LOOP
    v_comp := NULL;
    SELECT fd.competition_id INTO v_comp
      FROM pyramid_feed_divisions fd
     WHERE fd.source_id = src.id AND fd.external_id = split_part(d->>'ext_id', ':', 1);
    v_comp := coalesce(v_comp, src.competition_id);

    INSERT INTO pyramid_divisions (source_id, competition_id, external_id, name, sort_order, counts, last_seen_at, removed_at)
    VALUES (src.id, v_comp, d->>'ext_id', d->>'name', coalesce((d->>'sort')::int, 0),
            NOT ((d->>'name') = ANY (src.uncounted_divisions)), v_seen, NULL)
    ON CONFLICT (source_id, external_id) DO UPDATE
       SET competition_id = EXCLUDED.competition_id, name = EXCLUDED.name,
           sort_order = EXCLUDED.sort_order, counts = EXCLUDED.counts,
           last_seen_at = v_seen, removed_at = NULL
    RETURNING id INTO v_div;

    DELETE FROM pyramid_division_zones WHERE division_id = v_div;
    FOR z IN SELECT * FROM jsonb_array_elements(coalesce(d->'zones', '[]'::jsonb)) LOOP
      CONTINUE WHEN nullif(z->>'kind', '') IS NULL;
      INSERT INTO pyramid_zone_kinds (code, label, color, sort_order)
      VALUES (z->>'kind', coalesce(nullif(z->>'label', ''), z->>'kind'), coalesce(nullif(z->>'color', ''), '#94a3b8'), 90)
      ON CONFLICT (code) DO NOTHING;
      INSERT INTO pyramid_division_zones (division_id, kind, from_pos, to_pos, label)
      VALUES (v_div, z->>'kind', (z->>'from')::int, (z->>'to')::int, coalesce(nullif(z->>'label', ''), z->>'kind'))
      ON CONFLICT DO NOTHING;
    END LOOP;

    FOR t IN SELECT * FROM jsonb_array_elements(coalesce(d->'teams', '[]'::jsonb)) LOOP
      v_explicit := nullif(btrim(t->>'club'), '') IS NOT NULL;
      v_cname := btrim(regexp_replace(coalesce(nullif(btrim(t->>'club'), ''), btrim(t->>'name')), '\s*\([^)]*\)', '', 'g'));
      v_key := fh_pyramid_name_key(v_cname);
      CONTINUE WHEN v_key IS NULL;
      INSERT INTO pyramid_clubs (name, name_key) VALUES (v_cname, v_key)
      ON CONFLICT (name_key) DO UPDATE SET name = EXCLUDED.name WHERE v_explicit;
      SELECT id INTO v_club FROM pyramid_clubs WHERE name_key = v_key;

      INSERT INTO pyramid_teams (division_id, external_id, name, pyramid_club_id, position,
                                 played, wins, draws, losses, goals_for, goals_against, points,
                                 last_seen_at, removed_at)
      VALUES (v_div, coalesce(nullif(t->>'ext_id', ''), btrim(t->>'name')), btrim(t->>'name'), v_club,
              (t->>'pos')::int,
              coalesce((t->>'gp')::int, 0), coalesce((t->>'w')::int, 0), coalesce((t->>'d')::int, 0),
              coalesce((t->>'l')::int, 0), coalesce((t->>'gf')::int, 0), coalesce((t->>'ga')::int, 0),
              coalesce((t->>'pts')::int, 0), v_seen, NULL)
      ON CONFLICT (division_id, external_id) DO UPDATE
         SET name = EXCLUDED.name, pyramid_club_id = EXCLUDED.pyramid_club_id,
             position = EXCLUDED.position, played = EXCLUDED.played, wins = EXCLUDED.wins,
             draws = EXCLUDED.draws, losses = EXCLUDED.losses, goals_for = EXCLUDED.goals_for,
             goals_against = EXCLUDED.goals_against, points = EXCLUDED.points,
             last_seen_at = v_seen, removed_at = NULL;
    END LOOP;
  END LOOP;

  UPDATE pyramid_teams pt SET removed_at = v_seen
    FROM pyramid_divisions pd
   WHERE pd.id = pt.division_id AND pd.source_id = src.id
     AND pt.removed_at IS NULL AND pt.last_seen_at < v_seen;
  UPDATE pyramid_divisions SET removed_at = v_seen
   WHERE source_id = src.id AND removed_at IS NULL AND last_seen_at < v_seen;

  UPDATE pyramid_clubs pc SET club_id = c.id
    FROM clubs c
   WHERE pc.club_id IS NULL AND fh_pyramid_name_key(c.name) = pc.name_key;
  UPDATE pyramid_clubs pc SET club_id = a.club_id
    FROM club_aliases a
   WHERE pc.club_id IS NULL AND fh_pyramid_name_key(a.alias) = pc.name_key;

  UPDATE pyramid_sources
     SET last_fetched_at = v_seen, last_ok_at = v_seen, last_fetch_ok = true, last_fetch_note = NULL
   WHERE id = src.id;
  RETURN v_teams;
END $$;

-- ── Copy: the arrow legend ─────────────────────────────────────────────
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'APSL pyramid', l, 'apsl_pyramid', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('arrow_up',   'APSL pyramid — legend: up arrowhead',   'promotion up', 46),
    ('arrow_down', 'APSL pyramid — legend: down arrowhead', 'relegation down', 47),
    ('moves_to',   'APSL pyramid — zone tooltip',           '{zone} → {targets}', 48)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'apsl_pyramid' AND m.tier = v.t);

-- ── Conference order ───────────────────────────────────────────────────
-- Owner 2026-10-29: "move mayflower over so delaware and metropolitan can
-- be next to each other" — North Jersey Liga 1 links into both.
UPDATE pyramid_competitions SET sort_order = 5
 WHERE kind = 'conference' AND name = 'Mayflower Conference';

-- ── Cosmo plays Division 2 in two groups (the feed's teams[].conference) ─
-- D2 Group A / B each promote into D1; D3 relegates into both groups.
WITH cosmo AS (
    SELECT s.id FROM pyramid_sources s JOIN pyramid_competitions c ON c.id = s.competition_id
     WHERE c.name = 'Cosmopolitan Soccer League')
DELETE FROM pyramid_links l USING cosmo
 WHERE l.lower_source_id = cosmo.id
   AND (l.lower_division = 'Division 2' OR l.upper_division = 'Division 2');
WITH cosmo AS (
    SELECT s.id FROM pyramid_sources s JOIN pyramid_competitions c ON c.id = s.competition_id
     WHERE c.name = 'Cosmopolitan Soccer League')
INSERT INTO pyramid_links (lower_source_id, lower_division, upper_source_id, upper_division)
SELECT cosmo.id, v.lower, cosmo.id, v.upper
  FROM cosmo, (VALUES ('Division 2 - Group A', 'Division 1'),
                      ('Division 2 - Group B', 'Division 1'),
                      ('Division 3',           'Division 2 - Group A'),
                      ('Division 3',           'Division 2 - Group B')) AS v(lower, upper)
ON CONFLICT DO NOTHING;
