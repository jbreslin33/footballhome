-- 1650 (2026-11-23) — 🧮 Program budgets: membership grows by the month.
-- Owner: "there is no reason to break it by season because its a membership.
-- i think better to do it by year/month … most of what we have is a fixed cost
-- but membership should grow … for men we need i think a way to project to
-- get more members each month? with possibly even go over 70 as that means we
-- just don't put them on roster they are 'reserves'".
--
-- new_players_month = paying members added each month of a plan season
-- (NULL = none: the count stays flat, as before).  It only moves the dues:
-- teams, coaching and the shared-cost split stay on the season's players, so
-- going past a full roster adds money in and no cost.  The page's box sets
-- every plan season of the year.

ALTER TABLE program_season_plans
  ADD COLUMN IF NOT EXISTS new_players_month numeric(5,1)
    CHECK (new_players_month IS NULL OR new_players_month BETWEEN -20 AND 50);

INSERT INTO message_templates (category, label, kind, tier, body, is_active, sort_order, client_side, is_public)
SELECT 'Finances', v.label, 'finances', v.tier, v.body, true, v.ord, true, false
  FROM (VALUES
    ('Finances — program budgets: new members a month box', 'pb_col_growth', 'New members a month', 947),
    ('Finances — program budgets: dues by month, growing ({from_month}, {from}, {to_month}, {to}, {dues}, {collected})', 'pb_dues_grow', '{from_month} {from} → {to_month} {to} members × {dues} a month {collected}', 948),
    ('Finances — program budgets: dues by month, flat ({from_month}, {to_month}, {players}, {dues}, {months}, {collected})', 'pb_dues_flat', '{from_month}–{to_month}: {players} members × {dues} a month × {months} months {collected}', 949),
    ('Finances — program budgets: share of dues collected ({pct})', 'pb_dues_collected', '× {pct}% collected', 950)
  ) AS v(label, tier, body, ord)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates t WHERE t.kind = 'finances' AND t.tier = v.tier);
