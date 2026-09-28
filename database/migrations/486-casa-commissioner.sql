-- 486 (2026-09-28) — CASA commissioner section.
-- Owner: "the piece for footballhome that is for me being casa commissioner
-- … contact info for the casa select philadelphia liga 1 and 2 teams … use
-- my jbreslin@casasoccerleagues.com email for correspondance like sending
-- bcc emails to all clubs … a whole casa commissioner section. that i hit
-- casa and then there is more buttons".
--
-- #casa is the hub (tiles), #casa-contacts the first button: the Liga 1 /
-- Liga 2 clubs from club_competitions (mig 483) with their contacts, one-tap
-- email/text per contact and a BCC email to every club in a division or the
-- whole league — all composed from the league's correspondence address, not
-- the club's.  Sends are logged in club_contact_messages with the address
-- they went from.
ALTER TABLE leagues ADD COLUMN IF NOT EXISTS correspondence_email TEXT;
COMMENT ON COLUMN leagues.correspondence_email IS 'Gmail account league mail is composed from (authuser), e.g. the commissioner''s league address (mig 486).';
UPDATE leagues SET correspondence_email = 'jbreslin@casasoccerleagues.com' WHERE id = 2 AND correspondence_email IS NULL;

ALTER TABLE club_contact_messages ADD COLUMN IF NOT EXISTS sender_email TEXT;   -- NULL = the club's outreach address
ALTER TABLE club_contact_messages ADD COLUMN IF NOT EXISTS league_label TEXT;   -- 'CASA' when sent from the commissioner section
ALTER TABLE club_contact_messages ADD COLUMN IF NOT EXISTS group_key TEXT;      -- one BCC send = one key on every row

-- Copy + messages, kind 'casa'.  Tiles: subject = label, body = description.
-- Messages: tier all_* = BCC to a division/league, one_* = to one contact.
-- Tokens: {sender} {league} {division} {club} {contact_first} {from_email}.
CREATE OR REPLACE FUNCTION pg_temp.casa_tpl(p_tier text, p_label text, p_subject text, p_body text, p_sort int)
RETURNS void LANGUAGE sql AS $$
  INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
  SELECT 'CASA', p_label, 'casa', p_tier, p_subject, p_body, p_sort, true, true
   WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'casa' AND tier = p_tier);
$$;
SELECT pg_temp.casa_tpl('hub_title', 'CASA hub — title', NULL, 'CASA Select Philadelphia — Commissioner', 1);
SELECT pg_temp.casa_tpl('hub_subtitle', 'CASA hub — subtitle', NULL, 'Liga 1 and Liga 2. Mail from here goes out as {from_email}.', 2);
SELECT pg_temp.casa_tpl('tile_contacts', 'CASA hub — tile: clubs & contacts', 'Clubs & contacts', 'Every Liga 1 and Liga 2 club with its managers — email or text one, or BCC a whole division', 3);
SELECT pg_temp.casa_tpl('tile_links', 'CASA hub — tile: schedule & standings', 'Schedule & standings', 'The league pages for each division and our own team page', 4);
SELECT pg_temp.casa_tpl('tile_log', 'CASA hub — tile: sent mail', 'Sent from the league address', 'What went out to which clubs, and when', 5);
SELECT pg_temp.casa_tpl('contacts_subtitle', 'CASA contacts — subtitle', NULL, 'Pick a division or All. ✉️ All clubs opens one Gmail draft with every club BCC''d, from {from_email}.', 6);
SELECT pg_temp.casa_tpl('bcc_button', 'CASA contacts — BCC button', NULL, '✉️ Email all {scope} clubs (BCC)', 7);
SELECT pg_temp.casa_tpl('bcc_drafted', 'CASA contacts — after the BCC draft opens', NULL, 'Draft open in Gmail to {n} addresses across {clubs} clubs (BCC). {skipped} club(s) have no email on file.', 8);
SELECT pg_temp.casa_tpl('all_announcement', 'CASA — all clubs: announcement', 'CASA Select {division} — league notice',
'Hi all,

{sender} here, CASA Select Philadelphia commissioner. 

Thanks,
{sender}
{from_email}', 10);
SELECT pg_temp.casa_tpl('all_schedule', 'CASA — all clubs: schedule notice', 'CASA Select {division} — schedule update',
'Hi all,

{sender} here, CASA Select Philadelphia commissioner. Please check your schedule on the league site; the following has changed: 

Reply if anything conflicts.

Thanks,
{sender}
{from_email}', 11);
SELECT pg_temp.casa_tpl('all_reminder', 'CASA — all clubs: weekly reminder', 'CASA Select {division} — this weekend',
'Hi all,

{sender} here, CASA Select Philadelphia commissioner. A few reminders for this weekend''s games: rosters must be confirmed before kickoff, home teams provide the match ball and report the score on the league site by Sunday night.

Thanks,
{sender}
{from_email}', 12);
SELECT pg_temp.casa_tpl('one_note', 'CASA — one club: note', 'CASA Select — {club}',
'Hi {contact_first},

{sender} here, CASA Select Philadelphia commissioner. 

Thanks,
{sender}
{from_email}', 13);
SELECT pg_temp.casa_tpl('one_score', 'CASA — one club: score or roster missing', 'CASA Select — {club}, score / roster',
'Hi {contact_first},

{sender} here, CASA Select Philadelphia commissioner. We are missing the score or roster from your last game on the league site. Can you enter it today?

Thanks,
{sender}
{from_email}', 14);
