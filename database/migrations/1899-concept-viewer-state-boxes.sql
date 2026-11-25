-- 1899 (2026-11-25): the followed player's states in boxes down the left — formation, style, then actions
-- at the bottom. Owner 11/25: "now we need to categgorize the states. into diff boxes down the left side.
-- formation, stylle, then actions down bottom."
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'Football', 'Concept viewer — ' || v.l, 'taxonomy', v.t, NULL, v.b, v.o, true, true
  FROM (VALUES
    ('box: formation (team phase, his place in the shape)', 'box_formation', 'Formation', 451),
    ('box: style (how we defend: marking scheme, pressing distance, cover shadow)', 'box_style', 'Style', 452),
    ('box: actions (what he is doing: press, loose ball, double-team, recover, cover)', 'box_actions', 'Actions', 453)
  ) AS v(l, t, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'taxonomy' AND m.tier = v.t);
