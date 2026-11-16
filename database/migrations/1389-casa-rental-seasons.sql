-- 1389 (2026-11-16) — CASA rents in the spring too: a projected season until
-- its bookings are on the calendar.
--
-- Owner 2026-11-16: "casa will rent in sspring" → picked "Same as fall,
-- projected": spring = fall (5 Saturdays × 4 h × $75 = $1,500), marked
-- assumed until real bookings are on the calendar, then the calendar takes
-- over. Next year = fall + spring. Nothing written to Google Calendar.
--
-- A season = months of the year the renter usually books. For each budget
-- year and season: if ANY booking (fh_field_rental_income) falls in the
-- season's months that year, the calendar wins and nothing is projected;
-- otherwise sessions × hours × the policy's rate, spread evenly over the
-- season's months. Change a season = update/insert a row by migration.

CREATE TABLE IF NOT EXISTS field_rental_seasons (
    id                serial PRIMARY KEY,
    policy_id         integer NOT NULL REFERENCES field_rental_policies(id),
    label             text    NOT NULL,
    from_month        integer NOT NULL CHECK (from_month BETWEEN 1 AND 12),
    to_month          integer NOT NULL CHECK (to_month BETWEEN 1 AND 12),
    sessions          integer NOT NULL CHECK (sessions >= 0),
    hours_per_session numeric(5,2) NOT NULL CHECK (hours_per_session > 0),
    is_active         boolean NOT NULL DEFAULT true,
    note              text,
    UNIQUE (policy_id, label)
);

-- Fall = what CASA booked fall 2026 (Sep 19 – Oct 31, 5 Saturdays × 4 h);
-- spring = the same, per the owner.
INSERT INTO field_rental_seasons (policy_id, label, from_month, to_month, sessions, hours_per_session, note)
VALUES (1, 'fall',   9, 11, 5, 4, 'Fall 2026 actual: 5 Saturdays × 4 h'),
       (1, 'spring', 3,  5, 5, 4, 'Owner 2026-11-16 "casa will rent in sspring" → same as fall, projected')
ON CONFLICT (policy_id, label) DO NOTHING;

-- Every budget year × season: booked (calendar) and projected (when nothing
-- is booked in the window), one row per month of the season.
CREATE OR REPLACE FUNCTION fh_field_rental_projected(p_club integer)
RETURNS TABLE (budget_year text, season text, policy_label text, ym text,
               booked_usd numeric, booked_n integer, projected_usd numeric, projected_n numeric)
LANGUAGE sql STABLE AS $$
  WITH w AS (
    SELECT y.label AS budget_year, s.id AS season_id, s.label AS season, p.label AS policy_label, p.id AS policy_id,
           s.sessions, s.hours_per_session, p.rate_per_hour_usd,
           make_date(extract(year FROM y.starts_on)::int + CASE WHEN m < extract(month FROM y.starts_on) THEN 1 ELSE 0 END, m, 1) AS month_start,
           count(*) OVER (PARTITION BY y.id, s.id) AS n_months
      FROM budget_years y
      JOIN field_rental_policies p ON p.club_id = y.club_id
      JOIN field_rental_seasons s ON s.policy_id = p.id AND s.is_active
      CROSS JOIN LATERAL generate_series(s.from_month,
                   CASE WHEN s.to_month >= s.from_month THEN s.to_month ELSE s.to_month + 12 END) g(mm)
      CROSS JOIN LATERAL (SELECT ((g.mm - 1) % 12) + 1 AS m) mx
     WHERE y.club_id = p_club
       AND (p.effective_to IS NULL OR p.effective_to >= y.starts_on)
  ),
  b AS (
    SELECT w.*, COALESCE(r.amt, 0) AS booked_usd, COALESCE(r.n, 0)::int AS booked_n
      FROM w
      LEFT JOIN LATERAL (
        SELECT sum(i.amount_usd) AS amt, count(*) AS n
          FROM fh_field_rental_income(p_club) i
         WHERE i.policy_id = w.policy_id
           AND date_trunc('month', i.starts_at AT TIME ZONE 'America/New_York')::date = w.month_start
      ) r ON true
  )
  SELECT budget_year, season, policy_label, to_char(month_start, 'YYYY-MM'),
         booked_usd, booked_n,
         CASE WHEN sum(booked_n) OVER (PARTITION BY budget_year, season_id) > 0 THEN 0
              ELSE round(sessions * hours_per_session * rate_per_hour_usd / n_months, 2) END,
         CASE WHEN sum(booked_n) OVER (PARTITION BY budget_year, season_id) > 0 THEN 0
              ELSE round(sessions::numeric / n_months, 2) END
    FROM b
   ORDER BY budget_year, month_start
$$;

-- Words
INSERT INTO message_templates (category, label, kind, tier, body, is_active, sort_order, client_side, is_public)
SELECT 'Finances', v.label, 'finances', v.tier, v.body, true, v.ord, true, false
  FROM (VALUES
    ('Finances — rental: booked + assumed', 'plan_rental_detail', '{booked} booked + {assumed} assumed', 187),
    ('Finances — rental: assumed only',     'plan_rental_assumed', '{assumed} assumed (same as fall)', 188),
    ('Finances — rental: assumed unit',     'plan_rental_unit_assumed', 'bookings on the calendar; seasons not booked yet assumed like fall', 189),
    ('Finances — rental: projected item',   'cf_rental_projected', '{policy} — {season} (assumed)', 190)
  ) AS v(label, tier, body, ord)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates t WHERE t.kind = 'finances' AND t.tier = v.tier);
