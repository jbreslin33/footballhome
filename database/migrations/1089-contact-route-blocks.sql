-- 1089: a "don't use this route" note on a person's contact — owner
-- 2026-11-05: "make note anastasia blocks fh texter … so we use club text
-- or email".  Texts for Anastasiya Bembischew (22719, youth) go to her
-- mum Julie Briscoe (22720), whose phone blocks the owner's
-- number — so FH Texter AND a regular text (both from his number) can't
-- reach her.  The 📇 Contact popup greys those routes with the note; POST
-- /api/phone-relay/texts refuses an FH Texter send to a blocked number.

BEGIN;

CREATE TABLE IF NOT EXISTS person_contact_route_blocks (
    person_id   integer NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
    route       text    NOT NULL CHECK (route IN ('relay', 'text', 'club', 'email')),
    note        text    NOT NULL,
    created_at  timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (person_id, route)
);
COMMENT ON TABLE person_contact_route_blocks IS
  'mig 1089: a Contact popup route this person cannot receive (relay = FH Texter, text = regular text from your phone, club = club number, email). note = the reason the popup shows.';

-- The note for a route, by person or by any person holding that number.
CREATE OR REPLACE FUNCTION fh_contact_route_block(p_person_id integer, p_digits text, p_route text)
RETURNS text LANGUAGE sql STABLE AS $$
  SELECT b.note FROM person_contact_route_blocks b
   WHERE b.route = p_route
     AND (b.person_id = p_person_id
          OR (COALESCE(p_digits, '') <> '' AND EXISTS (
                SELECT 1 FROM person_phones pp
                 WHERE pp.person_id = b.person_id
                   AND right(regexp_replace(COALESCE(pp.phone_number, ''), '[^0-9]', '', 'g'), 10) = right(p_digits, 10))))
   ORDER BY b.created_at LIMIT 1
$$;

INSERT INTO person_contact_route_blocks (person_id, route, note)
SELECT 22720, v.route, 'Blocks texts from your number — use club text or email'
  FROM (VALUES ('relay'), ('text')) AS v(route)
 WHERE EXISTS (SELECT 1 FROM persons WHERE id = 22720 AND first_name = 'Julie' AND last_name = 'Briscoe')
ON CONFLICT DO NOTHING;

COMMIT;
