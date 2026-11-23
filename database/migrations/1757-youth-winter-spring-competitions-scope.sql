-- 1757 (2026-11-23): the youth winter and spring competitions belong to their age, not to club-wide.
--
-- Owner 2026-11-23: "for youth the question is do we count fall separate for
-- comps. we prob should so we have fall ppr travel u8, u10 and u12 … then
-- winter ppr travel u12. then spring inter county u12".
--
-- Each season's entry is already its own row (team_season_entries), but the
-- winter and spring teams (964/965/971/972) carry no budget scope, so their
-- fees fell under Club-wide on the Operating Budget — shared out to every
-- section — and were missing from #competitions.  Like the APSL reserves
-- list (mig 1320), the entry now names its scope: the age it is for.
-- No amounts change; $1,475 of 2026-27 moves from Club-wide to U10 / U12.

BEGIN;

UPDATE team_season_entries SET budget_scope = 'u10' WHERE team_id IN (965, 971) AND budget_scope IS NULL;
UPDATE team_season_entries SET budget_scope = 'u12' WHERE team_id IN (964, 972) AND budget_scope IS NULL;

INSERT INTO message_templates (category, label, kind, tier, body, sort_order, client_side)
SELECT 'Finances', 'Finances — competitions: ' || v.what, 'finances', v.tier, v.body, v.n, true
  FROM (VALUES
    ('game coaching line',  'cp_game_coaching', 'Game coaching', 952),
    ('game coaching split', 'cp_coach_split',   'coaching games are counted per team, shared evenly between its {n} competitions here', 953)
  ) v(what, tier, body, n)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'finances' AND m.tier = v.tier);

INSERT INTO schema_migrations (filename) VALUES ('1757-youth-winter-spring-competitions-scope.sql') ON CONFLICT DO NOTHING;
COMMIT;
