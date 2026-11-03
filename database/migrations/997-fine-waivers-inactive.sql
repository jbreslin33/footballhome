-- 997 (2026-11-03) — Fine waivers: inactive players start fresh.
-- Owner: "if a player is in inactive then leave them out of ranking and set
-- their fines to 0 as an adjustment as that can be reversed as we will only
-- bill them usual 35 a month" → "yes build the waiver table. we would be
-- able to waive them when coming back and start fresh".
--
-- Before this, an inactive player owed nothing only because 💤 Inactive
-- needs invite_only and fh_person_fines skips invite-only spots (mig 619).
-- That came undone when he came back: invite_only off → every fine since he
-- joined came back with him.  A waiver is the stored adjustment that stays:
--
--   fine_waivers     one row per stretch: person, waived_from, waived_until
--                    (NULL = still inactive), reason.  Fines on events
--                    inside the stretch are $0.  Reverse one by setting
--                    reversed_at (by migration) — the fines come back.
--   opened           when a player goes 💤 Inactive on any live team row
--                    and has no open waiver.  waived_from = the first day of
--                    the earliest month not yet billed: last month before
--                    this month's first Friday (its fines post then), else
--                    this month.  So the fines he ran up in the month he
--                    stopped coming are waived too.
--   closed           when he is no longer inactive on any live team row
--                    (moved back on #teams, or his own yes RSVP, mig 945):
--                    waived_until = now().  He starts fresh from there.
--
-- fh_person_fines keeps its signature and every caller (#fines, #payments
-- boxes, #my fines, the RSVP reminder's {fines}); the judging body moves to
-- fh_person_fines_all and the wrapper drops waived events.
-- fh_person_waived_fines lists what a waiver took off, for #fines.
-- A later migration that text-patches the judging body must patch
-- fh_person_fines_all now.

CREATE TABLE IF NOT EXISTS fine_waivers (
    id              SERIAL PRIMARY KEY,
    person_id       INT NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
    waived_from     TIMESTAMPTZ NOT NULL,
    waived_until    TIMESTAMPTZ,
    reason          TEXT NOT NULL DEFAULT 'inactive',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    reversed_at     TIMESTAMPTZ,
    reversed_reason TEXT,
    CHECK (waived_until IS NULL OR waived_until > waived_from)
);
CREATE UNIQUE INDEX IF NOT EXISTS fine_waivers_one_open
    ON fine_waivers (person_id) WHERE waived_until IS NULL AND reversed_at IS NULL;
COMMENT ON TABLE fine_waivers IS
    'mig 997: fines on events in [waived_from, waived_until) are $0. Opened when a player goes 💤 Inactive, closed when he is back (start fresh). Reverse by setting reversed_at, never DELETE.';

-- The first day (club time) of the earliest month whose fines are not on
-- LeagueApps yet: a month''s fines post with the next month''s dues on its
-- first Friday (mig 460/535).
CREATE OR REPLACE FUNCTION fh_fine_unbilled_since(p_at timestamptz DEFAULT now()) RETURNS timestamptz
LANGUAGE sql STABLE AS $$
    SELECT (CASE WHEN (p_at AT TIME ZONE 'America/New_York')::date < first_friday_of_month(p_at)
                 THEN date_trunc('month', (p_at AT TIME ZONE 'America/New_York')::date) - interval '1 month'
                 ELSE date_trunc('month', (p_at AT TIME ZONE 'America/New_York')::date)
            END)::timestamp AT TIME ZONE 'America/New_York'
$$;

CREATE OR REPLACE FUNCTION fh_fine_waived_at(p_person int, p_at timestamptz) RETURNS int
LANGUAGE sql STABLE AS $$
    SELECT w.id FROM fine_waivers w
     WHERE w.person_id = p_person AND w.reversed_at IS NULL
       AND w.waived_from <= p_at AND (w.waived_until IS NULL OR w.waived_until > p_at)
     ORDER BY w.waived_from LIMIT 1
$$;
COMMENT ON FUNCTION fh_fine_waived_at(int, timestamptz) IS 'mig 997: the fine_waivers row covering this moment for this person, or NULL.';

-- Open or close a person''s waiver to match his team rows.
CREATE OR REPLACE FUNCTION fh_fine_waivers_sync(p_person int) RETURNS void
LANGUAGE plpgsql AS $$
DECLARE inactive boolean;
BEGIN
    SELECT EXISTS (SELECT 1 FROM team_persons tp
                     JOIN squad_statuses ss ON ss.id = tp.squad_status_id AND ss.code = 'inactive'
                    WHERE tp.person_id = p_person AND tp.removed_at IS NULL)
      INTO inactive;
    IF inactive THEN
        INSERT INTO fine_waivers (person_id, waived_from, reason)
        SELECT p_person, fh_fine_unbilled_since(now()), 'inactive'
         WHERE NOT EXISTS (SELECT 1 FROM fine_waivers w
                            WHERE w.person_id = p_person AND w.waived_until IS NULL AND w.reversed_at IS NULL);
    ELSE
        UPDATE fine_waivers SET waived_until = GREATEST(now(), waived_from + interval '1 second')
         WHERE person_id = p_person AND waived_until IS NULL AND reversed_at IS NULL AND reason = 'inactive';
    END IF;
END $$;

CREATE OR REPLACE FUNCTION fh_team_persons_fine_waivers() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
    PERFORM fh_fine_waivers_sync(NEW.person_id);
    RETURN NULL;
END $$;

DROP TRIGGER IF EXISTS team_persons_fine_waivers ON team_persons;
CREATE TRIGGER team_persons_fine_waivers
    AFTER INSERT OR UPDATE OF squad_status_id, removed_at ON team_persons
    FOR EACH ROW EXECUTE FUNCTION fh_team_persons_fine_waivers();

-- Move the judging body to fh_person_fines_all.
DO $$
DECLARE d text;
BEGIN
    IF to_regprocedure('fh_person_fines_all(integer[], timestamptz)') IS NULL THEN
        d := pg_get_functiondef('fh_person_fines(integer[], timestamptz)'::regprocedure);
        d := replace(d, 'public.fh_person_fines(', 'public.fh_person_fines_all(');
        IF position('fh_person_fines_all(' IN d) = 0 THEN
            RAISE EXCEPTION 'mig 997: fh_person_fines definition not as expected';
        END IF;
        EXECUTE d;
    END IF;
END $$;
COMMENT ON FUNCTION fh_person_fines_all(integer[], timestamptz) IS
    'mig 460→997: every fine as judged, before waivers. Callers want fh_person_fines.';

CREATE OR REPLACE FUNCTION fh_person_fines(p_person_ids int[], p_from timestamptz)
RETURNS TABLE (
  person_id      int,
  fh_event_id    bigint,
  team_id        int,
  starts_at      timestamptz,
  event_kind     text,
  opponent       text,
  fine_kind      text,
  amount_usd     numeric,
  response       text,
  attendance     text
) LANGUAGE sql STABLE AS $$
    SELECT f.* FROM fh_person_fines_all(p_person_ids, p_from) f
     WHERE fh_fine_waived_at(f.person_id, f.starts_at) IS NULL
$$;
COMMENT ON FUNCTION fh_person_fines(integer[], timestamptz) IS
    'mig 460/997: the fines owed — fh_person_fines_all minus events inside a fine_waivers stretch.';

CREATE OR REPLACE FUNCTION fh_person_waived_fines(p_person_ids int[], p_from timestamptz)
RETURNS TABLE (person_id int, fh_event_id bigint, starts_at timestamptz, fine_kind text, amount_usd numeric, waiver_id int)
LANGUAGE sql STABLE AS $$
    SELECT f.person_id, f.fh_event_id, f.starts_at, f.fine_kind, f.amount_usd, w.id
      FROM fh_person_fines_all(p_person_ids, p_from) f
      CROSS JOIN LATERAL (SELECT fh_fine_waived_at(f.person_id, f.starts_at) AS id) w
     WHERE w.id IS NOT NULL
$$;
COMMENT ON FUNCTION fh_person_waived_fines(integer[], timestamptz) IS 'mig 997: the fines a waiver took to $0, for #fines.';

-- Everyone inactive today gets his waiver now.
SELECT fh_fine_waivers_sync(person_id)
  FROM (SELECT DISTINCT tp.person_id FROM team_persons tp
          JOIN squad_statuses ss ON ss.id = tp.squad_status_id AND ss.code = 'inactive'
         WHERE tp.removed_at IS NULL) x;

-- #fines wording (kind fines, mig 534).
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Fines', l, 'fines', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('waived_title', 'Waived box title',                         '💤 Waived — inactive', 794),
    ('waived_note',  'Waived box note',                          'Inactive players are billed the usual dues only. Fines from the first unbilled month until they are back are $0; they start fresh when they return. Undo a waiver by migration (fine_waivers.reversed_at).', 795),
    ('waived_open',  'Waiver still running ({from})',            'since {from} · still inactive', 796),
    ('waived_closed','Waiver ended ({from} {until})',            '{from} – back {until}', 797)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'fines' AND m.tier = v.t);
