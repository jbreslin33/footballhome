-- 1060: no LeagueApps member is ever missing from #teams (owner
-- 2026-11-04: "you missing players lol. move any la player to the age group
-- they fit at 'as long as its under' and if u15 or whatever then move to
-- u12. move them all to practice squad. we should never have an la member
-- missing from teams or rosters").
--   • Undoes mig 1057's exact-age winter teams: teams.age_exact back to
--     false on winter U10/U11/U12, so fh_youth_fit_team is the age band
--     again — the youngest team at or above the kid's age, else the oldest
--     (U13+ → U12).  The column stays for later use; nothing sets it.
--   • Every active youth LA member with no team in a term gets that term's
--     fit team (fh_youth_place for fall + winter).  New rows land 🏋
--     Practice Squad (no winter list).  ACTIVE players are untouched;
--     ranks re-set by RSVPs, ACTIVE first.
--   • Adults likewise: every active men's / women's member with no team
--     of their gender gets the home team (fh_adult_place, mig 1038).

BEGIN;

UPDATE teams SET age_exact = false WHERE age_exact;

SELECT fh_youth_place(m.person_id)
  FROM (SELECT DISTINCT m.person_id FROM person_la_memberships m JOIN leagueapps_programs lp ON lp.program_id = m.la_program_id
         WHERE m.ended_at IS NULL AND lp.variant = 'active' AND lp.category IN ('boys', 'girls')
           AND NOT EXISTS (SELECT 1 FROM person_adult_overrides o WHERE o.person_id = m.person_id)) m;

SELECT fh_adult_place(m.person_id, lp.category)
  FROM person_la_memberships m JOIN leagueapps_programs lp ON lp.program_id = m.la_program_id
 WHERE m.ended_at IS NULL AND lp.variant = 'active' AND lp.category IN ('men', 'women');

WITH s AS (
  SELECT tp.id,
         row_number() OVER (PARTITION BY tp.team_id ORDER BY
           COALESCE(rs.counts_as_on_roster, false) DESC,
           count(r.id) DESC,
           count(r.id) FILTER (WHERE r.responded_at >= now() - interval '14 days') DESC,
           p.last_name, p.first_name) AS rnk
    FROM team_persons tp
    JOIN persons p ON p.id = tp.person_id
    LEFT JOIN roster_statuses rs ON rs.id = tp.roster_status_id
    LEFT JOIN fh_event_rsvps r ON r.person_id = tp.person_id
   WHERE tp.removed_at IS NULL AND tp.team_id IN (940, 942, 946)
   GROUP BY tp.id, tp.team_id, rs.counts_as_on_roster, p.last_name, p.first_name)
UPDATE team_persons tp SET coach_sort_order = s.rnk FROM s WHERE s.id = tp.id;

COMMIT;
