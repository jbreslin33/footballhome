-- 1644 (2026-11-20) — 🧮 Program budgets: the full year, simply, with every
-- line switchable and its number editable.  Owner: "its program based not
-- 'season' inside year based" → "so lets do men and then the others can
-- follow" → "show me it simply for full year with ability to turn things on
-- or off or edit numbers".
--
-- One row per line the owner changed on a program's year: off (out of the
-- totals) and / or his own amount instead of the worked-out one.  No row =
-- the worked-out number, on.  line_key = the page's line (bucket | group |
-- category | key | label | source) or "b|<bucket>" for a whole block.
-- These change the 🧮 Program budgets page only — never the standard
-- reports, the other programs' shares or 🧩 Programs.

CREATE TABLE IF NOT EXISTS program_budget_adjustments (
  id                 bigserial PRIMARY KEY,
  program_id         integer NOT NULL REFERENCES finance_programs(id) ON DELETE CASCADE,
  budget_year_id     integer NOT NULL REFERENCES budget_years(id) ON DELETE CASCADE,
  line_key           text    NOT NULL CHECK (length(line_key) BETWEEN 1 AND 400),
  is_on              boolean NOT NULL DEFAULT true,
  amount_usd         numeric(12,2) CHECK (amount_usd IS NULL OR amount_usd BETWEEN 0 AND 10000000),
  updated_at         timestamptz NOT NULL DEFAULT now(),
  updated_by_user_id integer REFERENCES users(id),
  UNIQUE (program_id, budget_year_id, line_key)
);

INSERT INTO message_templates (category, label, kind, tier, body, is_active, sort_order, client_side, is_public)
SELECT 'Finances', v.label, 'finances', v.tier, v.body, true, v.ord, true, false
  FROM (VALUES
    ('Finances — program budgets: how to edit', 'pb_edit', 'The whole year. Untick a line to take it out of the totals; type a number to use yours instead of the worked-out one (grey) — clear it to go back. Changes here stay on this page: the standard reports and the other programs are not touched.', 938),
    ('Finances — program budgets: col line', 'pb_col_line', 'Line', 939),
    ('Finances — program budgets: col amount', 'pb_col_amount', 'Amount', 940),
    ('Finances — program budgets: changed lines ({n})', 'pb_changed', '{n} changed from the worked-out budget', 941),
    ('Finances — program budgets: worked-out balance ({amount})', 'pb_computed_balance', 'worked out: {amount}', 942)
  ) AS v(label, tier, body, ord)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates t WHERE t.kind = 'finances' AND t.tier = v.tier);

-- 🧑‍🏫 Coaching on the page = the hours really worked, projected to the year
-- (owner 11/20 "for coach pay just look at my current hours for coaching and
-- project. but separate practice from games and have games listed by team
-- then a total"); every block rolls up to its total ("do that for all items").
INSERT INTO message_templates (category, label, kind, tier, body, is_active, sort_order, client_side, is_public)
SELECT 'Finances', v.label, 'finances', v.tier, v.body, true, v.ord, true, false
  FROM (VALUES
    ('Finances — program budgets: coaching block', 'pb_sub_coaching', '🧑‍🏫 Coaching', 943),
    ('Finances — program budgets: coaching practice line ({coach})', 'pb_coach_practice', 'Practice ({coach})', 944),
    ('Finances — program budgets: coaching games line ({team}, {coach})', 'pb_coach_games', 'Games — {team} ({coach})', 945),
    ('Finances — program budgets: hours projected ({hours}, {days}, {year}, {rate})', 'pb_hours_detail', '{hours} h in {days} days → {year} h a year × ${rate}', 946)
  ) AS v(label, tier, body, ord)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates t WHERE t.kind = 'finances' AND t.tier = v.tier);

UPDATE message_templates SET body = 'MONEY OUT — tap a block for its lines'
 WHERE kind = 'finances' AND tier = 'pb_row_out' AND body = 'MONEY OUT — tap a row to open it';
