-- 856 (2026-10-29) — #apsl-pyramid: the club card.
--
-- Owner 2026-10-29: "clubs need to be selectable on map or standings etc.
-- and hud should show info. rosters, home field etc … year established etc."
--
-- pyramid_clubs.founded     the year a club was established — no feed has
--                           it; set on the card (✏️), by hand
-- pyramid_clubs.logo_url    the club's crest as its league's feed shows it
-- pyramid_sources.team_page a team's page on the league's site, '{id}' =
--                           the team's feed id — TeamPass team pages carry
--                           the staff and the active roster
-- pyramid_team_people       a team's staff + roster as that page lists them
--                           (names, goals, assists, date added), read when
--                           its card opens, kept 24 h
--                           (pyramid_teams.people_fetched_at)

ALTER TABLE pyramid_clubs ADD COLUMN IF NOT EXISTS founded smallint CHECK (founded BETWEEN 1800 AND 2100);
ALTER TABLE pyramid_clubs ADD COLUMN IF NOT EXISTS logo_url text;
ALTER TABLE pyramid_sources ADD COLUMN IF NOT EXISTS team_page text;
ALTER TABLE pyramid_teams ADD COLUMN IF NOT EXISTS people_fetched_at timestamptz;

UPDATE pyramid_sources s SET team_page = v.page
  FROM pyramid_competitions c,
       (VALUES ('American Premier Soccer League',       'https://app.teampass.com/APSL/Team/{id}'),
               ('Cosmopolitan Soccer League',           'https://app.teampass.com/CSL/Team/{id}'),
               ('Atlanta District Adult Soccer League', 'https://app.teampass.com/adasl/Team/{id}')) AS v(name, page)
 WHERE c.id = s.competition_id AND c.name = v.name;

CREATE TABLE IF NOT EXISTS pyramid_team_people (
    team_id  integer NOT NULL REFERENCES pyramid_teams(id) ON DELETE CASCADE,
    kind     text NOT NULL CHECK (kind IN ('staff', 'player')),
    sort     integer NOT NULL,
    name     text NOT NULL,
    role     text,
    goals    integer,
    assists  integer,
    added_on text,
    PRIMARY KEY (team_id, kind, sort)
);

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'APSL pyramid', l, 'apsl_pyramid', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('card_est',         'APSL pyramid — club card: established',     'Est. {year}', 160),
    ('card_est_unknown', 'APSL pyramid — club card: year not set',    'Est. —', 161),
    ('card_est_edit',    'APSL pyramid — club card: set the year',    'Year established', 162),
    ('card_record',      'APSL pyramid — club card: a team''s place', '#{pos} · {w}-{d}-{l} · {pts} pts', 163),
    ('card_ground',      'APSL pyramid — club card: home ground',     'Home ground', 164),
    ('card_no_ground',   'APSL pyramid — club card: no ground',       'No home ground published', 165),
    ('card_staff',       'APSL pyramid — club card: staff',           'Staff', 166),
    ('card_roster',      'APSL pyramid — club card: roster',          'Roster ({n})', 167),
    ('card_roster_cols', 'APSL pyramid — club card: roster columns',  'Player G A', 168),
    ('card_no_roster',   'APSL pyramid — club card: no roster',       'The league doesn''t publish this roster', 169),
    ('card_read',        'APSL pyramid — club card: roster read at',  'from the league''s site, read {when}', 170),
    ('card_hint',        'APSL pyramid — team name tooltip',          'Open the club card', 171)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'apsl_pyramid' AND m.tier = v.t);

-- ── Loader: the club's crest from its league's feed ───────────────────
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
      INSERT INTO pyramid_clubs (name, name_key) VALUES (v_cname, v_key)
      ON CONFLICT (name_key) DO UPDATE SET name = EXCLUDED.name WHERE v_explicit;
      SELECT id INTO v_club FROM pyramid_clubs WHERE name_key = v_key;
      IF nullif(btrim(t->>'club_logo'), '') IS NOT NULL THEN
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
END $$;


-- The map's popup gave way to the card.
DELETE FROM message_templates WHERE kind = 'apsl_pyramid' AND tier = 'map_club';
