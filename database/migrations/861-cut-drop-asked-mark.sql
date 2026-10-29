-- 861 (2026-10-29) — #teams Roster pill: a ✂ cut whose drop the league has
-- been asked for says so.
--
-- TODO "Mark a cut's drop as submitted": a cut player whose team row was
-- swept (no playing membership) has no card to move to Pending Drop, so
-- after the #apsl roster-moves email's ✓ Sent (league_move_requests, mig
-- 829) his list row still read "needs to be dropped".  The board now reads
-- the last drop ask per list name (RosterBoardExtras officialRosters.dropAsked)
-- and shows this row note instead.  {date} = the ask.

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Roster sheet', l, 'roster_sheet', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('board_official_cut_asked', 'Team boards — Roster pill: list row for a cut player whose drop the league was asked for ({date})',
     '⏳ ✂ drop asked {date} — waiting on the league', 953)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'roster_sheet' AND m.tier = v.t);
