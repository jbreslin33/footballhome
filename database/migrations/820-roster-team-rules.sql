-- 820 (2026-10-29) — league eligibility rules between official rosters.
--
-- Owner: "league rule is to be on apsl reserve roster you need to be on
-- liga 1 for that club. or liga 2 but we don't have liga 2 team yet" …
-- "apsl first team can't be on reserves" … "if someone is we need to flag
-- it. but the apsl should flag it at their end" … "so we can fix it before
-- league gets on us".
--
-- One row per rule, read by the #teams Roster pill (RosterBoardExtras →
-- rosterRules), which checks the league lists against each other:
--   requires  team_id's list may only hold players on the official list of
--             ONE OF its requires teams (Liga 2 = add a row the day it exists)
--   excludes  a player on team_id's list must not also be on other_team_id's;
--             flagged on team_id's column
-- Broken rules show as ⚠ INELIGIBLE on the board; a requires team's players
-- missing here (and not excluded) show under NEEDS ADD.

CREATE TABLE IF NOT EXISTS roster_team_rules (
    team_id       integer NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    other_team_id integer NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    rule          text    NOT NULL CHECK (rule IN ('requires', 'excludes')),
    note          text,
    created_at    timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (team_id, other_team_id, rule),
    CHECK (team_id <> other_team_id)
);

INSERT INTO roster_team_rules (team_id, other_team_id, rule, note) VALUES
  (938, 120, 'requires', 'APSL Reserves: must be on the club''s Liga 1 (or Liga 2) official roster'),
  (35,  938, 'excludes', 'APSL first team players can''t also be on the APSL Reserves roster')
ON CONFLICT DO NOTHING;

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Roster sheet', l, 'roster_sheet', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('board_ineligible_h',      'Team boards — Roster pill: red block of list players breaking a league rule (mig 820)', '⚠ INELIGIBLE — league rule, fix before the league does', 955),
    ('board_ineligible_banner', 'Team boards — official banner suffix ({n})',                                            '{n} ineligible',                                         956),
    ('board_rule_requires',     'Team boards — why: not on any required roster ({teams})',                               '⚠ not on the {teams} roster',                             957),
    ('board_rule_excludes',     'Team boards — why: also on an excluded roster ({team})',                                '⚠ also on the {team} roster — can''t be on both',         958),
    ('board_needs_add_from',    'Team boards — NEEDS ADD row for a required roster''s player not here yet ({team})',      'on the {team} roster — not added here',                   959)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'roster_sheet' AND m.tier = v.t);
