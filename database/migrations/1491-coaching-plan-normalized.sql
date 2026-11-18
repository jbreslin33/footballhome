-- 1491 (2026-11-18) — 🧑‍🏫 Coaching plan, normalized (owner: "this all needs to
-- be stored in db as normalized and on front and back end if needed oop" +
-- "we don't want spaghetti code").  Facts only — never a worked-out dollar
-- amount.  models/CoachingPlan.cpp turns these rows into each coach's hours
-- and money per season (and which programs share each hour); every report
-- asks it.  Replaces the hand-worked coaching budget lines (34, 37, 38, 39 and
-- mig 1490's early-arrival lines) once the reports read it (next step).
--
--   practice_slots          a weekly session of a year's schedule
--   practice_slot_programs  the programs that train in it (they share its cost)
--   practice_slot_coaches   the paid coaches working it (each paid its minutes)
--   coach_arrival_rules     minutes early before a coach's FIRST session of a
--                           practice day, per season
--   practice_season_breaks  weeks with no practice, per season and program kind
-- Games stay where they are: ref_fee_policies (kind 'coaching') × ref_fee_seasons
-- — coach_issuer_id names the coach (set below for the men's policies).
BEGIN;

CREATE TABLE IF NOT EXISTS practice_slots (
    id             SERIAL PRIMARY KEY,
    club_id        INTEGER NOT NULL,
    budget_year_id INTEGER NOT NULL REFERENCES budget_years(id),
    weekday        SMALLINT NOT NULL CHECK (weekday BETWEEN 1 AND 7),   -- ISO: 1 = Monday
    start_time     TIME NOT NULL,
    minutes        INTEGER NOT NULL CHECK (minutes > 0),
    label          TEXT NOT NULL,
    is_active      BOOLEAN NOT NULL DEFAULT true,
    note           TEXT,
    UNIQUE (budget_year_id, weekday, start_time, label)
);
CREATE TABLE IF NOT EXISTS practice_slot_programs (
    slot_id    INTEGER NOT NULL REFERENCES practice_slots(id) ON DELETE CASCADE,
    program_id INTEGER NOT NULL REFERENCES finance_programs(id),
    PRIMARY KEY (slot_id, program_id)
);
CREATE TABLE IF NOT EXISTS practice_slot_coaches (
    slot_id   INTEGER NOT NULL REFERENCES practice_slots(id) ON DELETE CASCADE,
    issuer_id INTEGER NOT NULL REFERENCES invoice_issuers(id),
    PRIMARY KEY (slot_id, issuer_id)
);
CREATE TABLE IF NOT EXISTS coach_arrival_rules (
    issuer_id      INTEGER NOT NULL REFERENCES invoice_issuers(id),
    budget_year_id INTEGER NOT NULL REFERENCES budget_years(id),
    season_id      INTEGER NOT NULL REFERENCES budget_seasons(id),
    minutes        INTEGER NOT NULL CHECK (minutes >= 0),
    PRIMARY KEY (issuer_id, budget_year_id, season_id)
);
CREATE TABLE IF NOT EXISTS practice_season_breaks (
    budget_year_id INTEGER NOT NULL REFERENCES budget_years(id),
    season_id      INTEGER NOT NULL REFERENCES budget_seasons(id),
    program_kind   TEXT NOT NULL CHECK (program_kind IN ('men', 'women', 'youth')),
    weeks_off      INTEGER NOT NULL CHECK (weeks_off >= 0),
    PRIMARY KEY (budget_year_id, season_id, program_kind)
);
COMMENT ON TABLE practice_slots IS 'mig 1491: a weekly practice session of a budget year (CoachingPlan).';
COMMENT ON TABLE coach_arrival_rules IS 'mig 1491: minutes early before a coach''s first session of a practice day, per season.';

-- ── 2026-27 (budget year 1) ─────────────────────────────────────────────
-- Youth: this winter's calendar is the year's schedule (owner 11/18), Mon/Wed/Fri.
INSERT INTO practice_slots (club_id, budget_year_id, weekday, start_time, minutes, label)
SELECT 134, 1, d, t::time, m, l
  FROM (VALUES (1), (3), (5)) AS w(d)
 CROSS JOIN (VALUES ('16:00', 45, 'U5–U8'), ('16:45', 60, 'U9–U10'), ('17:45', 75, 'U11–U15')) AS s(t, m, l)
ON CONFLICT DO NOTHING;
-- Men: 5 practices a week × 1½ h (owner 11/16, 11/18), the calendar's men's times.
INSERT INTO practice_slots (club_id, budget_year_id, weekday, start_time, minutes, label)
VALUES (134, 1, 1, '19:00', 90, 'Men'), (134, 1, 2, '21:00', 90, 'Men'), (134, 1, 3, '19:00', 90, 'Men'),
       (134, 1, 4, '19:00', 90, 'Men'), (134, 1, 5, '19:00', 90, 'Men')
ON CONFLICT DO NOTHING;

INSERT INTO practice_slot_programs (slot_id, program_id)
SELECT s.id, fp.id FROM practice_slots s JOIN finance_programs fp ON
       (s.label = 'U5–U8'   AND fp.code IN ('u5', 'u6', 'u7', 'u8'))
    OR (s.label = 'U9–U10'  AND fp.code IN ('u9', 'u10'))
    OR (s.label = 'U11–U15' AND fp.code IN ('u11', 'u12', 'u13', 'u14', 'u15'))
    OR (s.label = 'Men'     AND fp.code = 'mens')
 WHERE s.budget_year_id = 1
ON CONFLICT DO NOTHING;

-- Luke (2) and Anthony (4) at every youth session; James (1) at every men's.
INSERT INTO practice_slot_coaches (slot_id, issuer_id)
SELECT s.id, c.i FROM practice_slots s
  JOIN (VALUES ('U5–U8', 2), ('U5–U8', 4), ('U9–U10', 2), ('U9–U10', 4), ('U11–U15', 2), ('U11–U15', 4), ('Men', 1)) AS c(l, i) ON c.l = s.label
 WHERE s.budget_year_id = 1
ON CONFLICT DO NOTHING;

-- Early arrival before the first session of the day: 15 min winter, 30 the rest.
INSERT INTO coach_arrival_rules (issuer_id, budget_year_id, season_id, minutes)
SELECT i, 1, bs.id, CASE WHEN bs.code = 'winter' THEN 15 ELSE 30 END
  FROM (VALUES (2), (4)) AS c(i) CROSS JOIN budget_seasons bs
ON CONFLICT DO NOTHING;

-- Youth: 2 holiday weeks off in winter (as budget lines 37/38 had).
INSERT INTO practice_season_breaks (budget_year_id, season_id, program_kind, weeks_off)
SELECT 1, id, 'youth', 2 FROM budget_seasons WHERE code = 'winter'
ON CONFLICT DO NOTHING;

-- Games: the men's coaching policies name their coach (James) instead of NULL.
UPDATE ref_fee_policies SET coach_issuer_id = 1 WHERE kind = 'coaching' AND id IN (7, 8, 25, 26) AND coach_issuer_id IS NULL;

COMMIT;
