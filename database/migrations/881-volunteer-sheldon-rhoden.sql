-- 881 (2026-10-30) — Sheldon Rhoden is a volunteer (mig 704): no dues, no
-- fines, out of the projections.  Owner: "put sheldon as volunteer" …
-- "sheldon listed at youth" — the membership is the Boys program, and the
-- volunteer rule follows the person, so the section does not matter.

INSERT INTO club_volunteers (person_id, helps_with)
VALUES (22433, 'Coaching')
ON CONFLICT (person_id) DO NOTHING;
