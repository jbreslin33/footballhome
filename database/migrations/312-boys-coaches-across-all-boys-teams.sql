-- 312 — Every boys coach coaches every active boys team.
--
-- Why (2026-08-25, owner: "make the coaches coaches of all active
-- teams", answering the question migration 311 left open about Marcelo
-- Osorio-Soto and Walter Juarez de Leon).
--
-- 311 gave the four coach-less teams the three coaches who were on all
-- five existing boys teams, and deliberately stopped short of the other
-- two because their coverage looked like a per-team choice: Marcelo on
-- four of five, Walter on two. The owner's answer is that it was not a
-- choice — the staff coaches the programme, not individual age groups.
--
-- This matters beyond tidiness. A coach's move dropdown only offers
-- teams in coachedTeamIds, so a partial staff list silently removes a
-- coach's ability to move a player between age groups — the single most
-- common thing they do on this board. Walter could see two of nine.
--
-- Scope is boys only, deliberately. "All active teams" is read against
-- the cohort under discussion: mens (35, 120) and womens (901) carry a
-- different, smaller staff — James and Marcelo — and pulling Anthony,
-- Luke and Walter into the adult sides would be a cross-cohort grant the
-- owner has not asked for. Left for them to confirm separately.
--
-- coach_role_id left NULL, matching every existing boys row except the
-- three head-coach designations on 912/913/914.
INSERT INTO team_coaches (team_id, coach_id)
SELECT t.id, c.coach_id
  FROM teams t
  CROSS JOIN (
      -- Whoever already coaches an active boys team — no hardcoded ids,
      -- so a coach added to one team later is picked up by a re-run.
      SELECT DISTINCT tc.coach_id
        FROM team_coaches tc
        JOIN teams bt ON bt.id = tc.team_id
       WHERE bt.gender_category = 'boys' AND bt.is_active AND tc.ended_at IS NULL
  ) c
 WHERE t.gender_category = 'boys'
   AND t.is_active
   AND NOT EXISTS (
         SELECT 1 FROM team_coaches x
          WHERE x.team_id = t.id AND x.coach_id = c.coach_id AND x.ended_at IS NULL
       );

-- Guard: every active boys team must now carry the full staff.
DO $$
DECLARE bad TEXT; staff INT;
BEGIN
    SELECT count(DISTINCT tc.coach_id) INTO staff
      FROM team_coaches tc JOIN teams t ON t.id = tc.team_id
     WHERE t.gender_category = 'boys' AND t.is_active AND tc.ended_at IS NULL;

    SELECT string_agg(t.name || ' (' || cnt || '/' || staff || ')', ', ') INTO bad
      FROM (SELECT t.id, t.name,
                   (SELECT count(*) FROM team_coaches tc
                     WHERE tc.team_id = t.id AND tc.ended_at IS NULL) AS cnt
              FROM teams t
             WHERE t.gender_category = 'boys' AND t.is_active) t
     WHERE t.cnt <> staff;

    IF bad IS NOT NULL THEN
        RAISE EXCEPTION 'boys teams without the full staff: %', bad;
    END IF;
END $$;
