-- 1259 (2026-11-11) — #apsl-pyramid: one club under several names.
--
-- Owner 2026-11-11: "central jersey united in casa is real central nj in
-- apsl reserves".  The pyramid makes a club per team NAME (fh_pyramid_name_key),
-- so Real Central NJ Soccer (APSL Delaware River), "Real Central NJ II" (CASA
-- Central Jersey Liga 2) and "Central Jersey United" (CASA Central Jersey
-- Liga 1) were three clubs.  pyramid_club_aliases maps an outside name to
-- the real club; fh_pyramid_load() checks it before making a club, and an
-- alias never renames or re-crests the club.  Add a row when another club
-- turns out to play under another name somewhere (normalize on FH, not the
-- sources).

CREATE TABLE IF NOT EXISTS pyramid_club_aliases (
    name_key        text PRIMARY KEY,            -- fh_pyramid_name_key() of the outside name
    pyramid_club_id integer NOT NULL REFERENCES pyramid_clubs(id) ON DELETE CASCADE,
    note            text
);
COMMENT ON TABLE pyramid_club_aliases IS
    'mig 1259: a club''s team under another name in another league → the real pyramid club (read by fh_pyramid_load).';

INSERT INTO pyramid_club_aliases (name_key, pyramid_club_id, note)
SELECT v.k, c.id, v.note
  FROM (VALUES
    (fh_pyramid_name_key('Central Jersey United'), 'Real Central NJ reserves in CASA Central Jersey Liga 1 (owner 2026-11-11)'),
    (fh_pyramid_name_key('Real Central NJ II'),    'Real Central NJ''s second side in CASA Central Jersey Liga 2')
  ) AS v(k, note)
  JOIN pyramid_clubs c ON c.name_key = fh_pyramid_name_key('Real Central NJ Soccer')
ON CONFLICT (name_key) DO UPDATE SET pyramid_club_id = EXCLUDED.pyramid_club_id, note = EXCLUDED.note;

-- Their teams join the club now; the duplicate clubs go once empty.
UPDATE pyramid_teams t SET pyramid_club_id = a.pyramid_club_id
  FROM pyramid_clubs c JOIN pyramid_club_aliases a ON a.name_key = c.name_key
 WHERE t.pyramid_club_id = c.id AND c.id <> a.pyramid_club_id;
DELETE FROM pyramid_clubs c
 USING pyramid_club_aliases a
 WHERE a.name_key = c.name_key AND c.id <> a.pyramid_club_id
   AND NOT EXISTS (SELECT 1 FROM pyramid_teams t WHERE t.pyramid_club_id = c.id);

CREATE OR REPLACE FUNCTION public.fh_pyramid_load(p_source_id integer, p_divisions jsonb)
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
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
  v_venue integer;
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
      -- A known alias (mig 1259: a club's side under another name in
      -- another league, e.g. Real Central NJ's reserves = CASA's "Central
      -- Jersey United") joins the real club and never renames / re-crests it.
      v_club := NULL;
      SELECT a.pyramid_club_id INTO v_club FROM pyramid_club_aliases a WHERE a.name_key = v_key;
      IF v_club IS NULL THEN
        INSERT INTO pyramid_clubs (name, name_key) VALUES (v_cname, v_key)
        ON CONFLICT (name_key) DO UPDATE SET name = EXCLUDED.name WHERE v_explicit;
        SELECT id INTO v_club FROM pyramid_clubs WHERE name_key = v_key;
      END IF;
      IF nullif(btrim(t->>'club_logo'), '') IS NOT NULL
         AND NOT EXISTS (SELECT 1 FROM pyramid_club_aliases a WHERE a.name_key = v_key) THEN
        UPDATE pyramid_clubs SET logo_url = btrim(t->>'club_logo')
         WHERE id = v_club AND logo_url IS DISTINCT FROM btrim(t->>'club_logo');
      END IF;
      v_venue := NULL;
      IF nullif(btrim(t->>'venue_address'), '') IS NOT NULL THEN
        INSERT INTO pyramid_venues (address, name) VALUES (btrim(t->>'venue_address'), nullif(btrim(t->>'venue_name'), ''))
        ON CONFLICT (address) DO UPDATE SET name = coalesce(EXCLUDED.name, pyramid_venues.name)
        RETURNING id INTO v_venue;
      END IF;

      INSERT INTO pyramid_teams (division_id, external_id, name, pyramid_club_id, position,
                                 played, wins, draws, losses, goals_for, goals_against, points,
                                 last_seen_at, removed_at, venue_id)
      VALUES (v_div, coalesce(nullif(t->>'ext_id', ''), btrim(t->>'name')), btrim(t->>'name'), v_club,
              (t->>'pos')::int,
              coalesce((t->>'gp')::int, 0), coalesce((t->>'w')::int, 0), coalesce((t->>'d')::int, 0),
              coalesce((t->>'l')::int, 0), coalesce((t->>'gf')::int, 0), coalesce((t->>'ga')::int, 0),
              coalesce((t->>'pts')::int, 0), v_seen, NULL, v_venue)
      ON CONFLICT (division_id, external_id) DO UPDATE
         SET name = EXCLUDED.name, pyramid_club_id = EXCLUDED.pyramid_club_id,
             position = EXCLUDED.position, played = EXCLUDED.played, wins = EXCLUDED.wins,
             draws = EXCLUDED.draws, losses = EXCLUDED.losses, goals_for = EXCLUDED.goals_for,
             goals_against = EXCLUDED.goals_against, points = EXCLUDED.points,
             last_seen_at = v_seen, removed_at = NULL,
             venue_id = coalesce(EXCLUDED.venue_id, pyramid_teams.venue_id);
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
END $function$;
