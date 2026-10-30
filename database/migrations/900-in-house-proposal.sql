-- 900 (2026-10-30) — #in-house-proposal: the case for youth in-house.
--
-- Owner: "should we go completely in house for indoor and outdoor until a
-- certain age?", "lets make a proposal page at top level of fh", "for in
-- house we can pick a specific time for games and days", "1 travel team at
-- the oldest age for now which would be u12", "indoor", "same for outdoor
-- inter county", "more kits like men for home and away so we can play lh vs
-- lh. blue vs white".
--
-- A proposal, so nothing about teams or schedules changes here.  The numbers
-- are a snapshot of 2026-10-30 (rosters after mig 899, fall PPR games from
-- gcal), written as copy on purpose: the page argues from that date.
--
-- In a body, a line starting "- " is a bullet.  plan_rows is one age per
-- line, cells split by |.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Youth', l, 'in_house_proposal', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('tile_title',   'Role picker tile',              'In-House Proposal', 1),
    ('tile_sub',     'Role picker tile, second line', 'Lighthouse blue vs white through U10, one U12 travel team', 2),
    ('title',        'Page title',                    '🏠 In-House Proposal', 3),
    ('subtitle',     'Under the page title',          'Youth indoor and outdoor. Numbers as of October 30, 2026.', 4),

    ('ask_head',     'Section heading',               'The proposal', 5),
    ('ask_body',     'The proposal',
'- U8 and U10 go fully in-house, indoor and outdoor: Lighthouse blue vs Lighthouse white, same day and same time every week.
- U12 is our one travel team for now: PPR Indoor this winter, then Inter-County outdoors.
- Youth get home and away kits like the men, so any two Lighthouse sides can play each other.
- Older players stay as they are: 7 players, practices, no games.', 6),

    ('stat_1_value', 'Strip card',                    '16', 7),
    ('stat_1_label', 'Strip card',                    'different game days and times this fall', 8),
    ('stat_2_value', 'Strip card',                    '18 of 27', 9),
    ('stat_2_label', 'Strip card',                    'games were away from Lighthouse', 10),
    ('stat_3_value', 'Strip card',                    '10 of 31', 11),
    ('stat_3_label', 'Strip card',                    'U8 and U10 players are not on the league roster, so they get no games unless called in', 12),

    ('family_head',  'Section heading',               'Why it is easier for families', 13),
    ('family_body',  'Family reasons',
'- We pick the day and the time. It goes on the family calendar once and stays there.
- Fall games ran from 8:00 on a Saturday morning to 7:00 on a Wednesday night, on 13 dates. The schedule was not ours to set.
- Every game is at home, so no one drives across the city.
- U8 and U10 play back to back. Families with kids in both age groups stay in one place.
- On Monday, October 19 at 6:00, U10 and U12 played at different grounds. That cannot happen in-house.
- Every kid plays. No one sits at home because a league roster is full.', 14),

    ('slot_head',    'Section heading',               'Proposed game slot', 15),
    ('slot_body',    'The slot',
'Sundays at Lighthouse Sport Complex: U8 at 9:30, U10 at 10:30. Our home youth games already used these times on October 25.', 16),

    ('plan_head',    'Section heading',               'Age by age', 17),
    ('plan_cols',    'Table columns, split by |',     'Age|Players now|Program|Indoor|Outdoor', 18),
    ('plan_rows',    'Table rows, split by |',
'U8 (ages 6–8)|19|In-house|Blue vs white|Blue vs white
U10 (ages 9–10)|19|In-house|Blue vs white|Blue vs white
U12 (ages 11–12)|14|One travel team|PPR Indoor, 12 on the roster|Inter-County
U13 and up|7|No change|Practices|Practices', 19),
    ('plan_note',    'Under the table',
'Players are counted by age, so the seven 10-year-olds now on the U12 board are in U10. If this goes ahead, the empty U10 and U11 Indoor entries come off, and U8 and U10 finish the fall PPR schedule, which runs through November 8.', 20),

    ('risk_head',    'Section heading',               'What could go wrong', 21),
    ('risk_body',    'Risks',
'- Some families want outside games. Before U12 we would have nothing to offer them, and they could leave.
- Blue vs white is the same opponent every week. Reshuffling the sides every few weeks keeps it fresh.
- 19 players is thin for two 7-a-side teams once kids miss a week. Roll was taken at only 5 of 22 practices, so we do not know real turnout. On a short day, play smaller.
- 14 players at U12 for 12 indoor spots leaves two out. They keep practicing and come in as Call Ins.', 22),

    ('open_head',    'Section heading',               'Still to settle', 23),
    ('open_body',    'Open items',
'- Indoor: which room, and can we hold one fixed time? The Community Center hosted 11 practices this fall, but it still needs checking for games.
- Sunday field time against the men''s home games.
- Kits: price and how many. The most we would need is one extra kit for each of 38 U8 and U10 players.
- PPR Indoor and Inter-County: fees, entry deadlines and roster sizes.
- Who referees in-house games. The plan now carries $820 of youth referee fees through April, and some of that would go away.', 24)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'in_house_proposal' AND m.tier = v.t);
