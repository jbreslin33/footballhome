-- 1124 (2026-11-06) — Cover-shadow asks for its man; the shadow runs from
-- the ball.
--
-- Owner: "when i click cover shadow for tolu 9 it goes back to no job. if
-- i pick cover shadow it should then prompt for who to cover shadow AND
-- its assumed that is from the current ball carrier."  (The snap-back was
-- the save being refused — Controller::getPathParam is a stub; fixed in
-- the controllers.)  Picking a job now opens the player's sheet with a
-- "— who? —" pick; the shadow line always runs from whoever has the ball,
-- and pressing a later receiver from that shadow stays optional.
UPDATE tactic_job_kinds SET target_b_label = 'then press' WHERE code = 'cover_shadow';

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Game Center', 'Game Center — Tactics: pick the man for a new job', 'tactics', 'who', NULL, '— who? —', 1233, true, true, false
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'tactics' AND m.tier = 'who');
