-- 1202 (2026-11-09): 🎯 Tactics — a frozen Premier League moment copied
-- over to our tactics board (docs/tactics-trainer.md step 4; owner:
-- "except right to copy it over to … the event center").
--
-- POST /api/tactic-plans/copies (TacticPlansController) adds a FRESH state
-- under the plan's root for every copy and never touches an authored one.
-- copied_from holds where it came from: { source: {home, away, clock,
-- match_id}, ball: {x,y}, ours: [{position_id,x,y,concept_id,target}],
-- by_user_id, at } — ours as the engine had them, kept for reference; the
-- board still solves our spots from the jobs (one source of truth).
--
-- A pass to their #N stays unique among AUTHORED states only, so a copy
-- with the same ball carrier sits beside James's drawn step, not over it.

ALTER TABLE tactic_states ADD COLUMN IF NOT EXISTS copied_from JSONB;
COMMENT ON COLUMN tactic_states.copied_from IS
  'mig 1202: set = copied from a frozen game moment (trainer); {source,ball,ours,by_user_id,at}. NULL = authored on the board.';

ALTER TABLE tactic_states DROP CONSTRAINT IF EXISTS tactic_states_plan_id_parent_state_id_ball_with_key;
CREATE UNIQUE INDEX IF NOT EXISTS tactic_states_one_pass_authored
    ON tactic_states (plan_id, parent_state_id, ball_with) WHERE copied_from IS NULL;

-- Board copy for the copied step's pill and note.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'Game Center', v.l, 'tactics', v.t, NULL, v.b, v.o, true, true
  FROM (VALUES
    ('Game Center — 🎯 Tactics: pill of a step copied from the game ({home}, {away}, {clock}, {ball})', 'copied_pill', '📋 {home} v {away} {clock} · their {ball}', 1254),
    ('Game Center — 🎯 Tactics: note on a copied step ({home}, {away}, {clock})', 'copied_note',
     'Copied from the game: {home} v {away} at {clock}. Their men stand where they stood; ours are solved from the jobs.', 1255),
    ('Game Center — 🎯 Tactics: our-formation dropdown, the game''s own shape ({formation})', 'us_game', 'Ours: {formation} (this game)', 1256)
  ) AS v(l, t, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'tactics' AND m.tier = v.t);
