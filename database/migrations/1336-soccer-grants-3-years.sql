-- 1336 (2026-11-13): the soccer grant money, three years.
--
-- Owner: "we have grant money set aside for 3 years. 15k per year for
-- coaches. not sure how much set aside for refs. lets be conservative and say
-- 5k per year for refs … lets do 10k for equipment … i am trying to not rely
-- on it long term."
--   income_awards.purpose  what a grant pays for (invoice_line_categories)
--   2028-29 budget year added (third grant year)
--   9 awards: coaching $15,000, refs $5,000 (conservative, assumed),
--   equipment $10,000 — each of 2026-27, 2027-28, 2028-29.
-- The Year plan shows them club-wide (a "＋ Grants" view, off by default —
-- the plan must stand on dues alone).  Not yet split into sections.

BEGIN;

INSERT INTO budget_years (club_id, label, starts_on, ends_on)
SELECT 134, '2028-29', '2028-08-01', '2029-07-31'
 WHERE NOT EXISTS (SELECT 1 FROM budget_years WHERE club_id = 134 AND label = '2028-29');

ALTER TABLE income_awards ADD COLUMN IF NOT EXISTS purpose text REFERENCES invoice_line_categories(code);
COMMENT ON COLUMN income_awards.purpose IS 'What the money is earmarked for (mig 1336)';

INSERT INTO income_awards (club_id, kind, source_name, label, amount_usd, status, budget_year_id, note, purpose)
SELECT 134, 'grant', 'Soccer grant (3 years)', v.label, v.amt, 'awarded', y.id, v.note, v.purpose
  FROM budget_years y
 CROSS JOIN (VALUES ('Coaches',   15000.00, 'labor',     '$15k a year for coaches (owner 2026-11-13)'),
                    ('Referees',   5000.00, 'referees',  'Conservative — the real amount set aside is not known (owner 2026-11-13)'),
                    ('Equipment', 10000.00, 'equipment', '$10k a year for equipment (owner 2026-11-13)')) AS v(label, amt, purpose, note)
 WHERE y.club_id = 134 AND y.label IN ('2026-27', '2027-28', '2028-29');

INSERT INTO message_templates (category, label, kind, tier, body, is_active, sort_order, client_side, is_public) VALUES
  ('Finances', 'Finances — Year plan grants switch (off)', 'finances', 'plan_grants_add',   '＋ Grants', true, 90, true, false),
  ('Finances', 'Finances — Year plan grants switch (on)',  'finances', 'plan_grants_on',    '✓ Grants — tap to plan on dues alone', true, 91, true, false),
  ('Finances', 'Finances — Year plan grants heading',      'finances', 'plan_grants_title', 'Grants (club-wide, not split into sections yet)', true, 92, true, false),
  ('Finances', 'Finances — Year plan grants note',         'finances', 'plan_grants_note',  'Set aside for three years. The plan should stand on dues alone — grants are the cushion, not the plan.', true, 93, true, false);

INSERT INTO schema_migrations (filename) VALUES ('1336-soccer-grants-3-years.sql') ON CONFLICT DO NOTHING;
COMMIT;
