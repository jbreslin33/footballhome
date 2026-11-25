-- 1895 (2026-11-25): the concept viewer is the whole pitch, every player, a scrub bar.
--
-- Owner 11/25: "states need to be writtin small next to player but able to see through it. it should
-- follow plaeyr" · "we need youutbe like bar to slide the game forward or back to see exacatly what
-- statest the plaeyrs is in and the situation on field" · "get rid of one on side" · "orient field side
-- to side. even on phone as they would tilt phone" · "we need also controls for play speed. a slider bar
-- will do" · "all controls on pitch and transpearnet. the iptch should be whole screen. exit is
-- transparent on pitch" · "stop switching player focus. show all players on screen at all times" ·
-- "don't jump to diff players its disorietning".
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'Football', 'Concept viewer — ' || v.l, 'taxonomy', v.t, NULL, v.b, v.o, true, true
  FROM (VALUES
    ('exit button', 'view_exit', '✕ Exit', 440),
    ('live pill (playing the newest moment)', 'view_live', '● LIVE', 441),
    ('back to live button', 'view_go_live', 'Go live ›', 442),
    ('speed slider value ({x})', 'view_speed', '{x}×', 443),
    ('hint: tap a player', 'view_tap', 'Tap a player for his states', 444),
    ('player popup title ({num}, {player})', 'view_player', '#{num} {player}', 445),
    ('loader: connecting', 'view_connecting', 'Connecting to the live match…', 446),
    ('time behind live ({s})', 'view_behind', '−{s}', 447)
  ) AS v(l, t, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'taxonomy' AND m.tier = v.t);
