-- 584 (2026-10-14) — open the Sun 2026-10-18 USASA Cup tie to EVERY active
-- player on the three men's league teams, not just the submitted cup squad.
-- Owner: "make it so all players on apsl, reserves and liga 1 can see the
-- cup game … they should all be able to rsvp and we can select. i can then
-- edit the official roster/player pool."
--
-- Mechanism unchanged from mig 568: the cup container team (939, mig 567)
-- carries no players, so fh_event_invites rows are the only way the game
-- reaches anyone.  This widens the invite list from cup_roster_players to
-- the full APSL (35), APSL Reserves (938) and Liga 1 (120) rosters; the
-- 24 cup-squad invites (and their RSVPs) already stand and are skipped by
-- the open-invite unique index.  from_team_id records the player's own
-- team (APSL beats Reserves beats Liga 1 for dual-rostered players), the
-- same reading as youth call-ups (mig 355).
--
-- Idempotent: inserts nothing until the fh_events row exists, and never
-- duplicates an open invite.

INSERT INTO fh_event_invites (fh_event_id, person_id, from_team_id, invited_by_user_id, note)
SELECT e.id, pool.person_id, pool.team_id,
       (SELECT id FROM users WHERE person_id = 1),
       'All men''s league players invited to RSVP; squad picked from responses (mig 584)'
  FROM fh_events e
  JOIN gcal_events g ON g.id = e.gcal_event_id AND g.deleted_at IS NULL
  CROSS JOIN (
      SELECT DISTINCT ON (tp.person_id) tp.person_id, tp.team_id
        FROM team_persons tp
       WHERE tp.team_id IN (35, 938, 120)
         AND tp.removed_at IS NULL
       ORDER BY tp.person_id,
                CASE tp.team_id WHEN 35 THEN 1 WHEN 938 THEN 2 ELSE 3 END
  ) pool
 WHERE e.kind = 'match'
   AND e.league ILIKE '%usasa%'
   AND (g.starts_at AT TIME ZONE 'America/New_York')::date = '2026-10-18'
ON CONFLICT (fh_event_id, person_id) WHERE revoked_at IS NULL DO NOTHING;
