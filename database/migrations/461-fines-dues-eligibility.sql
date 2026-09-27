-- 461 — No fine while dues block the RSVP (owner 2026-09-27: "if they
-- can't rsvp due to over due dues we can't fine them").
--
-- The #my RSVP buttons are gated by fh_dues_eligible() (migration 416):
-- at or over the dues line ($70 = two full months) a player cannot
-- answer, so a missed answer is not their fault.  A fine is judged as of
-- the EVENT DAY, but the balance is only ever the latest LeagueApps
-- snapshot on person_la_memberships — nothing remembered what it was
-- last week.  So:
--
--   person_dues_balance_log   one row per person each time their live
--                             balance changes (trigger on the membership
--                             rows the LA sync writes), seeded now
--   fh_dues_balance_at()      the balance as of a moment (latest row at
--                             or before it; today's live figure when the
--                             log has nothing that early)
--   fh_dues_eligible_at()     that balance under the line
--   fh_person_fines()         skips every event the player was blocked on
--
-- Fines began 2026-09-27 and the log is seeded the same day, so every
-- fined event has a snapshot behind it.

CREATE TABLE IF NOT EXISTS person_dues_balance_log (
  id           bigserial PRIMARY KEY,
  person_id    int NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
  balance_usd  numeric(10,2) NOT NULL,
  observed_at  timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS person_dues_balance_log_person_idx
  ON person_dues_balance_log (person_id, observed_at DESC);
COMMENT ON TABLE person_dues_balance_log IS
  'Live dues balance (fh_dues_balance_usd) each time it changed, written by a trigger on person_la_memberships. Lets fines and eligibility be judged as of a past moment.';

-- Append a row when the person's live balance differs from the last logged.
CREATE OR REPLACE FUNCTION fh_log_dues_balance(p_person_id int) RETURNS void
LANGUAGE plpgsql AS $$
DECLARE
  v_now  numeric;
  v_last numeric;
BEGIN
  v_now := fh_dues_balance_usd(p_person_id);
  SELECT balance_usd INTO v_last FROM person_dues_balance_log
   WHERE person_id = p_person_id ORDER BY observed_at DESC, id DESC LIMIT 1;
  IF v_last IS NULL OR v_last <> v_now THEN
    INSERT INTO person_dues_balance_log (person_id, balance_usd) VALUES (p_person_id, v_now);
  END IF;
END $$;

CREATE OR REPLACE FUNCTION fh_membership_balance_changed() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP IN ('INSERT', 'UPDATE') THEN PERFORM fh_log_dues_balance(NEW.person_id); END IF;
  IF TG_OP IN ('DELETE', 'UPDATE') AND (TG_OP = 'DELETE' OR OLD.person_id <> NEW.person_id) THEN
    PERFORM fh_log_dues_balance(OLD.person_id);
  END IF;
  RETURN NULL;
END $$;

DROP TRIGGER IF EXISTS person_la_memberships_balance_log ON person_la_memberships;
CREATE TRIGGER person_la_memberships_balance_log
  AFTER INSERT OR DELETE OR UPDATE OF la_amount_owed_cents, la_amount_paid_cents, ended_at, la_program_id, person_id
  ON person_la_memberships
  FOR EACH ROW EXECUTE FUNCTION fh_membership_balance_changed();

-- Seed: today's balance for everyone with a current membership.
INSERT INTO person_dues_balance_log (person_id, balance_usd)
SELECT m.person_id, fh_dues_balance_usd(m.person_id)
  FROM (SELECT DISTINCT person_id FROM person_la_memberships WHERE ended_at IS NULL) m
 WHERE NOT EXISTS (SELECT 1 FROM person_dues_balance_log l WHERE l.person_id = m.person_id);

-- The balance as of a moment.  Falls back to the live figure when the
-- log has nothing that early (a person who joined after the seed is
-- logged on their first membership row, so this is rare).
CREATE OR REPLACE FUNCTION fh_dues_balance_at(p_person_id int, p_at timestamptz)
RETURNS numeric LANGUAGE sql STABLE AS $$
  SELECT COALESCE(
           (SELECT l.balance_usd FROM person_dues_balance_log l
             WHERE l.person_id = p_person_id AND l.observed_at <= p_at
             ORDER BY l.observed_at DESC, l.id DESC LIMIT 1),
           fh_dues_balance_usd(p_person_id))
$$;

CREATE OR REPLACE FUNCTION fh_dues_eligible_at(p_person_id int, p_club_id int, p_at timestamptz)
RETURNS boolean LANGUAGE sql STABLE AS $$
  SELECT COALESCE(fh_dues_balance_at(p_person_id, p_at) < fh_dues_line_usd(p_club_id), true)
$$;

-- fh_person_fines: as migration 460, plus "they could answer" — under
-- the dues line on the event day.
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
  WITH owed AS (
    SELECT DISTINCT ON (tp.person_id, fe.id)
           tp.person_id, fe.id AS fh_event_id, t.id AS team_id, t.club_id, t.club_section_id,
           ge.starts_at, fe.kind, fe.opponent,
           rv.response, rv.responded_at, att.status AS attendance
      FROM team_persons tp
      JOIN teams t              ON t.id = tp.team_id AND t.is_active
      LEFT JOIN roster_statuses rs ON rs.id = tp.roster_status_id
      JOIN fh_event_teams fet   ON fet.team_id = t.id
      JOIN fh_events fe         ON fe.id = fet.fh_event_id
                               AND fe.kind IN ('practice', 'match', 'intrasquad')
      JOIN gcal_events ge       ON ge.id = fe.gcal_event_id
      LEFT JOIN fh_event_rsvps rv       ON rv.fh_event_id = fe.id  AND rv.person_id  = tp.person_id
      LEFT JOIN fh_event_attendance att ON att.fh_event_id = fe.id AND att.person_id = tp.person_id
     WHERE tp.person_id = ANY (p_person_ids)
       AND tp.removed_at IS NULL
       AND COALESCE(rs.show_in_rsvp, true)
       AND t.club_section_id IS NOT NULL
       AND ge.deleted_at IS NULL AND ge.status IS DISTINCT FROM 'cancelled'
       AND ge.starts_at >= GREATEST(tp.joined_at, p_from)
       AND ge.starts_at <  now()
       AND NOT EXISTS (SELECT 1 FROM rsvp_suspensions s
                        WHERE s.person_id = tp.person_id
                          AND (s.team_id IS NULL OR s.team_id = t.id)
                          AND s.starts_at <= ge.starts_at
                          AND (s.ends_at IS NULL OR s.ends_at > ge.starts_at))
       -- Blocked from answering by dues on the event day: no fine (mig 461).
       AND fh_dues_eligible_at(tp.person_id, t.club_id, ge.starts_at)
     ORDER BY tp.person_id, fe.id, t.id
  ), judged AS (
    SELECT o.*,
           CASE
             WHEN o.response IS NULL OR o.responded_at >= o.starts_at
               THEN CASE WHEN o.kind = 'practice' THEN 'missed_rsvp_practice' ELSE 'missed_rsvp_game' END
             WHEN o.response = 'yes' AND o.attendance = 'absent'
               THEN CASE WHEN o.kind = 'practice' THEN 'no_show_practice' ELSE 'no_show_game' END
           END AS fine_kind
      FROM owed o
  )
  SELECT j.person_id, j.fh_event_id, j.team_id, j.starts_at, j.kind, j.opponent,
         j.fine_kind, amt.amount_usd, j.response, j.attendance
    FROM judged j
    CROSS JOIN LATERAL (
      SELECT fh_fine_amount_usd(j.club_id, j.club_section_id, j.fine_kind,
                                (j.starts_at AT TIME ZONE 'America/New_York')::date) AS amount_usd
    ) amt
   WHERE j.fine_kind IS NOT NULL AND amt.amount_usd IS NOT NULL AND amt.amount_usd > 0
$$;
