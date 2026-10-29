-- 863 (2026-10-29) — #teams Team pill: ＋ from LA.
--
-- TODO "Adds, split by pill": the Team pill answers "is he one of ours?",
-- so each team column gets a ＋ from LA picker — every LeagueApps
-- registrant in the section (Unassigned + every team) who is not on this
-- team; a tap puts him on it with the board's own additive assign.  The
-- league side (asking for him on the official roster) stays the Roster
-- pill's NEEDS ADD → PROPOSED lane (mig 817).  Admins and that team's
-- coaches only.

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Roster sheet', l, 'roster_sheet', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('board_from_la_btn',    'Team boards — Team pill: add-a-registrant button',                    '＋ from LA', 960),
    ('board_from_la_search', 'Team boards — Team pill: ＋ from LA search box placeholder',           'Search a name', 961),
    ('board_from_la_on',     'Team boards — Team pill: ＋ from LA row note, his other teams ({teams})', 'on {teams}', 962),
    ('board_from_la_free',   'Team boards — Team pill: ＋ from LA row note, on no team',             'no team', 963),
    ('board_from_la_none',   'Team boards — Team pill: ＋ from LA when nobody is left to add',        'Every LA registrant is already on this team', 964)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'roster_sheet' AND m.tier = v.t);
