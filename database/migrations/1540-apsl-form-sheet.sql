-- 1540 (2026-11-19) — The APSL registration form sheet: 📎 docs uploaded.
--
-- Owner: "this file needs to be read on load of admin of teams page,
-- rosters page, game event pages. reason is it will tell us if a player
-- has filled it out. for isntance in mars case he is not on roster and
-- flagged for apsl so if we see him or another we flag their card with
-- label docs uploaded" → "then once on offical apsl roster we can take
-- down flag".
--
-- The club's own Google Form ("APSL-Registration", responses sheet: First
-- Name, Last Name, Head Shot, Driver Licence or Passport) is the APSL
-- paperwork.  The sheet is private: it is shared (Viewer) with the
-- footballhome-gcal service account and read through the Sheets API.
-- Only the timestamp and the two name columns are stored — never the
-- photo / ID links.
--
--   league_form_sheets       one row per league form sheet; spreadsheet_id
--                            loaded by psql, NOT in this file (public repo)
--   league_form_responses    the sheet's rows as last read, matched to a
--                            person by trigger (alias → the league list's
--                            aliases → the league's teams → any team →
--                            any one person)
--   league_form_aliases      fix a missed spelling: one row by migration
--   fh_league_form_load(sheet, jsonb)
--                            LeagueFormSync hands it the rows; replaces the
--                            sheet's responses and writes league_registrations
--                            source 'league_form' (the form date wins over an
--                            official_list row, like casa_form)
--
-- The card (PersonStanding, /api/payments/standing — #teams, Game Center,
-- Event Center, the ⋯ player sheet):
--   📎 APSL docs  filled the form, not on an APSL official list yet
--   ❌ APSL       on an APSL team (35 / 938), not on a list, no form
--   nothing       on an APSL official list (Active or Reserve) — flag down
-- league_registration_forms.missing_on_league_teams decides ❌ for players
-- on the league's own teams only (a Liga 1 man doesn't owe the APSL form;
-- CASA keeps its section-wide shows_missing).

BEGIN;

CREATE TABLE IF NOT EXISTS league_form_sheets (
  id               serial PRIMARY KEY,
  league_id        integer NOT NULL REFERENCES leagues(id),
  season           text    NOT NULL,
  label            text    NOT NULL,
  spreadsheet_id   text,                 -- loaded by psql, never committed
  sheet_title      text    NOT NULL,
  is_active        boolean NOT NULL DEFAULT true,
  last_fetched_at  timestamptz,          -- last successful read
  last_tried_at    timestamptz,
  last_fetch_ok    boolean,
  last_fetch_note  text,
  created_at       timestamptz NOT NULL DEFAULT now()
);
COMMENT ON TABLE league_form_sheets IS
  'mig 1540: a league''s registration form responses sheet (Google Sheets, shared with the footballhome-gcal service account). LeagueFormSync reads it on /api/payments/standing (every admin card load), at most every 5 min. spreadsheet_id is set by psql, not by migration.';

CREATE TABLE IF NOT EXISTS league_form_aliases (
  sheet_id   integer NOT NULL REFERENCES league_form_sheets(id) ON DELETE CASCADE,
  name_key   text    NOT NULL,          -- fh_name_key(first || ' ' || last)
  person_id  integer NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
  note       text,
  created_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (sheet_id, name_key)
);

CREATE TABLE IF NOT EXISTS league_form_responses (
  sheet_id      integer NOT NULL REFERENCES league_form_sheets(id) ON DELETE CASCADE,
  row_no        integer NOT NULL,
  submitted_at  timestamptz,
  first_name    text NOT NULL DEFAULT '',
  last_name     text NOT NULL DEFAULT '',
  person_id     integer REFERENCES persons(id) ON DELETE SET NULL,
  matched_by    text,
  read_at       timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (sheet_id, row_no)
);
CREATE INDEX IF NOT EXISTS league_form_responses_person ON league_form_responses (person_id);

CREATE OR REPLACE FUNCTION fh_league_form_responses_match()
RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE
  k        text := fh_name_key(btrim(NEW.first_name) || ' ' || btrim(NEW.last_name));
  v_league integer;
  v_ids    integer[];
BEGIN
  NEW.person_id := NULL;
  NEW.matched_by := NULL;
  IF k = '' THEN RETURN NEW; END IF;
  SELECT league_id INTO v_league FROM league_form_sheets WHERE id = NEW.sheet_id;

  SELECT a.person_id INTO NEW.person_id FROM league_form_aliases a
   WHERE a.sheet_id = NEW.sheet_id AND a.name_key = k;
  IF NEW.person_id IS NOT NULL THEN NEW.matched_by := 'alias'; RETURN NEW; END IF;

  -- The league list's own spellings (official_roster_aliases).
  SELECT array_agg(DISTINCT a.person_id) INTO v_ids
    FROM official_roster_aliases a JOIN official_roster_sources s ON s.id = a.source_id
   WHERE s.league_id = v_league AND a.name_key = k;
  IF cardinality(v_ids) = 1 THEN NEW.person_id := v_ids[1]; NEW.matched_by := 'list_alias'; RETURN NEW; END IF;

  -- The league's teams, by FH name or per-team display name.
  SELECT array_agg(DISTINCT tp.person_id) INTO v_ids
    FROM official_roster_sources s
    JOIN team_persons tp ON tp.team_id = s.team_id AND tp.removed_at IS NULL
    JOIN persons p ON p.id = tp.person_id
    LEFT JOIN team_person_names tpn ON tpn.team_id = tp.team_id AND tpn.person_id = tp.person_id
   WHERE s.league_id = v_league AND s.is_active
     AND k IN (fh_name_key(p.first_name || ' ' || p.last_name),
               fh_name_key(COALESCE(tpn.first_name, p.first_name) || ' ' || COALESCE(tpn.last_name, p.last_name)));
  IF cardinality(v_ids) = 1 THEN NEW.person_id := v_ids[1]; NEW.matched_by := 'team'; RETURN NEW; END IF;

  SELECT array_agg(DISTINCT tp.person_id) INTO v_ids
    FROM team_persons tp JOIN persons p ON p.id = tp.person_id
   WHERE tp.removed_at IS NULL AND k = fh_name_key(p.first_name || ' ' || p.last_name);
  IF cardinality(v_ids) = 1 THEN NEW.person_id := v_ids[1]; NEW.matched_by := 'club'; RETURN NEW; END IF;

  SELECT array_agg(p.id) INTO v_ids FROM persons p
   WHERE k = fh_name_key(p.first_name || ' ' || p.last_name);
  IF cardinality(v_ids) = 1 THEN NEW.person_id := v_ids[1]; NEW.matched_by := 'person'; END IF;
  RETURN NEW;
END $$;

DROP TRIGGER IF EXISTS league_form_responses_match ON league_form_responses;
CREATE TRIGGER league_form_responses_match
  BEFORE INSERT OR UPDATE OF first_name, last_name, sheet_id ON league_form_responses
  FOR EACH ROW EXECUTE FUNCTION fh_league_form_responses_match();

-- ── Registrations ───────────────────────────────────────────────────
ALTER TABLE league_registrations DROP CONSTRAINT IF EXISTS league_registrations_source_check;
ALTER TABLE league_registrations ADD CONSTRAINT league_registrations_source_check
  CHECK (source IN ('casa_form', 'official_list', 'league_form'));
ALTER TABLE league_registrations
  ADD COLUMN IF NOT EXISTS league_form_sheet_id integer REFERENCES league_form_sheets(id) ON DELETE SET NULL;

CREATE OR REPLACE FUNCTION fh_league_form_apply(p_sheet integer)
RETURNS integer LANGUAGE plpgsql AS $$
DECLARE n integer;
BEGIN
  INSERT INTO league_registrations (person_id, league_id, season, registered_at, source, league_form_sheet_id)
  SELECT r.person_id, s.league_id, s.season, min(COALESCE(r.submitted_at, r.read_at)), 'league_form', s.id
    FROM league_form_responses r JOIN league_form_sheets s ON s.id = r.sheet_id
   WHERE r.sheet_id = p_sheet AND r.person_id IS NOT NULL
   GROUP BY r.person_id, s.league_id, s.season, s.id
  ON CONFLICT (person_id, league_id, season) DO UPDATE
     SET registered_at = LEAST(league_registrations.registered_at, EXCLUDED.registered_at),
         source = 'league_form', league_form_sheet_id = EXCLUDED.league_form_sheet_id
   WHERE league_registrations.source <> 'casa_form';
  GET DIAGNOSTICS n = ROW_COUNT;
  RETURN n;
END $$;

-- p_rows = [{"row":2,"at":"2026-09-01T20:47:50","first":"…","last":"…"}, …]
-- ("at" = the sheet's local time, America/New_York).  An empty array is a
-- failed parse, never "everyone withdrew": the old rows stay.
CREATE OR REPLACE FUNCTION fh_league_form_load(p_sheet integer, p_rows jsonb)
RETURNS integer LANGUAGE plpgsql AS $$
DECLARE n integer;
BEGIN
  IF p_rows IS NULL OR jsonb_array_length(p_rows) = 0 THEN RETURN 0; END IF;
  DELETE FROM league_form_responses WHERE sheet_id = p_sheet;
  INSERT INTO league_form_responses (sheet_id, row_no, submitted_at, first_name, last_name)
  SELECT p_sheet, (e->>'row')::int,
         CASE WHEN COALESCE(e->>'at', '') = '' THEN NULL
              ELSE (e->>'at')::timestamp AT TIME ZONE 'America/New_York' END,
         btrim(COALESCE(e->>'first', '')), btrim(COALESCE(e->>'last', ''))
    FROM jsonb_array_elements(p_rows) e
   WHERE btrim(COALESCE(e->>'first', '') || COALESCE(e->>'last', '')) <> '';
  GET DIAGNOSTICS n = ROW_COUNT;
  PERFORM fh_league_form_apply(p_sheet);
  RETURN n;
END $$;

CREATE OR REPLACE FUNCTION fh_league_form_aliases_rematch()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  UPDATE league_form_responses SET first_name = first_name
   WHERE sheet_id = COALESCE(NEW.sheet_id, OLD.sheet_id);
  PERFORM fh_league_form_apply(COALESCE(NEW.sheet_id, OLD.sheet_id));
  RETURN NULL;
END $$;
DROP TRIGGER IF EXISTS league_form_aliases_rematch ON league_form_aliases;
CREATE TRIGGER league_form_aliases_rematch
  AFTER INSERT OR UPDATE OR DELETE ON league_form_aliases
  FOR EACH ROW EXECUTE FUNCTION fh_league_form_aliases_rematch();

-- ── ❌ for the league's own teams only ───────────────────────────────
ALTER TABLE league_registration_forms
  ADD COLUMN IF NOT EXISTS missing_on_league_teams boolean NOT NULL DEFAULT false;
COMMENT ON COLUMN league_registration_forms.missing_on_league_teams IS
  'mig 1540: true = a player on one of this league''s own teams (official_roster_sources.team_id) who is on none of its lists and has no registration shows ❌ <league>. Narrower than shows_missing (whole section).';
UPDATE league_registration_forms SET missing_on_league_teams = true WHERE league_label = 'APSL';

INSERT INTO league_form_sheets (league_id, season, label, sheet_title)
SELECT 1, '2026/27', 'APSL-Registration (Responses)', 'Form Responses 1'
 WHERE NOT EXISTS (SELECT 1 FROM league_form_sheets WHERE league_id = 1 AND season = '2026/27');

-- ── Words ───────────────────────────────────────────────────────────
INSERT INTO message_templates (category, label, kind, tier, body, sort_order, client_side)
SELECT 'Person standing', v.label, 'person_standing', v.tier, v.body, v.ord, true
  FROM (VALUES
    ('docs_in',          'Card: filled the league form, not on its list yet ({league}, {date})',
     '📎 {league} docs uploaded[[ {date}]]', 61),
    ('docs_in_tip',      'Card: filled the league form — hover',
     'Filled the {league} registration form[[ on {date}]] (head shot + ID). Not on the {league} official roster yet — the flag comes down when the list has them.', 62),
    ('docs_missing',     'Card: on a league team, not on its list, no form ({league})',
     '❌ {league} docs', 63),
    ('docs_missing_tip', 'Card: no league form — hover',
     'On a {league} team but not on the official roster, and the {league} registration form (head shot + ID) has no row for them.', 64),
    ('box_docs_in',      'Team card box: filled the league form, not listed ({league})',
     '📎{league}', 65),
    ('docs_stale',       'Card: the league form sheet could not be read — appended',
     ' ⚠', 66),
    ('docs_stale_tip',   'Card: the league form sheet could not be read — hover',
     'Couldn''t read the {league} form sheet[[ — showing it as of {date}]].', 67)
  ) AS v(tier, label, body, ord)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'person_standing' AND m.tier = v.tier);

COMMIT;
