-- 1083: #teams player cards — the last-RSVP chip's date was hard to read.
-- The 🗓 emoji drew over the first digit at the chip's 0.6rem size
-- (owner 11/5: "a date that is not fully readable … no label should be
-- partially hidden").  Plain words instead of the icon; person-standing.js
-- also draws it at full chip size and opacity.
UPDATE message_templates SET body = 'last {date}', label = 'Teams chip: last RSVP ({date})', updated_at = now()
 WHERE kind = 'person_standing' AND tier = 'chip_last';
UPDATE message_templates SET body = 'no RSVP', label = 'Teams chip: never answered', updated_at = now()
 WHERE kind = 'person_standing' AND tier = 'chip_never';
