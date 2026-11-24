-- 1774 (2026-11-23): #dual-rostering — one name on two (or three) teams.
-- Owner: "we need vpn to scrape all apsl, casa (jersey etc) and the upsl and
-- college rosters lol. but def also upsl. i need you to have a page to
-- report dual or even tri rostering lol" → "maybe start with apsl, casa and
-- upsl".
--
-- Where the rosters come from:
--   APSL (+ CSL, ADASL)  every team's page on TeamPass, through the scraper
--                        VPN — pyramid_team_people (mig 856), until now only
--                        read when a club card opened; RosterWatchSync now
--                        sweeps every team.
--   CASA                 the league's public roster workbooks on Google
--                        Sheets (Captains & Coaches Corner): one row here
--                        per workbook → roster_sheet_teams / _players.
--                        Jersey has no workbook on the league site yet.
--   UPSL                 not read: upsl.com answers every automated reader
--                        (home line and VPN alike) with a Cloudflare
--                        challenge and publishes no roster list elsewhere.
--
-- roster_watch_entries = both kinds as one list (league, team, club, name,
-- name key, birth date where the league shows one).  The page groups it by
-- fh_name_key(name).  Same club = same FH club (pyramid_clubs.club_id), else
-- same pyramid club, else the same club name key.

BEGIN;

CREATE TABLE IF NOT EXISTS roster_watch_policy (
    id            integer PRIMARY KEY DEFAULT 1 CHECK (id = 1),
    stale_hours   integer NOT NULL DEFAULT 24 CHECK (stale_hours BETWEEN 1 AND 720),
    pause_ms      integer NOT NULL DEFAULT 800 CHECK (pause_ms BETWEEN 100 AND 60000),
    last_sweep_at timestamptz
);
COMMENT ON TABLE roster_watch_policy IS 'mig 1774: #dual-rostering — rosters are re-read when the last sweep is stale_hours old; pause_ms between two league-site requests';
INSERT INTO roster_watch_policy (id) VALUES (1) ON CONFLICT DO NOTHING;

CREATE TABLE IF NOT EXISTS roster_sheet_sources (
    id              serial PRIMARY KEY,
    league_label    text NOT NULL,
    workbook_id     text NOT NULL CHECK (workbook_id ~ '^[A-Za-z0-9_-]+$'),
    tab_name        text,
    is_active       boolean NOT NULL DEFAULT true,
    sort_order      integer NOT NULL DEFAULT 0,
    last_fetched_at timestamptz,
    last_fetch_ok   boolean,
    last_fetch_note text,
    created_at      timestamptz NOT NULL DEFAULT now(),
    UNIQUE (workbook_id, tab_name)
);
COMMENT ON TABLE roster_sheet_sources IS 'mig 1774: a league''s public roster workbook on Google Sheets. tab_name NULL = one tab per team (every tab is read); else the one tab that lists every team''s players';

CREATE TABLE IF NOT EXISTS roster_sheet_teams (
    id              serial PRIMARY KEY,
    source_id       integer NOT NULL REFERENCES roster_sheet_sources(id) ON DELETE CASCADE,
    name            text NOT NULL,
    division        text,
    pyramid_club_id integer REFERENCES pyramid_clubs(id) ON DELETE SET NULL
);
CREATE INDEX IF NOT EXISTS roster_sheet_teams_source_idx ON roster_sheet_teams (source_id);

CREATE TABLE IF NOT EXISTS roster_sheet_players (
    team_id   integer NOT NULL REFERENCES roster_sheet_teams(id) ON DELETE CASCADE,
    sort      integer NOT NULL,
    full_name text NOT NULL,
    dob       date,
    added_on  text,
    jersey    text,
    PRIMARY KEY (team_id, sort)
);

-- The workbooks the league site links today (2026-11-23).  11v11 only: the
-- small-sided, cup and over-30 workbooks are left out (a cup sheet repeats
-- the league one).
INSERT INTO roster_sheet_sources (league_label, workbook_id, tab_name, sort_order)
VALUES ('CASA Select Philadelphia · Liga 1', '1qGcNV7z-J9qabBTx_s8oYwrkPXaqqilC', NULL, 1),
       ('CASA Select Philadelphia · Liga 2', '1lKo5ibf0Q0GdjkVhy5gCQUkEGrbkvKAd', NULL, 2),
       ('CASA Select Lancaster · Liga 1',    '1MmvDYXP1je-eol7PMzdyaZ_ePrEu_YBT7CCn-DY43Ew', NULL, 3),
       ('CASA Philadelphia 11v11',           '1RsVdY6DpgMa3i2XpvXr3AWnYugEq53dK0KFpVkre0-w', 'Team Rosters - Fall 2026', 4),
       ('CASA Boston 11v11',                 '1u6bPCqc4CwEPulP1OtDBHAkYSMeg3_Qf2lQnIIAPoy8', 'Fall 2026', 5)
ON CONFLICT DO NOTHING;

-- The CASA sheets call our teams by other names.
INSERT INTO pyramid_club_aliases (name_key, pyramid_club_id, note)
SELECT v.k, c.id, 'mig 1774: the CASA roster sheet''s name'
  FROM (VALUES ('lighthouse boys club'), ('lighthouse old timers club')) v(k)
  JOIN pyramid_clubs c ON c.name = 'Lighthouse Mens Club 1893'
ON CONFLICT DO NOTHING;

-- …and five CASA Select teams by a shorter name than the league's feed does.
INSERT INTO pyramid_club_aliases (name_key, pyramid_club_id, note)
SELECT v.k, c.id, 'mig 1774: the CASA roster sheet''s name'
  FROM (VALUES ('nomads', 'nomads fc'), ('street soccer usa', 'street soccer usa philly'),
               ('coal region', 'coal region soccer club'), ('philadelphia heritage', 'phila heritage sc'),
               ('phoenix sc majors', 'phoenix scm')) v(k, club_key)
  JOIN pyramid_clubs c ON c.name_key = v.club_key
 WHERE NOT EXISTS (SELECT 1 FROM pyramid_clubs x WHERE x.name_key = v.k)
ON CONFLICT DO NOTHING;

-- '3/14/1998' → a date; anything else → NULL (a sheet is typed by hand).
CREATE OR REPLACE FUNCTION fh_try_date_mdy(p text) RETURNS date
LANGUAGE plpgsql IMMUTABLE AS $$
BEGIN
  IF p IS NULL OR btrim(p) !~ '^\d{1,2}/\d{1,2}/\d{4}$' THEN RETURN NULL; END IF;
  RETURN to_date(btrim(p), 'MM/DD/YYYY');
EXCEPTION WHEN others THEN RETURN NULL;
END $$;

-- One workbook's players, as RosterWatchSync read them:
--   [{team, division, first, last, dob, added, jersey}, …] in sheet order.
-- Replaces what the source had; an empty read keeps the old list.
CREATE OR REPLACE FUNCTION fh_roster_sheet_load(p_source_id integer, p_rows jsonb) RETURNS integer
LANGUAGE plpgsql AS $$
DECLARE
  v_n integer;
BEGIN
  IF p_rows IS NULL OR jsonb_typeof(p_rows) <> 'array' OR jsonb_array_length(p_rows) = 0 THEN RETURN 0; END IF;
  DELETE FROM roster_sheet_teams WHERE source_id = p_source_id;

  CREATE TEMP TABLE _rs ON COMMIT DROP AS
  SELECT o.ord,
         regexp_replace(btrim(x.team), '\s+', ' ', 'g') AS team,
         NULLIF(regexp_replace(btrim(coalesce(x.division, '')), '\s+', ' ', 'g'), '') AS division,
         regexp_replace(btrim(coalesce(x.first, '') || ' ' || coalesce(x.last, '')), '\s+', ' ', 'g') AS full_name,
         fh_try_date_mdy(x.dob) AS dob,
         NULLIF(btrim(coalesce(x.added, '')), '') AS added,
         NULLIF(btrim(coalesce(x.jersey, '')), '') AS jersey
    FROM jsonb_array_elements(p_rows) WITH ORDINALITY AS o(row, ord)
   CROSS JOIN LATERAL jsonb_to_record(o.row) AS x(team text, division text, first text, last text, dob text, added text, jersey text)
   WHERE btrim(coalesce(x.team, '')) <> '' AND btrim(coalesce(x.first, '') || coalesce(x.last, '')) <> '';

  INSERT INTO roster_sheet_teams (source_id, name, division, pyramid_club_id)
  SELECT p_source_id, g.name, g.division,
         (SELECT c.id FROM (SELECT pc.id FROM pyramid_clubs pc WHERE pc.name_key = fh_pyramid_name_key(g.name)
                            UNION ALL
                            SELECT a.pyramid_club_id FROM pyramid_club_aliases a WHERE a.name_key = fh_pyramid_name_key(g.name)) c
           LIMIT 1)
    FROM (SELECT (array_agg(team ORDER BY ord))[1] AS name, (array_agg(division ORDER BY ord))[1] AS division, min(ord) AS first_ord
            FROM _rs GROUP BY lower(team), lower(coalesce(division, ''))) g
   ORDER BY g.first_ord;

  INSERT INTO roster_sheet_players (team_id, sort, full_name, dob, added_on, jersey)
  SELECT t.id, row_number() OVER (PARTITION BY t.id ORDER BY r.ord), r.full_name, r.dob, r.added, r.jersey
    FROM _rs r
    JOIN roster_sheet_teams t ON t.source_id = p_source_id AND lower(t.name) = lower(r.team)
                             AND lower(coalesce(t.division, '')) = lower(coalesce(r.division, ''));
  GET DIAGNOSTICS v_n = ROW_COUNT;
  DROP TABLE _rs;
  RETURN v_n;
END $$;

-- Every rostered player we can read, one row per (team, player).
CREATE OR REPLACE VIEW roster_watch_entries AS
SELECT 'p' || t.id AS team_ref,
       CASE WHEN cm.kind = 'conference' THEN 'APSL · ' || cm.name ELSE coalesce(cm.short_name, cm.name) END AS league,
       t.name AS team, d.name AS division,
       coalesce('f' || pc.club_id, 'c' || pc.id) AS club_key, pc.name AS club,
       p.name AS full_name, fh_name_key(p.name) AS name_key,
       NULL::date AS dob, p.added_on, t.people_fetched_at AS read_at
  FROM pyramid_team_people p
  JOIN pyramid_teams t ON t.id = p.team_id AND t.removed_at IS NULL
  JOIN pyramid_divisions d ON d.id = t.division_id AND d.removed_at IS NULL
  JOIN pyramid_competitions cm ON cm.id = d.competition_id
  JOIN pyramid_clubs pc ON pc.id = t.pyramid_club_id
 WHERE p.kind = 'player'
UNION ALL
SELECT 's' || st.id, s.league_label, st.name, st.division,
       coalesce('f' || pc.club_id, 'c' || pc.id, 'n' || fh_pyramid_name_key(st.name)), coalesce(pc.name, st.name),
       sp.full_name, fh_name_key(sp.full_name), sp.dob, sp.added_on, s.last_fetched_at
  FROM roster_sheet_players sp
  JOIN roster_sheet_teams st ON st.id = sp.team_id
  JOIN roster_sheet_sources s ON s.id = st.source_id AND s.is_active
  LEFT JOIN pyramid_clubs pc ON pc.id = st.pyramid_club_id;

-- Menu: Leagues, after League Registration.
INSERT INTO menu_pages (code, group_code, label, icon, audience, sort_order, screens)
SELECT 'dual-rostering', 'leagues', 'Dual Rostering', '👯', 'admin',
       (SELECT coalesce(max(sort_order), 0) + 1 FROM menu_pages WHERE group_code = 'leagues'), '{dual-rostering}'
ON CONFLICT (code) DO NOTHING;

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Dual rostering', l, 'roster_watch', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('intro',        'Top line ({players}, {teams})',            '{players} rostered players on {teams} teams read from the leagues'' own sites. A name on two or more teams is listed below — a name match is a lead, not proof.', 1),
    ('pill_cross',   'Pill: different clubs',                    'Different clubs', 2),
    ('pill_same',    'Pill: same club',                          'Same club', 3),
    ('pill_tri',     'Pill: three or more teams',                '3+ teams', 4),
    ('pill_all',     'Pill: all',                                'All', 5),
    ('search',       'Search box placeholder',                   'Find a name, team or league', 6),
    ('chip_teams',   'Card chip: teams ({n})',                   '{n} teams', 7),
    ('chip_clubs',   'Card chip: clubs ({n})',                   '{n} clubs', 8),
    ('chip_same',    'Card chip: one club',                      'same club', 9),
    ('chip_dob_ok',  'Card chip: same birth date on two teams',  '✓ same birth date', 10),
    ('chip_dob_bad', 'Card chip: birth dates differ',            '⚠ different birth dates — likely two people', 11),
    ('row_dob',      'Roster row: birth date ({dob})',           'born {dob}', 12),
    ('row_added',    'Roster row: added ({added})',              'added {added}', 13),
    ('empty',        'Nothing to show',                          'No name is on two teams here.', 14),
    ('sources',      'Fold: where the rosters come from',        'Where the rosters come from', 15),
    ('src_ok',       'Source line ({teams}, {players}, {when})', '{teams} teams · {players} players · read {when}', 16),
    ('src_partial',  'Source line, pages missing ({read}, {teams}, {players}, {when})', '{read} of {teams} teams read · {players} players · oldest {when}', 17),
    ('src_never',    'Source line: not read yet',                'not read yet', 18),
    ('src_failed',   'Source line: last read failed ({note})',   '⚠ last read failed: {note}', 19),
    ('refresh',      'Button: read every roster again',          '🔄 Read every roster again', 20),
    ('reading',      'Progress: what is being read',             'rosters', 21),
    ('not_read',     'Leagues not read',                         'UPSL is not read: upsl.com turns away every automated reader and publishes no roster list elsewhere. CASA Jersey has no roster workbook on the league site.', 22)
  ) v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'roster_watch' AND m.tier = v.t);

INSERT INTO schema_migrations (filename) VALUES ('1774-dual-rostering-page.sql') ON CONFLICT DO NOTHING;

COMMIT;
