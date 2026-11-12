-- 1294 (2026-11-12): money in, laid out — #tuition shows Collected / This
-- month / Avg per month each as Tuition + Fines = Total; #fines shows the
-- Fines part alone.  Owner: "i think we need tuitions + fines = total. with
-- all laid out" / "for total collected and this month and avg" / "i guess we
-- could do just fines on fine screen".  The fines part is worked out in the
-- browser (frontend/js/lib/fines-collected.js) from GET /api/fines: on LA and
-- the player's dues balance $0, in the month the charge went on LA.
BEGIN;
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Payments', v.l, 'payments_overview', v.t, NULL, v.b, v.o, true, true, false
  FROM (VALUES
    ('Tuition stats — tuition part of the money',     'split_tuition',       '🎓 Tuition',                          1270),
    ('Tuition stats — fines part of the money',       'split_fines',         '🧾 Fines',                            1271),
    ('Tuition stats — tuition + fines',               'split_total',         '💰 Total',                            1272),
    ('Tuition stats — row: collected all time',       'split_row_collected', 'MONEY IN · COLLECTED',                1273),
    ('Tuition stats — row: this month',               'split_row_month',     'MONEY IN · THIS MONTH',               1274),
    ('Tuition stats — row: average ({months})',       'split_row_avg',       'MONEY IN · AVG / MONTH ({months} mo)', 1275)
  ) AS v(l, t, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'payments_overview' AND m.tier = v.t);
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Fines', v.l, 'fines', v.t, NULL, v.b, v.o, true, true, false
  FROM (VALUES
    ('Fines stats — money-in row',                    'stats_collected',  'MONEY IN',                  300),
    ('Fines stats — fines collected all time',        'stat_collected',   '💰 Collected',              301),
    ('Fines stats — fines collected this month',      'stat_this_month',  'This month',                302),
    ('Fines stats — average per month ({months})',    'stat_avg',         'Avg / month ({months} mo)', 303)
  ) AS v(l, t, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'fines' AND m.tier = v.t);
INSERT INTO schema_migrations (filename) VALUES ('1294-money-in-tuition-fines-split.sql') ON CONFLICT DO NOTHING;
COMMIT;
