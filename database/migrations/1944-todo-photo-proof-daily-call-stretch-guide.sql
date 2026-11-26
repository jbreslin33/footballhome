-- 1944 — ✅ To do: a daily item proved by a photo, a phone call when the photo isn't in by a time,
-- and a guide (the routine) on the item itself.  First user: Luke Breslin's daily stretching.
--
-- Owner 2026-11-26: "for luke breslin todo. streting every day. call if he has not uploaded photo of
-- him starting streting routine uploaded 1pm every day. on the page give him full complement of
-- stretehcss for soccer but just also in general"
--
--   person_todos.photo_proof   the item is ticked by uploading a photo (📷), not by ✓ Done
--   person_todos.call_at       club time; a daily item still without today's photo then gets ONE call
--                              (TodoCallScheduler, every 60 s; window call_at … call_at + 2 h; only if the
--                              item existed before that day's call time, so a fresh item never rings at once)
--   person_todos.guide_id      📖 the routine shown on the item (todo_guides → sections → items)
--   person_todo_photos         the day's photo(s), bytes in the DB like club_files
--   person_todo_calls          one row per item per club day = the claim (no double ring) + the log
--   todo_call_policy           one row: is_on (the kill switch)
--
-- Stretching content: FH original wording.  Warm-up order follows the FIFA 11+ injury-prevention
-- programme (FIFA Medical Network; Bizzini & Dvorak 2015); Nordic hamstring curl (van der Horst et al.
-- 2015, Am J Sports Med) and Copenhagen adductor plank (Harøy et al. 2019, Br J Sports Med) are the
-- evidence-based soccer strength pair; static holds of 30 s (ACSM guidance) after training, dynamic
-- before (long static holds right before sprinting cost power — Behm & Chaouachi 2011).

BEGIN;

CREATE TABLE IF NOT EXISTS todo_guides (
    id         smallserial PRIMARY KEY,
    slug       text NOT NULL UNIQUE,
    title      text NOT NULL,
    intro      text NOT NULL DEFAULT '',
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS todo_guide_sections (
    id       serial PRIMARY KEY,
    guide_id smallint NOT NULL REFERENCES todo_guides(id) ON DELETE CASCADE,
    sort     int NOT NULL,
    title    text NOT NULL,
    note     text NOT NULL DEFAULT '',
    UNIQUE (guide_id, sort)
);

CREATE TABLE IF NOT EXISTS todo_guide_items (
    id         serial PRIMARY KEY,
    section_id int NOT NULL REFERENCES todo_guide_sections(id) ON DELETE CASCADE,
    sort       int NOT NULL,
    name       text NOT NULL,
    how        text NOT NULL,
    dose       text NOT NULL DEFAULT '',
    UNIQUE (section_id, sort)
);

ALTER TABLE person_todos
    ADD COLUMN IF NOT EXISTS photo_proof boolean NOT NULL DEFAULT false,
    ADD COLUMN IF NOT EXISTS call_at     time,
    ADD COLUMN IF NOT EXISTS guide_id    smallint REFERENCES todo_guides(id) ON DELETE SET NULL;

CREATE TABLE IF NOT EXISTS person_todo_photos (
    id             bigserial PRIMARY KEY,
    person_todo_id bigint NOT NULL REFERENCES person_todos(id) ON DELETE CASCADE,
    club_day       date NOT NULL,
    mime           text NOT NULL,
    byte_size      int NOT NULL,
    bytes          bytea NOT NULL,
    uploaded_at    timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS person_todo_photos_day ON person_todo_photos (person_todo_id, club_day);

CREATE TABLE IF NOT EXISTS person_todo_calls (
    person_todo_id bigint NOT NULL REFERENCES person_todos(id) ON DELETE CASCADE,
    club_day       date NOT NULL,
    placed_at      timestamptz NOT NULL DEFAULT now(),
    contact        text,
    ok             boolean,
    twilio_sid     text,
    error          text,
    PRIMARY KEY (person_todo_id, club_day)
);

CREATE TABLE IF NOT EXISTS todo_call_policy (
    id    smallint PRIMARY KEY CHECK (id = 1),
    is_on boolean NOT NULL DEFAULT true
);
INSERT INTO todo_call_policy (id, is_on) VALUES (1, true) ON CONFLICT (id) DO NOTHING;

-- Calls due now: daily, photo-proved, a call time; club time past it (2 h window); the item existed
-- before today's call time; no photo today; not rung today; the policy on.
CREATE OR REPLACE VIEW fh_todo_calls_due AS
WITH c AS (SELECT (now() AT TIME ZONE 'America/New_York') AS now_local)
SELECT pt.id AS person_todo_id, pt.person_id, pt.body, pt.call_at,
       (c.now_local)::date AS club_day
  FROM person_todos pt, c
 WHERE (SELECT is_on FROM todo_call_policy WHERE id = 1)
   AND pt.repeat = 'daily' AND pt.photo_proof AND pt.call_at IS NOT NULL
   AND c.now_local::time >= pt.call_at
   AND c.now_local::time <  pt.call_at + interval '2 hours'
   AND pt.created_at < ((c.now_local::date + pt.call_at) AT TIME ZONE 'America/New_York')
   AND NOT EXISTS (SELECT 1 FROM person_todo_photos ph WHERE ph.person_todo_id = pt.id AND ph.club_day = c.now_local::date)
   AND NOT EXISTS (SELECT 1 FROM person_todo_calls cl WHERE cl.person_todo_id = pt.id AND cl.club_day = c.now_local::date);

-- ── Words ───────────────────────────────────────────────────────────────────
INSERT INTO message_templates (category, label, kind, tier, body, client_side, sort_order) VALUES
  ('To do', 'To-do call: spoken when the day''s photo is not in ({first}, {todo})', 'todo_call', 'call',
   'Hi {first}, this is Football Home with your daily reminder. Today''s photo is not in yet for: {todo}. Please start it now, take a photo, and upload it in the app under To do. Thank you.', false, 10),
  ('Event Center', 'To-do: upload the day''s photo button', 'event_center', 'todo_photo', '📷 Upload photo', true, 960),
  ('Event Center', 'To-do: photo uploaded today ({time})', 'event_center', 'todo_photo_in', '📷 Photo in {time}', true, 961),
  ('Event Center', 'To-do: replace today''s photo button', 'event_center', 'todo_photo_again', '📷 Replace', true, 962),
  ('Event Center', 'To-do: uploading…', 'event_center', 'todo_photo_busy', 'Uploading…', true, 963),
  ('Event Center', 'To-do: photo-proved item note', 'event_center', 'todo_photo_need', 'a photo ticks it off', true, 964),
  ('Event Center', 'To-do: call note ({time})', 'event_center', 'todo_call_note', '📞 a call at {time} if no photo', true, 965),
  ('Event Center', 'To-do: show the routine button', 'event_center', 'todo_guide_open', '📖 Routine', true, 966),
  ('Event Center', 'To-do: hide the routine button', 'event_center', 'todo_guide_close', '📖 Hide routine', true, 967),
  ('Player sheet', 'To-do tab: today''s photo link', 'player_sheet', 'todo_photo_view', '📷 Today''s photo', true, 970),
  ('Player sheet', 'To-do tab: photo-proved item, none today', 'player_sheet', 'todo_photo_none', '📷 No photo today', true, 971),
  ('Player sheet', 'To-do tab: call time tag ({time})', 'player_sheet', 'todo_call_tag', '📞 call {time} if no photo', true, 972),
  ('Player sheet', 'To-do tab: called today ({time})', 'player_sheet', 'todo_called', '📞 called {time}', true, 973);

-- ── The stretching guide ────────────────────────────────────────────────────
INSERT INTO todo_guides (slug, title, intro) VALUES
  ('stretching', 'Daily stretching — soccer and the whole body',
   'About 15–20 minutes. Warm up first (never stretch cold). Before training or a game do Part 1 only; do Parts 2 and 3 after training or in the evening. Stretch to a mild pull, never pain, never bounce, and keep breathing. Hold each static stretch 30 seconds a side, 2 rounds. Sharp pain = stop.')
ON CONFLICT (slug) DO NOTHING;

WITH g AS (SELECT id FROM todo_guides WHERE slug = 'stretching')
INSERT INTO todo_guide_sections (guide_id, sort, title, note)
SELECT g.id, s.sort, s.title, s.note FROM g, (VALUES
  (1, 'Part 1 — Dynamic warm-up (before training, 8–10 min)', 'Moving stretches that get the body ready to run, kick and turn. In order, the way the FIFA 11+ warm-up goes.'),
  (2, 'Part 2 — Soccer stretches (after training or evening)', 'The muscles soccer works hardest. 30 s each side, 2 rounds.'),
  (3, 'Part 3 — The whole body (general)', 'Back, neck, shoulders, chest and wrists — the rest of you. 30 s each, 2 rounds.'),
  (4, 'Part 4 — Strength that protects (2–3 days a week)', 'Not stretches, but the two exercises shown to cut soccer hamstring and groin injuries. Add them after Part 1 on two or three days a week.')
) AS s(sort, title, note)
ON CONFLICT (guide_id, sort) DO NOTHING;

WITH sec AS (SELECT s.id, s.sort FROM todo_guide_sections s JOIN todo_guides g ON g.id = s.guide_id WHERE g.slug = 'stretching')
INSERT INTO todo_guide_items (section_id, sort, name, how, dose)
SELECT sec.id, i.sort, i.name, i.how, i.dose FROM sec JOIN (VALUES
  -- Part 1
  (1, 1,  'Easy jog', 'Jog lightly, then jog with small arm circles forward and back.', '2 min'),
  (1, 2,  'Leg swings — front to back', 'Hold a wall or post, swing one leg forward and back, relaxed, a little higher each time.', '10 each leg'),
  (1, 3,  'Leg swings — side to side', 'Face the wall, swing the leg across your body and out to the side.', '10 each leg'),
  (1, 4,  'Hip out / hip in (open and close the gate)', 'Walking, lift the knee to the front and turn it out to the side; then lift it to the side and bring it round to the front.', '10 m each way'),
  (1, 5,  'Walking knee hug', 'Step, pull the other knee to your chest, rise onto the toes of the standing foot.', '10 m'),
  (1, 6,  'Walking quad pull', 'Step, catch the other ankle behind you, heel to bum, knees together, stand tall.', '10 m'),
  (1, 7,  'Walking lunge with a twist', 'Long step into a lunge, back knee just off the ground, turn your chest over the front leg.', '6 each leg'),
  (1, 8,  'Inchworm', 'From standing, walk your hands out to a plank, then walk the feet up to the hands with legs as straight as you can.', '5'),
  (1, 9,  'World''s greatest stretch', 'From a lunge, put both hands inside the front foot, drop the elbow toward the instep, then rotate that arm up to the sky.', '4 each side'),
  (1, 10, 'Heel flicks and high knees', 'Quick heel flicks to the bum, then quick high knees — light, on the balls of the feet.', '10 m each'),
  (1, 11, 'Side shuffle and carioca', 'Shuffle sideways without crossing the feet; then carioca (cross in front, cross behind) both ways.', '10 m each way'),
  (1, 12, 'Build-up runs', 'Three runs building from half pace to near full speed; walk back.', '3 × 30 m'),
  -- Part 2
  (2, 1,  'Hamstrings', 'Lie on your back, one leg straight up (a towel or band round the foot helps), the other leg flat. Pull gently, knee straight.', '30 s each, ×2'),
  (2, 2,  'Quads', 'Stand on one leg (hold something), heel to bum, knees together, push the hip forward a little.', '30 s each, ×2'),
  (2, 3,  'Hip flexors', 'Half-kneel (back knee on a towel), squeeze the glute of the back leg and shift forward until the front of that hip pulls. Arm up on the same side for more.', '30 s each, ×2'),
  (2, 4,  'Groin — butterfly', 'Sit, soles of the feet together, knees out; hold the feet and let the knees drop, back tall.', '30 s, ×2'),
  (2, 5,  'Groin — side lunge', 'Wide stance, bend one knee and sit to that side, other leg straight, toes up.', '30 s each, ×2'),
  (2, 6,  'Calf (straight knee)', 'Hands on a wall, back leg straight, heel down, lean in.', '30 s each, ×2'),
  (2, 7,  'Calf / Achilles (bent knee)', 'Same as above but bend the back knee, heel still down — feel it lower, near the ankle.', '30 s each, ×2'),
  (2, 8,  'Glutes — figure four', 'On your back, cross one ankle over the other knee, pull the bottom thigh toward you.', '30 s each, ×2'),
  (2, 9,  'Hips — 90/90', 'Sit with the front leg bent at 90° in front and the back leg bent at 90° behind; sit tall and lean over the front shin. Switch sides.', '30 s each, ×2'),
  (2, 10, 'Outside of the hip (TFL / IT band)', 'Stand, cross one leg behind the other, push that hip out and lean the other way, arm overhead.', '30 s each, ×2'),
  -- Part 3
  (3, 1,  'Neck side stretch', 'Sit or stand tall, ear toward the shoulder, the other shoulder down. Gentle — no pulling.', '30 s each, ×2'),
  (3, 2,  'Chest — doorway', 'Forearm on a doorframe, elbow at shoulder height, step through until the chest opens.', '30 s each, ×2'),
  (3, 3,  'Shoulder — across the body', 'Bring one arm straight across the chest, hold it with the other above the elbow.', '30 s each, ×2'),
  (3, 4,  'Triceps / lats overhead', 'Arm overhead, hand down the back, other hand gently pushes the elbow; lean a little to the side.', '30 s each, ×2'),
  (3, 5,  'Upper back — open book', 'Lie on your side, knees bent at 90°, arms straight in front; open the top arm across to the other side and follow it with your eyes.', '8 each side'),
  (3, 6,  'Spine — cat / cow', 'On hands and knees, round the back up slowly, then let it sink and lift the chest.', '10 slow'),
  (3, 7,  'Lower back — child''s pose', 'Kneel, sit back on the heels, arms long in front, forehead down, breathe into the back.', '30 s, ×2'),
  (3, 8,  'Front of the body — sphinx / cobra', 'Lie face down, prop on the forearms (sphinx) or hands (cobra), hips down, shoulders away from the ears.', '30 s, ×2'),
  (3, 9,  'Lying twist', 'On your back, knees together to one side, arms out, look the other way.', '30 s each, ×2'),
  (3, 10, 'Deep squat hold', 'Feet shoulder-width, sit all the way down, heels flat (hold something if needed), elbows push the knees out.', '30–60 s'),
  (3, 11, 'Wrists and forearms', 'Arm straight, palm up, pull the fingers back gently; then palm down, fingers toward you.', '20 s each way'),
  (3, 12, 'Ankle circles', 'Seated or standing, draw big slow circles with each foot, both directions.', '10 each way'),
  -- Part 4
  (4, 1,  'Nordic hamstring curl', 'Kneel with the heels held down (a partner or under a sofa). Keep the body straight from knees to head and lower yourself forward as slowly as you can; catch with the hands, push back up.', '2–3 sets of 5'),
  (4, 2,  'Copenhagen adductor plank', 'Side plank on the elbow with the top leg''s knee (easier) or ankle (harder) on a bench or chair, bottom leg off the ground; hold the body straight.', '3 × 15–30 s each side')
) AS i(sec, sort, name, how, dose) ON i.sec = sec.sort
ON CONFLICT (section_id, sort) DO NOTHING;

-- ── Luke Breslin's daily item (person 3463), given by James (person 1) ──────
INSERT INTO person_todos (person_id, body, repeat, assigned_by_person_id, photo_proof, call_at, guide_id)
SELECT 3463, 'Stretch — start your routine and upload a photo', 'daily', 1, true, '13:00',
       (SELECT id FROM todo_guides WHERE slug = 'stretching')
 WHERE NOT EXISTS (SELECT 1 FROM person_todos WHERE person_id = 3463 AND guide_id = (SELECT id FROM todo_guides WHERE slug = 'stretching'));

COMMIT;
