-- 1146 (2026-11-06) — The goal-kick note says the Law exactly.
--
-- The game session (mig 1145, James: "ok just turn it over to game") made
-- Law 16 the Law exactly: opponents out of the penalty AREA, not across
-- the whole width.  The app now caps a spot only inside the area's width
-- (tactic_restarts.zone_*), so the note under a goal-kick state says so.
UPDATE message_templates SET body = '⚖️ {label}: none of ours inside their penalty area until the ball is played.'
 WHERE kind = 'tactics' AND tier = 'restart';
