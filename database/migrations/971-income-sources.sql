-- 971 (2026-11-03) — where the club's money comes from.
-- Owner 2026-11-03: "official income is la dues. casa rentals $75 an hour
-- they are in gcal. also we get grants and finding out about their totals so
-- leave room in db for them" / "also we had a sponsor and will again".
--
--   income_kinds            la_dues | field_rental | grant | sponsorship
--   field_rental_policies   who rents our field, at what hourly rate, and how
--                           their bookings read on the calendar.  Money is
--                           derived from gcal — fh_field_rental_income() —
--                           never typed.  A booking on two calendars counts once.
--   income_awards           a grant or sponsorship: who, how much (NULL until
--                           known), status, budget year
--   income_receipts         money actually received against an award
-- Barn / pavilion rentals on the facility calendar are Lighthouse's, not
-- soccer's, and are not counted.
BEGIN;

CREATE TABLE IF NOT EXISTS income_kinds (
    code TEXT PRIMARY KEY, label TEXT NOT NULL, sort_order INTEGER NOT NULL DEFAULT 0);
INSERT INTO income_kinds (code, label, sort_order) VALUES
    ('la_dues',      'LeagueApps dues',  1),
    ('field_rental', 'Field rental',     2),
    ('grant',        'Grant',            3),
    ('sponsorship',  'Sponsorship',      4)
ON CONFLICT (code) DO NOTHING;

CREATE TABLE IF NOT EXISTS field_rental_policies (
    id                     SERIAL PRIMARY KEY,
    club_id                INTEGER NOT NULL,
    renter_organization_id INTEGER REFERENCES organizations(id),
    label                  TEXT NOT NULL,
    summary_pattern        TEXT NOT NULL,          -- regex on gcal_events.summary
    rate_per_hour_usd      NUMERIC(8,2) NOT NULL,
    effective_from         DATE NOT NULL,
    effective_to           DATE,
    note                   TEXT
);
COMMENT ON TABLE field_rental_policies IS 'Field rentals we are paid for, by the hour off the calendar (mig 971).';
INSERT INTO field_rental_policies (club_id, renter_organization_id, label, summary_pattern, rate_per_hour_usd, effective_from, note)
SELECT 134, 2, 'CASA field rental', '^\s*casa soccer', 75.00, '2026-08-01', 'Owner 2026-11-03: "casa rentals $75 an hour they are in gcal"'
 WHERE NOT EXISTS (SELECT 1 FROM field_rental_policies WHERE club_id = 134 AND label = 'CASA field rental');

CREATE OR REPLACE FUNCTION fh_field_rental_income(p_club int)
RETURNS TABLE (policy_id int, gcal_event_id int, starts_at timestamptz, hours numeric, amount_usd numeric)
LANGUAGE sql STABLE AS $$
  SELECT DISTINCT ON (p.id, g.starts_at, g.ends_at)
         p.id, g.id, g.starts_at,
         round(extract(epoch FROM g.ends_at - g.starts_at) / 3600.0, 2),
         round(extract(epoch FROM g.ends_at - g.starts_at) / 3600.0 * p.rate_per_hour_usd, 2)
    FROM field_rental_policies p
    JOIN gcal_events g ON g.summary ~* p.summary_pattern
                      AND g.deleted_at IS NULL AND g.status IS DISTINCT FROM 'cancelled' AND NOT g.all_day
                      AND (g.starts_at AT TIME ZONE 'America/New_York')::date >= p.effective_from
                      AND (p.effective_to IS NULL OR (g.starts_at AT TIME ZONE 'America/New_York')::date <= p.effective_to)
   WHERE p.club_id = p_club
   ORDER BY p.id, g.starts_at, g.ends_at, g.id
$$;
COMMENT ON FUNCTION fh_field_rental_income(int) IS 'Each rental booking once (mig 971): hours × the policy rate.';

CREATE TABLE IF NOT EXISTS income_award_statuses (
    code TEXT PRIMARY KEY, label TEXT NOT NULL, counts_ahead BOOLEAN NOT NULL, sort_order INTEGER NOT NULL DEFAULT 0);
INSERT INTO income_award_statuses (code, label, counts_ahead, sort_order) VALUES
    ('prospect', 'Looking into it', false, 1),
    ('applied',  'Applied',         false, 2),
    ('awarded',  'Awarded',         true,  3),
    ('received', 'Received in full', false, 4),
    ('declined', 'Declined',        false, 5),
    ('lapsed',   'Lapsed',          false, 6)
ON CONFLICT (code) DO NOTHING;

CREATE TABLE IF NOT EXISTS income_awards (
    id              SERIAL PRIMARY KEY,
    club_id         INTEGER NOT NULL,
    kind            TEXT NOT NULL REFERENCES income_kinds(code),
    organization_id INTEGER REFERENCES organizations(id),
    source_name     TEXT NOT NULL,                 -- grantor / sponsor as they name themselves
    label           TEXT NOT NULL,                 -- the program or deal
    amount_usd      NUMERIC(10,2),                 -- NULL until the total is known
    status          TEXT NOT NULL DEFAULT 'prospect' REFERENCES income_award_statuses(code),
    budget_year_id  INTEGER REFERENCES budget_years(id),
    expected_on     DATE,
    note            TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    CHECK (kind IN ('grant', 'sponsorship'))
);
COMMENT ON TABLE income_awards IS 'Grants and sponsorships (mig 971). amount_usd stays NULL until the total is known.';

CREATE TABLE IF NOT EXISTS income_receipts (
    id          SERIAL PRIMARY KEY,
    award_id    INTEGER NOT NULL REFERENCES income_awards(id) ON DELETE CASCADE,
    received_on DATE NOT NULL,
    amount_usd  NUMERIC(10,2) NOT NULL,
    note        TEXT
);
COMMENT ON TABLE income_receipts IS 'Money actually received against a grant or sponsorship (mig 971).';
COMMIT;
