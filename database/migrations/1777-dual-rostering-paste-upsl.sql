-- 1777 (2026-11-23): #dual-rostering — a roster by paste, for UPSL.
-- Owner: "upsl is what we really need" · "here is the div we need for sure
-- to compare to delaware river apsl" (premier.upsl.com, conference 225).
-- upsl.com shows every team's roster on its team page but answers every
-- automated reader with a Cloudflare challenge, so the server cannot read
-- it.  Instead: open the team page, copy it all, paste it on the page —
-- the page picks the names out, shows them to be fixed, and saves them as
-- that team's roster.  Pasting a team again replaces it.
--
-- roster_sheet_sources.system  'google_sheet' (read by RosterWatchSync) or
--                              'paste' (filled by hand; no workbook)
-- roster_sheet_teams.loaded_at when that team's roster came in

BEGIN;

ALTER TABLE roster_sheet_sources ADD COLUMN IF NOT EXISTS system text NOT NULL DEFAULT 'google_sheet'
    CHECK (system IN ('google_sheet', 'paste'));
ALTER TABLE roster_sheet_sources ALTER COLUMN workbook_id DROP NOT NULL;
ALTER TABLE roster_sheet_sources DROP CONSTRAINT IF EXISTS roster_sheet_sources_system_workbook;
ALTER TABLE roster_sheet_sources ADD CONSTRAINT roster_sheet_sources_system_workbook
    CHECK ((system = 'google_sheet') = (workbook_id IS NOT NULL));
ALTER TABLE roster_sheet_teams ADD COLUMN IF NOT EXISTS loaded_at timestamptz NOT NULL DEFAULT now();

INSERT INTO roster_sheet_sources (league_label, system, sort_order)
SELECT 'UPSL Premier', 'paste', 10
 WHERE NOT EXISTS (SELECT 1 FROM roster_sheet_sources WHERE league_label = 'UPSL Premier' AND system = 'paste');

-- One pasted team: its names in page order.  Replaces that team in that
-- source (same name, any case); no names = nothing changes.
CREATE OR REPLACE FUNCTION fh_roster_paste_load(p_source_id integer, p_team text, p_names jsonb) RETURNS integer
LANGUAGE plpgsql AS $$
DECLARE
  v_team text := regexp_replace(btrim(coalesce(p_team, '')), '\s+', ' ', 'g');
  v_id   integer;
  v_n    integer;
BEGIN
  IF v_team = '' OR p_names IS NULL OR jsonb_typeof(p_names) <> 'array' OR jsonb_array_length(p_names) = 0 THEN RETURN 0; END IF;
  IF NOT EXISTS (SELECT 1 FROM roster_sheet_sources WHERE id = p_source_id AND system = 'paste' AND is_active) THEN
    RAISE EXCEPTION 'source % does not take pasted rosters', p_source_id;
  END IF;
  DELETE FROM roster_sheet_teams WHERE source_id = p_source_id AND lower(name) = lower(v_team);
  INSERT INTO roster_sheet_teams (source_id, name, pyramid_club_id)
  VALUES (p_source_id, v_team,
          (SELECT c.id FROM (SELECT pc.id FROM pyramid_clubs pc WHERE pc.name_key = fh_pyramid_name_key(v_team)
                             UNION ALL
                             SELECT a.pyramid_club_id FROM pyramid_club_aliases a WHERE a.name_key = fh_pyramid_name_key(v_team)) c
            LIMIT 1))
  RETURNING id INTO v_id;
  INSERT INTO roster_sheet_players (team_id, sort, full_name)
  SELECT v_id, row_number() OVER (ORDER BY min(x.ord)), (array_agg(x.name ORDER BY x.ord))[1]
    FROM (SELECT regexp_replace(btrim(n.value), '\s+', ' ', 'g') AS name, n.ord
            FROM jsonb_array_elements_text(p_names) WITH ORDINALITY AS n(value, ord)) x
   WHERE x.name <> '' AND length(x.name) <= 80
   GROUP BY lower(x.name);
  GET DIAGNOSTICS v_n = ROW_COUNT;
  UPDATE roster_sheet_sources SET last_fetched_at = now(), last_fetch_ok = true, last_fetch_note = NULL WHERE id = p_source_id;
  RETURN v_n;
END $$;

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Dual rostering', l, 'roster_watch', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('paste_fold',    'Fold: add a roster by paste',              '➕ Add a roster by paste (UPSL)', 30),
    ('paste_how',     'Paste: how to',                            'Open the team''s page on the league site, press Ctrl+A then Ctrl+C, and paste it below. Check the names found, fix them, and save. Pasting a team again replaces its roster.', 31),
    ('paste_league',  'Paste: league field',                      'League', 32),
    ('paste_team',    'Paste: team field',                        'Team name', 33),
    ('paste_raw',     'Paste: the page text box',                 'Paste the team page here', 34),
    ('paste_names',   'Paste: names found ({n})',                 'Names found ({n}) — one per line, fix before saving', 35),
    ('paste_save',    'Paste: save button ({n})',                 'Save {n} players', 36),
    ('paste_saved',   'Paste: saved ({n}, {team})',               '✓ {n} players saved for {team}', 37),
    ('paste_teams',   'Paste: teams already in ({n})',            'Pasted so far ({n})', 38),
    ('paste_team_row','Paste: one team in ({team}, {n}, {when})', '{team} · {n} players · {when}', 39),
    ('paste_remove',  'Paste: remove a team',                     'Remove', 40)
  ) v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'roster_watch' AND m.tier = v.t);

UPDATE message_templates
   SET body = 'UPSL is not read by the server: upsl.com turns away every automated reader, so its rosters come in by paste (below). CASA Jersey has no roster workbook on the league site.'
 WHERE kind = 'roster_watch' AND tier = 'not_read';

INSERT INTO schema_migrations (filename) VALUES ('1777-dual-rostering-paste-upsl.sql') ON CONFLICT DO NOTHING;

COMMIT;
