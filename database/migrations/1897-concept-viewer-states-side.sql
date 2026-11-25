-- 1897 (2026-11-25): the followed player's states docked on the side, one line each, with what he is
-- DOING and the concept the engine says he is playing back in.
-- Owner 11/25: "we need the states on the side. also tehre is no way that is all the states going on.
-- his job on the ball" · "i hate how you list the states in a line. they should be 1 line each".
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'Football', 'Concept viewer — ' || v.l, 'taxonomy', v.t, NULL, v.b, v.o, true, true
  FROM (VALUES
    ('state table row: the concept his act plays', 'tbl_using', 'Playing', 448),
    ('side panel heading: machines on ({n})', 'view_machines_on', 'Machines on ({n})', 449),
    ('side panel heading: who ({num}, {player})', 'view_following', 'Following #{num} {player}', 450)
  ) AS v(l, t, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'taxonomy' AND m.tier = v.t);
