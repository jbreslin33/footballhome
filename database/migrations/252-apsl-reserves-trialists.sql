-- ─────────────────────────────────────────────────────────────────────
-- 252-apsl-reserves-trialists.sql (2026-07-31)
--
-- First on-demand internal groups under the group model (ADR
-- 2026-07-30, decision 5): APSL Reserves (call-up pool — players
-- cleared to play up for APSL) and APSL Trialists (on no roster yet;
-- tagged on friendlies, never on league fixtures).
--
-- Explicit ids so the eligibility catalogs (kEligibilityTeams,
-- rsvp-eligibility.js, person.js, mens-roster.js) can reference them
-- as stable constants:
--   924  APSL Reserves    gcal: Club: Mens / Team: APSL Reserves | Reserves
--   925  APSL Trialists   gcal: Club: Mens / Team: APSL Trialists | Trialists
--
-- Both render as mens roster-board columns (board_sort_order set,
-- no mutex — multi-team membership is legal).  Membership starts
-- empty; admins add via the board or the person-screen checkboxes.
-- ─────────────────────────────────────────────────────────────────────

BEGIN;

INSERT INTO teams (id, name, kind, gender_category, slug,
                   label, short_label, color, board_sort_order)
VALUES
    (924, 'APSL Reserves',  'internal', 'mens', 'apsl-reserves',
     'APSL Reserves',  'RES', '#60a5fa', 7),
    (925, 'APSL Trialists', 'internal', 'mens', 'apsl-trialists',
     'APSL Trialists', 'TRI', '#f97316', 8)
ON CONFLICT (slug) DO NOTHING;

SELECT setval('teams_id_seq', GREATEST((SELECT MAX(id) FROM teams), 925));

-- gcal aliases: canonical name + short convenience form.  Values are
-- matched post-jsNormAlias, so any casing/punctuation in the calendar
-- description resolves.
INSERT INTO gcal_team_aliases (club_alias, team_alias, team_id, notes) VALUES
    ('mens', 'apsl reserves',  924, 'APSL call-up pool'),
    ('mens', 'reserves',       924, 'Short form of APSL Reserves'),
    ('mens', 'apsl trialists', 925, 'APSL trialists — friendlies only'),
    ('mens', 'trialists',      925, 'Short form of APSL Trialists')
ON CONFLICT (club_alias, team_alias) DO NOTHING;

COMMIT;
