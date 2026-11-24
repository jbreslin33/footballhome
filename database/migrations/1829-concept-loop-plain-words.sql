-- 1829 (2026-11-24): 🎮 the concept popup — say what the bar's buttons do.
--
-- Owner 11/24, looking at the popup: "the game controls are weird" · "like earlier later
-- watch live?" · "what is that".  The popup is the live match; each time a player starts
-- doing the concept, the seconds around it become a short clip that replays on a loop.
-- "‹ Earlier / Later ›" read like a time scrubber, and nothing said the picture was a
-- replay.  Then: "loop and watch live are confusing. maybe if it was toggle and both showed" —
-- 🔁 Examples | ● Live match is one switch now, both words showing, the current one filled in
-- (frontend/js/game/client.js).  Words only (mig 1828's rows):
UPDATE message_templates SET body = v.b
  FROM (VALUES
    ('loop_example',  '🔁 Replaying example {i} of {n}: {player} doing this (8 seconds, on a loop)'),
    ('loop_waiting',  'This is the live match. Waiting for a player to do this — the first example will replay here.'),
    ('loop_live',     'This is the live match, right now. {n} examples saved.'),
    ('loop_prev',     '‹ Previous example'),
    ('loop_next',     'Next example ›'),
    ('loop_go_live',  '● Live match'),
    ('loop_go_loop',  '🔁 Examples')
  ) AS v(t, b)
 WHERE message_templates.kind = 'taxonomy' AND message_templates.tier = v.t;
