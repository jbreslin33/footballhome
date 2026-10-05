-- 525 (2026-10-05) — #my: the whose-schedule pills go by training group and
-- game team, and say what still needs an answer.  Owner, on the Me · player
-- / Me · coach pills of mig 524: "i wonder if we should break down the
-- coaches to the separate teams … show on or above pills which ones they
-- are missing rsvp for to make it easy for them? then if all are filled
-- they are good? by further i mean u10/u12 practice as one pill, u8
-- practice as another (2nd grade and under) and liga1/apsl same pill except
-- for games we need diff pills for diff teams".
--
-- A practice belongs to the pill of its teams' RSVP group (rsvp_team_groups,
-- mig 419: 4:30 kids / 5:30 kids / Men — the feed now hands each team's
-- group); a game to the pill of the team it is for; a child keeps its own
-- pill.  Each pill carries the number of this week's events still without
-- an answer, or a tick when there are none.  The two role pills are retired.
UPDATE message_templates SET is_active = false WHERE kind = 'my_schedule' AND tier IN ('who_player', 'who_coach');
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'System', v.label, 'my_schedule', v.tier, NULL, v.body, v.sort, true, true
  FROM (VALUES ('who_practice', 'My schedule — whose: a training group''s practices', '{group} practice', 15),
               ('who_game',     'My schedule — whose: a team''s games',               '{team} game',      16),
               ('who_missing',  'My schedule — pill badge: answers still missing',    '{n} to answer',    17),
               ('who_done',     'My schedule — pill badge: all answered',             'all answered',     18)) AS v(tier, label, body, sort)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'my_schedule' AND m.tier = v.tier);
