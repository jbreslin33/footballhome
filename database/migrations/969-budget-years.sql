-- 969 (2026-11-03) — the budget year runs Aug 1 – Jul 31.
-- Owner 2026-11-03: "we will think of budget as august 1st start for year and
-- july 31 end."  budget_years holds the years; every budget line belongs to
-- one and must sit inside it (trigger).  Full-season lines now span the whole
-- year; summer field paint stops at Jul 31; the cup entries due Aug 2027 are
-- 2027-28 money.
BEGIN;

CREATE TABLE IF NOT EXISTS budget_years (
    id        SERIAL PRIMARY KEY,
    club_id   INTEGER NOT NULL,
    label     TEXT NOT NULL,
    starts_on DATE NOT NULL,
    ends_on   DATE NOT NULL,
    CHECK (ends_on > starts_on),
    UNIQUE (club_id, label)
);
COMMENT ON TABLE budget_years IS 'Budget years, Aug 1 – Jul 31 (owner 2026-11-03, mig 969).';
INSERT INTO budget_years (club_id, label, starts_on, ends_on) VALUES
    (134, '2026-27', '2026-08-01', '2027-07-31'),
    (134, '2027-28', '2027-08-01', '2028-07-31')
ON CONFLICT (club_id, label) DO NOTHING;

ALTER TABLE budget_lines ADD COLUMN IF NOT EXISTS budget_year_id INTEGER REFERENCES budget_years(id);

-- Whole-season lines span the year.
UPDATE budget_lines SET period_start = '2026-08-01', period_end = '2027-07-31'
 WHERE id IN (1, 2, 3, 13, 14, 15, 16);
-- Summer paint: June and July are this year; August is next year's.
UPDATE budget_lines SET period_end = '2027-07-31', label = 'Field paint — Summer (Jun–Jul)' WHERE id = 19 AND period_end = '2027-08-31';

UPDATE budget_lines b SET budget_year_id = y.id
  FROM budget_years y
 WHERE y.club_id = b.club_id AND b.period_start BETWEEN y.starts_on AND y.ends_on AND b.budget_year_id IS NULL;
ALTER TABLE budget_lines ALTER COLUMN budget_year_id SET NOT NULL;

CREATE OR REPLACE FUNCTION fh_budget_line_in_year() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM budget_years y WHERE y.id = NEW.budget_year_id
                    AND NEW.period_start >= y.starts_on AND NEW.period_end <= y.ends_on) THEN
    RAISE EXCEPTION 'budget line % (%–%) is outside its budget year', NEW.label, NEW.period_start, NEW.period_end;
  END IF;
  RETURN NEW;
END $$;
DROP TRIGGER IF EXISTS budget_line_in_year ON budget_lines;
CREATE TRIGGER budget_line_in_year BEFORE INSERT OR UPDATE OF period_start, period_end, budget_year_id ON budget_lines
   FOR EACH ROW EXECUTE FUNCTION fh_budget_line_in_year();

COMMIT;
