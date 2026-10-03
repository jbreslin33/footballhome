-- 515 — Kids' games have no bench: Game Center draws everyone who is Going.
--
-- Owner 2026-10-03: "we need kids 'lineup' on game center to show everyone
-- playing. even if 12 kids are 'going' lets not have a bench for kids games
-- so example if 12 going show a 444 formation … just fake it as the kids
-- will be rotated for equal time".
--
-- The rule is per team (like field_size, mig 322), not inferred from the
-- age label in JavaScript: teams.lineup_everyone_plays.  On for every team
-- of the Boys and Girls sections; the lineup endpoint hands it to Game
-- Center, which then draws the Going RSVPs spread over the pitch instead of
-- a picked starting side + bench.

BEGIN;

ALTER TABLE teams ADD COLUMN IF NOT EXISTS lineup_everyone_plays boolean NOT NULL DEFAULT false;

COMMENT ON COLUMN teams.lineup_everyone_plays IS
    'mig 515: no bench for this team''s games — Game Center''s lineup is everyone whose game RSVP is Going, spread over the pitch (kids rotate for equal time).';

UPDATE teams t
   SET lineup_everyone_plays = true
  FROM club_sections cs
 WHERE cs.id = t.club_section_id
   AND cs.name IN ('Boys', 'Girls');

-- Wording, kind 'lineup_everyone'.
CREATE OR REPLACE FUNCTION pg_temp.le(p_tier text, p_label text, p_body text, p_sort int)
RETURNS void LANGUAGE sql AS $$
  INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
  SELECT 'Game Center', p_label, 'lineup_everyone', p_tier, NULL, p_body, p_sort, true, true
   WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'lineup_everyone' AND tier = p_tier);
$$;
SELECT pg_temp.le('note',    'Everyone plays — note under the card', 'Everyone who is Going plays — no bench. Players rotate for equal time, so the spots shown are not fixed positions.', 1);
SELECT pg_temp.le('count',   'Everyone plays — coach tally',         'Playing {n} · {shape}', 2);
SELECT pg_temp.le('section', 'Everyone plays — card section',        'Playing', 3);

COMMIT;
