-- 1562 (2026-11-19) — No reminder, no missed-RSVP fine.  🪑 Reserves fined like anyone.
--
-- Owner, deciding what 🪑 Reserves are for: "really its deciding who we
-- fine lol" → "i have idea. they get fined if we send reminder" → "if no
-- reminder then no fine" → "that shold hold for everone. never a fine for
-- no rsvp unless there was a reminder sent." → "no show is a fine" →
-- "alwyas".
--
--   · missed_rsvp_practice / missed_rsvp_game: only when a reminder naming
--     that event went to him before kickoff — rsvp_reminders +
--     rsvp_reminder_events (#rsvps / Game Center / event-page Remind, the
--     group Remind all, and now every group message from a game's page and
--     📣 Ask Reserves, logged by POST /api/rsvp-board/log-ask)
--   · no_show_*: unchanged — said Going, marked absent = fined, always
--   · 🪑 Reserves (squad status standby) are no longer skipped: a Reserve
--     who was asked and didn't answer, or said Going and didn't come, is
--     fined like a Regular.  Other Team-pill groups still owe nothing.
--   · fine_reminder_policy.needs_reminder = the switch (one row)
-- Applies to every period (fines are derived, nothing stored).

BEGIN;

CREATE TABLE IF NOT EXISTS fine_reminder_policy (
  id             boolean PRIMARY KEY DEFAULT true CHECK (id),
  needs_reminder boolean NOT NULL
);
COMMENT ON TABLE fine_reminder_policy IS
  'mig 1562: needs_reminder = a missed-RSVP fine only when a logged reminder (rsvp_reminder_events) named the event before kickoff. No-show fines ignore it.';
INSERT INTO fine_reminder_policy (needs_reminder) VALUES (true) ON CONFLICT DO NOTHING;

CREATE INDEX IF NOT EXISTS rsvp_reminder_events_event ON rsvp_reminder_events (fh_event_id);

CREATE OR REPLACE FUNCTION fh_reminded_before(p_person integer, p_event bigint, p_at timestamptz)
RETURNS boolean LANGUAGE sql STABLE AS $$
  SELECT EXISTS (SELECT 1 FROM rsvp_reminder_events re
                   JOIN rsvp_reminders r ON r.id = re.rsvp_reminder_id
                  WHERE re.fh_event_id = p_event AND r.person_id = p_person AND r.sent_at < p_at)
$$;
COMMENT ON FUNCTION fh_reminded_before(integer, bigint, timestamptz) IS
  'mig 1562: was a reminder naming this event logged for this person before p_at (kickoff)?';

CREATE OR REPLACE FUNCTION public.fh_person_fines_all(p_person_ids integer[], p_from timestamp with time zone)
 RETURNS TABLE(person_id integer, fh_event_id bigint, team_id integer, starts_at timestamp with time zone, event_kind text, opponent text, fine_kind text, amount_usd numeric, response text, attendance text)
 LANGUAGE sql
 STABLE
AS $function$
   WITH ev AS MATERIALIZED (
     -- The window's events first (mig 1403): the date filter used to run
     -- last, after every event of every team x every roster row (678k rows
     -- to keep 2.5k, 3 s on #tuition / #fines).
     SELECT fe.id, fe.kind, fe.opponent, ge.starts_at
       FROM gcal_events ge
       JOIN fh_events fe ON fe.gcal_event_id = ge.id
                        AND fe.kind IN ('practice', 'match', 'intrasquad')
      WHERE ge.starts_at >= p_from AND ge.starts_at < now()
        AND ge.deleted_at IS NULL AND ge.status IS DISTINCT FROM 'cancelled'
   ), owed AS (
     SELECT DISTINCT ON (tp.person_id, fe.id)
            tp.person_id, fe.id AS fh_event_id, t.id AS team_id, t.club_id, t.club_section_id,
            fe.starts_at, fe.kind, fe.opponent,
            rv.response, rv.responded_at, att.status AS attendance
       FROM ev fe
       JOIN fh_event_teams fet   ON fet.fh_event_id = fe.id
       JOIN teams t              ON t.id = fet.team_id AND t.is_active
       JOIN team_persons tp      ON tp.team_id = t.id
       LEFT JOIN roster_statuses rs ON rs.id = tp.roster_status_id
       LEFT JOIN fh_event_rsvps rv       ON rv.fh_event_id = fe.id  AND rv.person_id  = tp.person_id
       LEFT JOIN fh_event_attendance att ON att.fh_event_id = fe.id AND att.person_id = tp.person_id
      WHERE tp.person_id = ANY (p_person_ids)
        AND tp.removed_at IS NULL
        -- Call-up-gated team (mig 603): being on the roster creates no
        -- expectation, so no fine. Invited call-ups are deliberately not
        -- fined either (youth semantics).
        AND NOT fh_team_callup_only(tp.team_id)
        AND NOT tp.invite_only  -- mig 619: paper spots owe nothing
        -- mig 1528: a Team-pill group owes nothing — except 🪑 Reserves
        -- (mig 1562): fined like anyone when reminded / a no-show.
        AND (tp.squad_status_id IS NULL
             OR tp.squad_status_id = (SELECT id FROM squad_statuses WHERE code = 'standby'))
        AND t.club_section_id IS NOT NULL
        AND fe.starts_at >= GREATEST(tp.joined_at, p_from)
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
   ), fined AS MATERIALIZED (
     -- Only rows that would be fined go through the per-person checks
     -- below (mig 1249): they are the expensive part, and most event rows
     -- are answered in time.
     SELECT * FROM judged WHERE fine_kind IS NOT NULL
   ), kept AS (
     SELECT f.* FROM fined f
      WHERE NOT fh_event_suspended(f.fh_event_id, f.person_id)        -- ⛔ suspended for this game (mig 1077)
        AND fh_dues_eligible_at(f.person_id, f.club_id, f.starts_at)  -- dues blocked that day (mig 461)
        AND NOT fh_fine_exempt(f.person_id)                            -- coaches (mig 693)
        AND NOT fh_person_injured_at(f.person_id, f.starts_at)         -- injured that day (mig 510)
        -- No reminder, no missed-RSVP fine (mig 1562): a logged reminder
        -- naming this event, to him, before kickoff.  No-shows always.
        AND (f.fine_kind NOT LIKE 'missed_rsvp%'
             OR NOT (SELECT needs_reminder FROM fine_reminder_policy)
             OR fh_reminded_before(f.person_id, f.fh_event_id, f.starts_at))
   )
   SELECT j.person_id, j.fh_event_id, j.team_id, j.starts_at, j.kind, j.opponent,
          j.fine_kind, amt.amount_usd, j.response, j.attendance
     FROM kept j
     CROSS JOIN LATERAL (
       SELECT fh_fine_amount_usd(j.club_id, j.club_section_id, j.fine_kind,
                                 (j.starts_at AT TIME ZONE 'America/New_York')::date) AS amount_usd
     ) amt
    WHERE amt.amount_usd IS NOT NULL AND amt.amount_usd > 0
 $function$;

COMMIT;
