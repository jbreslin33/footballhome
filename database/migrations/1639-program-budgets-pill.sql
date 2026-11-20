-- 1639 (2026-11-20) — #finances 🧮 Program budgets: a pill per program, sub
-- pills for where each cost sits.  Owner: "we need a pill for each program to
-- figure out budget. then on that pill we can have sub pills for 'inner' club
-- wide like boys/girls club wide or mens club wide. then also club wide share,
-- grants, etc. use teams as pills. we need function to have them 'share'
-- coach with other age groups and pay their share. travel teams have no
-- players yet but will have expenses … a player is only counted 1x" →
-- "u10 travel is paid for by u8, u9, 10. u12 travel is paid for by u11, u12."
-- → "travel kids can be listed 2x but their money goes to their 'age'" →
-- men: "roll them all together as mens program".
--
-- No new tables: ProgramBudget already counts each payer once (dues by payer →
-- program) and shares a team / coach / section / club cost by paying players.
-- Its answer now also carries "parts" (each line's level + source + whole
-- cost + sharers) and "teams"; POST /api/finances/program-team adds / drops a
-- payer of a budget team.  This migration: U8 joins the U10 travel teams'
-- payers, and the pill's wording.

-- U10 Travel (fall / winter / spring) is paid for by U8, U9 and U10
INSERT INTO finance_program_teams (program_id, team_id)
SELECT p.id, t.team_id
  FROM finance_programs p
  JOIN (SELECT DISTINCT fpt.team_id FROM finance_program_teams fpt
          JOIN finance_programs u10 ON u10.id = fpt.program_id AND u10.code = 'u10'
          JOIN teams tm ON tm.id = fpt.team_id AND tm.name LIKE 'U10 Travel%') t ON true
 WHERE p.code = 'u8'
ON CONFLICT DO NOTHING;

INSERT INTO message_templates (category, label, kind, tier, body, is_active, sort_order, client_side, is_public)
SELECT 'Finances', v.label, 'finances', v.tier, v.body, true, v.ord, true, false
  FROM (VALUES
    ('Finances — pill: program budgets', 'pill_budgets', '🧮 Program budgets', 920),
    ('Finances — program budgets: title', 'pb_title', 'Program budgets', 921),
    ('Finances — program budgets: note', 'pb_note', 'One budget per program. Every player is counted once, in their own age group — a travel kid can be on two team lists, but their dues go to their age. A team, a shared coach, the section and the club are costs: each is shared by the programs that pay for it, by paying players.', 922),
    ('Finances — program budgets: sub pill overview', 'pb_sub_all', 'Overview', 923),
    ('Finances — program budgets: sub pill own ({program})', 'pb_sub_own', '{program} only', 924),
    ('Finances — program budgets: sub pill shared coaches', 'pb_sub_coach', '🧑‍🏫 Shared coaches', 925),
    ('Finances — program budgets: sub pill section ({section})', 'pb_sub_section', '{section}-wide', 926),
    ('Finances — program budgets: sub pill club-wide', 'pb_sub_club', 'Club-wide share', 927),
    ('Finances — program budgets: sub pill grants', 'pb_sub_grant', 'Grants', 928),
    ('Finances — program budgets: group money in', 'pb_row_in', 'MONEY IN', 929),
    ('Finances — program budgets: group money out', 'pb_row_out', 'MONEY OUT — tap a row to open it', 930),
    ('Finances — program budgets: col whole cost', 'pb_col_whole', 'Whole cost', 931),
    ('Finances — program budgets: col shared by', 'pb_col_with', 'Shared by', 932),
    ('Finances — program budgets: col this program''s part ({program})', 'pb_col_share', '{program} pays', 933),
    ('Finances — program budgets: team payers heading', 'pb_paid_by', 'Paid for by', 934),
    ('Finances — program budgets: team payers hint', 'pb_paid_by_hint', '(tap a program to add or drop it)', 935),
    ('Finances — program budgets: empty sub pill', 'pb_no_costs', 'Nothing here yet.', 936),
    ('Finances — program budgets: players ({n})', 'pb_players', '{n} paying players, counted once', 937)
  ) AS v(label, tier, body, ord)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates t WHERE t.kind = 'finances' AND t.tier = v.tier);
