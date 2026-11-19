-- 1539 (2026-11-19) — A volunteer's dues read "vol", not $0 / paid
-- (owner: "so instead of paid if voluneter it soudl said vol right?").
-- #teams team-card box (PersonStanding.boxLine) and the live game card's
-- dues note (lineup_note_*).  Words only.
INSERT INTO message_templates (category, label, kind, tier, body, sort_order, client_side)
SELECT v.cat, v.label, v.kind, v.tier, v.body, v.ord, true
  FROM (VALUES
    ('Person standing', 'person_standing', 'box_dues_volunteer', 'Team card box: volunteer (no dues)', '🙋 vol', 79),
    ('Eligibility', 'eligibility', 'lineup_note_volunteer', 'Live game card: volunteer instead of Dues:0', 'Vol', 41)
  ) AS v(cat, kind, tier, label, body, ord)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = v.kind AND m.tier = v.tier);
