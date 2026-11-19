-- 1518 (2026-11-19) — League registrations: who filled the league's form.
--
-- Owner, sorting Liga 1 no-responses into a men's Practice Squad: "we
-- also need to know if they were previously on roster so that if we call
-- them back up the commish can just add them" → "its tecncially not that
-- they were on roster its that they filled from. if on roster they filled
-- form" → "basically this needs to be for any plyer right?" → "yes seed
-- registrations from the csv and build it".  And: "i don't want to have
-- to upload that again lol. from here on out we can use teams page sync".
--
-- A registration is a fact about the PERSON for a league season, not
-- about a team: it survives being dropped from the list (that is what
-- lets the commissioner just re-add him) and exists before he is ever
-- listed (6 APSL men filled the CASA form without being on the CASA list).
--
--   league_registrations     one row per person × league × season
--   official_roster_sources.league_id
--                            which league a list belongs to, so the pull
--                            can say "on the list ⇒ registered"
--   fh_league_registrations_import_casa_form(club_file_id)
--                            reads the CASA SportsEngine form export
--                            uploaded on #files (First Name, Last Name,
--                            Date of Birth, Registration Date, Account
--                            Email) and writes source = 'casa_form' rows.
--                            Re-runnable on a fresh upload; never needed
--                            for the list path.
--   fh_official_roster_reconcile (mig 1026) now also writes source =
--                            'official_list' rows for every matched man on
--                            a pull — the #teams load keeps it current.
--
-- Matching (one person only, else skipped): account email on
-- person_emails; else date of birth + first name, last name, or the FH
-- last name inside the form's ("Santa" in "Santa Castano").
-- Seeded from club_files 55 (casa_form_filled_by.csv, 431 rows, 11/19).
-- The names and emails stay in the DB (club_files); none are in this file.

BEGIN;

ALTER TABLE official_roster_sources
  ADD COLUMN IF NOT EXISTS league_id integer REFERENCES leagues(id);
COMMENT ON COLUMN official_roster_sources.league_id IS
  'mig 1518: the league this list belongs to. A man on the list is registered with it for the source''s season (league_registrations, source official_list).';
UPDATE official_roster_sources SET league_id = 2 WHERE league_label = 'CASA' AND league_id IS NULL;   -- CASA Select
UPDATE official_roster_sources SET league_id = 1 WHERE league_label LIKE 'APSL%' AND league_id IS NULL; -- APSL (+ Reserves)

CREATE TABLE IF NOT EXISTS league_registrations (
  person_id      integer NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
  league_id      integer NOT NULL REFERENCES leagues(id),
  season         text    NOT NULL,
  registered_at  timestamptz NOT NULL,
  source         text    NOT NULL CHECK (source IN ('casa_form', 'official_list')),
  club_file_id   integer REFERENCES club_files(id) ON DELETE SET NULL,
  created_at     timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (person_id, league_id, season)
);
COMMENT ON TABLE league_registrations IS
  'mig 1518: a person registered with a league for a season (filled its form). Survives a list drop — the commissioner can re-add him. source casa_form = the SportsEngine form export on #files (club_file_id); official_list = seen on the league''s list by a #teams pull (on the list ⇒ registered).';

-- ── The CASA form export ─────────────────────────────────────────────
CREATE OR REPLACE FUNCTION fh_league_registrations_import_casa_form(p_club_file_id integer)
RETURNS integer LANGUAGE plpgsql AS $$
DECLARE n integer;
BEGIN
  WITH raw AS (
    SELECT regexp_split_to_table(replace(convert_from(f.bytes, 'UTF8'), E'﻿', ''), E'\r?\n') AS l
      FROM club_files f WHERE f.id = p_club_file_id
  ), r AS (
    SELECT row_number() OVER () AS rn,
           regexp_match(l, '^([^,]*),([^,]*),([^,]*),"([^"]*)",(.*)$') AS m FROM raw
  ), c AS MATERIALIZED (
    SELECT rn, fh_name_key(m[1]) AS first_k, fh_name_key(m[2]) AS last_k,
           to_date(btrim(m[3]), 'MM/DD/YYYY') AS dob,
           to_timestamp(regexp_replace(m[4], '\s+[A-Z]{3}$', ''), 'MM/DD/YYYY, HH12:MIam')::timestamp
             AT TIME ZONE 'America/New_York' AS reg_at,
           lower(btrim(m[5])) AS email
      FROM r
     WHERE m IS NOT NULL AND m[3] ~ '^\s*\d{2}/\d{2}/\d{4}\s*$'
  ), cand AS (
    -- Two equality joins (hash / index), never an OR across all persons:
    -- the OR form ran minutes on 431 rows.
    -- DOB + a name (rank 1) beats an email (rank 2): an email can also sit
    -- on a blank duplicate row (Rosado, Hizdri on 11/19).
    SELECT c.rn, c.reg_at, pe.person_id, 2 AS rk
      FROM c JOIN person_emails pe ON lower(pe.email) = c.email
    UNION
    SELECT c.rn, c.reg_at, p.id, 1
      FROM c JOIN persons p ON p.birth_date = c.dob
     WHERE fh_name_key(p.first_name) = c.first_k
        OR fh_name_key(p.last_name) = c.last_k
        OR (length(fh_name_key(p.last_name)) >= 3
            AND position(fh_name_key(p.last_name) IN c.last_k) = 1)
  ), best AS (
    SELECT DISTINCT ON (rn, person_id) rn, reg_at, person_id, rk FROM cand ORDER BY rn, person_id, rk
  ), top AS (
    SELECT *, min(rk) OVER (PARTITION BY rn) AS top_rk FROM best
  ), hit AS (
    SELECT reg_at, person_id, count(*) OVER (PARTITION BY rn) AS hits FROM top WHERE rk = top_rk
  )
  INSERT INTO league_registrations (person_id, league_id, season, registered_at, source, club_file_id)
  SELECT person_id, 2, '2026/27', min(reg_at), 'casa_form', p_club_file_id
    FROM hit WHERE hits = 1
   GROUP BY person_id
  ON CONFLICT (person_id, league_id, season) DO UPDATE
     SET registered_at = LEAST(league_registrations.registered_at, EXCLUDED.registered_at),
         source = 'casa_form', club_file_id = EXCLUDED.club_file_id;
  GET DIAGNOSTICS n = ROW_COUNT;
  RETURN n;
END $$;
COMMENT ON FUNCTION fh_league_registrations_import_casa_form(integer) IS
  'mig 1518: CASA SportsEngine form export (a #files upload) → league_registrations for CASA Select 2026/27. Matches by account email, else DOB + a name; ambiguous rows skipped. Re-runnable; the form date wins over an official_list row.';

SELECT fh_league_registrations_import_casa_form(55);

-- ── The #teams pull: on the list ⇒ registered ────────────────────────
CREATE OR REPLACE FUNCTION public.fh_official_roster_reconcile(p_source integer)
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
DECLARE v_team integer; n integer := 0;
BEGIN
    SELECT team_id INTO v_team FROM official_roster_sources WHERE id = p_source;
    -- An empty list is a failed parse, never "the league dropped everyone".
    IF v_team IS NULL OR NOT EXISTS (SELECT 1 FROM official_roster_names WHERE source_id = p_source) THEN
        RETURN 0;
    END IF;

    UPDATE team_persons tp
       SET removed_at = now(), removed_reason = 'league_list_drop',
           removed_details = jsonb_build_object('source_id', p_source, 'mig', 1026)
      FROM official_roster_seen s
     WHERE s.source_id = p_source AND tp.person_id = s.person_id
       AND tp.team_id = v_team AND tp.removed_at IS NULL AND tp.call_in
       AND NOT EXISTS (SELECT 1 FROM official_roster_names n
                        WHERE n.source_id = p_source AND n.person_id = s.person_id);
    GET DIAGNOSTICS n = ROW_COUNT;

    DELETE FROM official_roster_seen s
     WHERE s.source_id = p_source
       AND NOT EXISTS (SELECT 1 FROM official_roster_names n
                        WHERE n.source_id = p_source AND n.person_id = s.person_id);
    INSERT INTO official_roster_seen (source_id, person_id)
    SELECT DISTINCT p_source, person_id FROM official_roster_names
     WHERE source_id = p_source AND person_id IS NOT NULL
    ON CONFLICT DO NOTHING;

    -- mig 1518: on the league's list ⇒ registered with it this season.
    -- A form row already there keeps its (earlier, real) date.
    INSERT INTO league_registrations (person_id, league_id, season, registered_at, source)
    SELECT DISTINCT n.person_id, s.league_id, s.season, now(), 'official_list'
      FROM official_roster_names n
      JOIN official_roster_sources s ON s.id = n.source_id
     WHERE n.source_id = p_source AND n.person_id IS NOT NULL AND s.league_id IS NOT NULL
    ON CONFLICT (person_id, league_id, season) DO NOTHING;

    -- On a list → sees the games unless sees says no: computed by the
    -- fh_event_invites view (mig 1450), nothing to sync.
    RETURN n;
END $function$;

-- Everyone on a list today, without waiting for the next pull.
INSERT INTO league_registrations (person_id, league_id, season, registered_at, source)
SELECT DISTINCT n.person_id, s.league_id, s.season, n.pulled_at, 'official_list'
  FROM official_roster_names n
  JOIN official_roster_sources s ON s.id = n.source_id
 WHERE n.person_id IS NOT NULL AND s.league_id IS NOT NULL AND s.is_active
ON CONFLICT (person_id, league_id, season) DO NOTHING;

COMMIT;
