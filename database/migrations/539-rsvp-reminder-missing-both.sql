-- 539 (2026-10-07) — rsvp_reminder / missing_both reads "6 RSVPs (2 games
-- and 4 practices)", not "6 RSVPs — 2 games and 4 practices": the sentence
-- it sits in already has a dash ("Hi Jim — you're missing …").
UPDATE message_templates
   SET body = '{total} RSVPs ({games} game[[{games_s}]] and {practices} practice[[{practices_s}]])', updated_at = now()
 WHERE kind = 'rsvp_reminder' AND tier = 'missing_both';
