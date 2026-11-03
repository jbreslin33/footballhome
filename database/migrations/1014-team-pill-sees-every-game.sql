-- 1014: Team pill "👀 Sees every game" line per column (owner 2026-11-03:
-- "so active is who by default without me interaction sees apsl to rsvp
-- right? … we always bring 20 so this list needs to be at least 20").
-- Counts full spots not injured + standing call-ups against the
-- match-day squad (teams.matchday_squad_size, NULL = field_size + 9).

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Roster sheet', l, 'roster_sheet', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('board_sees_ok',    'Team boards — Team pill: sees every game, squad covered', '👀 Sees every game: {n} / {target}', 1015),
    ('board_sees_short', 'Team boards — Team pill: sees every game, squad short',   '👀 Sees every game: {n} / {target} · ⚠ {short} short — call up or add to the team', 1016)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'roster_sheet' AND m.tier = v.t);
