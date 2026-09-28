-- 483 (2026-09-28) — Opponent contacts: who to text or email at the clubs we play.
-- Owner: "would be good to have a messaging system for opponents. so its easy
-- to text or email them same way we do rsvp reminders … a contact page but
-- also right on the game center … break it down by division and conference
-- so its not a big mess. also youth break down u8, u10 etc … same for women."
--
-- Model: a club sits in one or more COMPETITIONS (league + division/conference
-- /age band + season) — that is what the pills on #opponents group by — and
-- has CONTACTS (people, or a bare team email).  A contact is club-wide unless
-- scoped to one competition (a big club with a different manager per team).
-- Each Text/Email tap is logged in club_contact_messages like rsvp_reminders.
-- Wording of the messages and the page is message_templates kind='opponent'.
--
-- First fill, all read-only public or owner-supplied sources:
--   CASA Select recruiting sheet (club_files #4, uploaded by owner 9/28) —
--     Liga 1 / Liga 2 opponents + prospects, lead, last-contacted, emails;
--   apslsoccer.com Teams page — Delaware River Conference groups A and B,
--     public staff names (no phones/emails are public there);
--   tcwsl.com Team Info pages — Divisions I–III, captain name + email.
-- Youth (U8, U10 …) uses the same shape: league + 'U10' as the division.

CREATE TABLE IF NOT EXISTS club_competitions (
    id              SERIAL PRIMARY KEY,
    club_id         INTEGER NOT NULL REFERENCES clubs(id) ON DELETE CASCADE,
    league_id       INTEGER REFERENCES leagues(id) ON DELETE SET NULL,
    league_label    TEXT NOT NULL,                      -- 'APSL', 'CASA', 'TCWSL', 'EPYSA' — the first pill row
    division_label  TEXT NOT NULL,                      -- 'Delaware River A', 'Liga 2', 'Division III', 'U10' — the second
    season          TEXT NOT NULL DEFAULT '2026/27',
    status          TEXT NOT NULL DEFAULT 'opponent' CHECK (status IN ('opponent','prospect','inactive')),
    lead_name       TEXT,                               -- who at Lighthouse owns the relationship (sheet: Lead)
    last_contacted  TEXT,                               -- free text from the sheet ("JB called 8/10")
    notes           TEXT,
    home_field      TEXT,
    external_url    TEXT,                               -- the league's page for this team
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (club_id, league_label, division_label, season)
);
CREATE INDEX IF NOT EXISTS club_competitions_group_idx ON club_competitions (season, league_label, division_label);

CREATE TABLE IF NOT EXISTS club_contacts (
    id              SERIAL PRIMARY KEY,
    club_id         INTEGER NOT NULL REFERENCES clubs(id) ON DELETE CASCADE,
    competition_id  INTEGER REFERENCES club_competitions(id) ON DELETE SET NULL,   -- NULL = whole club
    name            TEXT,                               -- NULL = a bare team mailbox
    role            TEXT,                               -- Manager, Head Coach, Captain, Registrar …
    phone           TEXT,
    email           TEXT,
    note            TEXT,
    source          TEXT,                               -- 'casa-sheet', 'apslsoccer.com', 'tcwsl.com', 'manual'
    is_active       BOOLEAN NOT NULL DEFAULT true,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS club_contacts_club_idx ON club_contacts (club_id, is_active);

CREATE TABLE IF NOT EXISTS club_contact_messages (
    id              BIGSERIAL PRIMARY KEY,
    club_id         INTEGER NOT NULL REFERENCES clubs(id) ON DELETE CASCADE,
    contact_id      INTEGER REFERENCES club_contacts(id) ON DELETE SET NULL,
    match_id        INTEGER,                            -- matches.id when sent from Game Center
    channel         TEXT NOT NULL CHECK (channel IN ('email','sms')),
    contact         TEXT NOT NULL,                      -- the address or number the compose opened with
    tier            TEXT NOT NULL,                      -- message_templates tier used
    sent_by_user_id INTEGER,
    sent_at         TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS club_contact_messages_club_idx ON club_contact_messages (club_id, sent_at DESC);

-- ── message wording (kind 'opponent'; tiers with a subject are the message
--    choices, the rest is page copy).  Tokens: {club} {contact_first}
--    {our_team} {date} {time} {venue} {home_away} {sender}.
CREATE OR REPLACE FUNCTION pg_temp.opp_tpl(p_tier text, p_label text, p_subject text, p_body text, p_sort int)
RETURNS void LANGUAGE sql AS $$
  INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
  SELECT 'Opponents', p_label, 'opponent', p_tier, p_subject, p_body, p_sort, true, true
   WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'opponent' AND tier = p_tier);
$$;
SELECT pg_temp.opp_tpl('confirm', 'Opponent — confirm the game', 'Lighthouse 1893 SC {home_away} {club} — {date}',
'Hi {contact_first},

{sender} here from Lighthouse 1893 SC. Confirming our game {home_away} {club} on {date} at {time}, {venue}. Please confirm you have the same, and let us know your kit colors.

Thanks,
{sender}', 1);
SELECT pg_temp.opp_tpl('kit', 'Opponent — ask kit colors', 'Kit colors — Lighthouse 1893 SC {home_away} {club}, {date}',
'Hi {contact_first},

{sender} from Lighthouse 1893 SC. What colors are you wearing {date}? We''ll pick ours to avoid a clash.

Thanks,
{sender}', 2);
SELECT pg_temp.opp_tpl('reschedule', 'Opponent — move the game', 'Lighthouse 1893 SC {home_away} {club} — moving {date}?',
'Hi {contact_first},

{sender} from Lighthouse 1893 SC. Would you be open to moving our game on {date}? Send a couple of dates and times that work and we''ll sort it with the league.

Thanks,
{sender}', 3);
SELECT pg_temp.opp_tpl('general', 'Opponent — blank note', 'Lighthouse 1893 SC — {club}',
'Hi {contact_first},

{sender} from Lighthouse 1893 SC. 

Thanks,
{sender}', 4);
SELECT pg_temp.opp_tpl('subtitle', 'Opponents page — subtitle', NULL,
'Who to text or email at the clubs we play. Pick the league, then the division or age group. Each tap opens your phone or Gmail with the message filled in and is logged here.', 10);
SELECT pg_temp.opp_tpl('no_contacts', 'Opponents — club has nobody listed yet', NULL,
'No contact yet — add a name, phone or email.', 11);
SELECT pg_temp.opp_tpl('game_center_title', 'Game Center — opponent contacts panel title', NULL, '📇 Contact {club}', 12);
SELECT pg_temp.opp_tpl('game_center_none', 'Game Center — no club matched to this opponent', NULL,
'No club matched to "{opponent}". Add it on the Opponents page (an alias with that exact spelling links it).', 13);
SELECT pg_temp.opp_tpl('prospect_label', 'Opponents — pill for prospects (clubs we are recruiting, not playing)', NULL, 'Prospects', 14);

-- ── a club by any of its spellings; created when new ────────────────────
CREATE OR REPLACE FUNCTION pg_temp.club_for(p_alias text, p_canonical text) RETURNS int LANGUAGE plpgsql AS $$
DECLARE cid int;
BEGIN
  SELECT club_id INTO cid FROM club_aliases WHERE LOWER(BTRIM(alias)) = LOWER(BTRIM(p_alias)) LIMIT 1;
  IF cid IS NULL THEN SELECT id INTO cid FROM clubs WHERE LOWER(BTRIM(name)) = LOWER(BTRIM(p_canonical)) ORDER BY id LIMIT 1; END IF;
  IF cid IS NULL THEN SELECT id INTO cid FROM clubs WHERE LOWER(BTRIM(name)) = LOWER(BTRIM(p_alias)) ORDER BY id LIMIT 1; END IF;
  IF cid IS NULL THEN INSERT INTO clubs (name, sport_id, is_active) VALUES (BTRIM(p_canonical), 1, true) RETURNING id INTO cid; END IF;
  IF LOWER(BTRIM(p_alias)) <> LOWER(BTRIM(p_canonical)) AND NOT EXISTS (SELECT 1 FROM club_aliases WHERE LOWER(BTRIM(alias)) = LOWER(BTRIM(p_alias))) THEN
    INSERT INTO club_aliases (club_id, alias, notes) VALUES (cid, BTRIM(p_alias), 'mig 483 opponent contacts');
  END IF;
  RETURN cid;
END $$;

CREATE OR REPLACE FUNCTION pg_temp.comp(p_alias text, p_canonical text, p_league_id int, p_league text, p_division text,
                                        p_status text, p_lead text, p_last text, p_notes text, p_field text, p_url text) RETURNS int LANGUAGE plpgsql AS $$
DECLARE cid int; kid int;
BEGIN
  cid := pg_temp.club_for(p_alias, p_canonical);
  INSERT INTO club_competitions (club_id, league_id, league_label, division_label, season, status, lead_name, last_contacted, notes, home_field, external_url)
  VALUES (cid, p_league_id, p_league, p_division, '2026/27', p_status, NULLIF(p_lead,''), NULLIF(p_last,''), NULLIF(p_notes,''), NULLIF(p_field,''), NULLIF(p_url,''))
  ON CONFLICT (club_id, league_label, division_label, season) DO UPDATE
     SET lead_name = COALESCE(EXCLUDED.lead_name, club_competitions.lead_name),
         last_contacted = COALESCE(EXCLUDED.last_contacted, club_competitions.last_contacted),
         notes = COALESCE(EXCLUDED.notes, club_competitions.notes),
         home_field = COALESCE(EXCLUDED.home_field, club_competitions.home_field),
         external_url = COALESCE(EXCLUDED.external_url, club_competitions.external_url)
  RETURNING id INTO kid;
  RETURN kid;
END $$;

CREATE OR REPLACE FUNCTION pg_temp.contact(p_alias text, p_canonical text, p_name text, p_role text, p_phone text, p_email text, p_source text, p_comp int DEFAULT NULL)
RETURNS void LANGUAGE plpgsql AS $$
DECLARE cid int;
BEGIN
  cid := pg_temp.club_for(p_alias, p_canonical);
  IF p_email IS NOT NULL AND p_email <> '' AND EXISTS (SELECT 1 FROM club_contacts WHERE club_id = cid AND LOWER(email) = LOWER(p_email)) THEN
    UPDATE club_contacts SET name = COALESCE(name, NULLIF(p_name,'')), role = COALESCE(role, NULLIF(p_role,'')), phone = COALESCE(phone, NULLIF(p_phone,''))
     WHERE club_id = cid AND LOWER(email) = LOWER(p_email);
    RETURN;
  END IF;
  IF (p_email IS NULL OR p_email = '') AND p_name IS NOT NULL AND EXISTS (SELECT 1 FROM club_contacts WHERE club_id = cid AND LOWER(COALESCE(name,'')) = LOWER(p_name)) THEN
    RETURN;
  END IF;
  INSERT INTO club_contacts (club_id, competition_id, name, role, phone, email, source)
  VALUES (cid, p_comp, NULLIF(p_name,''), NULLIF(p_role,''), NULLIF(p_phone,''), NULLIF(LOWER(p_email),''), p_source);
END $$;


-- ── CASA Select sheet (club_files #4) ──────────────────────────────────
SELECT pg_temp.club_for('Persepolis FC I', 'Persepolis FC');
SELECT pg_temp.contact('Persepolis FC I', 'Persepolis FC', NULL, NULL, NULL, 'aashrafiuon@gmail.com', 'casa-sheet');
SELECT pg_temp.club_for('Westtown FC I', 'Westtown FC');
SELECT pg_temp.comp('Desert Hawks FC', 'Desert Hawks', 2, 'CASA', 'Liga 1', 'opponent', 'Breslin', NULL, NULL, NULL, NULL);
SELECT pg_temp.contact('Desert Hawks FC', 'Desert Hawks', NULL, NULL, NULL, 'mogoub87@gmail.com', 'casa-sheet');
SELECT pg_temp.comp('Oaklyn United FC II', 'Oaklyn United FC', 2, 'CASA', 'Liga 1', 'opponent', 'Michael', NULL, 'Mass email 6/29.', NULL, NULL);
SELECT pg_temp.contact('Oaklyn United FC II', 'Oaklyn United FC', NULL, NULL, NULL, 'mpastore822@gmail.com', 'casa-sheet');
SELECT pg_temp.contact('Oaklyn United FC II', 'Oaklyn United FC', NULL, NULL, NULL, 'alew46@gmail.com', 'casa-sheet');
SELECT pg_temp.contact('Oaklyn United FC II', 'Oaklyn United FC', NULL, NULL, NULL, 'info@oaklynunitedfc.com', 'casa-sheet');
SELECT pg_temp.contact('Oaklyn United FC II', 'Oaklyn United FC', NULL, NULL, NULL, 'noah.blodget@gmail.com', 'casa-sheet');
SELECT pg_temp.comp('Philadelphia SC Select', 'Philadelphia SC Select', 2, 'CASA', 'Liga 1', 'opponent', 'Nolan', NULL, 'Mass email 8/11.', NULL, NULL);
SELECT pg_temp.contact('Philadelphia SC Select', 'Philadelphia SC Select', NULL, NULL, NULL, 'psc.adults@gmail.com', 'casa-sheet');
SELECT pg_temp.comp('Philadelphia Sierra Stars', 'Philadelphia Sierra Stars', 2, 'CASA', 'Liga 1', 'opponent', 'Michael', NULL, 'Mass email 6/29.', NULL, NULL);
SELECT pg_temp.contact('Philadelphia Sierra Stars', 'Philadelphia Sierra Stars', NULL, NULL, NULL, 'umarr2122@gmail.com', 'casa-sheet');
SELECT pg_temp.contact('Philadelphia Sierra Stars', 'Philadelphia Sierra Stars', NULL, NULL, NULL, 'alphakanu5@gmail.com', 'casa-sheet');
SELECT pg_temp.comp('Phoenix SCM', 'Phoenix SCM', 2, 'CASA', 'Liga 1', 'opponent', 'Nolan', NULL, 'Mass email 6/15.', NULL, NULL);
SELECT pg_temp.contact('Phoenix SCM', 'Phoenix SCM', NULL, NULL, NULL, 'powj44@gmail.com', 'casa-sheet');
SELECT pg_temp.comp('VE Reserves', 'Vereinigung Erzgebirge', 2, 'CASA', 'Liga 1', 'opponent', 'Breslin', NULL, NULL, NULL, NULL);
SELECT pg_temp.contact('VE Reserves', 'Vereinigung Erzgebirge', 'Billy Gorman', 'Captain', '267-574-3080', 'oldfield.rob10@gmail.com', 'casa-sheet');
SELECT pg_temp.contact('VE Reserves', 'Vereinigung Erzgebirge', NULL, NULL, NULL, 'ericmroby@gmail.com', 'casa-sheet');
SELECT pg_temp.contact('VE Reserves', 'Vereinigung Erzgebirge', NULL, NULL, NULL, 'gormanbilly15@gmail.com', 'casa-sheet');
SELECT pg_temp.contact('VE Reserves', 'Vereinigung Erzgebirge', NULL, NULL, NULL, 'nicksienkiewicz4@gmail.com', 'casa-sheet');
SELECT pg_temp.contact('VE Reserves', 'Vereinigung Erzgebirge', NULL, NULL, NULL, 'q1s2d3@ymail.com', 'casa-sheet');
SELECT pg_temp.comp('WC Predators II', 'WC Predators', 2, 'CASA', 'Liga 1', 'opponent', 'Nolan', NULL, NULL, NULL, NULL);
SELECT pg_temp.contact('WC Predators II', 'WC Predators', 'Ridge Robinson', 'Manager', '(720) 206-5091', 'ridgescores@gmail.com', 'casa-sheet');
SELECT pg_temp.contact('WC Predators II', 'WC Predators', NULL, NULL, NULL, 'blsantangelo@comcast.net', 'casa-sheet');
SELECT pg_temp.comp('Danubia SC', 'Danubia Soccer Club', 2, 'CASA', 'Liga 2', 'opponent', 'Breslin', NULL, 'Mass email 8/11.', NULL, NULL);
SELECT pg_temp.contact('Danubia SC', 'Danubia Soccer Club', NULL, NULL, NULL, 'gmbreslin14@verizon.net', 'casa-sheet');
SELECT pg_temp.comp('Desert Hawks II', 'Desert Hawks', 2, 'CASA', 'Liga 2', 'opponent', 'Breslin', NULL, NULL, NULL, NULL);
SELECT pg_temp.contact('Desert Hawks II', 'Desert Hawks', 'Mohamed Mahgoub', NULL, '(215) 939-0056', 'mogoub87@gmail.com', 'casa-sheet');
SELECT pg_temp.comp('Nomads FC', 'Nomads FC', 2, 'CASA', 'Liga 2', 'opponent', 'Breslin', NULL, NULL, NULL, NULL);
SELECT pg_temp.contact('Nomads FC', 'Nomads FC', 'Amer Bleik', NULL, NULL, 'amerbleik8@gmail.com', 'casa-sheet');
SELECT pg_temp.comp('Persepolis United FC II', 'Persepolis FC', 2, 'CASA', 'Liga 2', 'opponent', 'Nolan', NULL, 'Mass email 6/15.', NULL, NULL);
SELECT pg_temp.contact('Persepolis United FC II', 'Persepolis FC', NULL, NULL, NULL, 'aashrafiuon@gmail.com', 'casa-sheet');
SELECT pg_temp.contact('Persepolis United FC II', 'Persepolis FC', NULL, NULL, NULL, 'mirzaeipayman@gmail.com', 'casa-sheet');
SELECT pg_temp.contact('Persepolis United FC II', 'Persepolis FC', NULL, NULL, NULL, 'seankhazael@gmail.com', 'casa-sheet');
SELECT pg_temp.comp('Phila Heritage SC II', 'Philadelphia Heritage SC', 2, 'CASA', 'Liga 2', 'opponent', 'Breslin', NULL, NULL, NULL, NULL);
SELECT pg_temp.contact('Phila Heritage SC II', 'Philadelphia Heritage SC', NULL, NULL, NULL, 'rsvp@heritagesoccerclub.com', 'casa-sheet');
SELECT pg_temp.contact('Phila Heritage SC II', 'Philadelphia Heritage SC', NULL, NULL, NULL, 'mberg@heritagesoccerclub.com', 'casa-sheet');
SELECT pg_temp.comp('Philadelphia Lions', 'Philadelphia Lions', 2, 'CASA', 'Liga 2', 'opponent', 'Nolan', 'JB called 8/10', NULL, NULL, NULL);
SELECT pg_temp.contact('Philadelphia Lions', 'Philadelphia Lions', 'Moore Massaquoi', NULL, '4845229762', 'hansfirefox@yahoo.com', 'casa-sheet');
SELECT pg_temp.comp('Phoenix SCR', 'Phoenix', 2, 'CASA', 'Liga 2', 'opponent', 'Nolan', NULL, 'Mass email 6/15.', NULL, NULL);
SELECT pg_temp.contact('Phoenix SCR', 'Phoenix', NULL, NULL, NULL, 'powj44@gmail.com', 'casa-sheet');
SELECT pg_temp.contact('Phoenix SCR', 'Phoenix', NULL, NULL, NULL, 'bigtroy5@yahoo.com', 'casa-sheet');
SELECT pg_temp.comp('Street Soccer USA Philly', 'Street Soccer USA Philly', 2, 'CASA', 'Liga 2', 'opponent', 'Michael', NULL, NULL, NULL, NULL);
SELECT pg_temp.contact('Street Soccer USA Philly', 'Street Soccer USA Philly', 'Wilson Jah', NULL, NULL, 'wilsonjehbleh@yahoo.com', 'casa-sheet');
SELECT pg_temp.comp('Ade United FC', 'Ade United FC', 2, 'CASA', 'Liga 1', 'prospect', 'Michael', NULL, 'Mass email 6/29.', NULL, NULL);
SELECT pg_temp.contact('Ade United FC', 'Ade United FC', NULL, NULL, NULL, 'l.king129147@gmail.com', 'casa-sheet');
SELECT pg_temp.contact('Ade United FC', 'Ade United FC', NULL, NULL, NULL, 'adeunitedfc@gmail.com', 'casa-sheet');
SELECT pg_temp.contact('Ade United FC', 'Ade United FC', NULL, NULL, NULL, 'morarueli@gmail.com', 'casa-sheet');
SELECT pg_temp.comp('Philly Black Stars', 'Philly Black Stars', 2, 'CASA', 'Liga 1', 'prospect', 'Michael', 'MM messaged 7/16', 'Mass email 6/29.', NULL, NULL);
SELECT pg_temp.contact('Philly Black Stars', 'Philly Black Stars', NULL, NULL, NULL, 'asantetuta@yahoo.com', 'casa-sheet');
SELECT pg_temp.comp('Illyrians', 'Illyrians FC', 2, 'CASA', 'Liga 1', 'prospect', 'Michael', NULL, 'Mass email 6/29.', NULL, NULL);
SELECT pg_temp.contact('Illyrians', 'Illyrians FC', NULL, NULL, NULL, 'eldionp@gmail.com', 'casa-sheet');
SELECT pg_temp.comp('Westtown FC II', 'Westtown FC', 2, 'CASA', 'Liga 2', 'prospect', 'Breslin', NULL, 'Mass email 8/11.', NULL, NULL);
SELECT pg_temp.comp('Falls SC', 'Falls SC', 2, 'CASA', 'Liga 2', 'prospect', 'Breslin', 'JB messaged 7/22', 'Not Playing', NULL, NULL);
SELECT pg_temp.comp('Philadelphia Sierra Stars II', 'Philadelphia Sierra Stars', 2, 'CASA', 'Liga 2', 'prospect', 'Breslin', NULL, 'Not Playing', NULL, NULL);
SELECT pg_temp.comp('Sewells Old Boys II', 'Sewell Old Boys FC', 2, 'CASA', 'Liga 2', 'prospect', 'Michael', 'NB messaged 7/21', 'Mass email 6/29.', NULL, NULL);
SELECT pg_temp.contact('Sewells Old Boys II', 'Sewell Old Boys FC', NULL, NULL, NULL, 'sewelloldboysfc@gmail.com', 'casa-sheet');
SELECT pg_temp.contact('Sewells Old Boys II', 'Sewell Old Boys FC', NULL, NULL, NULL, 'freddierenzullijr@icloud.com', 'casa-sheet');
SELECT pg_temp.contact('Sewells Old Boys II', 'Sewell Old Boys FC', NULL, NULL, NULL, 'nick483873@gmail.com', 'casa-sheet');
SELECT pg_temp.comp('Life Center', 'Life Center', 2, 'CASA', 'Liga 2', 'prospect', 'Grayson', NULL, 'Not Playing', NULL, NULL);
SELECT pg_temp.comp('Medford Strikers II', 'Medford Strikers', 2, 'CASA', 'Liga 2', 'prospect', 'Nolan', 'NB messaged 8/10', 'Mass email 12/15.', NULL, NULL);
SELECT pg_temp.comp('KSC TBD', 'Kensington Soccer Club', 2, 'CASA', 'Unplaced', 'prospect', 'Breslin', 'NB messaged 2/3', NULL, NULL, NULL);
SELECT pg_temp.comp('Screamers FC', 'Screamers FC', 2, 'CASA', 'Unplaced', 'prospect', 'Grayson', 'GR emailed 7/8', NULL, NULL, NULL);
SELECT pg_temp.comp('RVSC', 'RVSC', 2, 'CASA', 'Unplaced', 'prospect', 'Grayson', 'GR 1/12', NULL, NULL, NULL);
SELECT pg_temp.comp('Northern Burlington SC', 'Northern Burlington SC', 2, 'CASA', 'Unplaced', 'prospect', 'Grayson', 'GR emailed 7/8', 'Mass email 12/15.', NULL, NULL);
SELECT pg_temp.comp('Cherry Hill FC', 'Cherry Hill FC', 2, 'CASA', 'Unplaced', 'prospect', 'Grayson', 'GR 1/12', NULL, NULL, NULL);
SELECT pg_temp.comp('Philadelphia SC U19', 'Philadelphia SC', 2, 'CASA', 'Unplaced', 'prospect', 'Nolan', 'NB messaged 10/21', NULL, NULL, NULL);
SELECT pg_temp.comp('FC Neman Philadelphia', 'FC Neman Philadelphia', 2, 'CASA', 'Unplaced', 'prospect', 'Breslin', 'JB message 1/23', 'Mass email 12/15.', NULL, NULL);
SELECT pg_temp.comp('Ethiopia', 'Ethiopia', 2, 'CASA', 'Unplaced', 'prospect', 'Breslin', NULL, 'Can''t do sundays', NULL, NULL);
SELECT pg_temp.comp('Hulmeville', 'Hulmeville', 2, 'CASA', 'Unplaced', 'prospect', 'Breslin', NULL, 'Interested in summer / fall Mass email 12/15.', NULL, NULL);
SELECT pg_temp.contact('Hulmeville', 'Hulmeville', 'Charlie Haravitch', 'Board Member', '215-6304060', NULL, 'casa-sheet');
SELECT pg_temp.comp('South Jersey FC', 'South Jersey FC', 2, 'CASA', 'Unplaced', 'prospect', 'Grayson', NULL, 'Fall 2026 is more likely', NULL, NULL);
SELECT pg_temp.comp('Sanko United', 'Sanko United', 2, 'CASA', 'Unplaced', 'prospect', 'Michael', NULL, NULL, NULL, NULL);

-- ── APSL Delaware River Conference (apslsoccer.com, public staff names) ──
SELECT pg_temp.comp('Colonial SC', 'Colonial Soccer Club', 1, 'APSL', 'Delaware River A', 'opponent', NULL, NULL, NULL, NULL, 'https://apslsoccer.com/APSL/Team/168339');
SELECT pg_temp.comp('Jersey Shore Boca', 'Jersey Shore Boca', 1, 'APSL', 'Delaware River A', 'opponent', NULL, NULL, NULL, NULL, 'https://apslsoccer.com/APSL/Team/165426');
SELECT pg_temp.contact('Jersey Shore Boca', 'Jersey Shore Boca', 'Aaron Gilman', 'Head Coach', NULL, NULL, 'apslsoccer.com');
SELECT pg_temp.contact('Jersey Shore Boca', 'Jersey Shore Boca', 'Guy Lockwood', 'Board Position', NULL, NULL, 'apslsoccer.com');
SELECT pg_temp.comp('Medford Strikers', 'Medford Strikers', 1, 'APSL', 'Delaware River A', 'opponent', NULL, NULL, NULL, NULL, 'https://apslsoccer.com/APSL/Team/165433');
SELECT pg_temp.comp('Philadelphia Heritage SC', 'Philadelphia Heritage SC', 1, 'APSL', 'Delaware River A', 'opponent', NULL, NULL, NULL, NULL, 'https://apslsoccer.com/APSL/Team/165445');
SELECT pg_temp.contact('Philadelphia Heritage SC', 'Philadelphia Heritage SC', 'Ryan Pereus', 'Manager', NULL, NULL, 'apslsoccer.com');
SELECT pg_temp.contact('Philadelphia Heritage SC', 'Philadelphia Heritage SC', 'Matt Bergmaier', 'Manager', NULL, NULL, 'apslsoccer.com');
SELECT pg_temp.comp('Philadelphia Soccer Club', 'Philadelphia Soccer Club', 1, 'APSL', 'Delaware River A', 'opponent', NULL, NULL, NULL, NULL, 'https://apslsoccer.com/APSL/Team/165447');
SELECT pg_temp.contact('Philadelphia Soccer Club', 'Philadelphia Soccer Club', 'Aaron Sexton', 'Manager', NULL, NULL, 'apslsoccer.com');
SELECT pg_temp.contact('Philadelphia Soccer Club', 'Philadelphia Soccer Club', 'Scott McCoubrey', 'Head Coach', NULL, NULL, 'apslsoccer.com');
SELECT pg_temp.comp('Sewell Old Boys FC', 'Sewell Old Boys FC', 1, 'APSL', 'Delaware River A', 'opponent', NULL, NULL, NULL, NULL, 'https://apslsoccer.com/APSL/Team/165458');
SELECT pg_temp.comp('WC Predators', 'WC Predators', 1, 'APSL', 'Delaware River A', 'opponent', NULL, NULL, NULL, NULL, 'https://apslsoccer.com/APSL/Team/165469');
SELECT pg_temp.comp('Westtown FC', 'Westtown FC', 1, 'APSL', 'Delaware River A', 'opponent', NULL, NULL, NULL, NULL, 'https://apslsoccer.com/APSL/Team/168337');
SELECT pg_temp.contact('Westtown FC', 'Westtown FC', 'Micah Knaub', 'Manager', NULL, NULL, 'apslsoccer.com');
SELECT pg_temp.contact('Westtown FC', 'Westtown FC', 'Neil Pearson', 'Head Coach', NULL, NULL, 'apslsoccer.com');
SELECT pg_temp.contact('Westtown FC', 'Westtown FC', 'Nick Haynes', 'Team Admin', NULL, NULL, 'apslsoccer.com');
SELECT pg_temp.comp('Feelsgood FC', 'Feelsgood FC', 1, 'APSL', 'Delaware River B', 'opponent', NULL, NULL, NULL, NULL, 'https://apslsoccer.com/APSL/Team/165602');
SELECT pg_temp.contact('Feelsgood FC', 'Feelsgood FC', 'Kevin McCartney', 'Manager', NULL, NULL, 'apslsoccer.com');
SELECT pg_temp.comp('Oaklyn United FC', 'Oaklyn United FC', 1, 'APSL', 'Delaware River B', 'opponent', NULL, NULL, NULL, NULL, 'https://apslsoccer.com/APSL/Team/165441');
SELECT pg_temp.comp('Persepolis United FC', 'Persepolis FC', 1, 'APSL', 'Delaware River B', 'opponent', NULL, NULL, NULL, NULL, 'https://apslsoccer.com/APSL/Team/165603');
SELECT pg_temp.contact('Persepolis United FC', 'Persepolis FC', 'Mark Manis', 'Head Coach', NULL, NULL, 'apslsoccer.com');
SELECT pg_temp.contact('Persepolis United FC', 'Persepolis FC', 'Payman Mirzaei', 'Team Admin', NULL, NULL, 'apslsoccer.com');
SELECT pg_temp.comp('Philadelphia Ukrainian Nationals', 'Philadelphia Ukrainian Nationals', 1, 'APSL', 'Delaware River B', 'opponent', NULL, NULL, NULL, NULL, 'https://apslsoccer.com/APSL/Team/168338');
SELECT pg_temp.comp('Real Central NJ Soccer', 'Real Central NJ Soccer', 1, 'APSL', 'Delaware River B', 'opponent', NULL, NULL, NULL, NULL, 'https://apslsoccer.com/APSL/Team/165453');
SELECT pg_temp.contact('Real Central NJ Soccer', 'Real Central NJ Soccer', 'Ira Jersey', 'Head Coach', NULL, NULL, 'apslsoccer.com');
SELECT pg_temp.contact('Real Central NJ Soccer', 'Real Central NJ Soccer', 'Hilary Jersey', 'Team Admin', NULL, NULL, 'apslsoccer.com');
SELECT pg_temp.comp('Vereinigung Erzgebirge Majors', 'Vereinigung Erzgebirge', 1, 'APSL', 'Delaware River B', 'opponent', NULL, NULL, NULL, NULL, 'https://apslsoccer.com/APSL/Team/168335');
SELECT pg_temp.contact('Vereinigung Erzgebirge Majors', 'Vereinigung Erzgebirge', 'Rob Oldfield', 'Manager', NULL, NULL, 'apslsoccer.com');
SELECT pg_temp.contact('Vereinigung Erzgebirge Majors', 'Vereinigung Erzgebirge', 'Billy Gorman', 'Manager', NULL, NULL, 'apslsoccer.com');
SELECT pg_temp.comp('Vidas United FC', 'Vidas United FC', 1, 'APSL', 'Delaware River B', 'opponent', NULL, NULL, NULL, NULL, 'https://apslsoccer.com/APSL/Team/165466');
SELECT pg_temp.contact('Vidas United FC', 'Vidas United FC', 'Nolan Bair', 'Manager', NULL, NULL, 'apslsoccer.com');
SELECT pg_temp.contact('Vidas United FC', 'Vidas United FC', 'Awwal Ayinde', 'Head Coach', NULL, NULL, 'apslsoccer.com');

-- ── TCWSL Divisions I–III (tcwsl.com Team Info pages) ──────────────────
SELECT pg_temp.contact('Colonials SC', 'Colonial Soccer Club', 'Kami Rennie', 'Captain', NULL, 'kurlykami20@msn.com', 'tcwsl.com', pg_temp.comp('Colonials SC', 'Colonial Soccer Club', 7, 'TCWSL', 'Division I', 'opponent', NULL, NULL, NULL, 'Plymouth Whitemarsh High School, Colonial Drive, Plymouth Meeting, PA 19462', 'http://www.tcwsl.com/V2/teams/ColonialsSC/teaminfo.shtml'));
SELECT pg_temp.comp('FC Storm', 'FC Storm', 7, 'TCWSL', 'Division I', 'opponent', NULL, NULL, NULL, 'Academy of Notre Dame de Namur, 560 Sproul Rd., Villanova, PA 19085', 'http://www.tcwsl.com/V2/teams/FCStorm/teaminfo.shtml');
SELECT pg_temp.contact('FC Storm', 'FC Storm', 'Mallory Deviedma', 'Captain', NULL, 'm.deviedma@gmail.com', 'tcwsl.com');
SELECT pg_temp.comp('Quakertown', 'Quakertown Soccer Club', 7, 'TCWSL', 'Division I', 'opponent', NULL, NULL, NULL, 'Quakertown Sports Complex, 221 California Rd., Quakertown, PA 18951', 'http://www.tcwsl.com/V2/teams/QuakertownSoccerClub/teaminfo.shtml');
SELECT pg_temp.contact('Quakertown', 'Quakertown Soccer Club', 'Amy Roesener', 'Captain', NULL, 'qscwomensteam@gmail.com', 'tcwsl.com');
SELECT pg_temp.comp('Senza Nome', 'Senza Nome Soccer', 7, 'TCWSL', 'Division I', 'opponent', NULL, NULL, NULL, 'Monsignor Bonner & Archbishop Prendergast Catholic High School, 403 N Lansdowne Ave., Drexel Hill, PA 19026', 'http://www.tcwsl.com/V2/teams/SenzaNomeSoccer/teaminfo.shtml');
SELECT pg_temp.contact('Senza Nome', 'Senza Nome Soccer', 'senzanomesoccer@gmail.com', 'Captain', NULL, 'senzanomesoccer@gmail.com', 'tcwsl.com');
SELECT pg_temp.comp('Surge', 'Surge', 7, 'TCWSL', 'Division I', 'opponent', NULL, NULL, NULL, 'Delacy Soccer Complex, 500 S. Creek Rd, West Chester, PA 19382', 'http://www.tcwsl.com/V2/teams/Surge/teaminfo.shtml');
SELECT pg_temp.contact('Surge', 'Surge', 'Amber Potter', 'Captain', NULL, 'amber.potter1016@gmail.com', 'tcwsl.com');
SELECT pg_temp.comp('Bandits FC', 'Bandits FC', 7, 'TCWSL', 'Division II', 'opponent', NULL, NULL, NULL, 'Academy of Notre Dame de Namur, 560 Sproul Rd., Villanova, PA 19085', 'http://www.tcwsl.com/V2/teams/BanditsFC/teaminfo.shtml');
SELECT pg_temp.contact('Bandits FC', 'Bandits FC', 'Gina Febbo', 'Captain', NULL, 'soccerstar41@comcast.net', 'tcwsl.com');
SELECT pg_temp.comp('Boyertown Breakers', 'Boyertown Breakers', 7, 'TCWSL', 'Division II', 'opponent', NULL, NULL, NULL, 'JK Memorial Field, Niantic Road & Victoria Drive, Barto, PA 19504', 'http://www.tcwsl.com/V2/teams/BoyertownBreakers/teaminfo.shtml');
SELECT pg_temp.contact('Boyertown Breakers', 'Boyertown Breakers', 'Brittany Marks', 'Captain', NULL, 'brittany.20@outlook.com', 'tcwsl.com');
SELECT pg_temp.contact('Colonials SC – D2', 'Colonial Soccer Club', NULL, 'Captain', NULL, 'staceyvaitis@comcast.net', 'tcwsl.com', pg_temp.comp('Colonials SC – D2', 'Colonial Soccer Club', 7, 'TCWSL', 'Division II', 'opponent', NULL, NULL, NULL, NULL, 'http://www.tcwsl.com/V2/teams/ColonialsSC-D2/teaminfo.shtml'));
SELECT pg_temp.comp('Gaels', 'Gaels', 7, 'TCWSL', 'Division II', 'opponent', NULL, NULL, NULL, 'Academy of Notre Dame de Namur, 560 Sproul Rd., Villanova, PA 19085', 'http://www.tcwsl.com/V2/teams/Gaels/teaminfo.shtml');
SELECT pg_temp.contact('Gaels', 'Gaels', 'Corrie DeStefano', 'Captain', NULL, 'gfaux@comcast.net', 'tcwsl.com');
SELECT pg_temp.contact('Gaels', 'Gaels', NULL, 'Captain', NULL, 'serfmunke@yahoo.com', 'tcwsl.com');
SELECT pg_temp.contact('Falcons Orange', 'Falcons', 'Catey Arthars', 'Captain', NULL, 'cateyarthars@gmail.com', 'tcwsl.com', pg_temp.comp('Falcons Orange', 'Falcons', 7, 'TCWSL', 'Division II', 'opponent', NULL, NULL, NULL, 'Germantown Supersite, 1199 E Sedgwick St, Philadelphia, PA 19150', 'http://www.tcwsl.com/V2/teams/FalconsOrange/teaminfo.shtml'));
SELECT pg_temp.contact('Falcons Orange', 'Falcons', NULL, 'Captain', NULL, 'meilynwoodferrara@gmail.com', 'tcwsl.com', pg_temp.comp('Falcons Orange', 'Falcons', 7, 'TCWSL', 'Division II', 'opponent', NULL, NULL, NULL, 'Germantown Supersite, 1199 E Sedgwick St, Philadelphia, PA 19150', 'http://www.tcwsl.com/V2/teams/FalconsOrange/teaminfo.shtml'));
SELECT pg_temp.comp('Rose Tree', 'Rose Tree', 7, 'TCWSL', 'Division II', 'opponent', NULL, NULL, NULL, 'Sleighton Park, Corner of Valley Rd. & Forge Rd., Media, PA 19063', 'http://www.tcwsl.com/V2/teams/RoseTree/teaminfo.shtml');
SELECT pg_temp.contact('Rose Tree', 'Rose Tree', 'Shannon Campbell', 'Captain', NULL, 'katecollins315@gmail.com', 'tcwsl.com');
SELECT pg_temp.contact('Rose Tree', 'Rose Tree', NULL, 'Captain', NULL, 'shannon.campbell3@gmail.com', 'tcwsl.com');
SELECT pg_temp.comp('Aston', 'Aston', 7, 'TCWSL', 'Division III', 'opponent', NULL, NULL, NULL, 'Hilltop Elementary School, 401 Cherry Tree Rd, Upper Chichester, PA 19014', 'http://www.tcwsl.com/V2/teams/Aston/teaminfo.shtml');
SELECT pg_temp.contact('Aston', 'Aston', 'Katie Bostwick', 'Captain', NULL, 'kbostwick7@gmail.com', 'tcwsl.com');
SELECT pg_temp.contact('Colonials SC – D3', 'Colonial Soccer Club', NULL, 'Captain', NULL, 'd3colonials@gmail.com', 'tcwsl.com', pg_temp.comp('Colonials SC – D3', 'Colonial Soccer Club', 7, 'TCWSL', 'Division III', 'opponent', NULL, NULL, NULL, NULL, 'http://www.tcwsl.com/V2/teams/ColonialsSC-D3/teaminfo.shtml'));
SELECT pg_temp.contact('Falcons Green', 'Falcons', NULL, 'Captain', NULL, 'ebflynn@gmail.com', 'tcwsl.com', pg_temp.comp('Falcons Green', 'Falcons', 7, 'TCWSL', 'Division III', 'opponent', NULL, NULL, NULL, NULL, 'http://www.tcwsl.com/V2/teams/FalconsGreen/teaminfo.shtml'));
SELECT pg_temp.comp('Hav3', 'Hav3', 7, 'TCWSL', 'Division III', 'opponent', NULL, NULL, NULL, 'Monsignor Bonner & Archbishop Prendergast Catholic High School, 403 N Lansdowne Ave., Drexel Hill, PA 19026', 'http://www.tcwsl.com/V2/teams/Hav3/teaminfo.shtml');
SELECT pg_temp.contact('Hav3', 'Hav3', 'Susan Reutter', 'Captain', NULL, 'bigsuepsu@hotmail.com', 'tcwsl.com');
SELECT pg_temp.comp('Merion SC', 'Merion SC', 7, 'TCWSL', 'Division III', 'opponent', NULL, NULL, NULL, NULL, 'http://www.tcwsl.com/V2/teams/MarionSC/teaminfo.shtml');
SELECT pg_temp.contact('Merion SC', 'Merion SC', 'Jaclyn McGlone', 'Captain', NULL, 'jconn213@gmail.com', 'tcwsl.com');
SELECT pg_temp.comp('PSC', 'PSC (TCWSL)', 7, 'TCWSL', 'Division III', 'opponent', NULL, NULL, NULL, '10402 Decatur Rd., Philadelphia, PA 19154', 'http://www.tcwsl.com/V2/teams/PhiladelphiaSoccerClub/teaminfo.shtml');
SELECT pg_temp.contact('PSC', 'PSC (TCWSL)', '-->', 'Captain', NULL, 'sheinricha@juno.com', 'tcwsl.com');
SELECT pg_temp.comp('The Purple Team', 'The Purple Team', 7, 'TCWSL', 'Division III', 'opponent', NULL, NULL, NULL, 'Andrew Evans Park, 2418 Conestoga Rd, Chester Springs, PA 19425', 'http://www.tcwsl.com/V2/teams/ThePurpleTeam/teaminfo.shtml');
SELECT pg_temp.contact('The Purple Team', 'The Purple Team', 'Lindy Rolston', 'Captain', NULL, 'thepurpleteamsoccer@gmail.com', 'tcwsl.com');
SELECT pg_temp.comp('Roslyn', 'Roslyn', 7, 'TCWSL', 'Division III', 'opponent', NULL, NULL, NULL, 'Crestmont Park, 2595 Rubicam Ave, Willow Grove, PA', 'http://www.tcwsl.com/V2/teams/Roslyn/teaminfo.shtml');
SELECT pg_temp.contact('Roslyn', 'Roslyn', 'Christina Gottschall', 'Captain', NULL, 'cng9976@verizon.net', 'tcwsl.com');
SELECT pg_temp.comp('Rush', 'Rush', 7, 'TCWSL', 'Division III', 'opponent', NULL, NULL, NULL, 'Delacy Soccer Complex, 500 S. Creek Rd, West Chester, PA 19382', 'http://www.tcwsl.com/V2/teams/Rush/teaminfo.shtml');
SELECT pg_temp.contact('Rush', 'Rush', 'Em Mowatt', 'Captain', NULL, '10elmo97@gmail.com', 'tcwsl.com');
SELECT pg_temp.comp('WestMont', 'WestMont', 7, 'TCWSL', 'Division III', 'opponent', NULL, NULL, NULL, 'Hilltop Farm Soccer Complex (Field #5), 560 Royersford Rd, Royersford, PA 19468', 'http://www.tcwsl.com/V2/teams/WestMont/teaminfo.shtml');
SELECT pg_temp.contact('WestMont', 'WestMont', 'Rose Emrick', 'Captain', NULL, 'hinkle.emrick@gmail.com', 'tcwsl.com');

-- ── the calendar's spellings of this season's opponents, so Game Center's
--    match → club lookup (the same club_aliases chain the crests use) hits.
SELECT pg_temp.club_for('Persepolis', 'Persepolis FC');
SELECT pg_temp.club_for('Persepolis I', 'Persepolis FC');
SELECT pg_temp.club_for('Persepolis II', 'Persepolis FC');
SELECT pg_temp.club_for('Real Central NJ APSL', 'Real Central NJ Soccer');
SELECT pg_temp.club_for('Ethiopa', 'Ethiopia');
SELECT pg_temp.club_for('Torresdale', 'Torresdale Boys Club');
SELECT pg_temp.club_for('Torresdale Boys Club', 'Torresdale Boys Club');
