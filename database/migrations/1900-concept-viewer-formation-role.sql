-- 1900 (2026-11-25): the viewer's FORMATION box shows the formation his side plays and his place in it.
-- Owner 11/25: "send the formation and his role too". The game server sends them on ROSTER (2.11 tail:
-- formations.code, the board label, formation_slot_roles.role); the words for each role are here.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'Football', 'Concept viewer — ' || v.l, 'taxonomy', v.t, NULL, v.b, v.o, true, true
  FROM (VALUES
    ('formation row ({code})', 'view_formation', '{code}', 454),
    ('formation popup ({code}, {team})', 'view_formation_def', '{team} play {code}.', 455),
    ('position row ({role}, {label})', 'view_position', '{role} ({label})', 456),
    ('position popup ({role}, {label}, {num})', 'view_position_def', 'He plays {label}, the number {num} in the shape: a {role}.', 457),
    ('role: keeper', 'role_keeper', 'Goalkeeper', 460),
    ('role: centre-back', 'role_centre-back', 'Centre-back', 461),
    ('role: full-back', 'role_full-back', 'Full-back', 462),
    ('role: wing-back', 'role_wing-back', 'Wing-back', 463),
    ('role: single-pivot', 'role_single-pivot', 'Holding midfielder', 464),
    ('role: double-pivot', 'role_double-pivot', 'One of the two holding midfielders', 465),
    ('role: eight', 'role_eight', 'Central midfielder (an eight)', 466),
    ('role: ten', 'role_ten', 'Attacking midfielder (a ten)', 467),
    ('role: wide-forward', 'role_wide-forward', 'Wide forward', 468),
    ('role: nine', 'role_nine', 'Centre-forward (a nine)', 469)
  ) AS v(l, t, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'taxonomy' AND m.tier = v.t);
