-- 645 (2026-10-23) — CASA registration link on the Game Center card,
-- decided by the CASA list itself.
-- Owner: "we need additional link for CASA registration in liga 1 games
-- IF … we have already put 2 call downs in liga 1 20 man [and] the
-- player in question is not on casa roster as looked up … on screen
-- load".  Then: "only those set going … its actually for anyone not on
-- roster. its just that those who are on apsl would not need it if call
-- down has empty slot 1 or 2 … we need to make sure we show that it
-- failed."
--
-- 1. official_roster_names gets person_id — the league's spelling matched
--    to a person ONCE, in the DB, on every pull (trigger), so #teams and
--    Game Center never disagree about who is on the league's list.
--    official_roster_aliases is the human fix for a spelling the exact
--    match misses ("Joseph" on the sheet, "Joey" here); it survives the
--    wholesale replace every pull does.
-- 2. league_registration_forms.checks_league_list — for these leagues the
--    league's own list decides (CASA).  Off = the mig-638 behaviour:
--    roster status alone, rostered players only (APSL, for now).
-- 3. fh_event_registration_gaps: for a list-checked league every Going
--    player — rostered on the game's team OR invited to it — who is on
--    neither the league's list nor a status that counts as on roster.  An
--    APSL call-down is exempt while the call-down cap (team_invite_caps)
--    has a free squad spot, or when they already hold one of the spots.
-- 4. fh_event_league_list: the list's pull state for the game (last
--    try, ok/failed, the time of the names it is still using) so Game
--    Center can say loudly when the check ran on a stale list.

-- 1. Matching -----------------------------------------------------------

-- Comparable form of a name: case, accents, hyphens/dots, spacing and a
-- trailing generational suffix ("Morfoh II") ignored.
CREATE OR REPLACE FUNCTION fh_name_key(p_name TEXT) RETURNS TEXT
LANGUAGE sql IMMUTABLE AS $$
    SELECT regexp_replace(
             btrim(regexp_replace(
               translate(lower(COALESCE(p_name, '')),
                         'áàâäãåéèêëíìîïóòôöõúùûüñçý.-''’',
                         'aaaaaaeeeeiiiiooooouuuuncy    '),
               '\s+', ' ', 'g')),
           ' (jr|sr|ii|iii|iv)$', '')
$$;

CREATE TABLE IF NOT EXISTS official_roster_aliases (
    source_id  INT  NOT NULL REFERENCES official_roster_sources(id) ON DELETE CASCADE,
    name_key   TEXT NOT NULL,
    person_id  INT  NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
    note       TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (source_id, name_key)
);
COMMENT ON TABLE official_roster_aliases IS 'mig 645: a league-list spelling (fh_name_key of official_roster_names.full_name) that is this person — the fix when the exact match misses. Survives every pull.';

ALTER TABLE official_roster_names ADD COLUMN IF NOT EXISTS person_id  INT REFERENCES persons(id) ON DELETE SET NULL;
ALTER TABLE official_roster_names ADD COLUMN IF NOT EXISTS matched_by TEXT;
COMMENT ON COLUMN official_roster_names.person_id  IS 'mig 645: who this league-list name is — set by the fh_official_roster_names_match trigger; NULL = no single person matched.';
COMMENT ON COLUMN official_roster_names.matched_by IS 'mig 645: alias | team (exact, rostered on the source team) | club (exact, any active roster row) | person (exact, unique in persons).';
CREATE INDEX IF NOT EXISTS official_roster_names_person ON official_roster_names (person_id);

-- One person or none: an alias first, then an exact name among the
-- source team's roster, then any active roster row, then every person —
-- each tier only when exactly one person answers (two "Ali Kol"s match
-- nobody).  Per-team display names (team_person_names) count as names.
CREATE OR REPLACE FUNCTION fh_official_roster_names_match() RETURNS trigger
LANGUAGE plpgsql AS $$
DECLARE
    k      TEXT := fh_name_key(NEW.full_name);
    v_team INT;
    v_ids  INT[];
BEGIN
    NEW.person_id := NULL;
    NEW.matched_by := NULL;
    SELECT a.person_id INTO NEW.person_id FROM official_roster_aliases a
     WHERE a.source_id = NEW.source_id AND a.name_key = k;
    IF NEW.person_id IS NOT NULL THEN NEW.matched_by := 'alias'; RETURN NEW; END IF;

    SELECT team_id INTO v_team FROM official_roster_sources WHERE id = NEW.source_id;

    SELECT array_agg(DISTINCT tp.person_id) INTO v_ids
      FROM team_persons tp JOIN persons p ON p.id = tp.person_id
      LEFT JOIN team_person_names tpn ON tpn.team_id = tp.team_id AND tpn.person_id = tp.person_id
     WHERE tp.team_id = v_team AND tp.removed_at IS NULL
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

DROP TRIGGER IF EXISTS official_roster_names_match ON official_roster_names;
CREATE TRIGGER official_roster_names_match
    BEFORE INSERT OR UPDATE OF full_name, source_id ON official_roster_names
    FOR EACH ROW EXECUTE FUNCTION fh_official_roster_names_match();

-- An alias added or changed re-matches that spelling on the current list.
CREATE OR REPLACE FUNCTION fh_official_roster_aliases_rematch() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE official_roster_names n SET full_name = n.full_name
     WHERE n.source_id = COALESCE(NEW.source_id, OLD.source_id)
       AND fh_name_key(n.full_name) = COALESCE(NEW.name_key, OLD.name_key);
    RETURN NULL;
END $$;
DROP TRIGGER IF EXISTS official_roster_aliases_rematch ON official_roster_aliases;
CREATE TRIGGER official_roster_aliases_rematch
    AFTER INSERT OR UPDATE OR DELETE ON official_roster_aliases
    FOR EACH ROW EXECUTE FUNCTION fh_official_roster_aliases_rematch();

-- The one CASA spelling the exact match misses today among our players.
INSERT INTO official_roster_aliases (source_id, name_key, person_id, note)
SELECT s.id, fh_name_key('Joseph Benzing'), p.id, 'sheet says Joseph, we say Joey'
  FROM official_roster_sources s, persons p
 WHERE s.team_id = 120 AND s.system = 'google_sheet'
   AND p.first_name = 'Joey' AND p.last_name = 'Benzing'
ON CONFLICT (source_id, name_key) DO NOTHING;

-- Match the lists already pulled.
UPDATE official_roster_names SET full_name = full_name;

-- 2. Which leagues the list decides --------------------------------------

ALTER TABLE league_registration_forms ADD COLUMN IF NOT EXISTS checks_league_list BOOLEAN NOT NULL DEFAULT false;
COMMENT ON COLUMN league_registration_forms.checks_league_list IS 'mig 645: the league''s own list (official_roster_names of the game team''s source) decides who is on the roster, and Going invitees are checked too, with the call-down cap exemption. false = roster status of rostered players only (mig 638).';
UPDATE league_registration_forms SET checks_league_list = true WHERE league_label = 'CASA';

-- 3. The gaps -------------------------------------------------------------

DROP FUNCTION IF EXISTS fh_event_registration_gaps(BIGINT, INT);
CREATE FUNCTION fh_event_registration_gaps(p_fh_event_id BIGINT, p_club_id INT)
RETURNS TABLE (person_id INT, first_name TEXT, last_name TEXT, status_code TEXT, status_label TEXT,
               player_done BOOLEAN, phone TEXT, email TEXT, form_label TEXT, subject TEXT, body TEXT,
               reason TEXT)
LANGUAGE sql STABLE AS $$
    WITH ev AS (
        SELECT e.id, e.match_id, lrf.checks_league_list, m.label, m.subject, m.body
          FROM fh_events e
          JOIN league_registration_forms lrf ON lrf.league_label = e.league
          JOIN message_templates m ON m.id = lrf.message_template_id AND m.is_active
         WHERE e.id = p_fh_event_id
    ),
    -- The league's list for this game: the game team's online source.
    list AS (
        SELECT s.id FROM official_roster_sources s
          JOIN fh_event_teams fet ON fet.team_id = s.team_id AND fet.fh_event_id = p_fh_event_id
         WHERE s.is_active AND s.system <> 'club_file'
         ORDER BY s.id LIMIT 1
    ),
    -- Call-down caps on this game and how many squad spots they use (the
    -- same count as the 🎟 panel, migs 616/618).
    caps AS (
        SELECT c.from_team_id, c.max_per_event,
               (SELECT count(*) FROM ev
                  JOIN match_lineups ml ON ml.match_id = ev.match_id AND ml.zone IN ('starter', 'bench')
                  JOIN players pl ON pl.id = ml.player_id
                 WHERE EXISTS (SELECT 1 FROM team_persons tp WHERE tp.person_id = pl.person_id
                                  AND tp.team_id = c.from_team_id AND tp.removed_at IS NULL)
                   AND NOT EXISTS (SELECT 1 FROM team_persons tp2
                                     JOIN fh_event_teams f2 ON f2.team_id = tp2.team_id AND f2.fh_event_id = p_fh_event_id
                                    WHERE tp2.person_id = pl.person_id AND tp2.removed_at IS NULL)) AS used
          FROM team_invite_caps c
         WHERE EXISTS (SELECT 1 FROM fh_event_teams fet WHERE fet.fh_event_id = p_fh_event_id AND fet.team_id = c.to_team_id)
    ),
    going AS (
        SELECT p.*,
               EXISTS (SELECT 1 FROM fh_event_teams fet JOIN team_persons tp
                         ON tp.team_id = fet.team_id AND tp.person_id = p.id AND tp.removed_at IS NULL
                        WHERE fet.fh_event_id = p_fh_event_id) AS rostered,
               EXISTS (SELECT 1 FROM fh_event_invites i WHERE i.fh_event_id = p_fh_event_id
                          AND i.person_id = p.id AND i.revoked_at IS NULL) AS invited
          FROM fh_event_rsvps r JOIN persons p ON p.id = r.person_id
         WHERE r.fh_event_id = p_fh_event_id AND r.response = 'yes'
    ),
    judged AS (
        SELECT g.*, rs.code AS rs_code, rs.display_name AS rs_label, COALESCE(rs.player_done, false) AS rs_done,
               EXISTS (SELECT 1 FROM fh_event_teams fet JOIN team_persons tp
                         ON tp.team_id = fet.team_id AND tp.person_id = g.id AND tp.removed_at IS NULL
                       JOIN roster_statuses rs3 ON rs3.id = tp.roster_status_id AND rs3.counts_as_on_roster
                        WHERE fet.fh_event_id = p_fh_event_id) AS status_on,
               EXISTS (SELECT 1 FROM list JOIN official_roster_names n ON n.source_id = list.id
                        WHERE n.person_id = g.id) AS on_list,
               -- An APSL call-down: rostered on a capped from-team, not on the game's team.
               (SELECT c.max_per_event > c.used
                       OR EXISTS (SELECT 1 FROM ev JOIN match_lineups ml ON ml.match_id = ev.match_id
                                    AND ml.zone IN ('starter', 'bench')
                                  JOIN players pl ON pl.id = ml.player_id AND pl.person_id = g.id)
                  FROM caps c
                 WHERE NOT g.rostered
                   AND EXISTS (SELECT 1 FROM team_persons tp WHERE tp.person_id = g.id
                                  AND tp.team_id = c.from_team_id AND tp.removed_at IS NULL)
                 ORDER BY c.max_per_event > c.used DESC LIMIT 1) AS calldown_ok
          FROM going g
          LEFT JOIN LATERAL (
              SELECT rs2.* FROM fh_event_teams fet
                JOIN team_persons tp ON tp.team_id = fet.team_id AND tp.person_id = g.id AND tp.removed_at IS NULL
                LEFT JOIN roster_statuses rs2 ON rs2.id = tp.roster_status_id
               WHERE fet.fh_event_id = p_fh_event_id
               ORDER BY rs2.sort_order DESC NULLS LAST LIMIT 1) rs ON true
    )
    SELECT j.id, j.first_name::text, j.last_name::text, j.rs_code::text, j.rs_label::text, j.rs_done,
           (SELECT ph.phone_number FROM person_phones ph WHERE ph.person_id = j.id AND ph.can_receive_sms
             ORDER BY ph.is_primary DESC, ph.id LIMIT 1)::text,
           (SELECT em.email FROM person_emails em WHERE em.person_id = j.id
             ORDER BY em.is_primary DESC, em.id LIMIT 1)::text,
           ev.label::text, COALESCE(fh_fill_form_links(ev.subject, p_club_id), ''), fh_fill_form_links(ev.body, p_club_id),
           CASE WHEN j.calldown_ok IS NOT NULL THEN 'calldown_cap_full'
                WHEN ev.checks_league_list AND EXISTS (SELECT 1 FROM list) THEN 'not_on_list'
                ELSE 'not_on_roster' END
      FROM judged j CROSS JOIN ev
     WHERE NOT j.status_on
       AND CASE WHEN ev.checks_league_list
                THEN (j.rostered OR j.invited)
                     AND NOT j.on_list
                     AND COALESCE(NOT j.calldown_ok, true)
                ELSE j.rostered END
     ORDER BY j.rs_done, j.last_name, j.first_name
$$;

-- 4. The list's pull state for one game ------------------------------------

CREATE OR REPLACE FUNCTION fh_event_league_list(p_fh_event_id BIGINT)
RETURNS TABLE (source_id INT, team_id INT, league_label TEXT, system TEXT,
               last_fetched_at TIMESTAMPTZ, last_fetch_ok BOOLEAN, last_fetch_note TEXT,
               names_pulled_at TIMESTAMPTZ, names INT, matched INT)
LANGUAGE sql STABLE AS $$
    SELECT s.id, s.team_id, s.league_label, s.system, s.last_fetched_at, s.last_fetch_ok, s.last_fetch_note,
           (SELECT max(n.pulled_at) FROM official_roster_names n WHERE n.source_id = s.id),
           (SELECT count(*)::int FROM official_roster_names n WHERE n.source_id = s.id),
           (SELECT count(n.person_id)::int FROM official_roster_names n WHERE n.source_id = s.id)
      FROM fh_events e
      JOIN league_registration_forms lrf ON lrf.league_label = e.league AND lrf.checks_league_list
      JOIN fh_event_teams fet ON fet.fh_event_id = e.id
      JOIN official_roster_sources s ON s.team_id = fet.team_id AND s.is_active AND s.system <> 'club_file'
     WHERE e.id = p_fh_event_id
     ORDER BY s.id LIMIT 1
$$;

-- Copy for the reasons and the list's pull state (client_side, MessageCopy).
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Game Center', l, 'reg_gap', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('not_on_list',       'Game Center — not on the league''s own list ({league})',        'not on the {league} list', 894),
    ('calldown_cap_full', 'Game Center — call-down, both spots taken ({league})',          'call-down spots full — needs {league} registration', 895),
    ('list_pulling',      'Game Center — league list being checked ({league})',            '🟡 checking the {league} roster…', 896),
    ('list_ok',           'Game Center — league list checked ({league}, {time}, {n})',      '✓ {league} roster checked {time} · {n} names', 897),
    ('list_failed',       'Game Center — league list pull FAILED ({league}, {time}, {note})', '⚠ {league} roster pull FAILED — {note}. Using the list from {time}; this may be wrong.', 898),
    ('list_never',        'Game Center — league list never pulled ({league})',             '⚠ {league} roster never pulled — can''t check who is on it.', 899),
    ('card_stale',        'Game Center — card note when the league list failed',           'list check failed', 900)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'reg_gap' AND m.tier = v.t);
