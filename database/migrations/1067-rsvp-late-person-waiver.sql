-- 1067: excuse ONE player's late RSVP for one game (owner 2026-11-04: "why
-- is Luke Breslin red for apsl event center. turn him normal").  Luke
-- answered Thursday's APSL game (at Vidas, fh_event 75692361) Tue 11/3 3:29
-- PM; the deadline was Mon 11/2 midnight, and on Men's games a late answer
-- costs the start (mig 508) → red "not eligible" in Game Center.
-- rsvp_deadline_waivers (mig 761) only waives a whole game;
-- rsvp_deadline_person_waivers waives it for one person — Game Center's
-- eligibility treats him as on time.  First row: Luke (3463) for 75692361.

BEGIN;

CREATE TABLE IF NOT EXISTS rsvp_deadline_person_waivers (
    fh_event_id  bigint  NOT NULL REFERENCES fh_events(id) ON DELETE CASCADE,
    person_id    integer NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
    note         text,
    created_at   timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (fh_event_id, person_id)
);
COMMENT ON TABLE rsvp_deadline_person_waivers IS
  'mig 1067: this person''s late RSVP for this game is excused — Game Center starter eligibility counts it on time. A whole-game waiver is rsvp_deadline_waivers (mig 761).';

INSERT INTO rsvp_deadline_person_waivers (fh_event_id, person_id, note)
SELECT 75692361, 3463, 'owner 2026-11-04: turn him normal'
 WHERE EXISTS (SELECT 1 FROM persons WHERE id = 3463 AND first_name = 'Luke' AND last_name = 'Breslin')
   AND EXISTS (SELECT 1 FROM fh_events WHERE id = 75692361)
ON CONFLICT DO NOTHING;

COMMIT;
