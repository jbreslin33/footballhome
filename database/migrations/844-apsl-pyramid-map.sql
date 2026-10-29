-- 844 (2026-10-29) — #apsl-pyramid "USA map" view: where the clubs play.
--
-- Owner 2026-10-29: "ok next view usa map" (first ask: "the multi views to be
-- map form — you jump round the usa and it shows you the pyramid").
--
-- pyramid_clubs gains its home ground: the venue a league's feed names for
-- the club's home games (TeamPass locations, SportsEngine event addresses),
-- geocoded in the background (Nominatim, as the carpool does).  A league's
-- region gets a point too, so a club whose league publishes no addresses
-- (ADASL, LISFL, MIPSL) still lands on the map, at its league.
-- The loader records the first venue a club is given; geocoded_at set with
-- no lat = tried and missed (not asked again until the address changes).

ALTER TABLE pyramid_clubs ADD COLUMN IF NOT EXISTS venue_name    text;
ALTER TABLE pyramid_clubs ADD COLUMN IF NOT EXISTS venue_address text;
ALTER TABLE pyramid_clubs ADD COLUMN IF NOT EXISTS lat           numeric(10,7);
ALTER TABLE pyramid_clubs ADD COLUMN IF NOT EXISTS lon           numeric(10,7);
ALTER TABLE pyramid_clubs ADD COLUMN IF NOT EXISTS geocoded_at   timestamptz;
ALTER TABLE pyramid_clubs ADD COLUMN IF NOT EXISTS geocode_note  text;

ALTER TABLE pyramid_competitions ADD COLUMN IF NOT EXISTS lat          numeric(10,7);
ALTER TABLE pyramid_competitions ADD COLUMN IF NOT EXISTS lon          numeric(10,7);
ALTER TABLE pyramid_competitions ADD COLUMN IF NOT EXISTS geocoded_at  timestamptz;
ALTER TABLE pyramid_competitions ADD COLUMN IF NOT EXISTS geocode_note text;

-- Re-read every source so the new venue fields arrive.
UPDATE pyramid_sources SET last_fetched_at = NULL;

-- ── Copy ───────────────────────────────────────────────────────────────
UPDATE message_templates SET body = 'USA map' WHERE kind = 'apsl_pyramid' AND tier = 'view_map';
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'APSL pyramid', l, 'apsl_pyramid', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('map_hint',        'APSL pyramid — map: how to',            'Tap a conference to fly there and see its pyramid · tap a dot for the club', 100),
    ('map_pick',        'APSL pyramid — map: nothing picked',    'Tap a conference on the map (or its pill) to see its pyramid here', 101),
    ('map_attribution', 'APSL pyramid — map tiles credit',       '© OpenStreetMap contributors', 102),
    ('map_club',        'APSL pyramid — map: club popup',        '{club}', 103),
    ('map_at_league',   'APSL pyramid — map: no address',        'shown at its league — no home ground published', 104),
    ('map_located',     'APSL pyramid — map: located count',     '{located} of {clubs} clubs at their home ground', 105)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'apsl_pyramid' AND m.tier = v.t);

-- ── Loader: a team's venue is recorded on its club (first one given) ───
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
      INSERT INTO pyramid_zone_kinds (code, label, sort_order)
      VALUES (z->>'kind', coalesce(nullif(z->>'label', ''), z->>'kind'), 90)
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
      IF nullif(btrim(t->>'venue_address'), '') IS NOT NULL THEN
        UPDATE pyramid_clubs
           SET venue_name = nullif(btrim(t->>'venue_name'), ''), venue_address = btrim(t->>'venue_address'),
               lat = NULL, lon = NULL, geocoded_at = NULL, geocode_note = NULL
         WHERE id = v_club AND venue_address IS NULL;
      END IF;

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

