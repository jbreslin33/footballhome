-- 625 (2026-10-21) — #jobs: auto-assigned event jobs, default-done.
--
-- Owner (TODO.md): jobs are assigned per event from who is actually
-- going (RSVP + attendance); footballhome auto-assigns.  Assignment is
-- STICKY — each player keeps a "home job" for speed, NO forced
-- rotation; gaps fill first with someone who has done the job before,
-- then whoever has done the fewest jobs lately (cross-training happens
-- organically via absences).  Late RSVPs re-run the fill; home holders
-- never get bumped.  Check-off defaults to DONE at the end of the
-- event — only the exceptions get flagged.  Definitions and their copy
-- are these rows (never hardcode copy).
--
--   job_definitions  the set per event kind ('practice'/'match'), with
--                    league_label scoping a set to one league (APSL
--                    game-day set); NULL = any league of that kind.
--                    toggleable = per-event on/off (tents).
--   job_homes        a player's sticky home job(s); code keeps it to
--                    one per set (one practice home, one game home).
--   job_assignments  who holds which job at one event; not_done flags
--                    the exception; source home/fill/manual.
--   event_job_offs   a toggleable job turned OFF for one event — the
--                    freed players pick up other gaps on the re-run.

CREATE TABLE IF NOT EXISTS job_definitions (
    id            SERIAL PRIMARY KEY,
    event_kind    TEXT NOT NULL,                -- 'practice' | 'match'
    league_label  TEXT,                         -- NULL = any league of the kind
    slug          TEXT NOT NULL,
    title         TEXT NOT NULL,                -- short chip title
    description   TEXT NOT NULL,                -- the detail shown on click
    needed_count  INT  NOT NULL DEFAULT 1,
    toggleable    BOOLEAN NOT NULL DEFAULT false,
    sort_order    INT  NOT NULL DEFAULT 0,
    is_active     BOOLEAN NOT NULL DEFAULT true
);
CREATE UNIQUE INDEX IF NOT EXISTS job_definitions_set_slug
    ON job_definitions (event_kind, COALESCE(league_label, ''), slug);

CREATE TABLE IF NOT EXISTS job_homes (
    id                SERIAL PRIMARY KEY,
    person_id         INT NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
    job_definition_id INT NOT NULL REFERENCES job_definitions(id) ON DELETE CASCADE,
    created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (person_id, job_definition_id)
);

CREATE TABLE IF NOT EXISTS job_assignments (
    id                SERIAL PRIMARY KEY,
    fh_event_id       BIGINT NOT NULL REFERENCES fh_events(id) ON DELETE CASCADE,
    job_definition_id INT NOT NULL REFERENCES job_definitions(id) ON DELETE CASCADE,
    person_id         INT NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
    source            TEXT NOT NULL DEFAULT 'fill',   -- 'home' | 'fill' | 'manual'
    not_done          BOOLEAN NOT NULL DEFAULT false, -- default DONE; flag exceptions
    created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (fh_event_id, job_definition_id, person_id)
);
CREATE INDEX IF NOT EXISTS job_assignments_person ON job_assignments (person_id);
CREATE INDEX IF NOT EXISTS job_assignments_event  ON job_assignments (fh_event_id);

CREATE TABLE IF NOT EXISTS event_job_offs (
    id                SERIAL PRIMARY KEY,
    fh_event_id       BIGINT NOT NULL REFERENCES fh_events(id) ON DELETE CASCADE,
    job_definition_id INT NOT NULL REFERENCES job_definitions(id) ON DELETE CASCADE,
    UNIQUE (fh_event_id, job_definition_id)
);

-- ── The practice set (any league) ───────────────────────────────────────
INSERT INTO job_definitions (event_kind, league_label, slug, title, description, needed_count, toggleable, sort_order)
SELECT v.* FROM (VALUES
    ('practice', NULL, 'cones',      'Cones',             'Pick up the cones and put them in the shed.', 1, false, 1),
    ('practice', NULL, 'balls',      'Balls',             'Gather the balls into the ball bags and put the bags in the shed.', 2, false, 2),
    ('practice', NULL, 'goals',      'Goals',             'Put away any goals that were used.', 2, false, 3),
    ('practice', NULL, 'lights',     'Lights — take-down','The 6 LED lights with stands run on the generator — one player takes down each light.', 6, false, 4),
    ('practice', NULL, 'lights-shed','Lights — to shed',  'Four players carry the lights to the shed and tarp them.', 4, false, 5),
    ('practice', NULL, 'generator',  'Generator',         'Shut the generator off.', 1, false, 6)
) AS v(event_kind, league_label, slug, title, description, needed_count, toggleable, sort_order)
WHERE NOT EXISTS (SELECT 1 FROM job_definitions d
                   WHERE d.event_kind = v.event_kind AND COALESCE(d.league_label,'') = COALESCE(v.league_label,'') AND d.slug = v.slug);

-- ── The APSL game-day set ───────────────────────────────────────────────
INSERT INTO job_definitions (event_kind, league_label, slug, title, description, needed_count, toggleable, sort_order)
SELECT v.* FROM (VALUES
    ('match', 'APSL', 'sub-cards',  'Sub cards',          'One player who starts on the bench holds the sub cards. If he is subbed in, the job passes to whoever was subbed off; if he is injured, reassign it to another player.', 1, false, 1),
    ('match', 'APSL', 'warmup',     'Warm-up (no ball)',  'Conduct the non-ball warm-up.', 1, false, 2),
    ('match', 'APSL', 'ball-warmup','Warm-up (ball)',     'Conduct the ball warm-up.', 1, false, 3),
    ('match', 'APSL', 'gk-warmup',  'Warm up goalie',     'Warm up the goalkeeper.', 1, false, 4),
    ('match', 'APSL', 'tents',      'Tents',              'Four players put the tents up. Toggle this job off for a game we are not bringing them — those four get other jobs instead.', 4, true, 5),
    ('match', 'APSL', 'water',      'Water',              'Two players bring one case of water each — reimbursed.', 2, false, 6),
    ('match', 'APSL', 'bench',      'Bench discipline',   'Make sure everyone on the bench has pinnies on and stays seated on the bench — no standing or using a ball on the sidelines.', 1, false, 7)
) AS v(event_kind, league_label, slug, title, description, needed_count, toggleable, sort_order)
WHERE NOT EXISTS (SELECT 1 FROM job_definitions d
                   WHERE d.event_kind = v.event_kind AND COALESCE(d.league_label,'') = COALESCE(v.league_label,'') AND d.slug = v.slug);
