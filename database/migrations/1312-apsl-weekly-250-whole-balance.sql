-- 1312 (2026-11-13): the $250 Mondays pay off the WHOLE 2026-27 APSL balance.
--
-- Owner: "that should pay off whole balance by end" — $2,940 (rate card:
-- $1,750 − $250 reserve credit + 36 × $40) at $250 every Monday from Nov 2:
-- 11 × $250 through Jan 11, last $190 on Jan 18.  Replaces mig 1311's
-- $2,230 / nine payments ending Dec 28.

BEGIN;

DELETE FROM team_season_installments WHERE entry_id = 1;
INSERT INTO team_season_installments (entry_id, due_on, amount, note)
SELECT 1, d::date, CASE WHEN d::date = '2027-01-18' THEN 190.00 ELSE 250.00 END,
       'APSL dues, $250 Mondays (' || row_number() OVER (ORDER BY d) || ' of 12)'
  FROM generate_series('2026-11-02'::date, '2027-01-18'::date, interval '7 days') d;

UPDATE cash_flow_planned SET is_active = false
 WHERE scope = 'apsl' AND category = 'league_dues' AND label LIKE 'APSL league balance%';
INSERT INTO cash_flow_planned (ym, label, amount, scope, category, is_active) VALUES
  ('2026-11', 'APSL dues, payments 1, 2, 3, 4, 5 of 12 at $250',            1250.00, 'apsl', 'league_dues', true),
  ('2026-12', 'APSL dues, payments 6, 7, 8, 9 of 12 at $250',               1000.00, 'apsl', 'league_dues', true),
  ('2027-01', 'APSL dues, payments 10, 11, 12 of 12 (last one $190)',        690.00, 'apsl', 'league_dues', true);

-- the dues line is fully carried by those rows, so it shows nothing extra
UPDATE budget_lines
   SET paid_before_usd = 2940.00,
       note = '$1,750 club fee − $250 reserve credit + 36 players × $40 (mig 965). 2026-27: paid $250 Mondays Nov 2–Jan 18 (cash-flow rows, mig 1312) — counted here so it is not shown twice'
 WHERE id = 1;

DO $$ BEGIN
  IF (SELECT sum(amount) FROM team_season_installments WHERE entry_id = 1) <> 2940
  OR (SELECT sum(amount) FROM cash_flow_planned WHERE is_active AND label LIKE 'APSL dues, payments%') <> 2940 THEN
    RAISE EXCEPTION 'APSL dues schedule does not sum to 2940';
  END IF;
END $$;

INSERT INTO schema_migrations (filename) VALUES ('1312-apsl-weekly-250-whole-balance.sql') ON CONFLICT DO NOTHING;
COMMIT;
