-- 1747 (2026-11-23) — Coaches inside each answer section of an event's list.
-- Owner: "we need coaches included in players sections at end section.
-- Coaches: xx" + "so it would the say x palyers and x coached going,,, x
-- playes and x coaches not going etc".
-- Page only (EventScreen._comingHtml): the separate Coaches fold is gone;
-- Going / No response / Not going each end with their coaches under the
-- existing sec_coaches heading, and the section count names both. The
-- player number never includes a coach. Words only.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Event Center', v.label, 'event_center', v.tier, NULL, v.body, v.sort_order, true, true, false
  FROM (VALUES
    ('Event — section count: players and coaches', 'sec_count_both', '{players} and {coaches}', 1350),
    ('Event — section count: players ({n})',       'n_players',      '{n} players',             1351),
    ('Event — section count: one player',          'n_player',       '1 player',                1352),
    ('Event — section count: coaches ({n})',       'n_coaches',      '{n} coaches',             1353),
    ('Event — section count: one coach',           'n_coach',        '1 coach',                 1354)
  ) AS v(label, tier, body, sort_order)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'event_center' AND m.tier = v.tier);
