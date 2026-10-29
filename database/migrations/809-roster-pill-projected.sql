-- 809 (2026-10-29) — #teams Roster pill: PROJECTED ROSTER, what the
-- league list looks like once the moves land.  Owner: "he counts in the
-- official total until he is dropped but we track him and see what new
-- projected roster would look like".
--
-- Projected = OFFICIAL − (cut + dropping + pending drop) + (proposed +
-- pending add).  Over teams.max_roster turns it red.  Copy only — the
-- numbers come from the board's own lanes.

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Roster sheet', l, 'roster_sheet', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('board_projected_h',      'Team boards — Roster pill: the list once the moves land',            'PROJECTED ROSTER',    953),
    ('board_projected_banner', 'Team boards — official banner suffix ({n})',                         '→ {n} projected',     954),
    ('board_projected_over',   'Team boards — projected past teams.max_roster ({n} over, {max} max)', '{n} over the {max} max', 955),
    ('board_projected_add',    'Team boards — note on a projected add row ({step})',                  '+ {step}',            956)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'roster_sheet' AND m.tier = v.t);
