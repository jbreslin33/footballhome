-- 1003 (2026-11-03) — A one-game note on the Game reminder.
-- Owner: "for u8 game reminder let parents know its last outdoor game then
-- indoor season teams will be formed. no extra cost no extra signup. so a
-- special reminder for that game only" … "also do same for u10 game as it
-- looks like only 1 u10 game left right?"
--
--   event_reminder_notes   one row per game that carries a special line:
--                          its words ride on every Game reminder for that
--                          game only (squad_notice: group, starter/bench/
--                          standby and the personal pool link), adult or
--                          parent.  No row = the reminder is unchanged.
--                          Add / change / drop a game's note by migration.
--   squad_notice copy      gains an optional [[ {note}]] after the game
--                          line, so it drops out cleanly when empty.
--
-- (fh_events.fh_notes stays the kit list and stays off reminders.)

BEGIN;

CREATE TABLE IF NOT EXISTS event_reminder_notes (
    fh_event_id BIGINT PRIMARY KEY REFERENCES fh_events(id) ON DELETE CASCADE,
    body        TEXT NOT NULL CHECK (btrim(body) <> ''),
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
COMMENT ON TABLE event_reminder_notes IS
  'A special line on one game''s Game reminder (squad_notice {note}); mig 1003.';

-- U8 Sat Nov 7 at West Philly and U10 Sun Nov 8 vs Torresdale — each
-- team's last outdoor game of the fall.
INSERT INTO event_reminder_notes (fh_event_id, body) VALUES
  (69236957, 'This is our LAST outdoor game of the season! Indoor season teams will be formed next — no extra cost and no extra signup.'),
  (75676613, 'This is our LAST outdoor game of the season! Indoor season teams will be formed next — no extra cost and no extra signup.')
ON CONFLICT (fh_event_id) DO UPDATE SET body = EXCLUDED.body, updated_at = now();

UPDATE message_templates
   SET body = CASE
         WHEN body LIKE '% [[{urgent} ]]{link}%' THEN replace(body, ' [[{urgent} ]]{link}', '[[ {note}]] [[{urgent} ]]{link}')
         WHEN body LIKE '%[[ {urgent}]] {link}%' THEN replace(body, '[[ {urgent}]] {link}', '[[ {note}]][[ {urgent}]] {link}')
         WHEN body LIKE '% Lineup: {link}%'      THEN replace(body, ' Lineup: {link}', '[[ {note}]] Lineup: {link}')
         ELSE body END,
       updated_at = now()
 WHERE kind = 'squad_notice' AND is_active AND body LIKE '%{link}%' AND body NOT LIKE '%{note}%';

DO $$
DECLARE n INT;
BEGIN
  SELECT count(*) INTO n FROM message_templates
   WHERE kind = 'squad_notice' AND is_active AND body LIKE '%{link}%' AND body NOT LIKE '%{note}%';
  IF n <> 0 THEN RAISE EXCEPTION '% Game reminder rows still lack {note}', n; END IF;
END $$;

COMMIT;
