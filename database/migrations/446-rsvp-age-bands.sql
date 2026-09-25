-- 446 (2026-09-25) — youth availability lists group players by age band.
--
-- Owner: "should we group players by apsl or liga 1 for men. and by u9,
-- u10, u11, u12/u13 etc" … "in the availability on my".  Men's lists
-- group by the tagged team (data already there); youth lists group by
-- the player's single age (fh_youth_single_age against the season end
-- year) into these bands.  Rows, not code, so the bands can change by
-- migration.  min_age/max_age are single ages (U9 = 9).
CREATE TABLE IF NOT EXISTS rsvp_age_bands (
    id         SERIAL PRIMARY KEY,
    club_id    INT  NOT NULL REFERENCES clubs(id),
    label      TEXT NOT NULL,
    min_age    INT  NOT NULL,
    max_age    INT  NOT NULL CHECK (max_age >= min_age),
    sort_order INT  NOT NULL DEFAULT 0,
    is_active  BOOLEAN NOT NULL DEFAULT true,
    UNIQUE (club_id, label)
);
COMMENT ON TABLE rsvp_age_bands IS 'Age bands the who''s-going lists on #my use for youth events (mig 446). Single ages: U9 = 9.';
INSERT INTO rsvp_age_bands (club_id, label, min_age, max_age, sort_order) VALUES
  (134, 'U6–8',   4,  8, 1),
  (134, 'U9',     9,  9, 2),
  (134, 'U10',   10, 10, 3),
  (134, 'U11',   11, 11, 4),
  (134, 'U12/13',12, 13, 5),
  (134, 'U14–16',14, 16, 6),
  (134, 'U17–19',17, 19, 7)
ON CONFLICT (club_id, label) DO NOTHING;
