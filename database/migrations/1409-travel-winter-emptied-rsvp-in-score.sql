-- 1409 (2026-11-16): two owner asks in one go.
--
-- 1. Empty ❄️ U10 Travel Winter (965) and ❄️ U12 Travel Winter (964)
--    (owner: "lets empty out u10 travel winter and u12 travel winter").
--    Same as the ⚽ pill's remove: rows closed (removed_at + admin_remove),
--    never deleted, so the trial sessions they went to while on those
--    teams still count in the scores below.  Their other youth teams stay.
--
-- 2. ⭐ Score gets RSVP % as a fourth part, all four equal (owner: "rank all
--    players on the other youth teams by 'commitment' level. equal weight.
--    rsvp %, attendance %, trial %, dues" + "make sortable by each" + "and
--    the final tally of all").
--      RSVP % = practices (trials included) and games on his teams while he
--      was on them, club year so far, that got an answer (yes or no, by
--      him, a parent or a standing RSVP) ÷ all of them.
--    New policy row (effective today) carries rsvp_weight = 1 next to the
--    other three; the old row keeps its history.

BEGIN;

UPDATE team_persons
   SET removed_at = now(), removed_reason = 'admin_remove'
 WHERE team_id IN (964, 965) AND removed_at IS NULL;

ALTER TABLE selection_score_policies
  ADD COLUMN IF NOT EXISTS rsvp_weight numeric NOT NULL DEFAULT 0 CHECK (rsvp_weight >= 0);

INSERT INTO selection_score_policies (club_id, trials_weight, attendance_weight, dues_weight, rsvp_weight,
                                      dues_months_to_zero, trial_title_pattern, window_start_month,
                                      effective_from, notes)
SELECT 134, 1, 1, 1, 1, 2, 'travel trials', 8, '2026-11-16',
       'owner 11/16: commitment = rsvp %, attendance %, trial %, dues, equal weight'
 WHERE NOT EXISTS (SELECT 1 FROM selection_score_policies WHERE club_id = 134 AND rsvp_weight > 0);

-- The newest row wins; two rows share today's date, so order by id too.
DROP FUNCTION IF EXISTS fh_selection_scores(integer[]);
CREATE FUNCTION fh_selection_scores(p_person_ids integer[])
RETURNS TABLE (person_id integer, attended integer, expected integer, trials integer, trials_held integer,
               rsvp_answered integer, rsvp_asked integer)
LANGUAGE sql STABLE AS $$
  WITH pol AS (
    SELECT * FROM selection_score_policies WHERE club_id = 134 AND effective_from <= CURRENT_DATE
     ORDER BY effective_from DESC, id DESC LIMIT 1
  ), w AS (
    SELECT make_timestamptz(extract(year FROM (now() AT TIME ZONE 'America/New_York')
                                              - make_interval(months => pol.window_start_month - 1))::int,
                            pol.window_start_month, 1, 0, 0, 0, 'America/New_York') AS from_at,
           pol.trial_title_pattern AS pat
      FROM pol
  ), ev AS MATERIALIZED (   -- his teams' past practices + games, only while he was on the team
    SELECT DISTINCT tp.person_id, e.id AS event_id, e.kind, (g.summary ~* w.pat) AS is_trial
      FROM team_persons tp
      JOIN fh_event_teams et ON et.team_id = tp.team_id
      JOIN fh_events e       ON e.id = et.fh_event_id AND e.kind IN ('practice', 'match')
      JOIN gcal_events g     ON g.id = e.gcal_event_id
      , w
     WHERE tp.person_id = ANY (p_person_ids)
       AND g.starts_at >= w.from_at AND g.starts_at < now()
       AND g.deleted_at IS NULL AND COALESCE(g.status, '') <> 'cancelled'
       AND (tp.joined_at IS NULL OR tp.joined_at < '1971-01-01' OR g.starts_at >= date_trunc('day', tp.joined_at))
       AND (tp.removed_at IS NULL OR g.starts_at < tp.removed_at)
  ), went AS (
    SELECT ev.person_id, ev.kind, ev.is_trial,
           EXISTS (SELECT 1 FROM fh_event_rsvps v WHERE v.fh_event_id = ev.event_id
                     AND v.person_id = ev.person_id) AS answered,
           CASE WHEN EXISTS (SELECT 1 FROM fh_event_attendance a WHERE a.fh_event_id = ev.event_id)
                THEN EXISTS (SELECT 1 FROM fh_event_attendance a WHERE a.fh_event_id = ev.event_id
                               AND a.person_id = ev.person_id AND a.status IN ('present', 'late'))
                ELSE EXISTS (SELECT 1 FROM fh_event_rsvps v WHERE v.fh_event_id = ev.event_id
                               AND v.person_id = ev.person_id AND v.response = 'yes') END AS went
      FROM ev
  )
  SELECT person_id,
         count(*) FILTER (WHERE kind = 'practice' AND went AND NOT is_trial)::int,
         count(*) FILTER (WHERE kind = 'practice' AND NOT is_trial)::int,
         count(*) FILTER (WHERE kind = 'practice' AND went AND is_trial)::int,
         count(*) FILTER (WHERE kind = 'practice' AND is_trial)::int,
         count(*) FILTER (WHERE answered)::int,
         count(*)::int
    FROM went GROUP BY person_id
$$;

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Roster sheet', l, 'roster_sheet', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('board_sort_rsvp',     'Team boards sort pill — share of practices/games answered', '📝 RSVP',        1046),
    ('board_chip_rsvp',     'Card chip under 📝 sort ({went} {of})',                     '📝 {went}/{of}', 1047)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'roster_sheet' AND m.tier = v.t);

UPDATE message_templates
   SET body = 'RSVP {rsvp} · Attendance {attendance} · Trials {trials} · Dues {dues}',
       label = 'Hover on the ⭐ chip ({rsvp} {attendance} {trials} {dues})'
 WHERE kind = 'roster_sheet' AND tier = 'board_chip_score_tip';

UPDATE message_templates
   SET label = 'Team boards sort pill — rsvp + attendance + trials + dues (commitment)'
 WHERE kind = 'roster_sheet' AND tier = 'board_sort_score';

COMMIT;
