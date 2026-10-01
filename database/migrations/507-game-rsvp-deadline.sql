-- 507 (2026-10-01) — Game RSVP deadline: stated in the reminder, and a
-- starter criterion.
--
-- Owner: "if a player is missing a game rsvp we need in reminder to state
-- the deadline which is for example if sunday game deadline is thursday
-- midnight. if sat wed midnight. etc. this is for youth or adult."  Then:
-- "being late with rsvp for game makes a player ineligible to start so add
-- that as a criteria to show they either set availability on time or
-- didn't. if they set it and change after deadline that is still eligible".
--
--   rsvp_deadline_policies        the rule: how many days before a game
--                                 the answer is due (club-wide, a section
--                                 row overrides) and the first game date
--                                 it applies to
--   fh_event_rsvp_first_answers   when each person FIRST answered an event.
--                                 fh_event_rsvps.responded_at moves on
--                                 every change and the row is deleted when
--                                 an answer is cleared, so "answered on
--                                 time, changed later" needs its own fact
--   fh_rsvp_deadline(event)       the deadline instant for a game, NULL
--                                 when none applies
--   fh_rsvp_deadline_note(event)  the reminder's line under a game
--
-- The deadline is midnight at the END of the day `days_before_game` days
-- before the game's local date: 3 → a Sunday game is due Thursday
-- midnight, a Saturday game Wednesday midnight.  Games only (kind
-- 'match'); practices have no deadline.
--
-- effective_from is the first GAME date the rule covers.  2026-10-04: the
-- Saturday 10/3 games' deadline (Wednesday midnight) had already passed
-- when the rule was written, so nobody is marked late for a deadline they
-- were never told about; Sunday 10/4 is due tonight.

CREATE TABLE IF NOT EXISTS rsvp_deadline_policies (
  id                 serial PRIMARY KEY,
  club_id            integer  NOT NULL REFERENCES clubs(id),
  club_section_id    integer  REFERENCES club_sections(id),
  days_before_game   smallint NOT NULL CHECK (days_before_game >= 0),
  time_zone          text     NOT NULL DEFAULT 'America/New_York',
  effective_from     date     NOT NULL DEFAULT CURRENT_DATE,
  created_by_user_id integer  REFERENCES users(id),
  created_at         timestamptz NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX IF NOT EXISTS rsvp_deadline_policies_scope_idx
  ON rsvp_deadline_policies (club_id, COALESCE(club_section_id, 0), effective_from);

COMMENT ON TABLE rsvp_deadline_policies IS
  'When a game RSVP is due (mig 507): midnight at the end of the day days_before_game days before the game. club_section_id NULL = the whole club; a section row wins. effective_from = first game date covered. Read by fh_rsvp_deadline().';

INSERT INTO rsvp_deadline_policies (club_id, club_section_id, days_before_game, effective_from)
SELECT 134, NULL, 3, DATE '2026-10-04'
 WHERE NOT EXISTS (SELECT 1 FROM rsvp_deadline_policies WHERE club_id = 134 AND club_section_id IS NULL);

-- ── First answers ────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS fh_event_rsvp_first_answers (
  fh_event_id        bigint  NOT NULL REFERENCES fh_events(id) ON DELETE CASCADE,
  person_id          integer NOT NULL REFERENCES persons(id)   ON DELETE CASCADE,
  first_responded_at timestamptz NOT NULL,
  PRIMARY KEY (fh_event_id, person_id)
);
COMMENT ON TABLE fh_event_rsvp_first_answers IS
  'When a person first answered an event (mig 507). Written once by a trigger on fh_event_rsvps and never moved by a later change or a cleared answer; decides "answered by the deadline".';

CREATE OR REPLACE FUNCTION fh_event_rsvps_note_first_answer() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
  INSERT INTO fh_event_rsvp_first_answers (fh_event_id, person_id, first_responded_at)
  VALUES (NEW.fh_event_id, NEW.person_id, NEW.responded_at)
  ON CONFLICT (fh_event_id, person_id) DO NOTHING;
  RETURN NEW;
END $$;

DROP TRIGGER IF EXISTS fh_event_rsvps_first_answer ON fh_event_rsvps;
CREATE TRIGGER fh_event_rsvps_first_answer
  AFTER INSERT ON fh_event_rsvps
  FOR EACH ROW EXECUTE FUNCTION fh_event_rsvps_note_first_answer();

-- Answers already on file: responded_at is the best first-answer time known.
INSERT INTO fh_event_rsvp_first_answers (fh_event_id, person_id, first_responded_at)
SELECT r.fh_event_id, r.person_id, r.responded_at FROM fh_event_rsvps r
ON CONFLICT (fh_event_id, person_id) DO NOTHING;

-- ── The deadline ─────────────────────────────────────────────────────
-- NULL when the event is not a game, no policy covers it, or the deadline
-- would fall before that week's RSVPs even open (mig 334: a Monday or
-- Tuesday game is due before Sunday's 8 PM release — nobody can be late
-- for something they could not answer).
CREATE OR REPLACE FUNCTION fh_rsvp_deadline(p_fh_event_id bigint)
RETURNS timestamptz LANGUAGE sql STABLE AS $$
  WITH ev AS (
    SELECT fe.id, ge.starts_at
      FROM fh_events fe
      JOIN gcal_events ge ON ge.id = fe.gcal_event_id
     WHERE fe.id = p_fh_event_id AND fe.kind = 'match'
  ), pol AS (
    SELECT p.days_before_game, p.time_zone, t.club_id, t.club_section_id
      FROM ev
      JOIN fh_event_teams fet ON fet.fh_event_id = ev.id
      JOIN teams t ON t.id = fet.team_id
      JOIN rsvp_deadline_policies p
        ON p.club_id = t.club_id
       AND (p.club_section_id IS NULL OR p.club_section_id = t.club_section_id)
       AND p.effective_from <= (ev.starts_at AT TIME ZONE p.time_zone)::date
     ORDER BY (p.club_section_id IS NOT NULL) DESC, p.effective_from DESC, p.id DESC
     LIMIT 1
  ), d AS (
    SELECT (((ev.starts_at AT TIME ZONE pol.time_zone)::date - pol.days_before_game + 1)::timestamp
              AT TIME ZONE pol.time_zone) AS deadline,
           fh_schedule_week_opens_at(pol.club_id, pol.club_section_id,
                                     fh_week_start(ev.starts_at, pol.time_zone)) AS opens
      FROM ev, pol
  )
  SELECT d.deadline FROM d WHERE d.opens IS NULL OR d.opens < d.deadline
$$;
COMMENT ON FUNCTION fh_rsvp_deadline(bigint) IS
  'The instant a game''s RSVP is due (mig 507): start of the day after the deadline day, so "on time" is first answer < this. NULL = no deadline applies.';

-- The line a reminder prints under a game: the deadline while it is still
-- ahead, a different sentence once it has passed.  {day} = "Thu Oct 1".
CREATE OR REPLACE FUNCTION fh_rsvp_deadline_note(p_fh_event_id bigint)
RETURNS text LANGUAGE sql STABLE AS $$
  SELECT replace(m.body, '{day}',
                 to_char((d.deadline AT TIME ZONE 'America/New_York')::date - 1, 'Dy Mon FMDD'))
    FROM (SELECT fh_rsvp_deadline(p_fh_event_id) AS deadline) d
    JOIN message_templates m
      ON m.kind = 'rsvp_reminder' AND m.is_active
     AND m.tier = CASE WHEN now() < d.deadline THEN 'deadline' ELSE 'deadline_passed' END
   WHERE d.deadline IS NOT NULL
   ORDER BY m.sort_order, m.id
   LIMIT 1
$$;

-- ── Copy ─────────────────────────────────────────────────────────────
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order)
SELECT 'RSVP', 'RSVP reminder — game deadline, still ahead', 'rsvp_reminder', 'deadline', NULL,
       'Deadline: {day} midnight — answer by then to be eligible to start.', 20
WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'rsvp_reminder' AND tier = 'deadline');
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order)
SELECT 'RSVP', 'RSVP reminder — game deadline, passed', 'rsvp_reminder', 'deadline_passed', NULL,
       'The deadline to be eligible to start was {day} midnight — please still answer.', 21
WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'rsvp_reminder' AND tier = 'deadline_passed');

-- Game Center's second starter criterion (client_side rows, read through
-- MessageCopy.block('eligibility', tier)).  {day} = "Thu 10/1".
CREATE OR REPLACE FUNCTION pg_temp.add_client_tpl(p_kind text, p_tier text, p_label text, p_body text, p_sort int)
RETURNS void LANGUAGE sql AS $$
  INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
  SELECT 'System', p_label, p_kind, p_tier, NULL, p_body, p_sort, true, true
   WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = p_kind AND tier = p_tier);
$$;

-- The card: the overall verdict as the header, then one box per criterion
-- (owner: "2 boxes. one for practice criteria and one for rsvp on time for
-- game and have eligibility at top as header").
SELECT pg_temp.add_client_tpl('eligibility', 'overall_eligible', 'Starter eligibility — header: both criteria met',
  'Eligible to start', 28);
SELECT pg_temp.add_client_tpl('eligibility', 'overall_projected', 'Starter eligibility — header: on track',
  'Projected eligible to start', 28);
SELECT pg_temp.add_client_tpl('eligibility', 'overall_projected_not', 'Starter eligibility — header: something still missing',
  'Projected NOT eligible to start', 28);
SELECT pg_temp.add_client_tpl('eligibility', 'overall_not_eligible', 'Starter eligibility — header: a criterion can no longer be met',
  'Not eligible to start', 28);
SELECT pg_temp.add_client_tpl('eligibility', 'practice_box_heading', 'Starter eligibility — box 1 heading',
  '1 · Practice criteria', 29);
SELECT pg_temp.add_client_tpl('eligibility', 'rsvp_box_heading', 'Starter eligibility — box 2 heading',
  '2 · Game RSVP on time', 30);
-- No answer yet reads as projected NOT eligible (owner: "i want it clear
-- also even now that a player has no rsvp and thus is projected to be
-- ineligible to start").
SELECT pg_temp.add_client_tpl('eligibility', 'rsvp_pill_on_time', 'Starter eligibility — game RSVP pill: on time',
  'Game RSVP Criteria: Met · answered on time', 31);
SELECT pg_temp.add_client_tpl('eligibility', 'rsvp_pill_pending', 'Starter eligibility — game RSVP pill: not answered, deadline ahead',
  'Game RSVP Criteria: No answer yet · projected NOT eligible to start · answer by {day} midnight', 32);
SELECT pg_temp.add_client_tpl('eligibility', 'rsvp_pill_late', 'Starter eligibility — game RSVP pill: missed the deadline',
  'Game RSVP Criteria: Not met · no answer by {day} midnight', 33);
SELECT pg_temp.add_client_tpl('eligibility', 'rsvp_rule', 'Starter eligibility — the game RSVP rule',
  'To start you must also set your availability for the game itself by {day} midnight. Going or Not Going both count, and changing your answer after the deadline is fine — what matters is that you answered in time.', 34);
SELECT pg_temp.add_client_tpl('eligibility', 'rsvp_row_on_time', 'Starter eligibility — roster row: game RSVP on time',
  'Game RSVP on time', 35);
SELECT pg_temp.add_client_tpl('eligibility', 'rsvp_row_pending', 'Starter eligibility — roster row: game RSVP not in, deadline ahead',
  'No game RSVP · projected ineligible', 36);
SELECT pg_temp.add_client_tpl('eligibility', 'rsvp_row_late', 'Starter eligibility — roster row: game RSVP missed the deadline',
  'Game RSVP late · ineligible', 37);
SELECT pg_temp.add_client_tpl('eligibility', 'rsvp_remedy_heading', 'Starter eligibility — the game''s Going / Out row',
  'Your answer for this game', 38);
