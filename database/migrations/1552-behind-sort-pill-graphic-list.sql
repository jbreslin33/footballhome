-- 1552 (2026-11-19) — #teams: 🚩 Behind sort pill + Team view Graphic | List.
--
-- Owner, after mig 1551 hard-sorted the team cards: "wait we already have
-- sort buttons" → the order is a pill in the existing sort row (🚩 Behind:
-- both → dues → RSVP → up to date) and the team cards follow whichever
-- sort pill is lit, like the columns.  And: "also why are we shoing the
-- old view too? that should be a toggle to show grphic or list view
-- right?" → Team view gets 🗂 Graphic (team cards only, default) | ☰ List
-- (the columns only).
INSERT INTO message_templates (category, label, kind, tier, body, sort_order, client_side)
SELECT 'Roster sheet', v.label, 'roster_sheet', v.tier, v.body, v.ord, true
  FROM (VALUES
    ('board_sort_behind',    'Sort pill: behind on RSVP / dues first', '🚩 Behind', 903),
    ('board_layout_graphic', 'Team view layout pill: the team cards', '🗂 Graphic', 904),
    ('board_layout_list',    'Team view layout pill: the columns', '☰ List', 905)
  ) AS v(tier, label, body, ord)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'roster_sheet' AND m.tier = v.tier);
