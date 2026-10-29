-- 847 (2026-10-29) — #apsl-pyramid "Growth by season": the leagues' past
-- seasons, counted.
--
-- Owner 2026-10-29: "commit and continue" — the last greyed view pill.
-- The TeamPass feeds serve any past season (?season=<id>, listed in the
-- feed's standings.season_list: APSL back to 2022/23).  A past season can't
-- change, so it is read ONCE; the current one is re-counted on every read.
--
-- pyramid_seasons            one row per league source + season
-- pyramid_season_divisions   per table that season: its teams and its clubs
--                            (the feed's club ids — totals count DISTINCT
--                            clubs, never a sum), tied to a competition by
--                            the feed id (pyramid_feed_divisions) or, for an
--                            old id, by name ("Delaware River Conference (…)"
--                            → Delaware River); unmatched → the source's own
--                            competition (APSL's cups sit at the root).
-- fh_pyramid_season_load(source, season jsonb) is the one writer.

CREATE TABLE IF NOT EXISTS pyramid_seasons (
    id          serial PRIMARY KEY,
    source_id   integer NOT NULL REFERENCES pyramid_sources(id) ON DELETE CASCADE,
    external_id text NOT NULL,
    name        text NOT NULL,
    is_current  boolean NOT NULL DEFAULT false,
    games       integer NOT NULL DEFAULT 0,
    fetched_at  timestamptz NOT NULL DEFAULT now(),
    UNIQUE (source_id, external_id)
);

CREATE TABLE IF NOT EXISTS pyramid_season_divisions (
    season_id      integer NOT NULL REFERENCES pyramid_seasons(id) ON DELETE CASCADE,
    external_id    text NOT NULL,
    name           text NOT NULL,
    competition_id integer REFERENCES pyramid_competitions(id) ON DELETE SET NULL,
    teams          integer NOT NULL DEFAULT 0,
    club_keys      text[] NOT NULL DEFAULT '{}',
    PRIMARY KEY (season_id, external_id)
);

-- p_season: {ext_id, name, current, games,
--            divisions: [{ext_id, name, teams, clubs: ["<feed club id>", …]}]}
CREATE OR REPLACE FUNCTION fh_pyramid_season_load(p_source_id integer, p_season jsonb) RETURNS integer
LANGUAGE plpgsql AS $$
DECLARE
  src   pyramid_sources%ROWTYPE;
  v_id  integer;
  d     jsonb;
  v_comp integer;
BEGIN
  SELECT * INTO src FROM pyramid_sources WHERE id = p_source_id;
  IF NOT FOUND THEN RAISE EXCEPTION 'pyramid source % not found', p_source_id; END IF;
  IF jsonb_array_length(coalesce(p_season->'divisions', '[]'::jsonb)) = 0 THEN
    RAISE EXCEPTION 'pyramid source % season %: no tables read', p_source_id, p_season->>'name';
  END IF;

  IF coalesce((p_season->>'current')::boolean, false) THEN
    UPDATE pyramid_seasons SET is_current = false WHERE source_id = src.id AND external_id <> p_season->>'ext_id';
  END IF;
  INSERT INTO pyramid_seasons (source_id, external_id, name, is_current, games, fetched_at)
  VALUES (src.id, p_season->>'ext_id', p_season->>'name', coalesce((p_season->>'current')::boolean, false),
          coalesce((p_season->>'games')::int, 0), now())
  ON CONFLICT (source_id, external_id) DO UPDATE
     SET name = EXCLUDED.name, is_current = EXCLUDED.is_current, games = EXCLUDED.games, fetched_at = now()
  RETURNING id INTO v_id;

  DELETE FROM pyramid_season_divisions WHERE season_id = v_id;
  FOR d IN SELECT * FROM jsonb_array_elements(p_season->'divisions') LOOP
    v_comp := NULL;
    SELECT fd.competition_id INTO v_comp FROM pyramid_feed_divisions fd
     WHERE fd.source_id = src.id AND fd.external_id = d->>'ext_id';
    IF v_comp IS NULL THEN
      SELECT c.id INTO v_comp FROM pyramid_competitions c
       WHERE c.parent_id = src.competition_id AND c.kind = 'conference' AND c.short_name IS NOT NULL
         AND lower(d->>'name') LIKE lower(c.short_name) || '%'
       ORDER BY length(c.short_name) DESC LIMIT 1;
    END IF;
    INSERT INTO pyramid_season_divisions (season_id, external_id, name, competition_id, teams, club_keys)
    VALUES (v_id, d->>'ext_id', d->>'name', coalesce(v_comp, src.competition_id),
            coalesce((d->>'teams')::int, 0),
            coalesce(ARRAY(SELECT jsonb_array_elements_text(coalesce(d->'clubs', '[]'::jsonb))), '{}'));
  END LOOP;
  RETURN v_id;
END $$;

-- ── Copy ───────────────────────────────────────────────────────────────
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'APSL pyramid', l, 'apsl_pyramid', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('growth_teams',   'APSL pyramid — growth: teams chart',      '{league} teams by season, by conference', 130),
    ('growth_tip',     'APSL pyramid — growth: bar tooltip',      '{conference} · {season}: {teams} teams', 132),
    ('growth_table',   'APSL pyramid — growth: table heading',    'The numbers', 133),
    ('growth_season',  'APSL pyramid — growth: season column',    'Season', 134),
    ('growth_total',   'APSL pyramid — growth: total row/col',    'Total teams', 135),
    ('growth_clubs_h', 'APSL pyramid — growth: clubs column',     'Clubs', 136),
    ('growth_games',   'APSL pyramid — growth: games column',     'Games', 137),
    ('growth_other',   'APSL pyramid — growth: other leagues',    'Other leagues with past seasons', 138),
    ('growth_none',    'APSL pyramid — growth: nothing yet',      'No past seasons read yet — they load in the background on the next refresh', 139)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'apsl_pyramid' AND m.tier = v.t);
UPDATE message_templates SET body = 'Growth by season' WHERE kind = 'apsl_pyramid' AND tier = 'view_growth';

-- ── Conferences that no longer exist ───────────────────────────────────
-- The APSL's Northeast Conference (2022/23–2023/24, played Fall + Spring)
-- split into Mayflower (MA) and Constitution (CT) from 2024/25.  An
-- inactive conference row: past seasons tie to it by name; the live tree
-- (active rows only) never shows it.
INSERT INTO pyramid_competitions (parent_id, kind, tier, name, short_name, region, sort_order, is_active)
SELECT root.id, 'conference', 1, 'Northeast Conference', 'Northeast', 'Massachusetts & Connecticut — split into Mayflower + Constitution, 2024/25', 1, false
  FROM pyramid_competitions root WHERE root.slug = 'apsl'
ON CONFLICT (parent_id, name) DO NOTHING;
INSERT INTO pyramid_competition_states (competition_id, state_code)
SELECT c.id, v.st FROM pyramid_competitions c, (VALUES ('MA'), ('CT')) AS v(st)
 WHERE c.name = 'Northeast Conference'
ON CONFLICT DO NOTHING;
-- Seasons read before this row existed.
UPDATE pyramid_season_divisions sd SET competition_id = ne.id
  FROM pyramid_competitions ne, pyramid_seasons ps, pyramid_sources s
 WHERE ne.name = 'Northeast Conference' AND ps.id = sd.season_id AND s.id = ps.source_id
   AND s.competition_id = ne.parent_id AND sd.name ILIKE 'Northeast%';

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'APSL pyramid', 'APSL pyramid — growth: former conferences', 'apsl_pyramid', 'growth_former', NULL, 'Former conferences', 140, true, true, false
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'apsl_pyramid' AND m.tier = 'growth_former');
