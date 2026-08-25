-- 303 — Point the bare `u8` and `u12` calendar tags at the real teams.
--
-- Why: migration 302 deleted "Lighthouse Youth League U8" (916) and
-- "…U12" (917), and their gcal_team_aliases rows went with them. Those
-- rows were the bug — `Team: u8` and `Team: u12` in a gcal description
-- resolved to those empty LYL rosters instead of the real U8 (912, 18
-- players) and U12 (914, 14 players), which is why both age groups had
-- zero event attachments while 710 future practices carried the dead
-- teams. But deleting them leaves the tags resolving to nothing at all,
-- which is no better: the live recurring practice tagged
-- `Team: u10, u12, u19` would attach U10 and U19 and silently skip U12.
--
-- Only the bare spellings were lost. 'u8 boys' and 'u12 boys' already
-- pointed at 912/914 and are untouched — which is why the misrouting was
-- invisible for so long: whichever spelling ops happened to type decided
-- whether the practice reached anyone.
--
-- Both club spellings, matching what migration 286 established for every
-- alias pointing at an active team.
INSERT INTO gcal_team_aliases (club_alias, team_alias, team_id, notes)
VALUES
    ('boys', 'u8',  912, 'U8 Boys — real active team (repointed off deleted LYL U8 916)'),
    ('boy',  'u8',  912, 'Alt club spelling — accepts `Club: Boy`'),
    ('boys', 'u12', 914, 'U12 Boys — real active team (repointed off deleted LYL U12 917)'),
    ('boy',  'u12', 914, 'Alt club spelling — accepts `Club: Boy`')
ON CONFLICT (club_alias, team_alias) DO UPDATE
  SET team_id = EXCLUDED.team_id,
      notes   = EXCLUDED.notes;
