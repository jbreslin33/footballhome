-- 1811 (2026-11-24): 🧬 Taxonomy of Football — a legend for the card colours.
--
-- Owner 11/24: "what are the colors for green for cover the presser etc" — the stripe on
-- each card was explained nowhere.  The reach pills now carry a dot in the stripe's colour
-- (green = the engine plays it, blue = the board places it, amber = a board job with no
-- geometry, none = named only) under this one line.  Words only.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'Football', 'Taxonomy of Football — the legend line above the reach pills', 'taxonomy', 'legend', NULL,
       'The colour on the left of each card is how far the idea reaches. Tap one to see only those:', 9, true, true
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'taxonomy' AND m.tier = 'legend');
