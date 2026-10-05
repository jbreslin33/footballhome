-- 524 (2026-10-05) — #my: whose schedule — Me as player / Me as coach / a
-- pill per child.  Owner: "having a player pill, coach pill, and for me or
-- parents like me who have a role at club and a child a child pill with
-- their name. so we can set schedule that way? … its confusing with all the
-- stuff jammed in."
--
-- A second row of pills on #my filters whichever view is showing by why the
-- event is on the viewer's schedule: their own playing (feed my_role player
-- / invited), their coaching (coach / staff), or one child (guardian_targets)
-- — a child's pill also narrows each card to that child's Go / No row.  The
-- row only appears when the viewer has at least two of these.  Words here;
-- a child's pill is the child's first name.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'System', v.label, 'my_schedule', v.tier, NULL, v.body, v.sort, true, true
  FROM (VALUES ('who_all',    'My schedule — whose: everything', 'Everyone',     12),
               ('who_player', 'My schedule — whose: my playing', 'Me · player',  13),
               ('who_coach',  'My schedule — whose: my coaching', 'Me · coach',  14)) AS v(tier, label, body, sort)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'my_schedule' AND m.tier = v.tier);
