-- 1159 (2026-11-07): Tactics 🧠 — 3-R2 high block, "ball to their 5" ready to pick.
--
-- Owner 11/7, asked what 3-R2 does when the goal kick goes to their 5 and
-- what 3-L2's back five do: "just put the options in drop down."  The
-- dropdowns already list every defending concept (mig 1153) for every
-- outfield man, jobs or not.  This opens the 3-R2 step from their GK to
-- their 5 (plan 1's root) the way the ⚽ Pass to: row's red 5 would: their
-- men and our jobs copied from the goal kick, for the coach to change.
-- 3-L2's 2–6 need nothing — no job = "— no job —" with the full list.
DO $$
DECLARE root int; sid int;
BEGIN
  SELECT s.id INTO root FROM tactic_states s
    JOIN tactic_plans p ON p.id = s.plan_id
    JOIN formations f ON f.id = p.formation_id AND f.name = 'Asymmetric 3-5-2 (3-R2)'
    JOIN formations o ON o.id = p.opponent_formation_id AND o.code = '4-3-3'
   WHERE p.moment = 'out_of_possession' AND p.block_height = 'high' AND s.parent_state_id IS NULL;
  IF root IS NULL THEN RAISE NOTICE '3-R2 plan not here — skipped'; RETURN; END IF;

  INSERT INTO tactic_states (plan_id, parent_state_id, ball_with)
  SELECT plan_id, id, 5 FROM tactic_states WHERE id = root
  ON CONFLICT (plan_id, parent_state_id, ball_with) DO NOTHING
  RETURNING id INTO sid;
  IF sid IS NULL THEN RETURN; END IF;   -- already drawn

  INSERT INTO tactic_state_opponents (state_id, number, x, y)
  SELECT sid, number, x, y FROM tactic_state_opponents WHERE state_id = root;
  INSERT INTO tactic_jobs (state_id, position_id, kind, target_b, partner_position_id, stance)
  SELECT sid, position_id, kind, target_b, partner_position_id, stance FROM tactic_jobs WHERE state_id = root;
  INSERT INTO tactic_job_targets (state_id, position_id, number, ord)
  SELECT sid, position_id, number, ord FROM tactic_job_targets WHERE state_id = root;
END $$;
