-- 1746 (2026-11-23) — 📝 League Registration (#league-registration): a league
-- entry as a checklist with its forms pre-filled.  Owner: "we need to prepare
-- for indoor ppr season. we will be entering a u12 boys team(girls can play)
-- so can u12, u11, u10. the last 4 docs i uploaded to files are needed filled
-- out. should have a league registration page for fh? and have these also as
-- check list items but you pre fill them for me and get them ready to be sent
-- to Jen Cole".
--
--   league_entries        one registration with a league (PPR Indoor 2027):
--                         who signs, who it goes to, the fees
--   league_entry_teams    each team entered: the team commitment form's
--                         answers (coach, court, dates …).  The official
--                         roster is the team's live players (team_persons).
--   league_entry_items    the checklist: one row per thing to hand in; a
--                         form row names the league's own Word file
--                         (club_files) and the page fills it in the browser.
--
-- The league's files stay as uploaded; nothing here stores a filled copy —
-- a form is filled fresh from the rows each time it is opened or sent.

CREATE TABLE IF NOT EXISTS league_entries (
    id                    serial PRIMARY KEY,
    league_id             integer NOT NULL REFERENCES leagues(id),
    club_id               integer NOT NULL REFERENCES clubs(id),
    title                 text    NOT NULL,
    season_label          text    NOT NULL,
    director_person_id    integer REFERENCES persons(id) ON DELETE SET NULL,
    send_to_name          text    NOT NULL DEFAULT '',
    send_to_email         text    NOT NULL DEFAULT '',
    fee_returning_usd     numeric(8,2) NOT NULL DEFAULT 0,
    fee_new_usd           numeric(8,2) NOT NULL DEFAULT 0,
    payable_to            text    NOT NULL DEFAULT '',
    note                  text    NOT NULL DEFAULT '',
    sent_at               timestamptz,
    sent_by               integer REFERENCES users(id) ON DELETE SET NULL,
    is_active             boolean NOT NULL DEFAULT true,
    created_at            timestamptz NOT NULL DEFAULT now(),
    UNIQUE (league_id, season_label)
);

CREATE TABLE IF NOT EXISTS league_entry_teams (
    id                    serial PRIMARY KEY,
    entry_id              integer NOT NULL REFERENCES league_entries(id) ON DELETE CASCADE,
    team_id               integer NOT NULL REFERENCES teams(id),
    age_group             text    NOT NULL,                       -- as the league names it: U12
    gender                text    NOT NULL CHECK (gender IN ('M', 'F')),
    team_name             text    NOT NULL DEFAULT '',
    is_returning          boolean NOT NULL DEFAULT false,         -- a current team of this league (the lower fee)
    coach_person_id       integer REFERENCES persons(id) ON DELETE SET NULL,
    coach_address         text    NOT NULL DEFAULT '',
    coach_city            text    NOT NULL DEFAULT '',
    coach_state           text    NOT NULL DEFAULT '',
    coach_zip             text    NOT NULL DEFAULT '',
    assistant_person_id   integer REFERENCES persons(id) ON DELETE SET NULL,
    assistant_address     text    NOT NULL DEFAULT '',
    assistant_city        text    NOT NULL DEFAULT '',
    assistant_state       text    NOT NULL DEFAULT '',
    assistant_zip         text    NOT NULL DEFAULT '',
    home_court            text    NOT NULL DEFAULT '',
    court_availability    text    NOT NULL DEFAULT '',
    unavailable_1         text    NOT NULL DEFAULT '',
    unavailable_2         text    NOT NULL DEFAULT '',
    unavailable_3         text    NOT NULL DEFAULT '',
    unavailable_4         text    NOT NULL DEFAULT '',
    prev_age_group        text    NOT NULL DEFAULT '',
    prev_record           text    NOT NULL DEFAULT '',
    max_roster            integer NOT NULL DEFAULT 12 CHECK (max_roster > 0),
    sort_order            integer NOT NULL DEFAULT 0,
    UNIQUE (entry_id, team_id)
);

CREATE TABLE IF NOT EXISTS league_entry_item_kinds (
    code  text PRIMARY KEY,
    label text NOT NULL
);
INSERT INTO league_entry_item_kinds (code, label) VALUES
    ('club_form', 'Club commitment form'),
    ('team_form', 'Team commitment form'),
    ('roster',    'Official team roster'),
    ('payment',   'Payment'),
    ('other',     'Other')
ON CONFLICT (code) DO NOTHING;

CREATE TABLE IF NOT EXISTS league_entry_items (
    id                serial PRIMARY KEY,
    entry_id          integer NOT NULL REFERENCES league_entries(id) ON DELETE CASCADE,
    entry_team_id     integer REFERENCES league_entry_teams(id) ON DELETE CASCADE,   -- NULL = the whole club
    kind              text    NOT NULL REFERENCES league_entry_item_kinds(code),
    label             text    NOT NULL,
    how               text    NOT NULL DEFAULT '',
    template_file_id  integer REFERENCES club_files(id) ON DELETE SET NULL,          -- the league's own form
    sort_order        integer NOT NULL DEFAULT 0,
    done_at           timestamptz,
    done_by           integer REFERENCES users(id) ON DELETE SET NULL
);
CREATE INDEX IF NOT EXISTS league_entry_items_entry_idx ON league_entry_items (entry_id, sort_order);

-- ── PPR Indoor 2027: one U12 boys team (girls can play; U10–U12) ──────────
-- Fees and "payable to" are the club commitment form's own ($100 a current
-- PPR team, $200 a non-PPR team, City of Philadelphia).  The contact was
-- given by the owner in chat, so the address is not in this file: set
-- send_to_name / send_to_email on the page.
INSERT INTO league_entries (league_id, club_id, title, season_label, director_person_id, fee_returning_usd, fee_new_usd, payable_to)
SELECT l.id, 134, 'PPR Indoor Soccer 2027', '2027 Indoor', 1, 100, 200, 'City of Philadelphia'
  FROM leagues l WHERE l.name = 'Philadelphia Parks & Recreation'
ON CONFLICT (league_id, season_label) DO NOTHING;

INSERT INTO league_entry_teams (entry_id, team_id, age_group, gender, team_name, is_returning, home_court, prev_age_group)
SELECT e.id, t.id, 'U12', 'M', 'Lighthouse 1893 SC U12', true,
       'The Lighthouse Community Center, 141 W Somerset St, Philadelphia, PA 19133', 'U12'
  FROM league_entries e JOIN teams t ON t.name = 'U12 Travel Winter' AND t.is_active
 WHERE e.season_label = '2027 Indoor'
ON CONFLICT (entry_id, team_id) DO NOTHING;

INSERT INTO league_entry_items (entry_id, entry_team_id, kind, label, how, template_file_id, sort_order)
SELECT e.id, CASE WHEN v.per_team THEN et.id END, v.kind, v.label, v.how,
       (SELECT f.id FROM club_files f WHERE f.original_filename = v.file ORDER BY f.id DESC LIMIT 1), v.ord
  FROM league_entries e
  JOIN league_entry_teams et ON et.entry_id = e.id
  JOIN (VALUES
    ('club_form', false, 'Club commitment form', 'One for the club: how many teams, and what is owed. Sign it.', '2027Clubcommitmentform- Copy - Copy.docx', 1),
    ('team_form', true,  'Team commitment form — U12', 'One per team: coach, home court, when the court is free, dates the team cannot play. Sign it.', '2027Teamcommitmentform - Copy.docx', 2),
    ('roster',    true,  'Official team roster — U12', 'Up to 12 players: name, date of birth, phone, and a photo of each in the numbered boxes. The coach signs and dates it.', 'Blank Roster.docx', 3),
    ('payment',   false, 'Check to the City of Philadelphia', 'Attach the check to the club commitment form.', NULL, 4)
  ) AS v(kind, per_team, label, how, file, ord) ON true
 WHERE e.season_label = '2027 Indoor'
   AND NOT EXISTS (SELECT 1 FROM league_entry_items i WHERE i.entry_id = e.id);

INSERT INTO menu_pages (code, group_code, label, icon, audience, sort_order, screens)
VALUES ('league-registration', 'leagues', 'League Registration', '📝', 'admin', 6, '{league-registration}')
ON CONFLICT (code) DO NOTHING;

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'League Registration', v.label, 'league_entry', v.tier, v.subject, v.body, v.ord, true, v.client, false
  FROM (VALUES
    ('Page — intro', 'intro', NULL, 'Everything a league wants from us to enter, as a checklist. The forms are the league''s own Word files, filled in from what Football Home knows — fix anything below and they refill.', 1, true),
    ('Page — checklist heading', 'sec_items', NULL, '✅ CHECKLIST', 2, true),
    ('Page — club heading', 'sec_club', NULL, '🏢 THE CLUB', 3, true),
    ('Page — team heading ({team})', 'sec_team', NULL, '⚽ {team}', 4, true),
    ('Page — roster heading ({n} {max})', 'sec_roster', NULL, '📋 OFFICIAL ROSTER — {n} of {max}', 5, true),
    ('Page — roster source ({team})', 'roster_from', NULL, 'These are the players on {team} in 👥 Teams — add or move kids there and this list follows. First {max} by name go on the form.', 6, true),
    ('Page — roster empty ({team})', 'roster_empty', NULL, 'Nobody is on {team} yet. Add the players in 👥 Teams and they appear here and on the form.', 7, true),
    ('Page — roster photos', 'roster_photos', NULL, 'The form also wants a photo of each player in the numbered boxes — Football Home has no player photos, so add those in Word (or by hand) before it goes in.', 8, true),
    ('Page — download a form', 'btn_download', NULL, '⬇ Filled form', 9, true),
    ('Page — blank form', 'btn_blank', NULL, 'Blank', 10, true),
    ('Page — tick', 'btn_done', NULL, '✓ Done', 11, true),
    ('Page — untick', 'btn_undo', NULL, '↩ Not done', 12, true),
    ('Page — send button ({name})', 'btn_send', NULL, '✉️ Email the filled forms to {name}', 13, true),
    ('Page — send confirm ({n} {name} {to})', 'send_confirm', NULL, 'Email {n} filled form(s) to {name} <{to}>, with a copy to you?', 14, true),
    ('Page — sent line ({when})', 'sent_line', NULL, '✉️ Sent {when}', 15, true),
    ('Page — no recipient', 'send_nobody', NULL, 'Fill in who it goes to first.', 16, true),
    ('Page — fees line ({returning} {new} {total})', 'fees', NULL, '{returning} current team(s) × {fee_returning} + {new} new team(s) × {fee_new} = {total}, payable to {payable_to}', 17, true),
    ('Page — still blank ({list})', 'missing', NULL, '⚠ Still blank on the forms: {list}', 18, true),
    ('Page — signatures', 'sign_note', NULL, 'The forms need a signature — print and sign, or sign in Word, before they count.', 19, true),
    ('Email to the league ({league_title} {club} {to_name} {list} {sender})', 'email', '{club} — {league_title} registration',
     'Hi {to_name},

Attached are the registration forms for {club} for {league_title}:

{list}

Please let me know if anything is missing.

Thanks,
{sender}', 20, false)
  ) AS v(label, tier, subject, body, ord, client)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'league_entry' AND m.tier = v.tier);
