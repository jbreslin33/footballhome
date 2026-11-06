-- 1142 (2026-11-06) — Restart laws on plan states: Law 16, the goal kick.
--
-- Owner: "remember on goal kick a 'defender' can't be in the penalty box or
-- higher than 18 yards from opp goal" — "that's a law of game".
-- IFAB Laws of the Game, Law 16 (The Goal Kick): opponents must be outside
-- the penalty area until the ball is in play.  As the owner states it for
-- the plans: none of ours deeper than their 18-yard line (16.5 m → y 84.29
-- in plan coordinates), across the whole width.
--
-- tactic_restarts holds the law (code, label, law, our max y while it
-- applies); tactic_states.restart tags a state as that restart.  Every
-- out_of_possession plan's root (their GK placing the ball) is a goal
-- kick; once the ball is played (a child state) the law no longer binds.
-- App: TacticGeometry.solve caps our spots at max_y; the engine reads the
-- same row (contract: game/DESIGN.md §8.137).

CREATE TABLE IF NOT EXISTS tactic_restarts (
    code        text PRIMARY KEY,
    label       text NOT NULL,
    law         text NOT NULL,                 -- the IFAB law it comes from
    our_max_y   numeric(5,2) NOT NULL CHECK (our_max_y BETWEEN 0 AND 100)
);
INSERT INTO tactic_restarts (code, label, law, our_max_y) VALUES
    ('goal_kick', 'Goal kick', 'Law 16 — opponents outside the penalty area until the ball is in play', 84.29)
ON CONFLICT (code) DO NOTHING;

ALTER TABLE tactic_states ADD COLUMN IF NOT EXISTS restart text REFERENCES tactic_restarts(code);

UPDATE tactic_states s SET restart = 'goal_kick'
  FROM tactic_plans p
 WHERE p.id = s.plan_id AND s.parent_state_id IS NULL AND p.moment = 'out_of_possession' AND s.ball_with = 1
   AND s.restart IS NULL;

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Game Center', 'Game Center — Tactics: a restart law holds our players back', 'tactics', 'restart', NULL, '⚖️ {label}: none of ours past their 18-yard line until the ball is played.', 1237, true, true, false
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'tactics' AND m.tier = 'restart');
