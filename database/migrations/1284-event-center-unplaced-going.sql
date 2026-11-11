-- 1284: Event Center games — Going players not yet placed come first, and
-- the list rolls up (owner 2026-11-11: "the ones 'going' who have not been
-- assinged starter or bench or alt need to show at top of page so i can
-- immediaely assing them. also the stuff on page neeedss to be rolled up so
-- that its not a long clutterdd list make it expandable").
--
-- 👥 All Players on a game: ⚠️ Going · Not placed sits open at the top with
-- the position numbers / Bench / Alt right on each card; Starters, Bench,
-- Alt, No response, Not going, Coaches … are closed folds with counts.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Event Center', l, 'event_center', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('sec_unplaced',      'Game — section: Going, not placed yet (top)',        '⚠️ Going · Not placed yet', 1290),
    ('sec_unplaced_note', 'Game — note over the not-placed cards',              'Tap a number to start them at that spot, or Bench / Alt', 1291),
    ('sec_all_placed',    'Game — every Going player is placed',                '✅ Every Going player is placed', 1292),
    ('sec_starters',      'Game — section: starters (fold)',                    '⭐ Starters', 1293),
    ('sec_bench',         'Game — section: bench (fold)',                       '🪑 Bench', 1294),
    ('sec_alt',           'Game — section: alternates (fold)',                  '🔁 Alt', 1295),
    ('side_start',        'Game card — label before the position numbers',      'Start:', 1296),
    ('side_bench',        'Game card — Bench button',                           'Bench', 1297),
    ('side_alt',          'Game card — Alt button',                             'Alt', 1298),
    ('side_no_roster',    'Game card — Going but not on the game roster',       'Not on this game''s roster', 1299)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'event_center' AND m.tier = v.t);
