-- 1498 (2026-11-18) — Under each name on the lineup: plain words, not A:/P:.
-- Owner 11/18: "i think we show for each player a simple way to show what
-- practices they made and if they are on pace or made threshold depending on
-- that week".  Replaces lineup_note_practice ("A:{attended} P:{total}", mig
-- 1299/1301) with three states against the week's own number (barn night
-- counts when attended, mig 1497):
--   ✓ Made it (1/1)   green  — attended ≥ needed
--   On pace · 0/1     yellow — attended + said Going ≥ needed
--   Needs 1           red    — short even counting the Goings
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'System', v.label, 'eligibility', v.tier, NULL, v.body, v.sort_order, true, true, false
  FROM (VALUES
    ('Lineup name note — made it',  'lineup_note_made',    '✓ Made it ({attended}/{needed})', 70),
    ('Lineup name note — on pace',  'lineup_note_on_pace', 'On pace · {attended}/{needed}',   71),
    ('Lineup name note — short',    'lineup_note_short',   'Needs {left}',                    72)
  ) AS v(label, tier, body, sort_order)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'eligibility' AND m.tier = v.tier);
