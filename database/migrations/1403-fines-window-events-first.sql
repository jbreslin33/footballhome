-- 1403: fines are worked out from the window's events first (owner 11/16
-- "continue with tuition load fix").  fh_person_fines_all joined every
-- event of every team to every roster row and filtered by date LAST:
-- 678k rows walked to keep 2.5k, ~3 s per call — #tuition's Men's tab
-- (3 months of fines on the cards) and the 24-month fines board paid it
-- on every open.  Same rows out: the window's events (date, not deleted,
-- not cancelled, kinds practice/match/intrasquad) are picked first, then
-- their teams and roster rows; joined_at is still checked per person.
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
