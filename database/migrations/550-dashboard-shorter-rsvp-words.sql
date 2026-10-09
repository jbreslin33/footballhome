-- 550 (2026-10-09) — #dashboard: shorter RSVP wording.
-- Owner: "we don't need text 'still to answer' something smaller to save
-- space. like 'rsvp'".  The event rows and the cell subtitles say
-- "no rsvp" instead.
UPDATE message_templates SET body = '{n}/{of} no rsvp'                      WHERE kind = 'dashboard' AND tier = 'rsvp_row';
UPDATE message_templates SET body = 'Released games this week · no rsvp'    WHERE kind = 'dashboard' AND tier = 'rsvp_games_sub';
UPDATE message_templates SET body = 'Released practices this week · no rsvp' WHERE kind = 'dashboard' AND tier = 'rsvp_practices_sub';
UPDATE message_templates SET body = 'All in'                                WHERE kind = 'dashboard' AND tier = 'rsvp_clear';
UPDATE message_templates SET body = 'None released'                         WHERE kind = 'dashboard' AND tier = 'rsvp_none';
