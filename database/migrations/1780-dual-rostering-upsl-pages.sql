-- 1780 (2026-11-23): #dual-rostering — UPSL team pages as saved files.
-- Owner: "we need upsl rosters … get them like we do for apsl" · "what
-- about wget" · "then parse it".  The server still cannot read upsl.com
-- (Cloudflare challenge), but a saved copy of a team page parses cleanly:
-- .single-team__roster-player blocks carry first<br>last, a position and
-- data-appearences; the header carries the team (h1) and its conference
-- (.page__header--conference).  The ➕ fold now takes saved pages as files,
-- many at once, and files each under its own team and conference.
--
-- roster_sheet_players.appearances  games played, where the league shows it
-- fh_roster_paste_load(source, team, division, players)
--     players = ["Name", …] or [{name, apps}, …]; division = the team's
--     conference on the league site (the third pill row)

BEGIN;

ALTER TABLE roster_sheet_players ADD COLUMN IF NOT EXISTS appearances integer CHECK (appearances >= 0);

DROP FUNCTION IF EXISTS fh_roster_paste_load(integer, text, jsonb);
CREATE OR REPLACE FUNCTION fh_roster_paste_load(p_source_id integer, p_team text, p_division text, p_players jsonb) RETURNS integer
LANGUAGE plpgsql AS $$
DECLARE
  v_team text := regexp_replace(btrim(coalesce(p_team, '')), '\s+', ' ', 'g');
  v_div  text := NULLIF(regexp_replace(btrim(coalesce(p_division, '')), '\s+', ' ', 'g'), '');
  v_id   integer;
  v_n    integer;
BEGIN
  IF v_team = '' OR p_players IS NULL OR jsonb_typeof(p_players) <> 'array' OR jsonb_array_length(p_players) = 0 THEN RETURN 0; END IF;
  IF NOT EXISTS (SELECT 1 FROM roster_sheet_sources WHERE id = p_source_id AND system = 'paste' AND is_active) THEN
    RAISE EXCEPTION 'source % does not take pasted rosters', p_source_id;
  END IF;
  DELETE FROM roster_sheet_teams WHERE source_id = p_source_id AND lower(name) = lower(v_team);
  INSERT INTO roster_sheet_teams (source_id, name, division, pyramid_club_id)
  VALUES (p_source_id, v_team, v_div,
          (SELECT c.id FROM (SELECT pc.id FROM pyramid_clubs pc WHERE pc.name_key = fh_pyramid_name_key(v_team)
                             UNION ALL
                             SELECT a.pyramid_club_id FROM pyramid_club_aliases a WHERE a.name_key = fh_pyramid_name_key(v_team)) c
            LIMIT 1))
  RETURNING id INTO v_id;
  INSERT INTO roster_sheet_players (team_id, sort, full_name, appearances)
  SELECT v_id, row_number() OVER (ORDER BY min(x.ord)), (array_agg(x.name ORDER BY x.ord))[1], max(x.apps)
    FROM (SELECT regexp_replace(btrim(CASE jsonb_typeof(e.value) WHEN 'object' THEN e.value->>'name' ELSE e.value #>> '{}' END), '\s+', ' ', 'g') AS name,
                 CASE WHEN jsonb_typeof(e.value) = 'object' AND (e.value->>'apps') ~ '^\d{1,4}$' THEN (e.value->>'apps')::int END AS apps,
                 e.ord
            FROM jsonb_array_elements(p_players) WITH ORDINALITY AS e(value, ord)) x
   WHERE x.name <> '' AND length(x.name) <= 80
   GROUP BY lower(x.name);
  GET DIAGNOSTICS v_n = ROW_COUNT;
  UPDATE roster_sheet_sources SET last_fetched_at = now(), last_fetch_ok = true, last_fetch_note = NULL WHERE id = p_source_id;
  RETURN v_n;
END $$;

CREATE OR REPLACE VIEW roster_watch_entries AS
SELECT 'p' || t.id AS team_ref,
       CASE WHEN cm.kind = 'conference' THEN 'APSL · ' || cm.name ELSE coalesce(cm.short_name, cm.name) END AS league,
       t.name AS team, d.name AS division,
       coalesce('f' || pc.club_id, 'c' || pc.id) AS club_key, pc.name AS club,
       p.name AS full_name, fh_name_key(p.name) AS name_key,
       NULL::date AS dob, p.added_on, t.people_fetched_at AS read_at,
       CASE WHEN cm.kind = 'conference' THEN coalesce(root.short_name, root.name) ELSE coalesce(cm.short_name, cm.name) END AS league_group,
       CASE WHEN cm.kind = 'conference' THEN coalesce(cm.short_name, cm.name) ELSE d.name END AS league_sub,
       CASE WHEN cm.kind = 'affiliate' THEN 10 + cm.id ELSE 0 END AS group_order,
       CASE WHEN cm.kind = 'conference' THEN cm.sort_order WHEN cm.kind = 'league' THEN 1000 + d.sort_order ELSE d.sort_order END AS sub_order,
       NULL::integer AS appearances
  FROM pyramid_team_people p
  JOIN pyramid_teams t ON t.id = p.team_id AND t.removed_at IS NULL
  JOIN pyramid_divisions d ON d.id = t.division_id AND d.removed_at IS NULL
  JOIN pyramid_competitions cm ON cm.id = d.competition_id
  LEFT JOIN pyramid_competitions root ON root.id = cm.parent_id
  JOIN pyramid_clubs pc ON pc.id = t.pyramid_club_id
 WHERE p.kind = 'player'
UNION ALL
SELECT 's' || st.id, s.league_label, st.name, st.division,
       coalesce('f' || pc.club_id, 'c' || pc.id, 'n' || fh_pyramid_name_key(st.name)), coalesce(pc.name, st.name),
       sp.full_name, fh_name_key(sp.full_name), sp.dob, sp.added_on, s.last_fetched_at,
       s.league_group, s.league_sub,
       1000 + (SELECT min(x.sort_order) FROM roster_sheet_sources x WHERE x.league_group = s.league_group), s.sort_order,
       sp.appearances
  FROM roster_sheet_players sp
  JOIN roster_sheet_teams st ON st.id = sp.team_id
  JOIN roster_sheet_sources s ON s.id = st.source_id AND s.is_active
  LEFT JOIN pyramid_clubs pc ON pc.id = st.pyramid_club_id;

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Dual rostering', l, 'roster_watch', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('files_label',  'Paste: saved pages as files',               'Saved team pages (pick as many as you like)', 60),
    ('files_done',   'Files: result ({teams}, {players})',        '✓ {teams} teams saved · {players} players', 61),
    ('files_bad',    'Files: pages with no roster ({names})',     '⚠ no roster found in: {names}', 62),
    ('files_or',     'Paste: or by hand',                         'Or one team by hand:', 63),
    ('row_apps',     'Roster row: appearances ({n})',             '{n} appearances', 64)
  ) v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'roster_watch' AND m.tier = v.t);

UPDATE message_templates
   SET body = 'UPSL team pages cannot be read by the server. On each team''s page press Ctrl+S and save it ("Webpage, HTML only"), then pick the saved files here — team, conference, players and appearances are read from each. Saving a team again replaces its roster.'
 WHERE kind = 'roster_watch' AND tier = 'paste_how';
UPDATE message_templates SET body = '➕ Add UPSL rosters' WHERE kind = 'roster_watch' AND tier = 'paste_fold';
UPDATE message_templates
   SET body = 'UPSL is not read by the server: upsl.com turns away every automated reader, so its rosters come in from saved team pages (the ➕ fold on top). CASA Jersey has no roster workbook on the league site.'
 WHERE kind = 'roster_watch' AND tier = 'not_read';

INSERT INTO schema_migrations (filename) VALUES ('1780-dual-rostering-upsl-pages.sql') ON CONFLICT DO NOTHING;

COMMIT;
