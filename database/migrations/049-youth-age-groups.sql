-- Youth age-group buckets for the Boys/Girls Club dashboard.
--
-- Encodes the US Club Soccer / USYS Aug 1 – Jul 31 birth-date windows
-- (https://usclubsoccer.org/registration-player-age-groups/) and the
-- per-bucket roster caps Lighthouse 1893 enforces.  Buckets that combine
-- multiple U groups (U10 = U9+U10, U12 = U11+U12) span both windows.
--
-- The In-House and Philadelphia League buckets are split by club; the
-- travel buckets (U8/U10/U12) are gender-mixed (boys roster up girls).
--
-- season_end_year matches the spring year, e.g. 2027 = Fall 2026 / Spring
-- 2027 = the 2026-27 registration season.

CREATE TABLE IF NOT EXISTS youth_age_groups (
    id              SERIAL PRIMARY KEY,
    season_end_year INTEGER NOT NULL,
    bucket_label    TEXT    NOT NULL,
    club_filter     TEXT    NULL,            -- NULL = any, 'boys', 'girls'
    min_birth_date  DATE    NOT NULL,        -- inclusive
    max_birth_date  DATE    NOT NULL,        -- inclusive
    max_roster      INTEGER NULL,            -- NULL = unlimited (rec)
    sort_order      INTEGER NOT NULL,
    color           TEXT    NULL,            -- hex for UI swatches
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT youth_age_groups_unique
        UNIQUE (season_end_year, bucket_label),
    CONSTRAINT youth_age_groups_date_order
        CHECK (min_birth_date <= max_birth_date),
    CONSTRAINT youth_age_groups_club_filter
        CHECK (club_filter IS NULL OR club_filter IN ('boys', 'girls'))
);

CREATE INDEX IF NOT EXISTS idx_youth_age_groups_season
    ON youth_age_groups (season_end_year, sort_order);

-- ── Seed: 2026-27 season (season_end_year = 2027) ────────────────────────
-- Aug 1 cutoff.  U-8 / U-10 / U-12 caps are 12, 12, 16.  In-House and
-- Philadelphia League buckets are unlimited (rec / external league).
INSERT INTO youth_age_groups
    (season_end_year, bucket_label, club_filter, min_birth_date, max_birth_date, max_roster, sort_order, color)
VALUES
    (2027, 'In-House Boys',                 'boys',  DATE '2019-08-01', DATE '9999-12-31', NULL, 1, '#0e7490'),
    (2027, 'In-House Girls',                'girls', DATE '2019-08-01', DATE '9999-12-31', NULL, 2, '#db2777'),
    -- U-8: born Aug 1, 2018 – Jul 31, 2019
    (2027, 'U8',                            NULL,    DATE '2018-08-01', DATE '2019-07-31',   12, 3, '#0d9488'),
    -- U-10 bucket = U-9 + U-10: born Aug 1, 2016 – Jul 31, 2018
    (2027, 'U10',                           NULL,    DATE '2016-08-01', DATE '2018-07-31',   12, 4, '#2563eb'),
    -- U-12 bucket = U-11 + U-12: born Aug 1, 2014 – Jul 31, 2016
    (2027, 'U12',                           NULL,    DATE '2014-08-01', DATE '2016-07-31',   16, 5, '#7c3aed'),
    (2027, 'Philadelphia League — Boys',    'boys',  DATE '1900-01-01', DATE '2014-07-31', NULL, 6, '#1d4ed8'),
    (2027, 'Philadelphia League — Girls',   'girls', DATE '1900-01-01', DATE '2014-07-31', NULL, 7, '#be185d')
ON CONFLICT (season_end_year, bucket_label) DO NOTHING;
