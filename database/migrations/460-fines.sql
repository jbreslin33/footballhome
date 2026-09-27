-- 460 — Fines (owner 2026-09-27): "we need a fines part to financial.
-- similar to pro rate. it should show next to pro rate ... always show
-- last 3 months of fines with the individual months each in a box ...
-- for now just sept starting now ... this is only for men. not women.
-- for men $1 missed rsvp practice. $3 missed rsvp game. $5 rsvp then no
-- show practice. $10 rsvp then no show game."  Parents are not fined.
--
-- Nothing is stored per fine: a fine is DERIVED from the RSVP and
-- attendance rows that already exist (fh_event_rsvps, fh_event_attendance)
-- against the rate in force on the day of the event, so a corrected RSVP
-- or attendance mark corrects the fine.  The rates follow the
-- dues_policies pattern: one row per (club, section, kind, effective
-- date), section beats club-wide, history kept.  With no row in force
-- for a section (Womens, Boys, Girls today) there is no fine.
--
-- Fines are shown on #payments so the owner adds them to the next
-- posting in LeagueApps by hand ("all adding to balance is at change of
-- month"); the balance itself still lives in LA.
--
--   fine_kinds        the four kinds and their player-facing labels
--   fine_policies     the rates
--   fh_fine_amount_usd(club, section, kind, on)   rate in force that day
--   fh_person_fines(person_ids, from)  one row per fined (person, event)

CREATE TABLE IF NOT EXISTS fine_kinds (
  code        text PRIMARY KEY,
  label       text NOT NULL,
  sort_order  smallint NOT NULL
);
COMMENT ON TABLE fine_kinds IS 'Kinds of fine and their labels on #payments. Wording lives here, not in JS.';

INSERT INTO fine_kinds (code, label, sort_order) VALUES
  ('missed_rsvp_practice', 'No RSVP for a practice',            1),
  ('missed_rsvp_game',     'No RSVP for a game',                2),
  ('no_show_practice',     'Said yes, no-show at a practice',   3),
  ('no_show_game',         'Said yes, no-show at a game',       4)
ON CONFLICT (code) DO NOTHING;

CREATE TABLE IF NOT EXISTS fine_policies (
  id                 serial PRIMARY KEY,
  club_id            int NOT NULL REFERENCES clubs(id),
  club_section_id    int REFERENCES club_sections(id),          -- NULL = whole club
  fine_kind          text NOT NULL REFERENCES fine_kinds(code),
  amount_usd         numeric(8,2) NOT NULL CHECK (amount_usd >= 0),
  effective_from     date NOT NULL DEFAULT CURRENT_DATE,
  created_by_user_id int REFERENCES users(id),
  created_at         timestamptz NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX IF NOT EXISTS fine_policies_scope_idx
  ON fine_policies (club_id, COALESCE(club_section_id, 0), fine_kind, effective_from);
COMMENT ON TABLE fine_policies IS
  'Fine rates. Section-scoped row beats club-wide; latest effective_from <= the event day wins. Insert a new row to change a rate; never update history. No row in force = no fine.';

-- Lighthouse Mens (club_sections 1), from today.
INSERT INTO fine_policies (club_id, club_section_id, fine_kind, amount_usd, effective_from)
SELECT 134, 1, k.code, k.amt, DATE '2026-09-27'
  FROM (VALUES ('missed_rsvp_practice', 1.00),
               ('missed_rsvp_game',     3.00),
               ('no_show_practice',     5.00),
               ('no_show_game',        10.00)) AS k(code, amt)
 WHERE NOT EXISTS (SELECT 1 FROM fine_policies WHERE club_id = 134 AND club_section_id = 1 AND fine_kind = k.code);

-- The rate in force for (club, section, kind) on a day.  NULL = no fine.
CREATE OR REPLACE FUNCTION fh_fine_amount_usd(p_club_id int, p_section_id int, p_kind text, p_on date)
RETURNS numeric LANGUAGE sql STABLE AS $$
  SELECT amount_usd
    FROM fine_policies
   WHERE club_id = p_club_id
     AND fine_kind = p_kind
     AND (club_section_id IS NULL OR club_section_id = p_section_id)
     AND effective_from <= p_on
   ORDER BY (club_section_id IS NOT NULL) DESC, effective_from DESC, id DESC
   LIMIT 1
$$;

-- Every fine the given people have earned since p_from, one row per
-- (person, event).  Who owes an answer follows the RSVP board
-- (RsvpBoard.cpp): rostered players on an active team whose roster status
-- shows on the board, from the day they joined, not suspended.  Coaches
-- and staff are not fined.
--   missed_rsvp_*   the event started and no answer was in before kickoff
--   no_show_*       they said yes and the coach marked them absent
--                   (late counts as there; excused is not a no-show; an
--                   unmarked event proves nothing)
-- Games = match + intrasquad, as on #reports.  The rate is the one in
-- force on the event day for the team's section; a day with none
-- (before the policy, or a section without one) yields no row.
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
