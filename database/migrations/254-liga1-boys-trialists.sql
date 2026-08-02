-- ─────────────────────────────────────────────────────────────────────
-- 254-liga1-boys-trialists.sql (2026-08-02)
--
-- More on-demand internal trialist groups, same shape as APSL
-- Trialists (migration 252): on no roster yet, tagged on friendlies,
-- never on league fixtures. Mutex-free (kind='internal', no
-- mutex_group) so a trialist can also sit on a real column.
--
-- Explicit ids continuing the 252 block:
--   926  Liga 1 Trialists    gcal: Club: Mens / Team: Liga 1 Trialists
--   927  U8 Boys Trialists   gcal: Club: Boys / Team: U8 Trialists
--   928  U10 Boys Trialists  gcal: Club: Boys / Team: U10 Trialists
--   929  U12 Boys Trialists  gcal: Club: Boys / Team: U12 Trialists
--
-- Boys board already runs 1..6 (LYL U8/U12/U16, then the U8/U10/U12
-- admin buckets — migration 113); the three Trialists columns go at
-- 7/8/9, same "it's ok to scroll" tradeoff as Reserves/Trialists did
-- on the mens board.
--
-- Same as 252, these also join the eligibility catalogs: kEligibilityTeams
-- (MensRosterController.cpp), rsvp-eligibility.js / person.js `_teams()` /
-- `_rsvpTeams()` (all four ids), and the mens-roster.js RSVP modal
-- (926 only — that modal stays mens-focused).
-- ─────────────────────────────────────────────────────────────────────

BEGIN;

INSERT INTO teams (id, name, kind, gender_category, slug,
                   label, short_label, color, board_sort_order)
VALUES
    (926, 'Liga 1 Trialists',   'internal', 'mens', 'liga1-trialists',
     'Liga 1 Trialists',   'L1 TRI',  '#f97316', 9),
    (927, 'U8 Boys Trialists',  'internal', 'boys', 'u8-boys-trialists',
     'U8 Boys Trialists',  'U8 TRI',  '#f97316', 7),
    (928, 'U10 Boys Trialists', 'internal', 'boys', 'u10-boys-trialists',
     'U10 Boys Trialists', 'U10 TRI', '#f97316', 8),
    (929, 'U12 Boys Trialists', 'internal', 'boys', 'u12-boys-trialists',
     'U12 Boys Trialists', 'U12 TRI', '#f97316', 9)
ON CONFLICT (slug) DO NOTHING;

SELECT setval('teams_id_seq', GREATEST((SELECT MAX(id) FROM teams), 929));

-- gcal aliases: canonical name + short convenience form, matching the
-- 252 pattern (values matched post-jsNormAlias, so casing/punctuation
-- in the calendar description resolves).
INSERT INTO gcal_team_aliases (club_alias, team_alias, team_id, notes) VALUES
    ('mens', 'liga 1 trialists', 926, 'Liga 1 trialists — friendlies only'),
    ('mens', 'liga1 trialists',  926, 'Alt spelling for Liga 1 Trialists'),
    ('boys', 'u8 trialists',     927, 'U8 Boys trialists — friendlies only'),
    ('boys', 'u10 trialists',    928, 'U10 Boys trialists — friendlies only'),
    ('boys', 'u12 trialists',    929, 'U12 Boys trialists — friendlies only')
ON CONFLICT (club_alias, team_alias) DO NOTHING;

COMMIT;
